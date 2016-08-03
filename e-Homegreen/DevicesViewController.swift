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
import AudioToolbox


class DevicesViewController: PopoverVC, UIGestureRecognizerDelegate{
    
    var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
    let reuseIdentifier = "deviceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var scrollView = FilterPullDown()
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
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRectMake(0, 0, CGFloat.max, 44))
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    @IBOutlet weak var indicatorGreen: UIView!
    @IBOutlet weak var indicatorRed: UIView!
    
    //Zone and category control
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var zoneCategoryControl: UISegmentedControl!
    @IBOutlet weak var zoneAndCategorySlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        deviceCollectionView.delaysContentTouches = false
        deviceCollectionView.delegate = self
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
        
        zoneAndCategorySlider.continuous = false        
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Devices", subtitle: "All, All, All")
        
        bottomView.hidden = true
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DevicesViewController.panView(_:)))
        panRecognizer.delegate = self
        bottomView.addGestureRecognizer(panRecognizer)
        
        // Initialize Indicators
        indicatorRed.layer.cornerRadius = indicatorRed.frame.size.width/2
        indicatorGreen.layer.cornerRadius = indicatorRed.frame.size.width/2
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.Devices)
    }
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
    override func viewDidAppear(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        
        deviceCollectionView.reloadData()
        addObservers()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.refreshVisibleDevicesInScrollView()
        }
        appDel.setFilterBySSIDOrByiBeaconAgain()
    }
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        deviceCollectionView.reloadData()
        
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    override func nameAndId(name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
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
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func changeFullScreeenImage(){
        if UIApplication.sharedApplication().statusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        }
    }
    
    func defaultFilter(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            scrollView.setDefaultFilterItem(Menu.Devices)
        }
    }

    func refreshLocalParametars () {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
//        updateDeviceList()
        deviceCollectionView.reloadData()
    }
    

    func updateSubtitle(location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Devices", subtitle: location + ", " + level + ", " + zone)
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
    
    func updateDeviceList (user:User) {
        let fetchRequest = NSFetchRequest(entityName: String(Device))
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
        predicateArray.append(NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true)))
        predicateArray.append(NSPredicate(format: "isVisible == %@", NSNumber(bool: true)))
        
        // Filtering out PC devices
        predicateArray.append(NSPredicate(format: "type != %@", ControlType.PC))
        
        // Filtering by parametars from filter
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
            
            // filter Curtain devices that are, actually, one device
            
            // All curtains
            let curtainDevices = devices.filter({$0.controlType == ControlType.Curtain || $0.controlType == ControlType.CurtainsRelay})
            if curtainDevices.count > 0{
                for i in 0...curtainDevices.count-1{
                    if i+1 < curtainDevices.count{ // if next exist
                        for j in i+1...curtainDevices.count-1{
                            if (curtainDevices[i].address == curtainDevices[j].address
                                && curtainDevices[i].controlType == curtainDevices[j].controlType
                                && curtainDevices[i].isCurtainModeAllowed.boolValue
                                && curtainDevices[j].isCurtainModeAllowed.boolValue
                                && curtainDevices[i].curtainGroupID == curtainDevices[j].curtainGroupID) {
                                
                                if let indexOfDeviceToBeNotShown = devices.indexOf(curtainDevices[j]){
                                    devices.removeAtIndex(indexOfDeviceToBeNotShown)
                                }
                            }
                        }
                    }
                }
            }
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
//        if devices[tag].controlType == ControlType.Curtain {
//// TODO: MAKE (REVISE) FUNCTIONALITY
//            if gestureRecognizer.state == UIGestureRecognizerState.Began {
//                longTouchOldValue = Int(devices[tag].currentValue)
//                deviceInControlMode = true
//                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(DevicesViewController.updateCurtain(_:)), userInfo: tag, repeats: true)
//            }
//            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
//                longTouchOldValue = 0
//                let deviceGroupId = devices[tag].curtainGroupID.integerValue
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: UInt8(Int(self.devices[tag].currentValue)), groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.longTouchOldValue)
//                    })
//                })
//                timer.invalidate()
//                deviceInControlMode = false
//                if devices[tag].opening == true {
//                    devices[tag].opening = false
//                }else {
//                    devices[tag].opening = true
//                }
//                return
//            }
//        }
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
                setDeviceValue = 0xFF
                skipLevel = UInt8(Int(self.devices[tag].skipState))
            }
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)/255*100
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
//        // Curtain?
//        if devices[tag].controlType == ControlType.Curtain {
//            var setDeviceValue:UInt8 = 0
//            if Int(devices[tag].currentValue) > 0 {
//                setDeviceValue = UInt8(0)
//            } else {
//                setDeviceValue = UInt8(100)
//            }
//            let deviceCurrentValue = Int(devices[tag].currentValue)
//            devices[tag].currentValue = Int(setDeviceValue)
//            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
//            let deviceGroupId = devices[tag].curtainGroupID.integerValue
//            dispatch_async(dispatch_get_main_queue(), {
//                _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
//            })
//        }
        updateCells()
    }
    
    func openCurtain(gestureRecognizer:UITapGestureRecognizer){
        // Light
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        
        if devices[tag].controlType == ControlType.Curtain {
            var setDeviceValue:UInt8 = 0xFF
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)/255*100
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceGroupId = devices[tag].curtainGroupID.integerValue
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
            })
        }
        updateCells()
    }
    func closeCurtain(gestureRecognizer:UITapGestureRecognizer){
        // Light
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        
        if devices[tag].controlType == ControlType.Curtain {
            var setDeviceValue:UInt8 = 0x00
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)/255*100
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceGroupId = devices[tag].curtainGroupID.integerValue
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
            })
        }
        updateCells()
    }
    func stopCurtain(gestureRecognizer:UITapGestureRecognizer){
        // Light
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        
        if devices[tag].controlType == ControlType.Curtain {
            var setDeviceValue:UInt8 = 0xEF
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)*100/255
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceGroupId = devices[tag].curtainGroupID.integerValue
            dispatch_async(dispatch_get_main_queue(), {
                _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
            })
        }
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
            var deviceValue = Double(devices[tag].currentValue)
            if devices[tag].opening == true{
                if deviceValue < 100 {
                    deviceValue += 5
                }
            } else {
                if deviceValue >= 5 {
                    deviceValue -= 5
                }
            }
            devices[tag].currentValue = Int(deviceValue) //*100)
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                //                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.picture.image = devices[tag].returnImage(Double(deviceValue)) //*100))
                cell.lightSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                cell.curtainImage.image = devices[tag].returnImage(Double(deviceValue))//*100))
                cell.setNeedsDisplay()
            }
        }
    }
    
    func updateCurtain(timer: NSTimer){
        if let tag = timer.userInfo as? Int {
            var deviceValue = Double(devices[tag].currentValue)///100
            if devices[tag].opening == true{
                if deviceValue < 100 {
                    deviceValue += 20
                }
            } else {
                if deviceValue >= 20 {
                    deviceValue -= 20
                }
            }
            devices[tag].currentValue = Int(deviceValue)//*100)
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? DeviceCollectionCell {
                //                cell.picture.image = ImageHandler.returnPictures(Int(devices[tag].categoryId), deviceValue: Double(deviceValue), motionSensor: false)
                cell.picture.image = devices[tag].returnImage(Double(deviceValue))//*100))
                cell.lightSlider.value = Float(deviceValue)
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
                cell.curtainImage.image = devices[tag].returnImage(Double(deviceValue))//*100))
                cell.setNeedsDisplay()
            }
        }
    }

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
// TODO: MAKE (REVISE) FUNCTIONALITY
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
// TODO: MAKE (REVISE) FUNCTIONALITY
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
            let deviceGroupId = devices[tag].curtainGroupID.integerValue
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    _ = RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, value: UInt8(Int(self.devices[tag].currentValue)), groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: withOldValue)
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
                return Double(devices[tag].currentValue)
