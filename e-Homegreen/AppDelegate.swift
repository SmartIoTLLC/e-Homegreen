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

        // slider setup
        UISlider.appearance().setMaximumTrackImage(UIImage(named: "slidertrackmax"), forState: UIControlState.Normal)
        UISlider.appearance().setMinimumTrackImage(UIImage(named: "slidertrackmin"), forState: UIControlState.Normal)
        UISlider.appearance().setThumbImage(UIImage(named: "slider"), forState: UIControlState.Normal)
        UISlider.appearance().setThumbImage(UIImage(named: "sliderselected"), forState: UIControlState.Highlighted)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        //navigation setup
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        let fontDictionary = [ NSForegroundColorAttributeName:UIColor.whiteColor() ]
        UINavigationBar.appearance().titleTextAttributes = fontDictionary
        
        //whether there admin exist and if exist check if user logged in
        if let _ = AdminController.shared.getAdmin() {
            if !DatabaseUserController.shared.isLogged(){
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let logIn = storyboard.instantiateViewControllerWithIdentifier("LoginController") as! LogInViewController
                self.window?.rootViewController = logIn
                self.window?.makeKeyAndVisible()
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let sideMenu = storyboard.instantiateViewControllerWithIdentifier("SideMenu") as! SWRevealViewController
                let devices = Menu.Devices.controller
                sideMenu.setFrontViewController(devices, animated: true)
                self.window?.rootViewController = sideMenu
                self.window?.makeKeyAndVisible()
            }
        }else{
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let createAdmin = storyboard.instantiateViewControllerWithIdentifier("CreateAdmin") as! CreateAdminViewController
            self.window?.rootViewController = createAdmin
            self.window?.makeKeyAndVisible()
        }
        
        
        
