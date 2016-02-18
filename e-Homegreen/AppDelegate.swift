//
//  AppDelegate.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var timer: dispatch_source_t!
    var refreshTimer: dispatch_source_t!
    
//    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//
//    }
    func refreshDevicesToYesterday () {
        var error:NSError?
        let fetchRequest = NSFetchRequest(entityName: "Device")
        do {
            if let devices = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device] {
                for device in devices {
                    
                    device.stateUpdatedAt = NSDate.yesterDay()
                }
                saveContext()
            }
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        API.shared.sendRequest(.GET, url: "") { (completion) -> () in
            switch completion {
            case .Success(let response):
                print("")
            case .Error(let error):
                print("")
            }
        }
    }
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
//        refreshDevicesToYesterday()
        broadcastTimeAndDate()
        refreshAllConnections()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "setFilterBySSIDOrByiBeacon", userInfo: nil, repeats: false)
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        UISlider.appearance().setMaximumTrackImage(UIImage(named: "slidertrackmax"), forState: UIControlState.Normal)
        UISlider.appearance().setMinimumTrackImage(UIImage(named: "slidertrackmin"), forState: UIControlState.Normal)
        UISlider.appearance().setThumbImage(UIImage(named: "slider"), forState: UIControlState.Normal)
        UISlider.appearance().setThumbImage(UIImage(named: "sliderselected"), forState: UIControlState.Highlighted)
        // Override point for customization after application launch.
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let containerViewController = ContainerViewController()
        window!.rootViewController = containerViewController
        
        configureStateForTheFirstTime()
        
        setFilterBySSIDOrByiBeaconAgain()
        return true
    }
    func setFilterBySSIDOrByiBeaconAgain () {
        fetchIBeacons()
        loadItems()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "setFilterBySSIDOrByiBeacon", userInfo: nil, repeats: false)
    }
    func setFilterBySSIDOrByiBeacon () {
        checkIfThereISGatewayWithExistingSSID()
        var beacon:IBeacon?
        for item in iBeacons {
            if beacon == nil {
                beacon = item
            }
            if beacon?.accuracy > item.accuracy {
                beacon = item
            }
        }
        if beacon != nil && beacon!.accuracy != 10000 {
            let zone = returnZoneWithIBeacon(beacon!)
            if zone != nil {
                print("OVO JE BIO NAJBLIZI IBEACON: \(beacon!.name) SA ACCURACY: \(beacon!.accuracy) ZA OVAJ GATEWAY: \(beacon?.iBeaconZone?.gateway.name) A POKAZUJE OVAj GATEWAY: \(zone?.gateway.name)")
                let filterArray = ["Devices", "Scenes", "Events", "Sequences", "Timers", "Flags", "Energy", "Chat", "Surveillance"]
                for filter in filterArray {
                    var filterParametars = LocalSearchParametar.getLocalParametar(filter)
                    if zone!.level == 0 {
                        filterParametars[0] = zone!.gateway.name
                        filterParametars[1] = "\(zone!.id)"
                        LocalSearchParametar.setLocalParametar(filter, parametar: filterParametars)
                    } else {
                        filterParametars[0] = zone!.gateway.name
                        filterParametars[2] = "\(zone!.id)"
                        LocalSearchParametar.setLocalParametar(filter, parametar: filterParametars)
                    }
                }
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFilter, object: self, userInfo: nil)
        for item in iBeacons {
            item.accuracy = 10000
        }
        beacon = nil
        stopiBeacons()
    }
    func checkIfThereISGatewayWithExistingSSID() {
            if let ssid = UIDevice.currentDevice().SSID {
                fetchGateways()
                for gateway in gateways {
                    print(gateway.ssid)
                    print(ssid)
                    if gateway.ssid == ssid {
                        let filterArray = ["Devices", "Scenes", "Events", "Sequences", "Timers", "Flags", "Energy", "Chat", "Surveillance"]
                        for filter in filterArray {
                            var filterParametars = LocalSearchParametar.getLocalParametar(filter)
                            //                        This logic is responsible for suplying filter with Gateway name if it is different gateway and leaving it as it is if it is same gateway
                            if filterParametars[0] != "\(gateway.name)" {
                                filterParametars[0] = "\(gateway.name)"
                                filterParametars[1] = "All"
                                filterParametars[2] = "All"
                                filterParametars[3] = "All"
                                filterParametars[4] = "All"
                                filterParametars[5] = "All"
                                filterParametars[6] = "All"
                                LocalSearchParametar.setLocalParametar(filter, parametar: filterParametars)
//                                dispatch_async(dispatch_get_main_queue(), {
                                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFilter, object: self, userInfo: nil)
//                                })
                            }
                        }
                        break
                    }
                }
            }
            else {
                print("Nije nasao ssid.")
            }
//        })
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    var iBeacons:[IBeacon] = []
    func fetchIBeacons() {
        var error:NSError?
        let fetchRequest = NSFetchRequest(entityName: "IBeacon")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [IBeacon]
            iBeacons = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    var inOutSockets:[InOutSocket] = []
    var gateways:[Gateway] = []
    func fetchGateways () {
        var error:NSError?
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicateOne
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
            gateways = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        for item in self.gateways {
            item.remoteIpInUse = self.returnIpAddress(item.remoteIp)
        }
        do {
            try self.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
    }
    func returnIpAddress (url:String) -> String {
        print("123")
        let host = CFHostCreateWithName(nil,url).takeRetainedValue();
        CFHostStartInfoResolution(host, .Addresses, nil);
        var success: DarwinBoolean = false
        if let test = CFHostGetAddressing(host, &success) {
            let addresses = test.takeUnretainedValue() as NSArray
            if (addresses.count > 0){
                let theAddress = addresses[0] as! NSData;
                var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                if getnameinfo(UnsafePointer(theAddress.bytes), socklen_t(theAddress.length),
                    &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        if let numAddress = String.fromCString(hostname) {
                            print("1234")
                            return numAddress
                        }
                }
            }
        }
        print("12345")
        return "255.255.255.255"
    }
    
    func disconnectAllConnections () {
        if inOutSockets != [] {
            for inOutSocket in inOutSockets {
                inOutSocket.socket.close()
            }
            inOutSockets = []
        }
    }
    func establishAllConnections () {
        disconnectAllConnections()
        fetchGateways()
        if gateways != [] {
            for gateway in gateways {
                if inOutSockets != [] {
                    var foundRemote:Bool = false
                    var foundLocal:Bool = false
                    for inOutSocket in inOutSockets {
                        if inOutSocket.port == UInt16(Int(gateway.localPort)) {
                            foundLocal = true
                        }
                        if inOutSocket.port == UInt16(Int(gateway.remotePort)) {
                            foundRemote = true
                        }
                    }
                    if !foundLocal {
                        inOutSockets.append(InOutSocket(port: UInt16(Int(gateway.localPort))))
                    }
                    if !foundRemote {
                        inOutSockets.append(InOutSocket(port: UInt16(Int(gateway.remotePort))))
                    }
                } else {
                    inOutSockets.append(InOutSocket(port: UInt16(Int(gateway.localPort))))
                    if inOutSockets[0].port != UInt16(Int(gateway.remotePort)) {
                        inOutSockets.append(InOutSocket(port: UInt16(Int(gateway.remotePort))))
                    }
                }
            }
        }
    }
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        establishAllConnections()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        disconnectAllConnections()
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.e-homeautomation.e_Homegreen" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("e_Homegreen", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("e_Homegreen.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    lazy var moc:NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var moc = NSManagedObjectContext()
        moc.persistentStoreCoordinator = coordinator
        return moc
    }()
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}

