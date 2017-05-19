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


class DevicesViewController: PopoverVC{
    
    var sectionInsets = UIEdgeInsets(top: 25, left: 0, bottom: 20, right: 0)
    let reuseIdentifier = "deviceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var scrollView = FilterPullDown()
    var isScrolling:Bool = false
    var shouldUpdate:Bool = false
    
    var deviceInControlMode = false
    var userLogged:User?
    
    //zone and category control
    var panRecognizer:UIPanGestureRecognizer!
    var panStartPoint:CGPoint!
    var startingBottomConstraint:CGFloat?
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    var changeSliderValueOldValue = 0
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
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
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        deviceCollectionView.delaysContentTouches = false
        deviceCollectionView.delegate = self
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
        
        zoneAndCategorySlider.isContinuous = false        
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Devices", subtitle: "All All All")
        
        bottomView.isHidden = true
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DevicesViewController.panView(_:)))
        panRecognizer.delegate = self
        bottomView.addGestureRecognizer(panRecognizer)
        
        zoneAndCategorySlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.changeGroupSliderValueOnOneTap(_:))))
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.devices)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DevicesViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerDevices), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.revealViewController().panGestureRecognizer().delegate = self
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            
            revealViewController().rearViewRevealWidth = 200
            
        }
        
        deviceCollectionView.isUserInteractionEnabled = true
        
        if AdminController.shared.isAdminLogged(){
            if let user = DatabaseUserController.shared.getOtherUser(){
                userLogged = user
                updateDeviceList(user)
            } else {
                devices = []
            }
            deviceCollectionView.reloadData()
        }else{
            if let user = DatabaseUserController.shared.getLoggedUser(){
                userLogged = user
                updateDeviceList(user)
            } else {
                devices = []
            }
            deviceCollectionView.reloadData()
        }
        
        changeFullScreeenImage()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        
        addObservers()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.refreshVisibleDevicesInScrollView()
        }
