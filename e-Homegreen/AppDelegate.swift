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

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var timer: DispatchSource!
    var refreshTimer: DispatchSource!
    
//    func refreshDevicesToYesterday () {
//        var error:NSError?
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
//        do {
//            if let devices = try managedObjectContext!.fetch(fetchRequest) as? [Device] {
//                for device in devices {
//                    
//                    device.stateUpdatedAt = Date.yesterDay()
//                }
//                saveContext()
//            }
//        } catch let error1 as NSError {
//            error = error1
//            print("Unresolved error \(error), \(error!.userInfo)")
//            abort()
//        }
//    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        CreateUserFromJSONController.shared.unzipAndDeleteFile(url)
        
        return true
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // slider setup
        UISlider.appearance().setMaximumTrackImage(UIImage(named: "slidertrackmax"), for: UIControlState())
        UISlider.appearance().setMinimumTrackImage(UIImage(named: "slidertrackmin"), for: UIControlState())
        UISlider.appearance().setThumbImage(UIImage(named: "slider"), for: UIControlState())
        UISlider.appearance().setThumbImage(UIImage(named: "sliderselected"), for: UIControlState.highlighted)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        //navigation setup
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        let fontDictionary = [ NSForegroundColorAttributeName:UIColor.white ]
        UINavigationBar.appearance().titleTextAttributes = fontDictionary
        
        //whether there admin exist and if exist check if user logged in
        if let _ = AdminController.shared.getAdmin() {
            if AdminController.shared.isAdminLogged(){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let sideMenu = storyboard.instantiateViewController(withIdentifier: "SideMenu") as! SWRevealViewController
                let controller:UINavigationController = Menu.settings.controller
                sideMenu.setFront(controller, animated: true)
                self.window?.rootViewController = sideMenu
                self.window?.makeKeyAndVisible()
            }else{
                if !DatabaseUserController.shared.isLogged(){
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let logIn = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LogInViewController
                    self.window?.rootViewController = logIn
                    self.window?.makeKeyAndVisible()
                }else{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let sideMenu = storyboard.instantiateViewController(withIdentifier: "SideMenu") as! SWRevealViewController
                    var controller:UINavigationController = Menu.settings.controller
                    if let user = DatabaseUserController.shared.getLoggedUser(){
                        if user.openLastScreen.boolValue == true{
                            if let id = user.lastScreenId as? Int, let menu = Menu(rawValue: id) {
                                controller = menu.controller
                            }
                        }
                    }
                    sideMenu.setFront(controller, animated: true)
                    self.window?.rootViewController = sideMenu
                    self.window?.makeKeyAndVisible()
                }
            }
        }else{
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let createAdmin = storyboard.instantiateViewController(withIdentifier: "CreateAdmin") as! CreateAdminViewController
            self.window?.rootViewController = createAdmin
            self.window?.makeKeyAndVisible()
        }
        
        
        
//        broadcastTimeAndDate()
//        refreshAllConnections()
        establishAllConnections()
//        Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.setFilterBySSIDOrByiBeacon), userInfo: nil, repeats: false)
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
//        configureStateForTheFirstTime()
        
//        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
//        UIApplication.shared.cancelAllLocalNotifications()
        
//        setFilterBySSIDOrByiBeaconAgain()
        
        return true
    }
    
    func handleRegionEvent(_ region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            if let message = notefromRegionIdentifier(region.identifier) {
                if let viewController = window?.rootViewController {
                    self.window?.makeKeyAndVisible()
                    viewController.view.makeToast(message: message)
                }
            }
        } else {
            // Otherwise present a local notification
//            let notification = UILocalNotification()
//            notification.alertBody = notefromRegionIdentifier(region.identifier)
//            notification.soundName = "Default";
//            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    func notefromRegionIdentifier(_ identifier: String) -> String? {
        if let url = URL(string: identifier){
            if let id = persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                if let location = managedObjectContext?.object(with: id) as? Location {
                    if let id = location.timerId{
                        if let timer = DatabaseTimersController.shared.getTimerByid(id){
                            DatabaseTimersController.shared.startTImerOnLocation(timer)
                        }
                    }
                    return location.name
                }
            }
        }
        
        return nil
    }
    