//        broadcastTimeAndDate()
//        refreshAllConnections()
        establishAllConnections()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(AppDelegate.setFilterBySSIDOrByiBeacon), userInfo: nil, repeats: false)
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
//        configureStateForTheFirstTime()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        setFilterBySSIDOrByiBeaconAgain()
        
        return true
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleRegionEvent(region)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleRegionEvent(region)
        }
    }
    
    func handleRegionEvent(region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active {
            if let message = notefromRegionIdentifier(region.identifier) {
                if let viewController = window?.rootViewController {
                    self.window?.makeKeyAndVisible()
                    viewController.view.makeToast(message: message)
                }
            }
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = notefromRegionIdentifier(region.identifier)
            notification.soundName = "Default";
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    func notefromRegionIdentifier(identifier: String) -> String? {
        if let url = NSURL(string: identifier){
            if let id = persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) {
                if let location = managedObjectContext?.objectWithID(id) as? Location {
                    return location.name
                }
            }
        }
        
        return nil
    }
    
    
    func setFilterBySSIDOrByiBeaconAgain () {
        fetchIBeacons()
        loadItems()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "setFilterBySSIDOrByiBeacon", userInfo: nil, repeats: false)
    }
    func setFilterBySSIDOrByiBeacon () {
        checkIfThereIsLocationWithExistingSSID()
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
            let zoneWithBeacon = returnZoneWithIBeacon(beacon!)
            // Check if zone exists with that iBeacon
            if let zone = zoneWithBeacon {
                print("OVO JE BIO NAJBLIZI IBEACON: \(beacon!.name) SA ACCURACY: \(beacon!.accuracy) ZA OVAJ GATEWAY: \(beacon?.iBeaconZone?.location!.name) A POKAZUJE OVAj GATEWAY: \(zone.location!.name)")
                if let zoneLocation = zone.location, zoneName = zone.name, lvlId = zone.level {
                    // Check if zone has level (which is another zone)
                    let levelId = Int(lvlId)
                    if levelId == 0 {
                        for item in  FilterEnumeration.allFilters {
                            Filter.sharedInstance.saveFilter(item: FilterItem(location:zoneLocation.name!, levelId:Int(zone.id!), zoneId:0, categoryId:0, levelName:zoneName, zoneName:"All", categoryName:"All"), forTab: item)
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFilter, object: self, userInfo: nil)
                        return
                    } else {
                        if let level = fetchZone(Int(levelId)) {
                            for item in  FilterEnumeration.allFilters {
                                Filter.sharedInstance.saveFilter(item: FilterItem(location:zoneLocation.name!, levelId:Int(level.id!), zoneId:Int(zone.id!), categoryId:0, levelName:level.name!, zoneName:zoneName, categoryName:"All"), forTab: item)
                            }
                            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFilter, object: self, userInfo: nil)
                            // Exit method
                            return
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
    }
    func checkIfThereIsLocationWithExistingSSID() {
        if let ssid = UIDevice.currentDevice().SSID {
            let ssidsDB:[SSID] = fetchSSIDs()
            for ssidDB in ssidsDB {
                if ssid == ssidDB {
                    if let location = ssidDB.location, locationName = location.name {
                        for item in  FilterEnumeration.allFilters {
                            let filter = Filter.sharedInstance.returnFilter(forTab: item)
                            if filter.location != locationName {
                                Filter.sharedInstance.saveFilter(item: FilterItem(location:locationName, levelId:0, zoneId:0, categoryId:0, levelName:"All", zoneName:"All", categoryName:"All"), forTab: item)
                            }
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFilter, object: self, userInfo: nil)
                    }
                    break
                }
            }
        } else {
            print("Nije nasao ssid.")
        }
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
    func fetchSSIDs() -> [SSID] {
        var error:NSError?
        let fetchRequest = NSFetchRequest(entityName: "SSID")
        do {
            let fetResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [SSID]
            if let results = fetResults {return results}
            return []
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return []
    }
    func fetchZone(id:Int) -> Zone? {
        var error:NSError?
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        do {
            let fetResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            let zone = fetResults![0]
            return zone
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return nil
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
                            return numAddress
                        }
                }
            }
        }
        return "255.255.255.255"
    }
    
    func disconnectAllConnections () {
        if inOutSockets != [] {
            for inOutSocket in inOutSockets {
                inOutSocket.socket.close()
            }
            for timer in timers{
                timer.invalidate()
            }
            timers = []
            inOutSockets = []
        }
    }
    var timers:[NSTimer] = []
    func establishAllConnections () {
        disconnectAllConnections()
        fetchGateways()
        if gateways != [] {
            for gateway in gateways {
                timers.append(NSTimer.scheduledTimerWithTimeInterval(Double(gateway.autoReconnectDelay!) * 60, target: self, selector: "refreshGateways:" , userInfo: ["gateway" :gateway], repeats: true))
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
    
    func refreshGateways(timer:NSTimer){
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        if let gateway = userInfo["gateway"] as? Gateway{
            let address = [Byte(Int(gateway.addressOne)), Byte(Int(gateway.addressTwo)), Byte(Int(gateway.addressThree))]
            SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address) , gateway: gateway)

        }
    }
    
    func refreshAllConnectionsToEHomeGreenPLC () {
        fetchGateways()
        // === === === === ===
        if gateways != [] {
            for gateway in gateways {
                if let minutes = gateway.autoReconnectDelay as? Int, date = gateway.autoReconnectDelayLast {
                    if NSDate().timeIntervalSinceDate(date.dateByAddingTimeInterval(NSTimeInterval(minutes))) >= 0 {
                        let address = [Byte(Int(gateway.addressOne)), Byte(Int(gateway.addressTwo)), Byte(Int(gateway.addressThree))]
                        SendingHandler.sendCommand(byteArray: Function.refreshGatewayConnection(address), gateway: gateway)
                    }
                }
            }
        }
        // === === === === ===
    }
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        establishAllConnections()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //when admin was logged then logout, this is for safe becouse user will have to login again on next start
        if AdminController.shared.isAdminLogged(){
            AdminController.shared.logoutAdmin()
        }
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
            var options: [NSObject : AnyObject] = [NSMigratePersistentStoresAutomaticallyOption:true,
                NSInferMappingModelAutomaticallyOption:true,
                NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
//            var options: [NSObject : AnyObject] = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
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

