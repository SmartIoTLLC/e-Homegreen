//
//  DevicesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Crashlytics


class DevicesViewController: CommonViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, PullDownViewDelegate {
    
    var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
    let reuseIdentifier = "deviceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var pullDown = PullDownView()
    var isScrolling:Bool = false
    var shouldUpdate:Bool = false
    
    var senderButton:UIButton?
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    var timer:NSTimer = NSTimer()
    
    var locationSearchText = ["", "", "", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        } else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 121, height: 150)
        }
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        self.view.addSubview(pullDown)
        
//        let button = UIButton(type: UIButtonType.RoundedRect)
//        button.frame = CGRectMake(20, 50, 100, 30)
//        button.setTitle("Crash", forState: UIControlState.Normal)
//        button.addTarget(self, action: "crashButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
//        view.addSubview(button)

        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        deviceCollectionView.delaysContentTouches = false
        deviceCollectionView.delegate = self
        // Do any additional setup after loading the view.
//        LocalSearchParametar.setLocalParametar("Devices", parametar: ["All","All","All","All"])
        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
//        (locationSearch, levelSearch, zoneSearch, categorySearch) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3])
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        updateDeviceList()
        adjustScrollInsetsPullDownViewAndBackgroudImage() //   <- had to put it because of insets and other things...
    }
    @IBAction func crashButtonTapped(sender: AnyObject) {
        printOut("proba")
        CLSLogv("Log awesomeness %@", getVaList(["Wow. Much fun. Very nice. Wow."]))
        Crashlytics.sharedInstance().crash()
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    override func viewDidAppear(animated: Bool) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
        deviceCollectionView.reloadData()
        addObservers()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.refreshVisibleDevicesInScrollView()
        }
        appDel.setFilterBySSIDOrByiBeaconAgain()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func batchUpdate (device:Device) {
        let batch = NSBatchUpdateRequest(entityName: "Device")
        batch.propertiesToUpdate = ["stateUpdatedAt":NSDate()]
        let predOne = NSPredicate(format: "gateway == %@", device.gateway)
        let predFour = NSPredicate(format: "address == %@", device.address)
        let predFive = NSPredicate(format: "type == %@", device.controlType)
        let predSix = NSPredicate(format: "isEnabled == %@", NSNumber(bool: true))
        let predSeven = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
        let predArray:[NSPredicate] = [predOne, predFour, predFive, predSix, predSeven]
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predArray)
        batch.predicate = compoundPred
        batch.resultType = .UpdatedObjectIDsResultType
        do {
            let batchResult = try appDel.managedObjectContext!.executeRequest(batch) as? NSBatchUpdateResult
            if let objectIDs = batchResult!.result as? [NSManagedObjectID] {
                for objectID in objectIDs {
                    let managedObject = appDel.managedObjectContext!.objectWithID(objectID)
                    self.appDel.managedObjectContext!.refreshObject(managedObject, mergeChanges: true)
                }
            }
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    func refreshLocalParametars () {
        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6], locationSearch: locationSearchText)
        updateDeviceList()
//        fetchDevicesInBackground()
        deviceCollectionView.reloadData()
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshVisibleDevicesInScrollView", name: NotificationKey.DidRefreshDeviceInfo, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: NotificationKey.RefreshFilter, object: nil)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidRefreshDeviceInfo, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
    }
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    var inte = 0
//    func fetchDevicesInBackground () {
//        inte++
//        print("fetchDevicesInBackground \(inte)")
//        let backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
//        backgroundContext.persistentStoreCoordinator = appDel.persistentStoreCoordinator
//        backgroundContext.performBlock{[weak self] in
//            do {
//                let devices = try backgroundContext.executeFetchRequest(self!.deviceBackgroundFetch()) as! [Device]
//                let mainContext = self!.appDel.managedObjectContext
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    print(devices.count)
//                    self!.devices = devices
////                    self!.devices = []
////                    for device in devices {
////                        let device = mainContext!.objectWithID(deviceId) as! Device
////                        self!.appDel.managedObjectContext?.refreshObject(device, mergeChanges: true)
////                        self!.devices.append(device)
////                    }
////                for device in self!.devices {
////                    device.cellTitle = self!.returnNameForDeviceAccordingToFilter(device)
////                }
//                    if !self!.isScrolling {
//                        self!.deviceCollectionView.reloadData()
//                    }
//                })
//            } catch let error as NSError {
//                print("Unresolved error \(error), \(error.userInfo)")
//                abort()
//            }
//        }
//    }
    func fetchDevicesInBackground () {
        updateCells()
    }
    func deviceBackgroundFetch () -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "Device")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        request.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        let predicateNull = NSPredicate(format: "categoryId != 0")
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo]
        
        if locationSearch != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearch)
            predicateArray.append(locationPredicate)
        }
        if levelSearch != "All" {
            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: Int(levelSearch)!))
            predicateArray.append(levelPredicate)
        }
        if zoneSearch != "All" {
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: Int(zoneSearch)!))
            predicateArray.append(zonePredicate)
        }
        if categorySearch != "All" {
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: Int(categorySearch)!))
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        request.predicate = compoundPredicate
        request.resultType = .ManagedObjectIDResultType
        
        return request
    }
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String) {
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (gateway, level, zone, category, levelName, zoneName, categoryName)
        LocalSearchParametar.setLocalParametar("Devices", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName])
        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
        updateDeviceList()
        deviceCollectionView.reloadData()
        fetchDevicesInBackground()
    }