//    func setFilterBySSIDOrByiBeaconAgain () {
//        fetchIBeacons()
//        loadItems()
//        Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.setFilterBySSIDOrByiBeacon), userInfo: nil, repeats: false)
//    }
    
//    func setFilterBySSIDOrByiBeacon () {
//        checkIfThereIsLocationWithExistingSSID()
//        var beacon:IBeacon?
//        for item in iBeacons {
//            if beacon == nil {
//                beacon = item
//            }
//            if beacon?.accuracy > item.accuracy {
//                beacon = item
//            }
//        }
//        if beacon != nil && beacon!.accuracy != 10000 {
//            let zoneWithBeacon = returnZoneWithIBeacon(beacon!)
//            // Check if zone exists with that iBeacon
//            if let zone = zoneWithBeacon {
//                print("OVO JE BIO NAJBLIZI IBEACON: \(beacon!.name) SA ACCURACY: \(beacon!.accuracy) ZA OVAJ GATEWAY: \(beacon?.iBeaconZone?.location!.name) A POKAZUJE OVAj GATEWAY: \(zone.location!.name)")
//                if let zoneLocation = zone.location, let zoneName = zone.name, let lvlId = zone.level {
//                    // Check if zone has level (which is another zone)
//                    let levelId = Int(lvlId)
//                    if levelId == 0 {
//                        for item in  FilterEnumeration.allFilters {
//                            Filter.sharedInstance.saveFilter(item: FilterItem(location:zoneLocation.name!, levelId:Int(zone.id!), zoneId:0, categoryId:0, levelName:zoneName, zoneName:"All", categoryName:"All"), forTab: item)
//                        }
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFilter), object: self, userInfo: nil)
//                        return
//                    } else {
//                        if let level = fetchZone(Int(levelId)) {
//                            for item in  FilterEnumeration.allFilters {
//                                Filter.sharedInstance.saveFilter(item: FilterItem(location:zoneLocation.name!, levelId:Int(level.id!), zoneId:Int(zone.id!), categoryId:0, levelName:level.name!, zoneName:zoneName, categoryName:"All"), forTab: item)
//                            }
//                            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFilter), object: self, userInfo: nil)
//                            // Exit method
//                            return
//                        }
//                    }
//                }
//            }
//            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFilter), object: self, userInfo: nil)
//            for item in iBeacons {
//                item.accuracy = 10000
//            }
//            beacon = nil
//            stopiBeacons()
//        }
//    }
//    func checkIfThereIsLocationWithExistingSSID() {
//        if let ssid = UIDevice.current.SSID {
//            let ssidsDB:[SSID] = fetchSSIDs()
//            for ssidDB in ssidsDB {
//                if ssid == ssidDB.name {
//                    if let location = ssidDB.location, let locationName = location.name {
//                        for item in  FilterEnumeration.allFilters {
//                            let filter = Filter.sharedInstance.returnFilter(forTab: item)
//                            if filter.location != locationName {
//                                Filter.sharedInstance.saveFilter(item: FilterItem(location:locationName, levelId:0, zoneId:0, categoryId:0, levelName:"All", zoneName:"All", categoryName:"All"), forTab: item)
//                            }
//                        }
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFilter), object: self, userInfo: nil)
//                    }
//                    break
//                }
//            }
//        } else {
//            print("Nije nasao ssid.")
//        }
//    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        Foundation.UserDefaults.standard.set(Date(), forKey: "timeTimerExitedApp")
        
        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterDevices, forKey: "timerDevicesValueWhenExitedApp")
        TimerForFilter.shared.stopTimer(type: Menu.devices)
        

        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterScenes, forKey: "timerScenesValueWhenExitedApp")
        TimerForFilter.shared.stopTimer(type: Menu.scenes)

        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterEvents, forKey: "timerEventsValueWhenExitedApp")
        TimerForFilter.shared.stopTimer(type: Menu.events)

        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterSequences, forKey: "timerSequencesValueWhenExitedApp")
