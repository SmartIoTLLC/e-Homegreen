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

class DevicesViewController: CommonViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, PullDownViewDelegate {
    
    var sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    let reuseIdentifier = "deviceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var pullDown = PullDownView()
    var isScrolling:Bool = false
    var shouldUpdate:Bool = false
    
    var senderButton:UIButton?
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    var timer:NSTimer = NSTimer()
    
    var locationSearchText = ["", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        } else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 118, height: 144)
        }
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        deviceCollectionView.delaysContentTouches = false
        deviceCollectionView.delegate = self
        // Do any additional setup after loading the view.
        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
        (locationSearch, levelSearch, zoneSearch, categorySearch) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3])
        updateDeviceList()
        adjustScrollInsetsPullDownViewAndBackgroudImage()
    }
    override func viewDidAppear(animated: Bool) {
        deviceCollectionView.reloadData()
        addObservers()
        refreshVisibleDevicesInScrollView()
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
        let predFive = NSPredicate(format: "type == %@", device.type)
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
        (locationSearch, levelSearch, zoneSearch, categorySearch) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3])
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[1], zone: locationSearchText[2], category: locationSearchText[3])
        updateDeviceList()
//        fetchDevicesInBackground()
        deviceCollectionView.reloadData()
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshVisibleDevicesInScrollView", name: "btnRefreshDevicesClicked", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: "refreshLocalParametarsNotification", object: nil)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "refreshDeviceListNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "btnRefreshDevicesClicked", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "refreshLocalParametarsNotification", object: nil)
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
    
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String) {
        (locationSearch, levelSearch, zoneSearch, categorySearch) = (gateway, level, zone, category)
        updateDeviceList()
        fetchDevicesInBackground()
        deviceCollectionView.reloadData()
        LocalSearchParametar.setLocalParametar("Devices", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch])
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
        fetchRequest.predicate = compoundPredicate        
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            devices = fetResults!.map({$0})
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
//            abort()
        }
    }
    
    func cellParametarLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(deviceCollectionView)
            if let index = deviceCollectionView.indexPathForItemAtPoint(location){
                let cell = deviceCollectionView.cellForItemAtIndexPath(index)
                if devices[index.row].type == "Dimmer" {
                    showDimmerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
                if devices[index.row].type == "hvac" {
                    showClimaParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
                if devices[index.row].type == "curtainsRelay" || devices[index.row].type == "appliance" {
                    showRelayParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
                if devices[index.row].type == "curtainsRS485" {
                    showCellParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))
                }
                if devices[index.row].type == "sensor" {
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
        
        if devices[tag].type == "Dimmer" {
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
        
        if devices[tag].type == "curtainsRS485" {
            
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                longTouchOldValue = Int(devices[tag].currentValue)
                deviceInControlMode = true
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateCurtain:"), userInfo: tag, repeats: true)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                longTouchOldValue = 0
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(self.devices[tag].currentValue))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.longTouchOldValue)
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
            if devices[tag].type == "Dimmer" {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: Function.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
            // Appliance?
            if devices[tag].type == "curtainsRelay" || devices[tag].type == "appliance" {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: Function.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
            // Curtain?
            if devices[tag].type == "curtainsRS485" {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: Function.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
        }
    }
    func oneTap(gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        // Light
        if devices[tag].type == "Dimmer" {
            var setDeviceValue:UInt8 = 0
            if Int(devices[tag].currentValue) > 0 {
                setDeviceValue = UInt8(0)
            } else {
                setDeviceValue = UInt8(100)
            }
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: setDeviceValue, delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
                })
            })
        }
        // Appliance?
        if devices[tag].type == "curtainsRelay" || devices[tag].type == "appliance" {
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceCurrentValue = Int(devices[tag].currentValue)
            if Int(devices[tag].currentValue) > 0 {
                devices[tag].currentValue = 0
            } else {
                devices[tag].currentValue = 255
            }
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: 0xF1, delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
            })
        }
        // Curtain?
        if devices[tag].type == "curtainsRS485" {
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
                _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(self.devices[tag].channel)), value: setDeviceValue), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
            })
        }