//    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String) {
//        (locationSearch, levelSearch, zoneSearch, categorySearch) = (gateway, level, zone, category)
//        LocalSearchParametar.setLocalParametar("Devices", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch])
//        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
//        updateDeviceList()
//        deviceCollectionView.reloadData()
//        fetchDevicesInBackground()
//    }
    var gateways:[Gateway]?
    func updateGateways(gatewayName:String, zone:Zone) {
        let fetchRequest = NSFetchRequest(entityName: "Gateway")
        let sortDescriptorOne = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne]
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
            gateways = fetResults!.map({$0})
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            //            abort()
        }
    }
    func updateDeviceList () {
        print("ovde je uslo")
        let fetchRequest = NSFetchRequest(entityName: "Device")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
//        let sortDescriptorFour = NSSortDescriptor(key: "curtainGroupID", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour,sortDescriptorFive]
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        let predicateNull = NSPredicate(format: "categoryId != 0") // s ovim kao nebi trebalo da izlazi uredjaj bez parametara?
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo]
        if locationSearch != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearch)
            predicateArray.append(locationPredicate)
        }
        if levelSearch != "All" {
//            DatabaseHandler.returnZoneWithId(<#T##id: Int##Int#>, gateway: <#T##Gateway#>)
//            DatabaseHandler.returnZoneIdWithName(<#T##name: String##String#>, gateway: <#T##Gateway#>)
            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: Int(levelSearch)!))
            let levelPredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", levelSearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [levelPredicate, levelPredicateTwo])
            predicateArray.append(copmpoundPredicate)
        }
        if zoneSearch != "All" {
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: Int(zoneSearch)!))
            let zonePredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", zoneSearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicate, zonePredicateTwo])
            predicateArray.append(copmpoundPredicate)
        }
        if categorySearch != "All" {
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: Int(categorySearch)!))
            let categoryPredicateTwo = NSPredicate(format: "ANY gateway.categories.name == %@", categorySearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, categoryPredicateTwo])
            predicateArray.append(copmpoundPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate        
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            devices = fetResults!.map({$0})
            for device in devices {
                device.cellTitle = returnNameForDeviceAccordingToFilter(device)
            }
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
//            abort()
        }
    }
    func setACPowerStatus(gesture:UIGestureRecognizer) {
        let tag = gesture.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        if devices[tag].currentValue == 0x00 {
            SendingHandler.sendCommand(byteArray: Function.setACStatus(address, channel: UInt8(Int(devices[tag].channel)), status: 0xFF), gateway: devices[tag].gateway)
        }
        if devices[tag].currentValue == 0xFF {
            SendingHandler.sendCommand(byteArray: Function.setACStatus(address, channel: UInt8(Int(devices[tag].channel)), status: 0x00), gateway: devices[tag].gateway)
        }
    }
    func cellParametarLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(deviceCollectionView)
            if let index = deviceCollectionView.indexPathForItemAtPoint(location){
                let cell = deviceCollectionView.cellForItemAtIndexPath(index)
                if devices[index.row].controlType == ControlType.Dimmer {
                    showDimmerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
                if devices[index.row].controlType == ControlType.Climate {
                    showClimaParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
                if devices[index.row].controlType == ControlType.Relay {
                    showRelayParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
                if devices[index.row].controlType == ControlType.Curtain {
                    showCellParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))
                }
                if devices[index.row].controlType == ControlType.Sensor {
                    showMultisensorParametar(CGPoint(x: self.view.center.x, y: self.view.center.y), device: devices[index.row])
                }
            }
        }
    }
    var longTouchOldValue = 0
    
    func longTouch(gestureRecognizer: UILongPressGestureRecognizer) {
        // Light
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        
        if devices[tag].controlType == ControlType.Dimmer {
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                longTouchOldValue = Int(devices[tag].currentValue)
                deviceInControlMode = true
                timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("update:"), userInfo: tag, repeats: true)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                longTouchOldValue = 0
                dispatch_async(dispatch_get_main_queue(), {
                    _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(self.devices[tag].currentValue)), delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.longTouchOldValue)
                })
                timer.invalidate()
                deviceInControlMode = false
                if devices[tag].opening == true {
                    devices[tag].opening = false
                }else {
                    devices[tag].opening = true
                }
                return
            }
        }
        if devices[tag].controlType == ControlType.Curtain {
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                longTouchOldValue = Int(devices[tag].currentValue)
                deviceInControlMode = true
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateCurtain:"), userInfo: tag, repeats: true)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                longTouchOldValue = 0
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: UInt8(Int(self.devices[tag].currentValue)), groupId:  0x00), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.longTouchOldValue)
                    })
                })
                timer.invalidate()
                deviceInControlMode = false
                if devices[tag].opening == true {
                    devices[tag].opening = false
                }else {
                    devices[tag].opening = true
                }
                return
            }
        }
    }
    func refreshDevice(sender:AnyObject) {
        if let button = sender as? UIButton {
            print(button.highlighted)
//            button.highlighted = !button.highlighted
            let tag = button.tag
            // Light
            if devices[tag].controlType == ControlType.Dimmer {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: Function.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
            // Appliance?
            if devices[tag].controlType == ControlType.Relay {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: Function.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
            // Curtain?
            if devices[tag].controlType == ControlType.Curtain {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: Function.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
        }
    }
    func oneTap(gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        // Light
        if devices[tag].controlType == ControlType.Dimmer {
            var setDeviceValue:UInt8 = 0
            var skipLevel:UInt8 = 0
            if Int(devices[tag].currentValue) > 0 {
                setDeviceValue = UInt8(0)
                skipLevel = 0
            } else {
                setDeviceValue = UInt8(100)
                skipLevel = UInt8(Int(self.devices[tag].skipState))
            }
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: setDeviceValue, delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: skipLevel), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
                })
//            })
        }
        // Appliance?
        if devices[tag].controlType == ControlType.Relay {
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceCurrentValue = Int(devices[tag].currentValue)
            var skipLevel:UInt8 = 0
            if Int(devices[tag].currentValue) > 0 {
                devices[tag].currentValue = 0
                skipLevel = 0
            } else {
                devices[tag].currentValue = 255
                skipLevel = UInt8(Int(self.devices[tag].skipState))
            }
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: 0xF1, delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: skipLevel), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
            })
        }
        // Curtain?
        if devices[tag].controlType == ControlType.Curtain {
            var setDeviceValue:UInt8 = 0
            if Int(devices[tag].currentValue) > 0 {
                setDeviceValue = UInt8(0)
            } else {
                setDeviceValue = UInt8(100)
            }
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: setDeviceValue, groupId:  0x00), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
            })
        }