//        TimerForFilter.shared.stopTimer(type: Menu.sequences)

        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterTimers, forKey: "timerTimersValueWhenExitedApp")
//        TimerForFilter.shared.stopTimer(type: Menu.timers)
        
        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterSecurity, forKey: "timerSecurityValueWhenExitedApp")
        TimerForFilter.shared.stopTimer(type: Menu.security)
        
        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterSurvailance, forKey: "timerSurvailanceValueWhenExitedApp")
//        TimerForFilter.shared.stopTimer(type: Menu.surveillance)
        
        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterFlags, forKey: "timerFlagsValueWhenExitedApp")
//        TimerForFilter.shared.stopTimer(type: Menu.flags)
        
        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterUsers, forKey: "timerUsersValueWhenExitedApp")
//        TimerForFilter.shared.stopTimer(type: Menu.users)
        
        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterPCControl, forKey: "timerPCControlValueWhenExitedApp")
//        TimerForFilter.shared.stopTimer(type: Menu.pcControl)
        
        Foundation.UserDefaults.standard.set(TimerForFilter.shared.counterEnergy, forKey: "timerEnergyValueWhenExitedApp")
//        TimerForFilter.shared.stopTimer(type: Menu.energy)
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if let dateExitedTheApp = Foundation.UserDefaults.standard.value(forKey: "timeTimerExitedApp") as? Date{
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerDevicesValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterDevices = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterDevices > 0 {
                    TimerForFilter.shared.startTimer(type: Menu.devices)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerDevices), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerScenesValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterScenes = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterScenes > 0 {
                    TimerForFilter.shared.startTimer(type: Menu.scenes)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerScenes), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerEventsValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterEvents = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterEvents > 0 {
                    TimerForFilter.shared.startTimer(type: Menu.events)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEvents), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerSequencesValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterSequences = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterSequences > 0 {
//                    TimerForFilter.shared.startTimer(type: Menu.sequences)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSequences), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerTimersValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterTimers = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterTimers > 0 {
//                    TimerForFilter.shared.startTimer(type: Menu.timers)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerTimers), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerSecurityValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterSecurity = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterSecurity > 0 {
                    TimerForFilter.shared.startTimer(type: Menu.security)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSecurity), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerSurvailanceValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterSurvailance = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterSurvailance > 0 {
//                    TimerForFilter.shared.startTimer(type: Menu.surveillance)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSurvailance), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerFlagsValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterFlags = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterFlags > 0 {
//                    TimerForFilter.shared.startTimer(type: Menu.flags)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerFlags), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerUsersValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterUsers = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterUsers > 0 {
//                    TimerForFilter.shared.startTimer(type: Menu.users)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerUsers), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerPCControlValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterPCControl = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterPCControl > 0 {
//                    TimerForFilter.shared.startTimer(type: Menu.pcControl)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerPCControl), object: nil)
                }
            }
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerChatValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterChat = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterChat > 0 {
//                    TimerForFilter.shared.startTimer(type: Menu.chat)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerChat), object: nil)
                }
            }
            
            if let timerOldValue = Foundation.UserDefaults.standard.value(forKey: "timerEnergyValueWhenExitedApp") as? Int{
                let timeExitedTheApp = dateExitedTheApp.timeIntervalSinceReferenceDate
                let currentTime = Date.timeIntervalSinceReferenceDate
                let counterValue = currentTime - timeExitedTheApp
                let seconds = Int(counterValue)
                TimerForFilter.shared.counterEnergy = timerOldValue - Int(seconds)
                if TimerForFilter.shared.counterEnergy > 0 {
//                    TimerForFilter.shared.startTimer(type: Menu.energy)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEnergy), object: nil)
                }
            }
        }
    }
    