//        deviceCollectionView.reloadData()
        updateCells()
    }
    func updateCells() {
        if let indexPaths = deviceCollectionView.indexPathsForVisibleItems() as? [NSIndexPath] {
            for indexPath in indexPaths {
                if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                    cell.lightSlider.continuous = true
                    let deviceValue = Double(devices[indexPath.row].currentValue) / 100
                    if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: deviceValue, motionSensor: false) {
                        cell.picture.image = image
                    } else {
                        if deviceValue == 0 {
                            cell.picture.image = UIImage(named: "lightBulb")
                        } else if deviceValue > 0 && deviceValue < 0.1 {
                            cell.picture.image = UIImage(named: "lightBulb1")
                        } else if deviceValue >= 0.1 && deviceValue < 0.2 {
                            cell.picture.image = UIImage(named: "lightBulb2")
                        } else if deviceValue >= 0.2 && deviceValue < 0.3 {
                            cell.picture.image = UIImage(named: "lightBulb3")
                        } else if deviceValue >= 0.3 && deviceValue < 0.4 {
                            cell.picture.image = UIImage(named: "lightBulb4")
                        } else if deviceValue >= 0.4 && deviceValue < 0.5 {
                            cell.picture.image = UIImage(named: "lightBulb5")
                        } else if deviceValue >= 0.5 && deviceValue < 0.6 {
                            cell.picture.image = UIImage(named: "lightBulb6")
                        } else if deviceValue >= 0.6 && deviceValue < 0.7 {
                            cell.picture.image = UIImage(named: "lightBulb7")
                        } else if deviceValue >= 0.7 && deviceValue < 0.8 {
                            cell.picture.image = UIImage(named: "lightBulb8")
                        } else if deviceValue >= 0.8 && deviceValue < 0.9 {
                            cell.picture.image = UIImage(named: "lightBulb9")
                        } else {
                            cell.picture.image = UIImage(named: "lightBulb10")
                        }
                    }
                    cell.lightSlider.value = Float(deviceValue)
                    cell.picture.tag = indexPath.row
                    cell.lblElectricity.text = "\(Float(devices[indexPath.row].current) * 0.01) A"
                    cell.lblVoltage.text = "\(Float(devices[indexPath.row].voltage)) V"
                    cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
                    cell.labelRunningTime.text = devices[indexPath.row].runningTime
                    if devices[indexPath.row].info {
                        cell.infoView.hidden = false
                        cell.backView.hidden = true
                    }else {
                        cell.infoView.hidden = true
                        cell.backView.hidden = false
                    }
                    if devices[indexPath.row].warningState == 0 {
                        cell.backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor
                    } else if devices[indexPath.row].warningState == 1 {
                        // Uppet state
                        cell.backView.colorTwo = UIColor.redColor().CGColor
                    } else if devices[indexPath.row].warningState == 2 {
                        // Lower state
                        cell.backView.colorTwo = UIColor.blueColor().CGColor
                    }
                    // If device is enabled add all interactions
                    if devices[indexPath.row].isEnabled.boolValue {
                        cell.disabledCellView.hidden = true
                    } else {
                        cell.disabledCellView.hidden = false
                    }
                    cell.setNeedsDisplay()
                } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                    let deviceValue = Double(devices[indexPath.row].currentValue) / 100
                    if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: deviceValue, motionSensor: false) {
                        cell.curtainImage.image = image
                    } else {
                        if deviceValue >= 0 && deviceValue < 0.2 {
                            cell.curtainImage.image = UIImage(named: "curtain0")
                        } else if deviceValue >= 0.2 && deviceValue < 0.4 {
                            cell.curtainImage.image = UIImage(named: "curtain1")
                        } else if deviceValue >= 0.4 && deviceValue < 0.6 {
                            cell.curtainImage.image = UIImage(named: "curtain2")
                        } else if deviceValue >= 0.6 && deviceValue < 0.8 {
                            cell.curtainImage.image = UIImage(named: "curtain3")
                        } else {
                            cell.curtainImage.image = UIImage(named: "curtain4")
                        }
                    }
                    cell.curtainSlider.value = Float(deviceValue)
                    cell.labelRunningTime.text = "\(devices[indexPath.row].runningTime)"
                    cell.lblElectricity.text = "\(Float(devices[indexPath.row].current) * 0.01) A"
                    cell.lblVoltage.text = "\(Float(devices[indexPath.row].voltage)) V"
                    cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
                    // If device is enabled add all interactions
                    if devices[indexPath.row].isEnabled.boolValue {
                        cell.disabledCellView.hidden = true
                    } else {
                        cell.disabledCellView.hidden = false
                    }
                    if devices[indexPath.row].info {
                        cell.infoView.hidden = false
                        cell.backView.hidden = true
                    }else {
                        cell.infoView.hidden = true
                        cell.backView.hidden = false
                    }
                    cell.setNeedsDisplay()
                } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? MultiSensorCell {
                    if devices[indexPath.row].numberOfDevices == 10 {
                        switch devices[indexPath.row].channel {
                        case 1:
                            if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: Double(devices[indexPath.row].currentValue)/255, motionSensor: false) {
                                cell.sensorImage.image = image
                            } else {
                                cell.sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue) C"
                        case 2:
                            if devices[indexPath.row].currentValue == 0 {
                                cell.sensorImage.image = UIImage(named: "applianceoff")
                            } else {
                                cell.sensorImage.image = UIImage(named: "applianceon")
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                        case 3:
                            if devices[indexPath.row].currentValue == 0 {
                                cell.sensorImage.image = UIImage(named: "applianceoff")
                            } else {
                                cell.sensorImage.image = UIImage(named: "applianceon")
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                        case 4:
                            if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: Double(devices[indexPath.row].currentValue)/255, motionSensor: false) {
                                cell.sensorImage.image = image
                            } else {
                                cell.sensorImage.image = UIImage(named: "sensor")
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)%"
                        case 5:
                            if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: Double(devices[indexPath.row].currentValue)/255, motionSensor: false) {
                                cell.sensorImage.image = image
                            } else {
                                cell.sensorImage.image = UIImage(named: "sensor_temperature")
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue) C"
                        case 6:
                            if let image = ImageHandler.returnPictures(2, deviceValue: Double(devices[indexPath.row].currentValue)/100, motionSensor: false) {
                                cell.sensorImage.image = image
                            } else {
                                cell.sensorImage.image = UIImage(named: "sensor_brightness")
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue) LUX"
                        case 7:
                            if devices[indexPath.row].currentValue == 1 {
                                cell.sensorImage.image = UIImage(named: "sensor_motion")
                            } else if devices[indexPath.row].currentValue == 0 {
                                cell.sensorImage.image = UIImage(named: "sensor_idle")
                            } else {
                                cell.sensorImage.image = UIImage(named: "sensor_third")
                            }
                            if devices[indexPath.row].currentValue == 1 {
                                cell.sensorState.text = "Motion"
                            } else if devices[indexPath.row].currentValue == 0 {
                                cell.sensorState.text = "Motion"
                            } else {
                                cell.sensorState.text = "Idle"
                            }
                        case 8:
                            if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: Double(devices[indexPath.row].currentValue)/255, motionSensor: false) {
                                cell.sensorImage.image = image
                            } else {
                                cell.sensorImage.image = UIImage(named: "sensor_ir_receiver")
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                        case 9:
                            if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: Double(devices[indexPath.row].currentValue)/255, motionSensor: false) {
                                cell.sensorImage.image = image
                            } else {
                                if devices[indexPath.row].currentValue == 1 {
                                    cell.sensorImage.image = UIImage(named: "tamper_on")
                                } else {
                                    cell.sensorImage.image = UIImage(named: "tamper_off")
                                }
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                        case 10:
                            if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: Double(devices[indexPath.row].currentValue)/255, motionSensor: false) {
                                cell.sensorImage.image = image
                            } else {
                                if devices[indexPath.row].currentValue == 1 {
                                    cell.sensorImage.image = UIImage(named: "sensor_noise")
                                } else {
                                    cell.sensorImage.image = UIImage(named: "sensor_no_noise")
                                }
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                        default:
                            cell.sensorState.text = "..."
                        }
                    }
                    if devices[indexPath.row].numberOfDevices == 6 {
                        switch devices[indexPath.row].channel {
                        case 1:
                            cell.sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue) C"
                        case 2:
                            cell.sensorImage.image = UIImage(named: "sensor")
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                        case 3:
                            cell.sensorImage.image = UIImage(named: "sensor")
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                        case 4:
                            cell.sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue) C"
                        case 5:
                            if devices[indexPath.row].currentValue == 1 {
                                cell.sensorImage.image = UIImage(named: "sensor_motion")
                                cell.sensorState.text = "Motion"
                            } else {
                                cell.sensorImage.image = UIImage(named: "sensor_idle")
                                cell.sensorState.text = "Idle"
                            }
                        case 6:
                            if devices[indexPath.row].currentValue == 1 {
                                cell.sensorImage.image = UIImage(named: "tamper_on")
                            } else {
                                cell.sensorImage.image = UIImage(named: "tamper_off")
                            }
                            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                        default:
                            cell.sensorState.text = "..."
                        }
                    }
                    cell.labelID.text = "\(indexPath.row + 1)"
                    cell.labelName.text = "\(devices[indexPath.row].name)"
                    cell.labelCategory.text = "\(devices[indexPath.row].categoryId)"
                    cell.labelLevel.text = "\(devices[indexPath.row].parentZoneId)"
                    cell.labelZone.text = "\(devices[indexPath.row].zoneId)"
                    if devices[indexPath.row].info {
                        cell.infoView.hidden = false
                        cell.backView.hidden = true
                    }else {
                        cell.infoView.hidden = true
                        cell.backView.hidden = false
                    }
                    // If device is enabled add all interactions
                    if devices[indexPath.row].isEnabled.boolValue {
                        cell.disabledCellView.hidden = true
                    } else {
                        cell.disabledCellView.hidden = false
                    }
                    cell.setNeedsDisplay()
                } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? ClimateCell {
                    cell.temperature.text = "\(devices[indexPath.row].roomTemperature) C"
                    cell.climateMode.text = devices[indexPath.row].mode
                    cell.climateSpeed.text = devices[indexPath.row].speed
                    var fanSpeed = 0.0
                    let speedState = devices[indexPath.row].speedState
                    if devices[indexPath.row].currentValue == 255 {
                        switch speedState {
                        case "Low":
                            cell.fanSpeedImage.image = UIImage(named: "fanlow")
                            fanSpeed = 1
                        case "Med" :
                            cell.fanSpeedImage.image = UIImage(named: "fanmedium")
                            fanSpeed = 0.3
                        case "High":
                            cell.fanSpeedImage.image = UIImage(named: "fanhigh")
                            fanSpeed = 0.1
                        default:
                            cell.fanSpeedImage.image = UIImage(named: "fanoff")
                            fanSpeed = 0.0
                        }
                        let animationImages:[UIImage] = [UIImage(named: "h1")!, UIImage(named: "h2")!, UIImage(named: "h3")!, UIImage(named: "h4")!, UIImage(named: "h5")!, UIImage(named: "h6")!, UIImage(named: "h7")!, UIImage(named: "h8")!]
                        let modeState = devices[indexPath.row].modeState
                        switch modeState {
                        case "Cool":
                            cell.modeImage.stopAnimating()
                            cell.modeImage.image = UIImage(named: "cool")
                            cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                        case "Heat":
                            cell.modeImage.stopAnimating()
                            cell.modeImage.image = UIImage(named: "heat")
                            cell.temperatureSetPoint.text = "\(devices[indexPath.row].heatTemperature) C"
                        case "Fan":
                            cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                            if fanSpeed == 0 {
                                cell.modeImage.image = UIImage(named: "fanauto")
                                cell.modeImage.stopAnimating()
                            } else {
                                cell.modeImage.animationImages = animationImages
                                cell.modeImage.animationDuration = NSTimeInterval(fanSpeed)
                                cell.modeImage.animationRepeatCount = 0
                                cell.modeImage.startAnimating()
                            }
                        default:
                            cell.modeImage.stopAnimating()
                            cell.modeImage.image = nil
                            let mode = devices[indexPath.row].mode
                            switch mode {
                            case "Cool":
                                cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                            case "Heat":
                                cell.temperatureSetPoint.text = "\(devices[indexPath.row].heatTemperature) C"
                            case "Fan":
                                cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                            default:
                                //  Hoce i tu da zezne
                                cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                            }
                        }
                    } else {
                        cell.fanSpeedImage.image = UIImage(named: "fanoff")
                        cell.modeImage.stopAnimating()
                    }
                    if devices[indexPath.row].currentValue == 0 {
                        cell.imageOnOff.image = UIImage(named: "poweroff")
                        cell.modeImage.image = nil
                    } else {
                        cell.imageOnOff.image = UIImage(named: "poweron")
                    }
                    cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
                    if devices[indexPath.row].info {
                        cell.infoView.hidden = false
                        cell.backView.hidden = true
                    }else {
                        cell.infoView.hidden = true
                        cell.backView.hidden = false
                    }
                    // If device is enabled add all interactions
                    if devices[indexPath.row].isEnabled.boolValue {
                        cell.disabledCellView.hidden = true
                    } else {
                        cell.disabledCellView.hidden = false
                    }
                    cell.setNeedsDisplay()
                } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? ApplianceCollectionCell {
                    let deviceValue = Double(devices[indexPath.row].currentValue)/255
                    if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: deviceValue, motionSensor: false) {
                        cell.image.image = image
                    } else {
                        if devices[indexPath.row].currentValue == 255 {
                            cell.image.image = UIImage(named: "applianceon")
                        }
                        if devices[indexPath.row].currentValue == 0{
                            cell.image.image = UIImage(named: "applianceoff")
                        }
                    }
                    if devices[indexPath.row].currentValue == 255 {
                        cell.onOff.setTitle("ON", forState: .Normal)
                    } else if devices[indexPath.row].currentValue == 0 {
                        cell.onOff.setTitle("OFF", forState: .Normal)
                    }
                    if devices[indexPath.row].info {
                        cell.infoView.hidden = false
                        cell.backView.hidden = true
                    }else {
                        cell.infoView.hidden = true
                        cell.backView.hidden = false
                    }
                    cell.labelRunningTime.text = "\(devices[indexPath.row].runningTime)"
                    cell.lblElectricity.text = "\(Float(devices[indexPath.row].current) * 0.01) A"
                    cell.lblVoltage.text = "\(Float(devices[indexPath.row].voltage)) V"
                    cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
                    // If device is enabled add all interactions
                    if devices[indexPath.row].isEnabled.boolValue {
                        cell.disabledCellView.hidden = true
                    } else {
                        cell.disabledCellView.hidden = false
                    }
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
//            UIView.setAnimationsEnabled(false)
//            self.deviceCollectionView.performBatchUpdates({
//                let indexPath = NSIndexPath(forItem: tag, inSection: 0)
//                self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
//                }, completion:  {(completed: Bool) -> Void in
//                    UIView.setAnimationsEnabled(true)
//            })
//            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
//            let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as! DeviceCollectionCell
//            cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
//            cell.setNeedsDisplay()
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.lightSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                cell.curtainImage.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
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
//            UIView.setAnimationsEnabled(false)
//            self.deviceCollectionView.performBatchUpdates({
//                let indexPath = NSIndexPath(forItem: tag, inSection: 0)
//                self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
//                }, completion:  {(completed: Bool) -> Void in
//                    UIView.setAnimationsEnabled(true)
//            })
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.lightSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                cell.curtainImage.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.curtainSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            }
        }
    }
    func adjustScrollInsetsPullDownViewAndBackgroudImage() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.width == 568{
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            }else if self.view.frame.size.width == 667{
                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            }
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
            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
            deviceCollectionView.reloadData()
            
        } else {
            if self.view.frame.size.width == 320{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }else if self.view.frame.size.width == 375{
                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }
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
            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
            deviceCollectionView.reloadData()
        }
        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[1], zone: locationSearchText[2], category: locationSearchText[3])
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
    }