//        deviceCollectionView.reloadData()
        updateCells()
    }
//    This has to be done, because we dont receive updates immmediately from gateway
    func updateCells() {
        if let indexPaths = deviceCollectionView.indexPathsForVisibleItems() as? [NSIndexPath] {
            for indexPath in indexPaths {
                print(indexPath.row)
                if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                    cell.refreshDevice(devices[indexPath.row])
                    cell.setNeedsDisplay()
                } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                    cell.refreshDevice(devices[indexPath.row])
                    cell.setNeedsDisplay()
                } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? MultiSensorCell {
                    cell.refreshDevice(devices[indexPath.row])
                    cell.setNeedsDisplay()
                } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? ClimateCell {
                    cell.refreshDevice(devices[indexPath.row])
                    cell.setNeedsDisplay()
                } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? ApplianceCollectionCell {
                    cell.refreshDevice(devices[indexPath.row])
                    cell.setNeedsDisplay()
                }
            }
        }
    }
    func update(timer: NSTimer){
        if let tag = timer.userInfo as? Int {
            var deviceValue = Double(devices[tag].currentValue)/100
            if devices[tag].opening == true{
                if deviceValue < 1 {
                    deviceValue += 0.05
                }
            } else {
                if deviceValue >= 0.05 {
                    deviceValue -= 0.05
                }
            }
            devices[tag].currentValue = Int(deviceValue*100)
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.lightSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    if let image = ImageHandler.returnPictures(Int(self.devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false) {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.curtainImage.image = image
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            if deviceValue == 0 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 00")
                            } else if deviceValue <= 1/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 01")
                            } else if deviceValue <= 2/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 02")
                            } else if deviceValue < 3/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 03")
                            } else {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 04")
                            }
                        })
                    }
                })
                cell.curtainSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            }
        }
    }
    
    func updateCurtain(timer: NSTimer){
        if let tag = timer.userInfo as? Int {
            var deviceValue = Double(devices[tag].currentValue)/100
            if devices[tag].opening == true{
                if deviceValue < 1 {
                    deviceValue += 0.20
                }
            } else {
                if deviceValue >= 0.20 {
                    deviceValue -= 0.20
                }
            }
            devices[tag].currentValue = Int(deviceValue*100)
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.lightSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    if let image = ImageHandler.returnPictures(Int(self.devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false) {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.curtainImage.image = image
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            if deviceValue == 0 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 00")
                            } else if deviceValue <= 1/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 01")
                            } else if deviceValue <= 2/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 02")
                            } else if deviceValue < 3/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 03")
                            } else {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 04")
                            }
                        })
                    }
                })
                cell.curtainSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            }
        }
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 2
//    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 2
//    }
    func calculateCellSize(inout size:CGSize) {
        var i:CGFloat = 2
        while i >= 2 {
            if (self.view.frame.size.width / i) >= 120 && (self.view.frame.size.width / i) <= 160 {
                break
            }
            i++
        }
        let cellWidth = Int(self.view.frame.size.width/i - (2/i + (i*5-5)/i))
        size = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
    }
    override func viewWillLayoutSubviews() {
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
    }
    func adjustScrollInsetsPullDownViewAndBackgroudImage() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        print(self.view.frame.size.width)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