//        appDel.setFilterBySSIDOrByiBeaconAgain()
    }
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        deviceCollectionView.reloadData()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(DevicesViewController.refreshDeviceList), name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DevicesViewController.refreshVisibleDevicesInScrollView), name: NSNotification.Name(rawValue: NotificationKey.DidRefreshDeviceInfo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DevicesViewController.refreshLocalParametars), name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidRefreshDeviceInfo), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            scrollView.setDefaultFilterItem(Menu.devices)
        }
    }
    func refreshLocalParametars () {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
//        updateDeviceList()
        deviceCollectionView.reloadData()
    }

    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Devices", subtitle: location + " " + level + " " + zone)
    }

    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Device)
    
    func updateDeviceList (_ user:User) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
        predicateArray.append(NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool)))
        predicateArray.append(NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool)))
        
        // Filtering out PC devices
        predicateArray.append(NSPredicate(format: "type != %@", ControlType.PC))
        
        // Filtering by parametars from filter
        if filterParametar.location != "All" {
            predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location))
        }
        if filterParametar.levelId != 0 && filterParametar.levelId != 255{
            predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int)))
        }
        if filterParametar.zoneId != 0 && filterParametar.zoneId != 255{
            predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int)))
        }
        if filterParametar.categoryId != 0 && filterParametar.categoryId != 255{
            predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int)))
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Device]
            devices = fetResults!.map({$0})
            
            // filter Curtain devices that are, actually, one device
            
            // All curtains
            let curtainDevices = devices.filter({$0.controlType == ControlType.Curtain})
            if curtainDevices.count > 0{
                for i in 0...curtainDevices.count-1{
                    if i+1 < curtainDevices.count{ // if next exist
                        for j in i+1...curtainDevices.count-1{
                            if (curtainDevices[i].address == curtainDevices[j].address
                                && curtainDevices[i].controlType == curtainDevices[j].controlType
                                && curtainDevices[i].isCurtainModeAllowed.boolValue
                                && curtainDevices[j].isCurtainModeAllowed.boolValue
                                && curtainDevices[i].curtainGroupID == curtainDevices[j].curtainGroupID) {
                                
                                if let indexOfDeviceToBeNotShown = devices.index(of: curtainDevices[j]){
                                    devices.remove(at: indexOfDeviceToBeNotShown)
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
            print("Unresolved error \(String(describing: error)), \(error!.userInfo)")
        }
    }

    func setACPowerStatus(_ gesture:UIGestureRecognizer) {
        let tag = gesture.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        if devices[tag].currentValue == 0x00 {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: UInt8(Int(devices[tag].channel)), status: 0xFF), gateway: devices[tag].gateway)
        }
        if devices[tag].currentValue == 0xFF {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: UInt8(Int(devices[tag].channel)), status: 0x00), gateway: devices[tag].gateway)
        }
    }
    func cellParametarLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: deviceCollectionView)
            if let index = deviceCollectionView.indexPathForItem(at: location){
                if devices[(index as NSIndexPath).row].controlType == ControlType.Dimmer {
                    showDimmerParametar(tag, devices: devices)
                }
                else if devices[(index as NSIndexPath).row].controlType == ControlType.Relay {
                    showRelayParametar(tag, devices: devices)
                }else if devices[(index as NSIndexPath).row].controlType == ControlType.Curtain {
                    showRelayParametar(tag, devices: devices)
                }else{
                    showIntelligentSwitchParameter(tag, devices: devices)
                }
            }
        }
    }
    
    func longTouch(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // Light
        let tag = gestureRecognizer.view!.tag
        
        if devices[tag].controlType == ControlType.Dimmer {
            if gestureRecognizer.state == UIGestureRecognizerState.began {
                
                showBigSlider(devices[tag], index: tag).delegate = self
                
            }
        }
    }
    func refreshDevice(_ sender:AnyObject) {
        if let button = sender as? UIButton {
            let tag = button.tag
            // Light
            if devices[tag].controlType == ControlType.Dimmer {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
            // Appliance?
            if devices[tag].controlType == ControlType.Relay {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
            // Curtain?
            if devices[tag].controlType == ControlType.Curtain {
                let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: devices[tag].gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: devices[tag].gateway)
            }
        }
    }
    func oneTap(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        // Light
        if devices[tag].controlType == ControlType.Dimmer {
            var setDeviceValue:UInt8 = 0
            var skipLevel:UInt8 = 0
            if Int(devices[tag].currentValue) > 0 {
                devices[tag].oldValue = devices[tag].currentValue
                setDeviceValue = UInt8(0)
                skipLevel = 0
            } else {
                if let oldVal = devices[tag].oldValue{
                    setDeviceValue = UInt8(round(oldVal.floatValue*100/255))
                }else{
                    setDeviceValue = 100
                }
                skipLevel = UInt8(Int(self.devices[tag].skipState))
            }
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = NSNumber(value: Int(setDeviceValue)*255/100)
            print("Device current value: \(deviceCurrentValue)%")
                DispatchQueue.main.async(execute: {
                _ = RepeatSendingHandler(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: setDeviceValue, delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: skipLevel), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
                })
        }
        // Appliance?
        if devices[tag].controlType == ControlType.Relay{
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            let deviceCurrentValue = Int(devices[tag].currentValue)
            var setDeviceValue:UInt8 = 0
            var skipLevel:UInt8 = 0
            if Int(devices[tag].currentValue) > 0 {
                setDeviceValue = UInt8(0)
                devices[tag].currentValue = 0
                skipLevel = 0
            } else {
                setDeviceValue = 100
                skipLevel = UInt8(Int(self.devices[tag].skipState))
            }
            devices[tag].currentValue = NSNumber(value: Int(setDeviceValue))
            DispatchQueue.main.async(execute: {
                _ = RepeatSendingHandler(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: setDeviceValue, delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: skipLevel), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
            })
        }
        updateCells()
    }
    
    func openCurtain(_ gestureRecognizer:UITapGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        let allDevices = CoreDataController.shahredInstance.fetchDevicesForGateway(devices[tag].gateway)
        var devicePair: Device? = nil
        for deviceTemp in allDevices{
            if deviceTemp.address == devices[tag].address {
                if ((devices[tag].channel.intValue == 1 && deviceTemp.channel.intValue == 3) ||
                    (devices[tag].channel.intValue == 3 && deviceTemp.channel.intValue == 1) ||
                    (devices[tag].channel.intValue == 2 && deviceTemp.channel.intValue == 4) ||
                    (devices[tag].channel.intValue == 4 && deviceTemp.channel.intValue == 2)) &&
                    deviceTemp.isCurtainModeAllowed.boolValue &&
                    devices[tag].isCurtainModeAllowed.boolValue{
                    
                    devicePair = deviceTemp
                }
            }
        }
        
        if devicePair == nil { // then this is new module, which works alone
            if devices[tag].controlType == ControlType.Curtain {
                let setDeviceValue:UInt8 = 0xFF
                let deviceCurrentValue = Int(devices[tag].currentValue)
                devices[tag].currentValue = 0xFF // We need to set this to 255 because we will always display Channel1 and 2 in devices. Not 3 or 4. And this channel needs to be ON for image to be displayed properly
                let deviceGroupId = devices[tag].curtainGroupID.intValue
                CoreDataController.shahredInstance.saveChanges()
                DispatchQueue.main.async(execute: {
                    _ = RepeatSendingHandler(byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
                })
            }
        }else{
            if devices[tag].controlType == ControlType.Curtain {
                let setDeviceValue:UInt8 = 0xFF
                let deviceCurrentValue = Int(devices[tag].currentValue)
                devices[tag].currentValue = 0xFF // We need to set this to 255 because we will always display Channel1 and 2 in devices. Not 3 or 4. And this channel needs to be ON for image to be displayed properly
                devicePair!.currentValue = 0xFF
                let deviceGroupId = devices[tag].curtainGroupID.intValue
                CoreDataController.shahredInstance.saveChanges()
                DispatchQueue.main.async(execute: {
                    _ = RepeatSendingHandler(byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
                })
            }
        }
        updateCells()
    }
    func closeCurtain(_ gestureRecognizer:UITapGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        let allDevices = CoreDataController.shahredInstance.fetchDevicesForGateway(devices[tag].gateway)
        var devicePair: Device? = nil
        for deviceTemp in allDevices{
            if deviceTemp.address == devices[tag].address {
                if ((devices[tag].channel.intValue == 1 && deviceTemp.channel.intValue == 3) ||
                    (devices[tag].channel.intValue == 3 && deviceTemp.channel.intValue == 1) ||
                    (devices[tag].channel.intValue == 2 && deviceTemp.channel.intValue == 4) ||
                    (devices[tag].channel.intValue == 4 && deviceTemp.channel.intValue == 2)) &&
                    deviceTemp.isCurtainModeAllowed.boolValue &&
                    devices[tag].isCurtainModeAllowed.boolValue{
                    
                    devicePair = deviceTemp
                }
            }
        }
        
        if devicePair == nil{
            if devices[tag].controlType == ControlType.Curtain {
                let setDeviceValue:UInt8 = 0x00
                let deviceCurrentValue = Int(devices[tag].currentValue)
                devices[tag].currentValue = 0x00
                let deviceGroupId = devices[tag].curtainGroupID.intValue
                CoreDataController.shahredInstance.saveChanges()
                updateCells()
                DispatchQueue.main.async(execute: {
                    _ = RepeatSendingHandler(byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue) // vratiti na deviceCurrentValue ovo poslednje
                })
            }
        }else{
            guard let _ = devicePair else{
                print("Error, no pair device found for curtain relay control")
                return
            }
            
            if devices[tag].controlType == ControlType.Curtain {
                let setDeviceValue:UInt8 = 0x00
                let deviceCurrentValue = Int(devices[tag].currentValue)
                devices[tag].currentValue = 0xFF// We need to set this to 255 because we will always display Channel1 and 2 in devices. Not 3 or 4.
                devicePair?.currentValue = 0
                let deviceGroupId = devices[tag].curtainGroupID.intValue
                CoreDataController.shahredInstance.saveChanges()
                updateCells()
                DispatchQueue.main.async(execute: {
                    _ = RepeatSendingHandler(byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue) // vratiti na deviceCurrentValue ovo poslednje
                })
            }
        }
        updateCells()
    }
    func stopCurtain(_ gestureRecognizer:UITapGestureRecognizer){
        // Light
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        let allDevices = CoreDataController.shahredInstance.fetchDevicesForGateway(devices[tag].gateway)
        var devicePair: Device? = nil
        for deviceTemp in allDevices{
            if deviceTemp.address == devices[tag].address {
                if ((devices[tag].channel.intValue == 1 && deviceTemp.channel.intValue == 3) ||
                    (devices[tag].channel.intValue == 3 && deviceTemp.channel.intValue == 1) ||
                    (devices[tag].channel.intValue == 2 && deviceTemp.channel.intValue == 4) ||
                    (devices[tag].channel.intValue == 4 && deviceTemp.channel.intValue == 2)) &&
                    deviceTemp.isCurtainModeAllowed.boolValue &&
                    devices[tag].isCurtainModeAllowed.boolValue{
                    
                    devicePair = deviceTemp
                }
            }
        }
        
        if devicePair == nil {
            if devices[tag].controlType == ControlType.Curtain {
                let setDeviceValue:UInt8 = 0xEF
                let deviceCurrentValue = Int(devices[tag].currentValue)
                devices[tag].currentValue = 0xEF
                let deviceGroupId = devices[tag].curtainGroupID.intValue
                CoreDataController.shahredInstance.saveChanges()
                updateCells()
                DispatchQueue.main.async(execute: {
                    _ = RepeatSendingHandler(byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
                })
            }
        }else{
            if devices[tag].controlType == ControlType.Curtain {
                let setDeviceValue:UInt8 = 0xEF
                let deviceCurrentValue = Int(devices[tag].currentValue)
                devices[tag].currentValue = 0x00
                devicePair?.currentValue = 0x00
                let deviceGroupId = devices[tag].curtainGroupID.intValue
                CoreDataController.shahredInstance.saveChanges()
                updateCells()
                DispatchQueue.main.async(execute: {
                    _ = RepeatSendingHandler(byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
                })
            }
        }
        updateCells()
    }
    
    func lockSalto(_ gestureRecognizer:UITapGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        let setDeviceValue:UInt8 = 0xFF
        let deviceCurrentValue = Int(devices[tag].currentValue)
        devices[tag].currentValue = 0
        CoreDataController.shahredInstance.saveChanges()
        DispatchQueue.main.async(execute: {
            _ = RepeatSendingHandler(byteArray: OutgoingHandler.setSaltoAccessMode(address, lockId: self.devices[tag].channel.intValue, mode: 3), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
        })
        updateCells()
    }
    func unlockSalto(_ gestureRecognizer:UITapGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        let setDeviceValue:UInt8 = 0xFF
        let deviceCurrentValue = Int(devices[tag].currentValue)
        devices[tag].currentValue = 1
        CoreDataController.shahredInstance.saveChanges()
        DispatchQueue.main.async(execute: {
            _ = RepeatSendingHandler(byteArray: OutgoingHandler.setSaltoAccessMode(address, lockId: self.devices[tag].channel.intValue, mode: 2), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
        })
        updateCells()
    }
    
    func thirdFcnSalto(_ gestureRecognizer:UITapGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        let setDeviceValue:UInt8 = 0xFF
        let deviceCurrentValue = Int(devices[tag].currentValue)
        devices[tag].currentValue = 0
        CoreDataController.shahredInstance.saveChanges()
        DispatchQueue.main.async(execute: {
            _ = RepeatSendingHandler(byteArray: OutgoingHandler.setSaltoAccessMode(address, lockId: self.devices[tag].channel.intValue, mode: 1), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: deviceCurrentValue)
        })
        updateCells()
    }
    
    //    This has to be done, because we dont receive updates immmediately from gateway
    func updateCells() {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell {
                cell.refreshDevice(devices[(indexPath as NSIndexPath).row])
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell {
                cell.refreshDevice(devices[(indexPath as NSIndexPath).row])
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? MultiSensorCell {
                cell.refreshDevice(devices[(indexPath as NSIndexPath).row])
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? ClimateCell {
                cell.refreshDevice(devices[(indexPath as NSIndexPath).row])
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? ApplianceCollectionCell {
                cell.refreshDevice(devices[(indexPath as NSIndexPath).row])
                cell.setNeedsDisplay()
            }else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? SaltoAccessCell {
                cell.refreshDevice(devices[(indexPath as NSIndexPath).row])
                cell.setNeedsDisplay()
            }
        }
    }
    func calculateCellSize(_ size:inout CGSize) {
        var i:CGFloat = 2
        while i >= 2 {
            if (self.view.frame.size.width / i) >= 120 && (self.view.frame.size.width / i) <= 160 {
                break
            }
            i += 1
        }
        let const = (2/i + (i*5-5)/i)
        let cellWidth = Int(self.view.frame.size.width/i - const)
        size = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
    }
    
    func handleTap (_ gesture:UIGestureRecognizer) {
        let location = gesture.location(in: deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItem(at: location){
            if devices[(index as NSIndexPath).row].controlType == ControlType.Dimmer {
                let cell = deviceCollectionView.cellForItem(at: index) as! DeviceCollectionCell
                UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews] , completion: nil)
            } else if devices[(index as NSIndexPath).row].controlType == ControlType.Relay {
                let cell = deviceCollectionView.cellForItem(at: index) as! ApplianceCollectionCell
                UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews] , completion: nil)
            } else if devices[(index as NSIndexPath).row].controlType == ControlType.Sensor || devices[(index as NSIndexPath).row].controlType == ControlType.IntelligentSwitch || devices[(index as NSIndexPath).row].controlType == ControlType.Gateway {
                let cell = deviceCollectionView.cellForItem(at: index) as! MultiSensorCell
                UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews] , completion: nil)
            } else if devices[(index as NSIndexPath).row].controlType == ControlType.Climate {
                let cell = deviceCollectionView.cellForItem(at: index) as! ClimateCell
                UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews] , completion: nil)
            } else if devices[(index as NSIndexPath).row].controlType == ControlType.Curtain {
// TODO: MAKE (REVISE) FUNCTIONALITY
                let cell = deviceCollectionView.cellForItem(at: index) as! CurtainCollectionCell
                UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews] , completion: nil)
            }
            
            devices[(index as NSIndexPath).row].info = true
        }
    }
    func handleTap2 (_ gesture:UIGestureRecognizer) {
        let location = gesture.location(in: deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItem(at: location){
            if devices[(index as NSIndexPath).row].controlType == ControlType.Dimmer {
                let cell = deviceCollectionView.cellForItem(at: index) as! DeviceCollectionCell
                UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews], completion: nil)
            } else if devices[(index as NSIndexPath).row].controlType == ControlType.Relay {
                let cell = deviceCollectionView.cellForItem(at: index) as! ApplianceCollectionCell
                UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews], completion: nil)
            } else if devices[(index as NSIndexPath).row].controlType == ControlType.Sensor || devices[(index as NSIndexPath).row].controlType == ControlType.IntelligentSwitch || devices[(index as NSIndexPath).row].controlType == ControlType.Gateway {
                let cell = deviceCollectionView.cellForItem(at: index) as! MultiSensorCell
                UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews], completion: nil)
            } else if devices[(index as NSIndexPath).row].controlType == ControlType.Climate {
                let cell = deviceCollectionView.cellForItem(at: index) as! ClimateCell
                UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews], completion: nil)
            } else if devices[(index as NSIndexPath).row].controlType == ControlType.Curtain {
// TODO: MAKE (REVISE) FUNCTIONALITY
                let cell = deviceCollectionView.cellForItem(at: index) as! CurtainCollectionCell
                UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.transitionFlipFromBottom, UIViewAnimationOptions.showHideTransitionViews], completion: nil)
            }
            devices[(index as NSIndexPath).row].info = false
        }
    }
    
    func changeSliderValueOnOneTap (_ gesture:UIGestureRecognizer) {
        if let slider = gesture.view as? UISlider {
            deviceInControlMode = false
            if slider.isHighlighted {
                changeSliderValueEnded(slider)
                return
            }
            let sliderOldValue = slider.value*100
            let pt = gesture.location(in: slider)
            let percentage = pt.x/slider.bounds.size.width
            let delta = Float(percentage) * Float(slider.maximumValue - slider.minimumValue)
            let value = round((slider.minimumValue + delta)*255)
            if !((value/255) >= 0 && (value/255) <= 255) {
                return
            }
            slider.setValue(value/255, animated: true)
            let tag = slider.tag
            devices[tag].oldValue = devices[tag].currentValue
            devices[tag].currentValue = NSNumber(value: Int(value))
            let indexPath = IndexPath(item: tag, section: 0)
            if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell {
                cell.picture.image = devices[tag].returnImage(Double(value))
                cell.lightSlider.value = slider.value
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell {
                cell.setImageForDevice(devices[tag])
                cell.setNeedsDisplay()
            }
            changeSliderValueWithTag(tag, withOldValue: Int(sliderOldValue))
        }
    }
    func changeSliderValueWithTag(_ tag:Int, withOldValue:Int) {
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]

        deviceInControlMode = false
        //   Dimmer
        if devices[tag].controlType == ControlType.Dimmer {
            let setValue = UInt8(Int(self.devices[tag].currentValue.doubleValue*100/255))
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                DispatchQueue.main.async(execute: {
                    _ = RepeatSendingHandler(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: setValue, delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: withOldValue)
                })
            })
        }
        //  Curtain
        if devices[tag].controlType == ControlType.Curtain {
            let deviceGroupId = devices[tag].curtainGroupID.intValue
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                DispatchQueue.main.async(execute: {
                    _ = RepeatSendingHandler(byteArray: OutgoingHandler.setCurtainStatus(address, value: UInt8(Int(self.devices[tag].currentValue)), groupId:  UInt8(deviceGroupId)), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: withOldValue)
                })
            })
        }
    }
    func changeSliderValueStarted (_ sender: UISlider) {
        let tag = sender.tag
        deviceInControlMode = true
        changeSliderValueOldValue = Int(devices[tag].currentValue)
    }
    func changeSliderValueEnded (_ sender:UISlider) {
        let tag = sender.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        //   Dimmer
        let v = self.devices[tag].currentValue.doubleValue
        let v2 = v*100/255
        let v3 = Int(v2)
        let v4 = UInt8(v3)
        
        
        if devices[tag].controlType == ControlType.Dimmer {
            DispatchQueue.main.async(execute: {
                _ = RepeatSendingHandler(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(self.devices[tag].channel)), value: UInt8(v4), delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: UInt8(Int(self.devices[tag].skipState))), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.changeSliderValueOldValue)
            })
        }
        //  Curtain
        if devices[tag].controlType == ControlType.Curtain {
            DispatchQueue.main.async(execute: {
                _ = RepeatSendingHandler(byteArray: OutgoingHandler.setCurtainStatus(address, value: UInt8(Int(self.devices[tag].currentValue)), groupId:  0x00), gateway: self.devices[tag].gateway, device: self.devices[tag], oldValue: self.changeSliderValueOldValue)
            })
        }
        changeSliderValueOldValue = 0
        deviceInControlMode = false
    }
    
    func changeSliderValue(_ sender: UISlider){
        let tag = sender.tag
        devices[tag].currentValue = NSNumber(value: Int(sender.value * 255))   // device values is Int, 0 to 255 (0x00 to 0xFF)
        
        let indexPath = IndexPath(item: tag, section: 0)
        if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell {
            let deviceValue:Double = {
                return Double(Double(devices[tag].currentValue))
            }()
            cell.picture.image = devices[tag].returnImage(Double(deviceValue))
            cell.lightSlider.value = Float(deviceValue/255) // Slider value accepts values from 0 to 1
            cell.setNeedsDisplay()
        } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell {
            cell.setImageForDevice(devices[tag])
            cell.setNeedsDisplay()
        }
    }
    func refreshDeviceList() {
        if !deviceInControlMode {
            if isScrolling {
                shouldUpdate = true
            } else {
                self.updateCells()
            }
        }
    }
    
    //MARK: Setting names for devices according to filter
    func returnNameForDeviceAccordingToFilter (_ device:Device) -> String {
        if filterParametar.location != "All" {
            if filterParametar.levelId != 0 && filterParametar.levelId != 255{
                if filterParametar.zoneId != 0 && filterParametar.zoneId != 255{
                    return "\(device.name)"
                } else {
                    if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.zoneId), location: device.gateway.location), let name = zone.name{
                        return "\(name) \(device.name)"
                    }else{
                        return "\(device.name)"
                    }
                }
            } else {
                if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location), let name = zone.name{
                    if let zone2 = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.zoneId), location: device.gateway.location), let name2 = zone2.name {
                        return "\(name) \(name2) \(device.name)"
                    }else{
                        return "\(name) \(device.name)"
                    }
                }else{
                    return "\(device.name)"
                }
            }
        } else {
            var text = "\(device.gateway.location.name!)"
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location), let name = zone.name {
                text += " " + name
            }
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.zoneId), location: device.gateway.location), let name = zone.name {
                text += " " + name
            }
            text += " " + device.name
            return text
        }