//    override func viewWillLayoutSubviews() {
//        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
//        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
//            if self.view.frame.size.width == 568{
//                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
//            }else if self.view.frame.size.width == 667{
//                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
//            }else{
//                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
//            }
//            var rect = self.pullDown.frame
//            pullDown.removeFromSuperview()
//            rect.size.width = self.view.frame.size.width
//            rect.size.height = self.view.frame.size.height
//            pullDown.frame = rect
//            pullDown = PullDownView(frame: rect)
//            pullDown.customDelegate = self
//            self.view.addSubview(pullDown)
//            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
//            //  This is from viewcontroller superclass:
//            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
////            deviceCollectionView.reloadData()
//            deviceCollectionView.setNeedsLayout()
//            
//        } else {
//            if self.view.frame.size.width == 320{
//                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            }else if self.view.frame.size.width == 375{
//                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            }else{
//                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            }
//            var rect = self.pullDown.frame
//            pullDown.removeFromSuperview()
//            rect.size.width = self.view.frame.size.width
//            rect.size.height = self.view.frame.size.height
//            pullDown.frame = rect
//            pullDown = PullDownView(frame: rect)
//            pullDown.customDelegate = self
//            self.view.addSubview(pullDown)
//            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
//            //  This is from viewcontroller superclass:
//            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
////            deviceCollectionView.reloadData()
//            deviceCollectionView.setNeedsLayout()
//        }
//        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
//        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[1], zone: locationSearchText[2], category: locationSearchText[3])
//    }
    
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func handleTap (gesture:UIGestureRecognizer) {
        let location = gesture.locationInView(deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItemAtPoint(location){
            if devices[index.row].type == "Dimmer" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! DeviceCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].type == "curtainsRelay" || devices[index.row].type == "appliance" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ApplianceCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].type == "sensor" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! MultiSensorCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].type == "hvac" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ClimateCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].type == "curtainsRS485" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! CurtainCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            }
            
            devices[index.row].info = true
        }
    }
    
    func handleTap2 (gesture:UIGestureRecognizer) {
        let location = gesture.locationInView(deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItemAtPoint(location){
            if devices[index.row].type == "Dimmer" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! DeviceCollectionCell
                
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            } else if devices[index.row].type == "curtainsRelay" || devices[index.row].type == "appliance" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ApplianceCollectionCell
                
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            }
            else if devices[index.row].type == "sensor" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! MultiSensorCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            }else if devices[index.row].type == "hvac" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ClimateCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            }else if devices[index.row].type == "curtainsRS485" {
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
            print("Eee \(sliderOldValue)")
            let pt = gesture.locationInView(slider)
            print("Eee \(pt)")
            let percentage = pt.x/slider.bounds.size.width
            print("Eee \(percentage)")
            let delta = Float(percentage) * Float(slider.maximumValue - slider.minimumValue)
            print("Eee \(delta)")
            let value = round((slider.minimumValue + delta)*100)
            print("Eee \(value)")
            if !((value/100) >= 0 && (value/100) <= 100) {
                return
            }
            slider.setValue(value/100, animated: true)
            let tag = slider.tag
            devices[tag].currentValue = Int(value)
            print("Eee \(value)")
//            UIView.setAnimationsEnabled(false)
//            self.deviceCollectionView.performBatchUpdates({
//                let indexPath = NSIndexPath(forItem: tag, inSection: 0)
//                self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
//                }, completion:  {(completed: Bool) -> Void in
//                    UIView.setAnimationsEnabled(true)
//            })
//            changeSliderValueWithTag(tag, withOldValue: Int(sliderOldValue))
//            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
//            let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as! DeviceCollectionCell
//            cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
//            cell.setNeedsDisplay()
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(slider.value), motionSensor: false)
                cell.lightSlider.value = slider.value
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                cell.curtainImage.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(slider.value), motionSensor: false)
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
        if devices[tag].type == "Dimmer" {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    print(self.devices[tag])
                    print("\(self.devices[tag].currentValue)")
                    print("\(Int(self.devices[tag].currentValue))")
                    _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(self.devices[tag].currentValue)), delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: withOldValue)
                })
            })
        }
        //  Curtain
        if devices[tag].type == "curtainsRS485" {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(self.devices[tag].currentValue))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: withOldValue)
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
        if devices[tag].type == "Dimmer" {
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(self.devices[tag].currentValue)), delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.changeSliderValueOldValue)
            })
            //            })
        }
        //  Curtain
        if devices[tag].type == "curtainsRS485" {
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(self.devices[tag].currentValue))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.changeSliderValueOldValue)
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
        
//        UIView.setAnimationsEnabled(false)
        //        self.deviceCollectionView.performBatchUpdates({
        let deviceValue = sender.value
        let indexPath = NSIndexPath(forItem: tag, inSection: 0)
        if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
            cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
            cell.lightSlider.value = deviceValue
            cell.setNeedsDisplay()
        } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
            cell.curtainImage.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
            cell.curtainSlider.value = deviceValue
            cell.setNeedsDisplay()
        }
//            self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
//            }, completion:  {(completed: Bool) -> Void in
//                UIView.setAnimationsEnabled(true)
//        })
    }
    func buttonTapped(sender:UIButton){
        let tag = sender.tag
        // Appliance?
        if devices[tag].type == "curtainsRelay" || devices[tag].type == "appliance" {
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            //            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, runningTime: 0x00), gateway: devices[tag].gateway)
            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway)
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
