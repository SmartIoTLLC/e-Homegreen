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


class DevicesViewController: UIViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, PullDownViewDelegate, SWRevealViewControllerDelegate {
    
    var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
    let reuseIdentifier = "deviceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var pullDown = PullDownView()
    var isScrolling:Bool = false
    var shouldUpdate:Bool = false
    
    var senderButton:UIButton?
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    var timer:NSTimer = NSTimer()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
//    var locationSearchText = ["", "", "", "", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
                revealViewController().rearViewRevealWidth = 200
            }else{
                revealViewController().rearViewRevealWidth = 200
            }
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let fontDictionary = [ NSForegroundColorAttributeName:UIColor.whiteColor() ]
        self.navigationController?.navigationBar.titleTextAttributes = fontDictionary
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        } else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 121, height: 150)
        }
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        self.view.addSubview(pullDown)

        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        deviceCollectionView.delaysContentTouches = false
        deviceCollectionView.delegate = self
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
        
        saveChanges()
        updateDeviceList()
        adjustScrollInsetsPullDownViewAndBackgroudImage() //   <- had to put it because of insets and other things...
    }
    
    @IBAction func fullScreen(sender: AnyObject) {
        
    }
    
    @IBAction func reload(sender: AnyObject) {
        
    }
    
    @IBAction func location(sender: AnyObject) {
        
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
    
    func refreshLocalParametars () {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
        updateDeviceList()
        deviceCollectionView.reloadData()
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DevicesViewController.refreshDeviceList), name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DevicesViewController.refreshVisibleDevicesInScrollView), name: NotificationKey.DidRefreshDeviceInfo, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DevicesViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
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
    func fetchDevicesInBackground () {
        updateCells()
    }
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String) {
//        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (gateway, level, zone, category, levelName, zoneName, categoryName)
//        LocalSearchParametar.setLocalParametar("Devices", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName])
//        locationSearchText = LocalSearchParametar.getLocalParametar("Devices")
//        updateDeviceList()
//        deviceCollectionView.reloadData()
//        fetchDevicesInBackground()
    }
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Device)
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Device)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
        updateDeviceList()
        deviceCollectionView.reloadData()
        fetchDevicesInBackground()
    }
    func updateDeviceList () {
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
        // Filtering out PC devices
        let predicateThree = NSPredicate(format: "type != %@", ControlType.PC)
        var predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo, predicateThree]
        if filterParametar.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterParametar.location)
            predicateArray.append(locationPredicate)
        }
        if filterParametar.levelId != 0 {
            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: filterParametar.levelId))
//            let levelPredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", filterParametar.levelName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [levelPredicate])
            predicateArray.append(copmpoundPredicate)
        }
        if filterParametar.zoneId != 0 {
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: filterParametar.zoneId))
//            let zonePredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", filterParametar.zoneName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicate])
            predicateArray.append(copmpoundPredicate)
        }
        if filterParametar.categoryId != 0 {
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: filterParametar.categoryId))
//            let categoryPredicateTwo = NSPredicate(format: "ANY gateway.categories.name == %@", filterParametar.categoryName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
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
                if devices[index.row].controlType == ControlType.Sensor || devices[index.row].controlType == ControlType.HumanInterfaceSeries || devices[index.row].controlType == ControlType.Gateway {
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
                timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(DevicesViewController.update(_:)), userInfo: tag, repeats: true)
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
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(DevicesViewController.updateCurtain(_:)), userInfo: tag, repeats: true)
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
                //                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.picture.image = devices[tag].returnImage(Double(deviceValue*100))
                cell.lightSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                cell.curtainImage.image = devices[tag].returnImage(Double(deviceValue*100))
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
                //                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.picture.image = devices[tag].returnImage(Double(deviceValue*100))
                cell.lightSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                cell.curtainImage.image = devices[tag].returnImage(Double(deviceValue*100))
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
//            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
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
//            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            deviceCollectionView.reloadData()
        }
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
        pullDown.drawMenu(filterParametar)
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
    }
    
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
            } else if devices[index.row].controlType == ControlType.Sensor || devices[index.row].controlType == ControlType.HumanInterfaceSeries || devices[index.row].controlType == ControlType.Gateway {
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
    
    func doubleTap (gesture:UIGestureRecognizer) {
        let location = gesture.locationInView(deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItemAtPoint(location){
            if devices[index.row].controlType == ControlType.Dimmer {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! DeviceCollectionCell
                if cell.typeOfLight.holdScrolling{
                    cell.typeOfLight.holdScrolling = false
                }else{
                    cell.typeOfLight.holdScrolling = true
                }
                
            } else if devices[index.row].controlType == ControlType.Relay {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ApplianceCollectionCell
                
            } else if devices[index.row].controlType == ControlType.Sensor || devices[index.row].controlType == ControlType.HumanInterfaceSeries || devices[index.row].controlType == ControlType.Gateway {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! MultiSensorCell
                
            } else if devices[index.row].controlType == ControlType.Climate {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ClimateCell
                
            } else if devices[index.row].controlType == ControlType.Curtain {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! CurtainCollectionCell
            }
            
            
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
            } else if devices[index.row].controlType == ControlType.Sensor || devices[index.row].controlType == ControlType.HumanInterfaceSeries || devices[index.row].controlType == ControlType.Gateway {
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
                //                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(slider.value), motionSensor: false)
                cell.picture.image = devices[tag].returnImage(Double(value))
                cell.lightSlider.value = slider.value
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                cell.curtainImage.image = devices[tag].returnImage(Double(value))
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
            let deviceValue:Double = {
                if Int(devices[tag].currentValue) > 100 {
                    return Double(Double(devices[tag].currentValue)/255)
                } else {
                    return Double(devices[tag].currentValue)/100
                }
            }()
            cell.picture.image = devices[tag].returnImage(Double(deviceValue*100))
            cell.lightSlider.value = Float(deviceValue)
            cell.setNeedsDisplay()
        } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
            let deviceValue:Double = {
                if Int(devices[tag].currentValue) > 100 {
                    return Double(Double(devices[tag].currentValue)/255)
                } else {
                    return Double(devices[tag].currentValue)/100
                }
            }()
            cell.curtainImage.image = devices[tag].returnImage(Double(deviceValue*100))
            cell.curtainSlider.value = Float(deviceValue)
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
    //MARK: Setting names for devices according to filter
    func returnNameForDeviceAccordingToFilter (device:Device) -> String {
        if filterParametar.location != "All" {
            if filterParametar.levelId != 0 {
                if filterParametar.zoneId != 0 {
                    return "\(device.name)"
                } else {
                    return "\(DatabaseHandler.returnZoneWithId(Int(device.zoneId), location: device.gateway.location)) \(device.name)"
                }
            } else {
                return "\(DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location)) \(DatabaseHandler.returnZoneWithId(Int(device.zoneId), location: device.gateway.location)) \(device.name)"
            }
        } else {
            return "\(device.gateway.name) \(DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location)) \(DatabaseHandler.returnZoneWithId(Int(device.zoneId), location: device.gateway.location)) \(device.name)"
        }
    }
}