//    var iBeacons:[IBeacon] = []
//    func fetchIBeacons() {
//        var error:NSError?
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = IBeacon.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        do {
//            let fetResults = try managedObjectContext!.fetch(fetchRequest) as? [IBeacon]
//            iBeacons = fetResults!
//        } catch let error1 as NSError {
//            error = error1
//            print("Unresolved error \(error), \(error!.userInfo)")
//            abort()
//        }
//    }
//    func fetchSSIDs() -> [SSID] {
//        var error:NSError?
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SSID.fetchRequest()
//        do {
//            let fetResults = try managedObjectContext!.fetch(fetchRequest) as? [SSID]
//            if let results = fetResults {return results}
//            return []
//        } catch let error1 as NSError {
//            error = error1
//            print("Unresolved error \(error), \(error!.userInfo)")
//            abort()
//        }
//        return []
//    }
//    func fetchZone(_ id:Int) -> Zone? {
//        var error:NSError?
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
//        do {
//            let fetResults = try managedObjectContext!.fetch(fetchRequest) as? [Zone]
//            let zone = fetResults![0]
//            return zone
//        } catch let error1 as NSError {
//            error = error1
//            print("Unresolved error \(error), \(error!.userInfo)")
//            abort()
//        }
//        return nil
//    }
    
    var inOutSockets:[InOutSocket] = []
    var gateways:[Gateway] = []
    func fetchGateways () {
        var error:NSError?
        let fetchRequest: NSFetchRequest<Gateway> = Gateway.fetchRequest()
        let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(value: true as Bool))
        fetchRequest.predicate = predicateOne
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetResults = try managedObjectContext!.fetch(fetchRequest)
            gateways = fetResults
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
    func returnIpAddress (_ url:String) -> String {
        let host = CFHostCreateWithName(nil,url as CFString).takeRetainedValue();
        CFHostStartInfoResolution(host, .addresses, nil);
        var success: DarwinBoolean = false
        if let test = CFHostGetAddressing(host, &success) {
            let addresses = test.takeUnretainedValue() as NSArray
            if (addresses.count > 0){
                let theAddress = addresses[0] as! Data;
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo((theAddress as NSData).bytes.bindMemory(to: sockaddr.self, capacity: theAddress.count), socklen_t(theAddress.count),
                    &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        if let numAddress = String(validatingUTF8: hostname) {
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
    var timers:[Foundation.Timer] = []
    func establishAllConnections () {
        disconnectAllConnections()
        fetchGateways()
        if gateways != [] {
            for gateway in gateways {
                timers.append(Foundation.Timer.scheduledTimer(timeInterval: Double(gateway.autoReconnectDelay!) * 60, target: self, selector: #selector(AppDelegate.refreshGateways(_:)) , userInfo: ["gateway" :gateway], repeats: true))
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
    
    func refreshGateways(_ timer:Foundation.Timer){
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        if let gateway = userInfo["gateway"] as? Gateway{
            let address = [Byte(Int(gateway.addressOne)), Byte(Int(gateway.addressTwo)), Byte(Int(gateway.addressThree))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address) , gateway: gateway)

        }
    }
    
    func refreshAllConnectionsToEHomeGreenPLC () {
        fetchGateways()
        if gateways != [] {
            for gateway in gateways {
                if let minutes = gateway.autoReconnectDelay as? Int, let date = gateway.autoReconnectDelayLast {
                    if Date().timeIntervalSince(date.addingTimeInterval(TimeInterval(minutes)) as Date) >= 0 {
                        let address = [Byte(Int(gateway.addressOne)), Byte(Int(gateway.addressTwo)), Byte(Int(gateway.addressThree))]
                        SendingHandler.sendCommand(byteArray: OutgoingHandler.refreshGatewayConnection(address), gateway: gateway)
                    }
                }
            }
        }
        // === === === === ===
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        establishAllConnections()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //when admin was logged then logout, this is for safe becouse user will have to login again on next start
        disconnectAllConnections()
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.e-homeautomation.e_Homegreen" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "e_Homegreen", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("e_Homegreen.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            var options: [AnyHashable: Any] = [NSMigratePersistentStoresAutomaticallyOption:true,
                NSInferMappingModelAutomaticallyOption:true,
                NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
//            var options: [NSObject : AnyObject] = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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