//            if self.view.frame.size.width == 480 { // iPhone 4, 4s
//                let cellWidth = Int(self.view.frame.size.width/4 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 568 { // iPhone 5, 5s
//                let cellWidth = Int(self.view.frame.size.width/5 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 667 { // iPhone 6
//                let cellWidth = Int(self.view.frame.size.width/5 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 736 { // iPhone 6 plus
//                let cellWidth = Int(self.view.frame.size.width/6 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 1024 { // iPad
//                let cellWidth = Int(self.view.frame.size.width/8 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 5, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 1366 { // iPad Pro
//                let cellWidth = Int(self.view.frame.size.width/11 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 5, left: 1, bottom: 0, right: 1)
//            } else {
//                collectionViewCellSize = CGSize(width: 10, height: 10)
//                sectionInsets = UIEdgeInsets(top: 5, left: 1, bottom: 0, right: 1)
//            }
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            deviceCollectionView.reloadData()
//            CGRectIn
        } else {
//            if self.view.frame.size.width == 320{
//                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            }else if self.view.frame.size.width == 375{
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            }else{
//                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            }
//            if self.view.frame.size.width == 375 {
//                let cellWidth = Int(self.view.frame.size.width/3 - 4)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//            }
//            if self.view.frame.size.width == 320 { // iPhone 4, 4s... iPhone 5, 5s
//                let cellWidth = Int(self.view.frame.size.width/2 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 375 { // iPhone 6
//                let cellWidth = Int(self.view.frame.size.width/3 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 414 { // iPhone 6 plus
//                let cellWidth = Int(self.view.frame.size.width/3 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 768 { // iPad
//                let cellWidth = Int(self.view.frame.size.width/6 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            } else if self.view.frame.size.width == 1024 {
//                let cellWidth = Int(self.view.frame.size.width/8 - 5)
//                collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//                sectionInsets = UIEdgeInsets(top: 5, left: 1, bottom: 0, right: 1)
//            }  else {
//                collectionViewCellSize = CGSize(width: 10, height: 10)
//                sectionInsets = UIEdgeInsets(top: 5, left: 1, bottom: 0, right: 1)
//            }
//            var i:CGFloat = 2
//            while i >= 2 {
//                if (self.view.frame.size.width / i) >= 120 && (self.view.frame.size.width / i) <= 160 {
//                    break
//                }
//                i++
//            }
//            let cellWidth = Int(self.view.frame.size.width/i - 5)
//            collectionViewCellSize = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
//            sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
//            print("\(cellWidth):\(collectionViewCellSize):\(sectionInsets)")
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            deviceCollectionView.reloadData()
        }
        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6], locationSearch: locationSearchText)
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
//        fetchEntities("Flag")
//        fetchEntities("Timer")
//        fetchEntities("Security")
    }