//        return "dasd"
    }
    
    //MARK: Zone and category controll
    
    //gesture delegate function
    func panView(_ gesture:UIPanGestureRecognizer){
        switch (gesture.state) {
        case .began:
            self.panStartPoint = gesture.location(in: self.bottomView)
            self.startingBottomConstraint = self.bottomConstraint.constant
            break
        case .changed:
            let currentPoint = gesture.translation(in: self.bottomView)
            let deltaX = currentPoint.y - self.panStartPoint.y
            var panningUp = false
            if currentPoint.y < self.panStartPoint.y {
                panningUp = true
            }

            if self.startingBottomConstraint == -154 {
                
                if !panningUp{
                    if deltaX == 0{
                        self.resetConstraintContstants(true, endEditing: true)
                    }
                    
                }else{
                    if panStartPoint.x > self.bottomView.center.x - 75 && panStartPoint.x < self.bottomView.center.x + 75{
                        if deltaX < -154 {
                            self.setConstraintsToShowBottomView(true, notifyDelegate: true)
                        }else{
                            self.bottomConstraint.constant = -154 - deltaX
                        }
                    }
                }
            }else{
                if !panningUp{
                    if -deltaX > -154{
                        self.bottomConstraint.constant = -deltaX
                    }else{
                        self.resetConstraintContstants(true, endEditing: true)
                    }
                }else{
                    if deltaX <= 0{
                        self.setConstraintsToShowBottomView(true, notifyDelegate: true)
                    }else{
                        self.bottomConstraint.constant = -154 - deltaX
                    }
                }
            }

            break
        case .ended:
            if self.startingBottomConstraint == -154 {
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
        case .cancelled:

            if self.startingBottomConstraint == -154 {
                self.resetConstraintContstants(true, endEditing: true)
            } else {
                self.setConstraintsToShowBottomView(true, notifyDelegate: true)
            }
            break
        default:
            break
        }
        
    }
    
    func resetConstraintContstants(_ animated:Bool, endEditing:Bool){
        if self.startingBottomConstraint == -154 &&
            self.bottomConstraint.constant == -154 {
            return
        }
        self.bottomConstraint.constant = -154
        
        self.updateConstraintsIfNeeded(animated, completion: { (finished) -> Void in
            self.bottomConstraint.constant = -154
            
            self.updateConstraintsIfNeeded(animated, completion: { (finished) -> Void in
                self.startingBottomConstraint = self.bottomConstraint.constant
            })
        })
    }
    func setConstraintsToShowBottomView(_ animated:Bool, notifyDelegate:Bool){
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
    func updateConstraintsIfNeeded(_ animated:Bool, completion:@escaping (_ finished: Bool) -> Void){
        var duration:Float = 0
        if animated {
            duration = 0.1
        }
        
        UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(0), options: UIViewAnimationOptions.curveEaseOut, animations:{ self.bottomView.layoutIfNeeded() }, completion: {
            success in
            completion(success)
        })
        
    }
    
    func changeGroupSliderValueOnOneTap (_ gesture:UIGestureRecognizer) {
        let s = gesture.view as! UISlider
        if s.isHighlighted{
            return // tap on thumb, let slider deal with it
        }
        let pt:CGPoint = gesture.location(in: s)
        let percentage:CGFloat = pt.x / s.bounds.size.width
        let delta:CGFloat = percentage * (CGFloat(s.maximumValue) - CGFloat(s.minimumValue))
        let value:CGFloat = CGFloat(s.minimumValue) + delta;
        s.setValue(Float(value), animated: true)
        zoneCategoryControlSlider(zoneAndCategorySlider)
    }
    
    // Controll zone and category
    // Pull up menu. Setting elements which need to be presented.
    
    func checkZoneAndCategoryFromFilter(_ filterParametar: FilterItem){
        bottomView.isHidden = true
        if filterParametar.locationObjectId != "All"{
            zoneCategoryControl.removeAllSegments()
            if filterParametar.zoneObjectId != "All"{
                zoneCategoryControl.insertSegment(withTitle: "Zone", at: zoneCategoryControl.numberOfSegments, animated: false)
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                    if zone.allowOption.intValue == TypeOfControl.allowed.rawValue || zone.allowOption.intValue == TypeOfControl.confirm.rawValue {
                        bottomView.isHidden = false
                        zoneCategoryControl.setEnabled(true, forSegmentAt: zoneCategoryControl.numberOfSegments-1)
                        zoneCategoryControl.selectedSegmentIndex = zoneCategoryControl.numberOfSegments-1
                    }
                }
            }
            
            if filterParametar.categoryObjectId != "All"{
                zoneCategoryControl.insertSegment(withTitle: "Category", at: zoneCategoryControl.numberOfSegments, animated: false)
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                    if category.allowOption.intValue == TypeOfControl.allowed.rawValue || category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                        bottomView.isHidden = false
                        zoneCategoryControl.setEnabled(true, forSegmentAt: zoneCategoryControl.numberOfSegments-1)
                        zoneCategoryControl.selectedSegmentIndex = zoneCategoryControl.numberOfSegments-1
                    }
                }
            }
        }else{
            bottomView.isHidden = true
        }
    }
    
    
    // Helper functions
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.devices)
    }
    
    @IBAction func zoneCategoryControlSlider(_ sender: UISlider) {
        let sliderValue = Int(sender.value)
        
        if let title = zoneCategoryControl.titleForSegment(at: zoneCategoryControl.selectedSegmentIndex){
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All"{
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                        if zone.allowOption.intValue == TypeOfControl.allowed.rawValue{
                            ZoneAndCategoryControl.shared.changeValueByZone(filterParametar.zoneId, location: filterParametar.location, value: sliderValue)
                        }else if zone.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok{
                                    ZoneAndCategoryControl.shared.changeValueByZone(self.filterParametar.zoneId, location: self.filterParametar.location, value: sliderValue)
                                }
                            })
                        }
                    }
                    
                }
            }else if title == "Category"{
                if filterParametar.categoryObjectId != "All"{
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                        if category.allowOption.intValue == TypeOfControl.allowed.rawValue{
                            ZoneAndCategoryControl.shared.changeValueByCategory(filterParametar.categoryId, location: filterParametar.location, value: sliderValue)
                        }else if category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok{
                                    ZoneAndCategoryControl.shared.changeValueByCategory(self.filterParametar.zoneId, location: self.filterParametar.location, value: sliderValue)
                                }
                            })
                        }
                    }
                    
                }
            }else{
                // nothing
            }
        }
    }
    @IBAction func on(_ sender: UIButton) {
        if let title = zoneCategoryControl.titleForSegment(at: zoneCategoryControl.selectedSegmentIndex){
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All"{
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                        if zone.allowOption.intValue == TypeOfControl.allowed.rawValue{
                            ZoneAndCategoryControl.shared.turnOnByZone(filterParametar.zoneId, location: filterParametar.location)
                            self.zoneAndCategorySlider.value = 100
                        }else if zone.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok{
                                    ZoneAndCategoryControl.shared.turnOnByZone(self.filterParametar.zoneId, location: self.filterParametar.location)
                                    self.zoneAndCategorySlider.value = 100
                                }
                            })
                        }
                    }
                    
                }
            }else if title == "Category"{
                if filterParametar.categoryObjectId != "All"{
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                        if category.allowOption.intValue == TypeOfControl.allowed.rawValue{
                            ZoneAndCategoryControl.shared.turnOnByCategory(filterParametar.categoryId, location: filterParametar.location)
                            self.zoneAndCategorySlider.value = 100
                        }else if category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok{
                                    ZoneAndCategoryControl.shared.turnOnByCategory(self.filterParametar.categoryId, location: self.filterParametar.location)
                                    self.zoneAndCategorySlider.value = 100
                                }
                            })
                        }
                    }
                    
                }
            }else{
                //nothing
            }
        }
    }
    @IBAction func off(_ sender: UIButton) {
        if let title = zoneCategoryControl.titleForSegment(at: zoneCategoryControl.selectedSegmentIndex){
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All"{
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                        if zone.allowOption.intValue == TypeOfControl.allowed.rawValue{
                            ZoneAndCategoryControl.shared.turnOffByZone(filterParametar.zoneId, location: filterParametar.location)
                            self.zoneAndCategorySlider.value = 0
                        }else if zone.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok{
                                    ZoneAndCategoryControl.shared.turnOffByZone(self.filterParametar.zoneId, location: self.filterParametar.location)
                                    self.zoneAndCategorySlider.value = 0
                                }
                            })
                        }
                    }
                    
                }
            }else if title == "Category"{
                if filterParametar.categoryObjectId != "All"{
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                        if category.allowOption.intValue == TypeOfControl.allowed.rawValue{
                            ZoneAndCategoryControl.shared.turnOffByCategory(filterParametar.categoryId, location: filterParametar.location)
                            self.zoneAndCategorySlider.value = 0
                        }else if category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok{
                                    ZoneAndCategoryControl.shared.turnOffByCategory(self.filterParametar.categoryId, location: self.filterParametar.location)
                                    self.zoneAndCategorySlider.value = 0
                                }
                            })
                        }
                    }
                    
                }
            }else{
                // nothing
            }
        }
    }
    @IBAction func changeZoneCategory(_ sender: UISegmentedControl) {
        if let title = zoneCategoryControl.titleForSegment(at: zoneCategoryControl.selectedSegmentIndex){
            if title == "Zone" {
                selectLabel.text = "Selected Zone:" + filterParametar.zoneName
            }else if title == "Category"{
                selectLabel.text = "Selected Category:" + filterParametar.categoryName
            }else{
                // nothing
            }
        }
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), for: UIControlState())
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }

        }
    }
    @IBAction func reload(_ sender: UIButton) {
        refreshVisibleDevicesInScrollView()
        sender.rotate(1)
    }
    @IBAction func location(_ sender: AnyObject) {
        
    }
    
}