//                if Int(devices[tag].currentValue) > 100 {
//                    return Double(Double(devices[tag].currentValue)/255)
//                } else {
//                    return Double(devices[tag].currentValue)/100
//                }
            }()
            cell.picture.image = devices[tag].returnImage(Double(deviceValue))//*100))
            cell.lightSlider.value = Float(deviceValue)
            cell.setNeedsDisplay()
        } else if let cell = self.deviceCollectionView.cellForItemAtIndexPath(indexPath) as? CurtainCollectionCell {
            let deviceValue:Double = {
                return Double(Int(devices[tag].currentValue))
//                if Int(devices[tag].currentValue) > 100 {
//                    return Double(Double(devices[tag].currentValue)/255)
//                } else {
//                    return Double(devices[tag].currentValue)/100
//                }
            }()
            cell.curtainImage.image = devices[tag].returnImage(Double(deviceValue))//*100))
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
            return "\(device.gateway.location.name!) \(DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location)) \(DatabaseHandler.returnZoneWithId(Int(device.zoneId), location: device.gateway.location)) \(device.name)"
        }
    }
    
    //MARK: Zone and category controll
    
    //gesture delegate function
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
    
    
    // Controll zone and category
    // Pull up menu. Setting elements which need to be presented.
    
    func checkZoneAndCategoryFromFilter(filterParametar: FilterItem){
        bottomView.hidden = true
        if filterParametar.locationObjectId != "All"{
            zoneCategoryControl.removeAllSegments()
            if filterParametar.zoneObjectId != "All"{
                zoneCategoryControl.insertSegmentWithTitle("Zone", atIndex: zoneCategoryControl.numberOfSegments, animated: false)
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                    if zone.allowOption.integerValue == TypeOfControl.Allowed.rawValue || zone.allowOption.integerValue == TypeOfControl.Confirm.rawValue {
                        bottomView.hidden = false
                        zoneCategoryControl.setEnabled(true, forSegmentAtIndex: zoneCategoryControl.numberOfSegments-1)
                        zoneCategoryControl.selectedSegmentIndex = zoneCategoryControl.numberOfSegments-1
                    }
                }
            }
            
            if filterParametar.categoryObjectId != "All"{
                zoneCategoryControl.insertSegmentWithTitle("Category", atIndex: zoneCategoryControl.numberOfSegments, animated: false)
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                    if category.allowOption.integerValue == TypeOfControl.Allowed.rawValue || category.allowOption.integerValue == TypeOfControl.Confirm.rawValue {
                        bottomView.hidden = false
                        zoneCategoryControl.setEnabled(true, forSegmentAtIndex: zoneCategoryControl.numberOfSegments-1)
                        zoneCategoryControl.selectedSegmentIndex = zoneCategoryControl.numberOfSegments-1
                    }
                }
            }
        }else{
            bottomView.hidden = true
        }
    }
    
    @IBAction func zoneCategoryControlSlider(sender: UISlider) {
        let sliderValue = Int(sender.value)
        
        if let title = zoneCategoryControl.titleForSegmentAtIndex(zoneCategoryControl.selectedSegmentIndex){
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All"{
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                        if zone.allowOption.integerValue == TypeOfControl.Allowed.rawValue{
                            ZoneAndCategoryControl.shared.changeValueByZone(filterParametar.zoneId, location: filterParametar.location, value: sliderValue)
                        }else if zone.allowOption.integerValue == TypeOfControl.Confirm.rawValue {
                            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to proced with this control?", preferredStyle: .ActionSheet)
                            
                            let okAction = UIAlertAction(title: "YES", style: .Default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                
                                ZoneAndCategoryControl.shared.changeValueByZone(self.filterParametar.zoneId, location: self.filterParametar.location, value: sliderValue)
                                
                            })
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                                (alert: UIAlertAction!) -> Void in
                                print("Cancelled")
                            })
                            
                            if let presentationController = optionMenu.popoverPresentationController {
                                presentationController.sourceView = sender
                                presentationController.sourceRect = sender.bounds
                            }
                            
                            optionMenu.addAction(okAction)
                            optionMenu.addAction(cancelAction)
                            self.presentViewController(optionMenu, animated: true, completion: nil)
                        }
                    }
                    
                }
            }else if title == "Category"{
                if filterParametar.categoryObjectId != "All"{
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                        if category.allowOption.integerValue == TypeOfControl.Allowed.rawValue{
                            ZoneAndCategoryControl.shared.changeValueByCategory(filterParametar.zoneId, location: filterParametar.location, value: sliderValue)
                        }else if category.allowOption.integerValue == TypeOfControl.Confirm.rawValue {
                            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to proced with this control?", preferredStyle: .ActionSheet)
                            
                            let okAction = UIAlertAction(title: "YES", style: .Default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                
                                ZoneAndCategoryControl.shared.changeValueByCategory(self.filterParametar.zoneId, location: self.filterParametar.location, value: sliderValue)
                                
                            })
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                                (alert: UIAlertAction!) -> Void in
                                print("Cancelled")
                            })
                            
                            if let presentationController = optionMenu.popoverPresentationController {
                                presentationController.sourceView = sender
                                presentationController.sourceRect = sender.bounds
                            }
                            
                            optionMenu.addAction(okAction)
                            optionMenu.addAction(cancelAction)
                            self.presentViewController(optionMenu, animated: true, completion: nil)
                        }
                    }
                    
                }
            }else{
                // nothing
            }
        }
    }

    @IBAction func on(sender: AnyObject) {
        if let title = zoneCategoryControl.titleForSegmentAtIndex(zoneCategoryControl.selectedSegmentIndex){
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All"{
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                        if zone.allowOption.integerValue == TypeOfControl.Allowed.rawValue{
                            ZoneAndCategoryControl.shared.turnOnByZone(filterParametar.zoneId, location: filterParametar.location)
                        }else if zone.allowOption.integerValue == TypeOfControl.Confirm.rawValue {
                            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to proced with this control?", preferredStyle: .ActionSheet)
                            
                            let okAction = UIAlertAction(title: "YES", style: .Default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                
                                ZoneAndCategoryControl.shared.turnOnByZone(self.filterParametar.zoneId, location: self.filterParametar.location)
                                
                            })
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                                (alert: UIAlertAction!) -> Void in
                                print("Cancelled")
                            })
                            
                            if let presentationController = optionMenu.popoverPresentationController {
                                presentationController.sourceView = sender as? UIView
                                presentationController.sourceRect = sender.bounds
                            }
                            
                            optionMenu.addAction(okAction)
                            optionMenu.addAction(cancelAction)
                            self.presentViewController(optionMenu, animated: true, completion: nil)
                        }
                    }
                    
                }
            }else if title == "Category"{
                if filterParametar.categoryObjectId != "All"{
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                        if category.allowOption.integerValue == TypeOfControl.Allowed.rawValue{
                            ZoneAndCategoryControl.shared.turnOnByCategory(filterParametar.categoryId, location: filterParametar.location)
                        }else if category.allowOption.integerValue == TypeOfControl.Confirm.rawValue {
                            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to proced with this control?", preferredStyle: .ActionSheet)
                            
                            let okAction = UIAlertAction(title: "YES", style: .Default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                
                                ZoneAndCategoryControl.shared.turnOnByCategory(self.filterParametar.categoryId, location: self.filterParametar.location)
                                
                            })
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                                (alert: UIAlertAction!) -> Void in
                                print("Cancelled")
                            })
                            
                            if let presentationController = optionMenu.popoverPresentationController {
                                presentationController.sourceView = sender as? UIView
                                presentationController.sourceRect = sender.bounds
                            }
                            
                            optionMenu.addAction(okAction)
                            optionMenu.addAction(cancelAction)
                            self.presentViewController(optionMenu, animated: true, completion: nil)
                        }
                    }
                    
                }
            }else{
                //nothing
            }
        }
    }
    
    @IBAction func off(sender: AnyObject) {
        if let title = zoneCategoryControl.titleForSegmentAtIndex(zoneCategoryControl.selectedSegmentIndex){
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All"{
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                        if zone.allowOption.integerValue == TypeOfControl.Allowed.rawValue{
                            ZoneAndCategoryControl.shared.turnOffByZone(filterParametar.zoneId, location: filterParametar.location)
                        }else if zone.allowOption.integerValue == TypeOfControl.Confirm.rawValue {
                            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to proced with this control?", preferredStyle: .ActionSheet)
                            
                            let okAction = UIAlertAction(title: "YES", style: .Default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                
                                ZoneAndCategoryControl.shared.turnOffByZone(self.filterParametar.zoneId, location: self.filterParametar.location)
                                
                            })
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                                (alert: UIAlertAction!) -> Void in
                                print("Canceled")
                            })
                            
                            if let presentationController = optionMenu.popoverPresentationController {
                                presentationController.sourceView = sender as? UIView
                                presentationController.sourceRect = sender.bounds
                            }
                            
                            optionMenu.addAction(okAction)
                            optionMenu.addAction(cancelAction)
                            self.presentViewController(optionMenu, animated: true, completion: nil)
                        }
                    }
                    
                }
            }else if title == "Category"{
                if filterParametar.categoryObjectId != "All"{
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                        if category.allowOption.integerValue == TypeOfControl.Allowed.rawValue{
                            ZoneAndCategoryControl.shared.turnOffByCategory(filterParametar.categoryId, location: filterParametar.location)
                        }else if category.allowOption.integerValue == TypeOfControl.Confirm.rawValue {
                            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to proced with this control?", preferredStyle: .ActionSheet)
                            
                            let okAction = UIAlertAction(title: "YES", style: .Default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                
                                ZoneAndCategoryControl.shared.turnOffByCategory(self.filterParametar.categoryId, location: self.filterParametar.location)
                                
                            })
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                                (alert: UIAlertAction!) -> Void in
                                print("Cancelled")
                            })
                            
                            if let presentationController = optionMenu.popoverPresentationController {
                                presentationController.sourceView = sender as? UIView
                                presentationController.sourceRect = sender.bounds
                            }
                            
                            optionMenu.addAction(okAction)
                            optionMenu.addAction(cancelAction)
                            self.presentViewController(optionMenu, animated: true, completion: nil)
                        }
                    }
                    
                }
            }else{
                // nothing
            }
        }
    }

    @IBAction func changeZoneCategory(sender: UISegmentedControl) {
        if let title = zoneCategoryControl.titleForSegmentAtIndex(zoneCategoryControl.selectedSegmentIndex){
            if title == "Zone" {
                selectLabel.text = "Selected Zone:" + filterParametar.zoneName
            }else if title == "Category"{
                selectLabel.text = "Selected Category:" + filterParametar.categoryName
            }else{
                // nothing
            }
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
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }

        }
    }
    
    @IBAction func reload(sender: UIButton) {
        refreshVisibleDevicesInScrollView()
        sender.rotate(1)
    }
    
    @IBAction func location(sender: AnyObject) {
        
    }
}

extension DevicesViewController: SWRevealViewControllerDelegate{
    
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
}

// Parametar from filter and relaod data
extension DevicesViewController: FilterPullDownDelegate{
    
    // Function is called when filter is defined
    func filterParametars(filterItem: FilterItem){
        filterParametar = filterItem
        
        // Update the subtitle in navigation in order for user to see what filter parameters are selected.
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        // Saves filter to database for later
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.Devices)
        
        checkZoneAndCategoryFromFilter(filterItem)
        
        if let user = userLogged{
            updateDeviceList(user)
            deviceCollectionView.reloadData()
            fetchDevicesInBackground()
        }
        
    }
}