//    var timers:[Timer] = []
//    var flags:[Flag] = []
//    var securities:[Security] = []
//    func fetchEntities (whatToFetch:String) {
//        if whatToFetch == "Flag" {
//            let fetchRequest = NSFetchRequest(entityName: "Flag")
//            let sortDescriptors = NSSortDescriptor(key: "flagName", ascending: true)
//            fetchRequest.sortDescriptors = [sortDescriptors]
//            do {
//                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Flag]
//                print(results.count)
//                flags = results
//            } catch let catchedError as NSError {
//                error = catchedError
//            }
//            return
//        }
//        
//        if whatToFetch == "Timer" {
//            let fetchRequest = NSFetchRequest(entityName: "Timer")
//            let sortDescriptors = NSSortDescriptor(key: "timerName", ascending: true)
//            fetchRequest.sortDescriptors = [sortDescriptors]
//            do {
//                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Timer]
//                timers = results
//            } catch let catchedError as NSError {
//                error = catchedError
//            }
//            return
//        }
//        if whatToFetch == "Security" {
//            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Security")
//            let sortDescriptorTwo = NSSortDescriptor(key: "name", ascending: true)
//            fetchRequest.sortDescriptors = [sortDescriptorTwo]
//            do {
//                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Security]
//                securities = fetResults!
//            } catch let error1 as NSError {
//                error = error1
//                print("Unresolved error \(error), \(error!.userInfo)")
//                abort()
//            }
//        }
//    }
    
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    var zoneSearchName:String = "All"
    var levelSearchName:String = "All"
    var categorySearchName:String = "All"
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func handleTap (gesture:UIGestureRecognizer) {
        let location = gesture.locationInView(deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItemAtPoint(location){
            if devices[index.row].controlType == ControlType.Dimmer {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! DeviceCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].controlType == ControlType.Relay {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ApplianceCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].controlType == ControlType.Sensor {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! MultiSensorCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].controlType == ControlType.Climate {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ClimateCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].controlType == ControlType.Curtain {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! CurtainCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            }
            
            devices[index.row].info = true
        }
    }
    
    func handleTap2 (gesture:UIGestureRecognizer) {
        let location = gesture.locationInView(deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItemAtPoint(location){
            if devices[index.row].controlType == ControlType.Dimmer {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! DeviceCollectionCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            } else if devices[index.row].controlType == ControlType.Relay {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ApplianceCollectionCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            } else if devices[index.row].controlType == ControlType.Sensor {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! MultiSensorCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            } else if devices[index.row].controlType == ControlType.Climate {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ClimateCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            } else if devices[index.row].controlType == ControlType.Curtain {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! CurtainCollectionCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            }
            devices[index.row].info = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func changeSliderValueOnOneTap (gesture:UIGestureRecognizer) {
        if let slider = gesture.view as? UISlider {
            deviceInControlMode = false
            if slider.highlighted {
                changeSliderValueEnded(slider)
                return
            }
            let sliderOldValue = slider.value*100
            let pt = gesture.locationInView(slider)
            let percentage = pt.x/slider.bounds.size.width
            let delta = Float(percentage) * Float(slider.maximumValue - slider.minimumValue)
            let value = round((slider.minimumValue + delta)*100)
            if !((value/100) >= 0 && (value/100) <= 100) {
                return
            }
            slider.setValue(value/100, animated: true)
            let tag = slider.tag
            devices[tag].currentValue = Int(value)
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(slider.value), motionSensor: false)
                cell.lightSlider.value = slider.value
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    if let image = ImageHandler.returnPictures(Int(self.devices[tag].categoryId), deviceValue: Double(slider.value), motionSensor: false) {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.curtainImage.image = image
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            if slider.value == 0 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 00")
                            } else if slider.value <= 1/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 01")
                            } else if slider.value <= 2/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 02")
                            } else if slider.value < 3/3 {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 03")
                            } else {
                                cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 04")
                            }
                        })
                    }
                })
                cell.curtainSlider.value = slider.value
                cell.setNeedsDisplay()
            }
            changeSliderValueWithTag(tag, withOldValue: Int(sliderOldValue))
        }
    }
    func changeSliderValueWithTag(tag:Int, withOldValue:Int) {
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        print(devices[tag])
        deviceInControlMode = false
        //   Dimmer
        if devices[tag].controlType == ControlType.Dimmer {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(self.devices[tag].currentValue)), delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: withOldValue)
                })
            })
        }
        //  Curtain
        if devices[tag].controlType == ControlType.Curtain {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: UInt8(Int(self.devices[tag].currentValue)), groupId:  0x00), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: withOldValue)
                })
            })
        }
    }
    func changeSliderValueStarted (sender: UISlider) {
        let tag = sender.tag
        deviceInControlMode = true
        changeSliderValueOldValue = Int(devices[tag].currentValue)
    }
    func changeSliderValueEnded (sender:UISlider) {
        let tag = sender.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        //   Dimmer
        if devices[tag].controlType == ControlType.Dimmer {
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(self.devices[tag].currentValue)), delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.changeSliderValueOldValue)
            })
            //            })
        }
        //  Curtain
        if devices[tag].controlType == ControlType.Curtain {
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: UInt8(Int(self.devices[tag].currentValue)), groupId:  0x00), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.changeSliderValueOldValue)
            })
            //            })
        }
        changeSliderValueOldValue = 0
        deviceInControlMode = false
    }
    
    var changeSliderValueOldValue = 0
    
    func changeSliderValue(sender: UISlider){
        let tag = sender.tag
        devices[tag].currentValue = Int(sender.value * 100)
        if sender.value == 1{
            devices[tag].opening = false
        }
        if sender.value == 0{
            devices[tag].opening = true
        }
        
        let deviceValue = sender.value
        let indexPath = NSIndexPath(forItem: tag, inSection: 0)
        if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
            cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
            cell.lightSlider.value = deviceValue
            cell.setNeedsDisplay()
        } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                if let image = ImageHandler.returnPictures(Int(self.devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false) {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.curtainImage.image = image
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        if deviceValue == 0 {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 00")
                        } else if deviceValue <= 1/3 {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 01")
                        } else if deviceValue <= 2/3 {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 02")
                        } else if deviceValue < 3/3 {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 03")
                        } else {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 04")
                        }
                    })
                }
            })
            cell.curtainSlider.value = deviceValue
            cell.setNeedsDisplay()
        }
    }
    
    func buttonTapped(sender:UIButton){
        let tag = sender.tag
        // Appliance?
        if devices[tag].controlType == ControlType.Relay {
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            //            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, runningTime: 0x00), gateway: devices[tag].gateway)
            let oldValue = Int(devices[tag].currentValue)
            _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway, device: devices[tag], oldValue: oldValue)
//            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway)
        }
    }
    func refreshDeviceList() {
        if !deviceInControlMode {
            if isScrolling {
                shouldUpdate = true
            } else {
                //                updateDeviceList()
                //                self.deviceCollectionView.reloadData()
                fetchDevicesInBackground()
            }
        }
    }
    var deviceInControlMode = false
    func returnNameForDeviceAccordingToFilter (device:Device) -> String {
        if locationSearchText[0] != "All" {
            if locationSearchText[1] != "All" {
                if locationSearchText[2] != "All" {
                    return "\(device.name)"
                } else {
                    return "\(DatabaseHandler.returnZoneWithId(Int(device.zoneId), gateway: device.gateway)) \(device.name)"
                }
            } else {
                return "\(DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), gateway: device.gateway)) \(DatabaseHandler.returnZoneWithId(Int(device.zoneId), gateway: device.gateway)) \(device.name)"
            }
        } else {
            return "\(device.gateway.name) \(DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), gateway: device.gateway)) \(DatabaseHandler.returnZoneWithId(Int(device.zoneId), gateway: device.gateway)) \(device.name)"
        }
    }
}
