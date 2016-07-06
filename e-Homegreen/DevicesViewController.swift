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
    var sidebarMenuOpen : Bool!
    
    var senderButton:UIButton?
    
    var deviceInControlMode = false
    var timer:NSTimer = NSTimer()
    var userLogged:User?
    
    var panRecognizer:UIPanGestureRecognizer!
    var panStartPoint:CGPoint?
    var startingBottomConstraint:CGFloat?
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    var inte = 0
    
    var changeSliderValueOldValue = 0
    
    var longTouchOldValue = 0
    
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    @IBOutlet weak var indicatorGreen: UIView!
    @IBOutlet weak var indicatorRed: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var zoneCategoryControl: UISegmentedControl!
    @IBOutlet weak var zoneAndCategorySlider: UISlider!
    
    override func viewWillAppear(animated: Bool) {
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
        if AdminController.shared.isAdminLogged(){
            if let user = DatabaseUserController.shared.getOtherUser(){
                userLogged = user
                updateDeviceList(user)
            }
        }else{
            if let user = DatabaseUserController.shared.getLoggedUser(){
                userLogged = user
                updateDeviceList(user)
            }
        }
        
        changeFullScreeenImage()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
        
        zoneAndCategorySlider.continuous = false
        
        adjustScrollInsetsPullDownViewAndBackgroudImage() //   <- had to put it because of insets and other things...
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DevicesViewController.panView(_:)))
        panRecognizer.delegate = self
        bottomView.addGestureRecognizer(panRecognizer)
        
        // Initialize Indicators
        indicatorRed.layer.cornerRadius = indicatorRed.frame.size.width/2
        indicatorGreen.layer.cornerRadius = indicatorRed.frame.size.width/2
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
    override func viewWillLayoutSubviews() {
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
    }

    func changeFullScreeenImage(){
        if UIApplication.sharedApplication().statusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func refreshLocalParametars () {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
//        updateDeviceList()
        deviceCollectionView.reloadData()
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DevicesViewController.refreshDeviceList), name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DevicesViewController.refreshVisibleDevicesInScrollView), name: NotificationKey.DidRefreshDeviceInfo, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DevicesViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DevicesViewController.updateIndicator(_:)), name: NotificationKey.IndicatorLamp, object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidRefreshDeviceInfo, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.IndicatorLamp, object: nil)
    }
    
    
    func updateIndicator(notification:NSNotification){
        if let info = notification.userInfo as? [String:String]{
            if let lamp = info["lamp"]{
                if lamp == "red" {
                    self.indicatorRed.alpha = 1
                    UIView.animateWithDuration(0.5, animations: { 
                        self.indicatorRed.alpha = 0
                    })
                }else if lamp == "green" {
                    self.indicatorGreen.alpha = 1
                    UIView.animateWithDuration(0.5, animations: {
                        self.indicatorGreen.alpha = 0
                    })
                }else{
                    print("INDICATOR ERROR")
                }
            }
        }
        //indicatorGreen.backgroundColor = UIColor.greenColor()
    }
    
    func fetchDevicesInBackground(){
        updateCells()
    }

    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Device)
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Device)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
        if let user = userLogged{
            updateDeviceList(user)
            deviceCollectionView.reloadData()
            fetchDevicesInBackground()
        }
        
    }
    func updateDeviceList (user:User) {
        let fetchRequest = NSFetchRequest(entityName: "Device")
        
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
        predicateArray.append(NSPredicate(format: "categoryId != 0")) // s ovim kao ne bi trebalo da izlazi uredjaj bez parametara?
        predicateArray.append(NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true)))
        predicateArray.append(NSPredicate(format: "isVisible == %@", NSNumber(bool: true)))
        
        // Filtering out PC devices
        predicateArray.append(NSPredicate(format: "type != %@", ControlType.PC))
        //filtering by parametars from filter
        if filterParametar.location != "All" {
            predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location))
        }
        if filterParametar.levelId != 0 {
            predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(integer: filterParametar.levelId)))
        }
        if filterParametar.zoneId != 0 {
            predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(integer: filterParametar.zoneId)))
        }
        if filterParametar.categoryId != 0 {
            predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(integer: filterParametar.categoryId)))
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
    
    func adjustScrollInsetsPullDownViewAndBackgroudImage() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
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
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            deviceCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            deviceCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            deviceCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            deviceCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
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
    
    func panView(gesture:UIPanGestureRecognizer){
        
        switch (gesture.state) {
        case .Began:
            self.panStartPoint = gesture.translationInView(self.bottomView)
            self.startingBottomConstraint = self.bottomConstraint.constant
            break
        case .Changed:
            let currentPoint = gesture.translationInView(self.bottomView)
            let deltaX = currentPoint.y - self.panStartPoint!.y
            var panningUp = false
            if currentPoint.y < self.panStartPoint!.y {
                panningUp = true
            }

            if self.startingBottomConstraint == -130 {
                
                if !panningUp{
                    if deltaX == 0{
                        self.resetConstraintContstants(true, endEditing: true)
                    }
                    
                }else{
                    let constant = deltaX
                    if constant < -130 {
                        self.setConstraintsToShowBottomView(true, notifyDelegate: true)
                    }else{
                       self.bottomConstraint.constant = -130 - deltaX
                    }
                }
            }else{
                if !panningUp{
                    if -deltaX > -130{
                        self.bottomConstraint.constant = -deltaX
                    }else{
                        self.resetConstraintContstants(true, endEditing: true)
                    }
                }else{
                    if deltaX <= 0{
                        self.setConstraintsToShowBottomView(true, notifyDelegate: true)
                    }else{
                        self.bottomConstraint.constant = -130 - deltaX
                    }
                }
            }

            break
        case .Ended:
            if self.startingBottomConstraint == -130 {
                if bottomConstraint.constant >= -100{
                    self.setConstraintsToShowBottomView(true, notifyDelegate: true)
                }else{
                    self.resetConstraintContstants(true, endEditing: true)
                }
            }else{
                if bottomConstraint.constant <= -30{
                    self.resetConstraintContstants(true, endEditing: true)
                }else{
                    self.setConstraintsToShowBottomView(true, notifyDelegate: true)
                }
            }

            break
        case .Cancelled:

            if self.startingBottomConstraint == -130 {
                self.resetConstraintContstants(true, endEditing: true)
            } else {
                self.setConstraintsToShowBottomView(true, notifyDelegate: true)
            }
            break
        default:
            break
        }
        
    }
    
    func resetConstraintContstants(animated:Bool, endEditing:Bool){
        if self.startingBottomConstraint == -130 &&
            self.bottomConstraint.constant == -130 {
            return
        }
        self.bottomConstraint.constant = -130
        
        self.updateConstraintsIfNeeded(animated, completion: { (finished) -> Void in
            self.bottomConstraint.constant = -130
            
            self.updateConstraintsIfNeeded(animated, completion: { (finished) -> Void in
                self.startingBottomConstraint = self.bottomConstraint.constant
            })
        })
    }
    
    func setConstraintsToShowBottomView(animated:Bool, notifyDelegate:Bool){
        if self.startingBottomConstraint == 0 &&
            self.bottomConstraint.constant == 0 {
            return
        }
        
        self.bottomConstraint.constant =  0
        
        self.updateConstraintsIfNeeded(animated) { (finished) -> Void in
            self.bottomConstraint.constant = 0
            
            self.updateConstraintsIfNeeded(animated, completion: { (finished) -> Void in
                self.startingBottomConstraint = self.bottomConstraint.constant
            })
        }
        
    }
    
    func updateConstraintsIfNeeded(animated:Bool, completion:(finished: Bool) -> Void){
        var duration:Float = 0
        if animated {
            duration = 0.1
        }
        
        UIView.animateWithDuration(NSTimeInterval(duration), delay: NSTimeInterval(0), options: UIViewAnimationOptions.CurveEaseOut, animations:{ self.bottomView.layoutIfNeeded() }, completion: {
            success in
            completion(finished: success)
        })
        
    }
    
    
    @IBAction func zoneCategoryControlSlider(sender: UISlider) {
        let sliderValue = Int(sender.value)
        switch zoneCategoryControl.selectedSegmentIndex{
        case 0:
            ZoneAndCategoryControl.shared.changeValueByZone(filterParametar.zoneId, location: filterParametar.location, value: sliderValue)
        case 1:
            ZoneAndCategoryControl.shared.changeValueByCategory(filterParametar.zoneId, location: filterParametar.location, value: sliderValue)
        default:
            break;
        }
    }

    @IBAction func on(sender: AnyObject) {
        switch zoneCategoryControl.selectedSegmentIndex{
        case 0:
            ZoneAndCategoryControl.shared.turnOnByZone(filterParametar.zoneId, location: filterParametar.location)
        case 1:
            ZoneAndCategoryControl.shared.turnOnByCategory(filterParametar.categoryId, location: filterParametar.location)
        default:
            break;
        }
    }
    
    @IBAction func off(sender: AnyObject) {
        switch zoneCategoryControl.selectedSegmentIndex{
        case 0:
            ZoneAndCategoryControl.shared.turnOffByZone(filterParametar.zoneId, location: filterParametar.location)
        case 1:
            ZoneAndCategoryControl.shared.turnOffByCategory(filterParametar.categoryId, location: filterParametar.location)
        default:
            break;
        }
    }

    @IBAction func changeZoneCategory(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
           selectLabel.text = "Select Zone To Control"
        case 1:
            selectLabel.text = "Select Category To Control"
        default:
            break;
        }
    }
    
    @IBAction func fullScreen(sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func reload(sender: UIButton) {
        refreshVisibleDevicesInScrollView()
        sender.rotate(1)
    }
    
    @IBAction func location(sender: AnyObject) {
        
    }
}