extension DevicesViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            deviceCollectionView.isUserInteractionEnabled = true
        } else {
            deviceCollectionView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            deviceCollectionView.isUserInteractionEnabled = true
        } else {
            deviceCollectionView.isUserInteractionEnabled = false
        }
    }
    
}

// Parametar from filter and relaod data
extension DevicesViewController: FilterPullDownDelegate{
    
    // Function is called when filter is defined
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        
        // Update the subtitle in navigation in order for user to see what filter parameters are selected.
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        // Saves filter to database for later
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.devices)
        
        checkZoneAndCategoryFromFilter(filterItem)
        
        if let user = userLogged{
            updateDeviceList(user)
            deviceCollectionView.reloadData()
            updateCells()
        }
        TimerForFilter.shared.counterDevices = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.devices)
        TimerForFilter.shared.startTimer(type: Menu.devices)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension DevicesViewController: BigSliderDelegate{
    func valueChanged(_ sender: UISlider) {
        changeSliderValue(sender)
    }
    
    func endValueChanged(_ sender: UISlider) {
        changeSliderValueEnded(sender)
    }
    
    func setONOFFDimmer(_ index:Int, turnOff:Bool){
        if devices[index].controlType == ControlType.Dimmer {
            var setDeviceValue:UInt8 = 0
            var skipLevel:UInt8 = 0
            if turnOff {
                devices[index].oldValue = devices[index].currentValue
                setDeviceValue = UInt8(0)
                skipLevel = 0
            } else {
                setDeviceValue = 100
                skipLevel = UInt8(Int(self.devices[index].skipState))
            }
            let address = [UInt8(Int(devices[index].gateway.addressOne)),UInt8(Int(devices[index].gateway.addressTwo)),UInt8(Int(devices[index].address))]
            let deviceCurrentValue = Int(devices[index].currentValue)
            devices[index].currentValue = NSNumber(value: Int(setDeviceValue)*255/100)
            DispatchQueue.main.async(execute: {
                _ = RepeatSendingHandler(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(self.devices[index].channel)), value: setDeviceValue, delay: Int(self.devices[index].delay), runningTime: Int(self.devices[index].runtime), skipLevel: skipLevel), gateway: self.devices[index].gateway, device: self.devices[index], oldValue: deviceCurrentValue)
            })
        }
    }
}
extension DevicesViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view! is UISlider{
            return false
        }
        return true
    }
}

