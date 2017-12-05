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
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Device)
    
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
        appDel = UIApplication.shared.delegate as! AppDelegate

        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DevicesViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerDevices), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        deviceCollectionView.isUserInteractionEnabled = true
        
        getUserAndUpdateDeviceList()
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    fileprivate func getUserAndUpdateDeviceList() {
        if AdminController.shared.isAdminLogged() {
            if let user = DatabaseUserController.shared.getOtherUser() { userLogged = user; updateDeviceList(user)
            } else { devices = [] }
            
        } else {
            if let user = DatabaseUserController.shared.getLoggedUser() { userLogged = user; updateDeviceList(user)
            } else { devices = [] }
            
        }
        deviceCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        
        addObservers()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.refreshVisibleDevicesInScrollView()
        }
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { deviceCollectionView.reloadData() })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDeviceList), name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshVisibleDevicesInScrollView), name: NSNotification.Name(rawValue: NotificationKey.DidRefreshDeviceInfo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocalParametars), name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCollectionView), name: NSNotification.Name(rawValue: NotificationKey.RefreshClimate), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidRefreshDeviceInfo), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshClimate), object: nil)
    }

    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            scrollView.setDefaultFilterItem(Menu.devices)
        }
    }
    
    func refreshLocalParametars () {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Device)
        deviceCollectionView.reloadData()
    }

    func cellParametarLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: deviceCollectionView)
            if let index = deviceCollectionView.indexPathForItem(at: location) {
                let controlType = devices[index.row].controlType
                
                if controlType == ControlType.Dimmer { showDimmerParametar(tag, devices: devices) }
                else if controlType == ControlType.Relay { showRelayParametar(tag, devices: devices) }
                else if controlType == ControlType.Curtain { showRelayParametar(tag, devices: devices) }
                else { showIntelligentSwitchParameter(tag, devices: devices) }
                
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
    
    func handleTap (_ gesture:UIGestureRecognizer) {
        let location = gesture.location(in: deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItem(at: location) {
            
            let controlType = devices[index.row].controlType
            let options: UIViewAnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
            
            if controlType == ControlType.Dimmer {
                if let cell = deviceCollectionView.cellForItem(at: index) as? DeviceCollectionCell {
                    UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil)
                }
                
            } else if controlType == ControlType.Relay {
                if let cell = deviceCollectionView.cellForItem(at: index) as? ApplianceCollectionCell {
                    UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil)
                }
                
            } else if controlType == ControlType.Sensor || controlType == ControlType.IntelligentSwitch || controlType == ControlType.Gateway {
                if let cell = deviceCollectionView.cellForItem(at: index) as? MultiSensorCell {
                    UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil)
                }
                
            } else if controlType == ControlType.Climate {
                if let cell = deviceCollectionView.cellForItem(at: index) as? ClimateCell {
                    UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil)
                }
                
            } else if controlType == ControlType.Curtain { // TODO: MAKE (REVISE) FUNCTIONALITY
                if let cell = deviceCollectionView.cellForItem(at: index) as? CurtainCollectionCell {
                    UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil)
                }
            }
            
            devices[index.row].info = true
        }
    }
    
    func handleTap2 (_ gesture:UIGestureRecognizer) {
        let location = gesture.location(in: deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItem(at: location) {
            
            let controlType                     = devices[index.row].controlType
            let options: UIViewAnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
            
            if controlType == ControlType.Dimmer {
                if let cell = deviceCollectionView.cellForItem(at: index) as? DeviceCollectionCell {
                    UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil)
                }
                
            } else if controlType == ControlType.Relay {
                if let cell = deviceCollectionView.cellForItem(at: index) as? ApplianceCollectionCell {
                    UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil)
                }
                
            } else if controlType == ControlType.Sensor || controlType == ControlType.IntelligentSwitch || controlType == ControlType.Gateway {
                if let cell = deviceCollectionView.cellForItem(at: index) as? MultiSensorCell {
                    UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil)
                }
                
            } else if controlType == ControlType.Climate {
                if let cell = deviceCollectionView.cellForItem(at: index) as? ClimateCell {
                    UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil)
                }
                
            } else if controlType == ControlType.Curtain { // TODO: MAKE (REVISE) FUNCTIONALITY
                if let cell = deviceCollectionView.cellForItem(at: index) as? CurtainCollectionCell {
                    UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil)
                }
            }
            devices[index.row].info = false
        }
    }
    
    func changeSliderValueOnOneTap (_ gesture:UIGestureRecognizer) {
        if let slider = gesture.view as? UISlider {
            deviceInControlMode = false
            if slider.isHighlighted { changeSliderValueEnded(slider); return }
            
            let sliderOldValue = slider.value*100
            let pt             = gesture.location(in: slider)
            let percentage     = pt.x/slider.bounds.size.width
            let delta          = Float(percentage) * Float(slider.maximumValue - slider.minimumValue)
            let value          = round((slider.minimumValue + delta)*255)
            
            if !((value/255) >= 0 && (value/255) <= 255) { return }
            
            slider.setValue(value/255, animated: true)
            let tag = slider.tag
            let indexPath = IndexPath(item: tag, section: 0)
            
            devices[tag].oldValue     = devices[tag].currentValue
            devices[tag].currentValue = NSNumber(value: Int(value))
            
            if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell {
                cell.picture.image     = devices[tag].returnImage(Double(value))
                cell.lightSlider.value = slider.value
                cell.setNeedsDisplay()
            } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell {
                cell.setImageForDevice(devices[tag]); cell.setNeedsDisplay()
            }
            changeSliderValueWithTag(tag, withOldValue: Int(sliderOldValue))
        }
    }
    func changeSliderValueWithTag(_ tag:Int, withOldValue:Int) {
        let address = [getByte(devices[tag].gateway.addressOne), getByte(devices[tag].gateway.addressTwo), getByte(devices[tag].address)]

        deviceInControlMode = false
        //   Dimmer
        if devices[tag].controlType == ControlType.Dimmer {
            let setValue = UInt8(Int(devices[tag].currentValue.doubleValue*100/255))
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: self.devices[tag].objectID,
                        newCommand: NSNumber(value: setValue),
                        oldValue: NSNumber(value: withOldValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(self.devices[tag].channel), value: setValue, delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: self.getByte(self.devices[tag].skipState)),
                        gateway: self.devices[tag].gateway,
                        device: self.devices[tag],
                        oldValue: withOldValue,
                        command: NSNumber(value: setValue)
                    )
                })
            })
        }
        //  Curtain
        if devices[tag].controlType == ControlType.Curtain {
            let deviceGroupId = devices[tag].curtainGroupID.intValue
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: self.devices[tag].objectID,
                        newCommand: self.devices[tag].currentValue,
                        oldValue: NSNumber(value: withOldValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setCurtainStatus(address, value: self.getByte(self.devices[tag].currentValue), groupId:  UInt8(deviceGroupId)),
                        gateway: self.devices[tag].gateway,
                        device: self.devices[tag],
                        oldValue: withOldValue,
                        command: self.devices[tag].currentValue
                    )
                })
            })
        }
    }
    func changeSliderValueStarted (_ sender: UISlider) {
        let tag = sender.tag
        deviceInControlMode       = true
        changeSliderValueOldValue = Int(devices[tag].currentValue)
    }
    
    func changeSliderValueEnded (_ sender:UISlider) {
        let tag         = sender.tag
        let controlType = devices[tag].controlType
        let address     = [getByte(devices[tag].gateway.addressOne), getByte(devices[tag].gateway.addressTwo), getByte(devices[tag].address)]
        //   Dimmer
        let v  = self.devices[tag].currentValue.doubleValue
        let v2 = v*100/255
        let v3 = Int(v2)
        let v4 = UInt8(v3)
        
        if controlType == ControlType.Dimmer {
            DispatchQueue.main.async(execute: {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: self.devices[tag].objectID,
                    newCommand: NSNumber(value: v4),
                    oldValue: NSNumber(value: self.changeSliderValueOldValue)
                )
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(self.devices[tag].channel), value: UInt8(v4), delay: Int(self.devices[tag].delay), runningTime: Int(self.devices[tag].runtime), skipLevel: self.getByte(self.devices[tag].skipState)),
                    gateway: self.devices[tag].gateway,
                    device: self.devices[tag],
                    oldValue: self.changeSliderValueOldValue,
                    command: NSNumber(value: v4)
                )
            })
        }
        //  Curtain
        if controlType == ControlType.Curtain {
            DispatchQueue.main.async(execute: {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: self.devices[tag].objectID,
                    newCommand: self.devices[tag].currentValue,
                    oldValue: NSNumber(value: self.changeSliderValueOldValue)
                )
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setCurtainStatus(address, value: self.getByte(self.devices[tag].currentValue), groupId:  0x00),
                    gateway: self.devices[tag].gateway,
                    device: self.devices[tag],
                    oldValue: self.changeSliderValueOldValue,
                    command: self.devices[tag].currentValue
                )
            })
        }
        changeSliderValueOldValue = 0
        deviceInControlMode = false
    }
    
    func changeSliderValue(_ sender: UISlider){
        let tag = sender.tag
        devices[tag].currentValue = NSNumber(value: Int(sender.value * 255))   // device values is Int, 0 to 255 (0x00 to 0xFF)
        
        let indexPath = IndexPath(item: tag, section: 0)
        if let cell = deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell {
            let deviceValue:Double = { return Double(Double(devices[tag].currentValue)) }()
            cell.picture.image     = devices[tag].returnImage(Double(deviceValue))
            cell.lightSlider.value = Float(deviceValue/255) // Slider value accepts values from 0 to 1
            cell.setNeedsDisplay()
        } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell {
            cell.setImageForDevice(devices[tag]); cell.setNeedsDisplay()
        }
    }
    
    func refreshDeviceList() {
        if !deviceInControlMode {
            if isScrolling { shouldUpdate = true } else { self.updateCells() }
        }
    }
    
    //MARK: Setting names for devices according to filter
    func returnNameForDeviceAccordingToFilter (_ device:Device) -> String {
        if filterParametar.location != "All" {
            if filterParametar.levelId != 0 && filterParametar.levelId != 255 {
                if filterParametar.zoneId != 0 && filterParametar.zoneId != 255 { return "\(device.name)"
                } else {
                    if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.zoneId), location: device.gateway.location), let name = zone.name { return "\(name) \(device.name)"
                    } else { return "\(device.name)" } }
                
            } else {
                if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location), let name = zone.name {
                    if let zone2 = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.zoneId), location: device.gateway.location), let name2 = zone2.name {
                        return "\(name) \(name2) \(device.name)"
                    } else { return "\(name) \(device.name)" }
                    
                } else { return "\(device.name)" } }
            
        } else {
            var text = "\(device.gateway.location.name!)"
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location), let name = zone.name { text += " " + name }
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.zoneId), location: device.gateway.location), let name = zone.name { text += " " + name }
            text += " " + device.name
            
            return text
        }

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
            if currentPoint.y < self.panStartPoint.y { panningUp = true }

            if self.startingBottomConstraint == -154 {
                
                if !panningUp { if deltaX == 0 { self.resetConstraintContstants(true, endEditing: true) } }
                else {
                    if panStartPoint.x > self.bottomView.center.x - 75 && panStartPoint.x < self.bottomView.center.x + 75 {
                        if deltaX < -154 { self.setConstraintsToShowBottomView(true, notifyDelegate: true) } else { self.bottomConstraint.constant = -154 - deltaX }
                    }
                }
                
            } else {
                if !panningUp {
                    if -deltaX > -154 { self.bottomConstraint.constant = -deltaX } else { self.resetConstraintContstants(true, endEditing: true) }
                } else {
                    if deltaX <= 0 { self.setConstraintsToShowBottomView(true, notifyDelegate: true) } else { self.bottomConstraint.constant = -154 - deltaX }
                }
            }
            
            break
            
        case .ended:
            if self.startingBottomConstraint == -154 {
                if bottomConstraint.constant >= -100 { self.setConstraintsToShowBottomView(true, notifyDelegate: true) } else { self.resetConstraintContstants(true, endEditing: true) }
                
            } else {
                if bottomConstraint.constant <= -30 { self.resetConstraintContstants(true, endEditing: true) } else { self.setConstraintsToShowBottomView(true, notifyDelegate: true) }
            }

            break
            
        case .cancelled:

            if self.startingBottomConstraint == -154 { self.resetConstraintContstants(true, endEditing: true) } else { self.setConstraintsToShowBottomView(true, notifyDelegate: true) }
            break
            
        default: break
        }
        
    }
    
    func resetConstraintContstants(_ animated:Bool, endEditing:Bool) {
        if self.startingBottomConstraint == -154 && self.bottomConstraint.constant == -154 { return }
        
        self.bottomConstraint.constant = -154
        
        self.updateConstraintsIfNeeded(animated, completion: { (finished) -> Void in
            self.bottomConstraint.constant = -154
            
            self.updateConstraintsIfNeeded(animated, completion: { (finished) -> Void in
                self.startingBottomConstraint = self.bottomConstraint.constant
            })
        })
    }
    func setConstraintsToShowBottomView(_ animated:Bool, notifyDelegate:Bool){
        if self.startingBottomConstraint == 0 && self.bottomConstraint.constant == 0 { return }
        
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
        if animated { duration = 0.1 }
        
        UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(0), options: UIViewAnimationOptions.curveEaseOut, animations:{ self.bottomView.layoutIfNeeded() }, completion: {
            success in
            completion(success)
        })
        
    }
    
    func changeGroupSliderValueOnOneTap (_ gesture:UIGestureRecognizer) {
        let s = gesture.view as! UISlider
        if s.isHighlighted { return } // tap on thumb, let slider deal with it
        let pt:CGPoint         = gesture.location(in: s)
        let percentage:CGFloat = pt.x / s.bounds.size.width
        let delta:CGFloat      = percentage * (CGFloat(s.maximumValue) - CGFloat(s.minimumValue))
        let value:CGFloat      = CGFloat(s.minimumValue) + delta;
        s.setValue(Float(value), animated: true)
        zoneCategoryControlSlider(zoneAndCategorySlider)
    }
    
    // Controll zone and category
    // Pull up menu. Setting elements which need to be presented.
    
    func checkZoneAndCategoryFromFilter(_ filterParametar: FilterItem){
        bottomView.isHidden = true
        if filterParametar.locationObjectId != "All" {
            zoneCategoryControl.removeAllSegments()
            if filterParametar.zoneObjectId != "All" {
                zoneCategoryControl.insertSegment(withTitle: "Zone", at: zoneCategoryControl.numberOfSegments, animated: false)
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                    if zone.allowOption.intValue == TypeOfControl.allowed.rawValue || zone.allowOption.intValue == TypeOfControl.confirm.rawValue {
                        bottomView.isHidden = false
                        zoneCategoryControl.setEnabled(true, forSegmentAt: zoneCategoryControl.numberOfSegments-1)
                        zoneCategoryControl.selectedSegmentIndex = zoneCategoryControl.numberOfSegments-1
                    }
                }
            }
            
            if filterParametar.categoryObjectId != "All" {
                zoneCategoryControl.insertSegment(withTitle: "Category", at: zoneCategoryControl.numberOfSegments, animated: false)
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) {
                    if category.allowOption.intValue == TypeOfControl.allowed.rawValue || category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                        bottomView.isHidden = false
                        zoneCategoryControl.setEnabled(true, forSegmentAt: zoneCategoryControl.numberOfSegments-1)
                        zoneCategoryControl.selectedSegmentIndex = zoneCategoryControl.numberOfSegments-1
                    }
                }
            }
        } else {
            bottomView.isHidden = true
        }
    }
    
    
    // Helper functions
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.devices)
    }
    
    @IBAction func zoneCategoryControlSlider(_ sender: UISlider) {
        let sliderValue = Int(sender.value)
        
        if let title = zoneCategoryControl.titleForSegment(at: zoneCategoryControl.selectedSegmentIndex) {
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All" {
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) {
                        if zone.allowOption.intValue == TypeOfControl.allowed.rawValue{
                            ZoneAndCategoryControl.shared.changeValueByZone(filterParametar.zoneId, location: filterParametar.location, value: sliderValue)
                        } else if zone.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok {
                                    ZoneAndCategoryControl.shared.changeValueByZone(self.filterParametar.zoneId, location: self.filterParametar.location, value: sliderValue)
                                }
                            })
                        }
                    }
                    
                }
            } else if title == "Category" {
                if filterParametar.categoryObjectId != "All" {
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) {
                        if category.allowOption.intValue == TypeOfControl.allowed.rawValue {
                            ZoneAndCategoryControl.shared.changeValueByCategory(filterParametar.categoryId, location: filterParametar.location, value: sliderValue)
                        } else if category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok {
                                    ZoneAndCategoryControl.shared.changeValueByCategory(self.filterParametar.zoneId, location: self.filterParametar.location, value: sliderValue)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func on(_ sender: UIButton) {
        if let title = zoneCategoryControl.titleForSegment(at: zoneCategoryControl.selectedSegmentIndex) {
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All" {
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) {
                        if zone.allowOption.intValue == TypeOfControl.allowed.rawValue {
                            ZoneAndCategoryControl.shared.turnOnByZone(filterParametar.zoneId, location: filterParametar.location)
                            self.zoneAndCategorySlider.value = 100
                        } else if zone.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proceed with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok {
                                    ZoneAndCategoryControl.shared.turnOnByZone(self.filterParametar.zoneId, location: self.filterParametar.location)
                                    self.zoneAndCategorySlider.value = 100
                                }
                            })
                        }
                    }
                    
                }
            } else if title == "Category" {
                if filterParametar.categoryObjectId != "All" {
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) {
                        if category.allowOption.intValue == TypeOfControl.allowed.rawValue {
                            ZoneAndCategoryControl.shared.turnOnByCategory(filterParametar.categoryId, location: filterParametar.location)
                            self.zoneAndCategorySlider.value = 100
                        } else if category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proceed with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok {
                                    ZoneAndCategoryControl.shared.turnOnByCategory(self.filterParametar.categoryId, location: self.filterParametar.location)
                                    self.zoneAndCategorySlider.value = 100
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func off(_ sender: UIButton) {
        if let title = zoneCategoryControl.titleForSegment(at: zoneCategoryControl.selectedSegmentIndex) {
            if title == "Zone" {
                if filterParametar.zoneObjectId != "All"{
                    if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) {
                        if zone.allowOption.intValue == TypeOfControl.allowed.rawValue {
                            ZoneAndCategoryControl.shared.turnOffByZone(filterParametar.zoneId, location: filterParametar.location)
                            self.zoneAndCategorySlider.value = 0
                        }else if zone.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proceed with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok {
                                    ZoneAndCategoryControl.shared.turnOffByZone(self.filterParametar.zoneId, location: self.filterParametar.location)
                                    self.zoneAndCategorySlider.value = 0
                                }
                            })
                        }
                    }
                    
                }
            }else if title == "Category"{
                if filterParametar.categoryObjectId != "All" {
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) {
                        if category.allowOption.intValue == TypeOfControl.allowed.rawValue {
                            ZoneAndCategoryControl.shared.turnOffByCategory(filterParametar.categoryId, location: filterParametar.location)
                            self.zoneAndCategorySlider.value = 0
                        } else if category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proceed with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok {
                                    ZoneAndCategoryControl.shared.turnOffByCategory(self.filterParametar.categoryId, location: self.filterParametar.location)
                                    self.zoneAndCategorySlider.value = 0
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func changeZoneCategory(_ sender: UISegmentedControl) {
        if let title = zoneCategoryControl.titleForSegment(at: zoneCategoryControl.selectedSegmentIndex) {
            if title == "Zone" { selectLabel.text = "Selected Zone:" + filterParametar.zoneName
            } else if title == "Category" { selectLabel.text = "Selected Category:" + filterParametar.categoryName }
        }
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)
    }
    
    @IBAction func reload(_ sender: UIButton) {
        refreshVisibleDevicesInScrollView()
        sender.rotate(1)
    }
    @IBAction func location(_ sender: AnyObject) {
        
    }
    
}

// MARK: - View setup
extension DevicesViewController {
    
    func setupViews() {
        if #available(iOS 11, *) {  headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
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
    }
    
    func calculateCellSize(_ size:inout CGSize) {
        var i:CGFloat = 2
        while i >= 2 {
            if (view.frame.size.width / i) >= 120 && (view.frame.size.width / i) <= 160 { break }
            i += 1
        }
        let const = (2/i + (i*5-5)/i)
        let cellWidth = Int(view.frame.size.width/i - const)
        size = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
    }
    
    //    This has to be done, because we dont receive updates immmediately from gateway
    func updateCells() {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let device = devices[indexPath.row]
            let tag    = indexPath.row
            
            if let cell = deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? MultiSensorCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? ClimateCell { cell.setCell(device: device, tag: tag); cell.setNeedsDisplay() }
            else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? ApplianceCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? SaltoAccessCell { cell.setCell(device: device, tag: tag); cell.setNeedsDisplay() }
        }
    }
}

// MARK: - Logic
extension DevicesViewController {
    
    // GENERAL
    func updateDeviceList (_ user:User) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let sortDescriptorOne   = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo   = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour  = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
        predicateArray.append(NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool)))
        predicateArray.append(NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool)))
        
        // Filtering out PC devices
        predicateArray.append(NSPredicate(format: "type != %@", ControlType.PC))
        
        // Filtering by parametars from filter
        if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location)) }
        if filterParametar.levelId != 0 && filterParametar.levelId != 255 { predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int))) }
        if filterParametar.zoneId != 0 && filterParametar.zoneId != 255 { predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int))) }
        if filterParametar.categoryId != 0 && filterParametar.categoryId != 255 { predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int))) }
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Device]
            devices = fetResults!.map({$0})
            
            // filter Curtain devices that are, actually, one device
            
            // All curtains
            let curtainDevices = devices.filter({$0.controlType == ControlType.Curtain})
            if curtainDevices.count > 0 {
                for i in 0...curtainDevices.count - 1 {
                    if i+1 < curtainDevices.count { // if next exist
                        for j in i+1...curtainDevices.count - 1 {
                            if (curtainDevices[i].address == curtainDevices[j].address
                                && curtainDevices[i].controlType == curtainDevices[j].controlType
                                && curtainDevices[i].isCurtainModeAllowed.boolValue
                                && curtainDevices[j].isCurtainModeAllowed.boolValue
                                && curtainDevices[i].curtainGroupID == curtainDevices[j].curtainGroupID) {
                                
                                if let indexOfDeviceToBeNotShown = devices.index(of: curtainDevices[j]) { devices.remove(at: indexOfDeviceToBeNotShown) }
                            }
                        }
                    }
                }
            }
            for device in devices { device.cellTitle = returnNameForDeviceAccordingToFilter(device) }
            
        } catch let error1 as NSError { error = error1; print("Unresolved error \(String(describing: error)), \(error!.userInfo)") }
    }
    
    func refreshDevice(_ sender:AnyObject) {
        if let button = sender as? UIButton {
            let tag         = button.tag
            let controlType = devices[tag].controlType
            let gateway     = devices[tag].gateway
            let address     = [getByte(devices[tag].gateway.addressOne), getByte(devices[tag].gateway.addressTwo), getByte(devices[tag].address)]
            
            // Light
            if controlType == ControlType.Dimmer {
                SendingHandler.sendCommand(
                    byteArray: OutgoingHandler.getLightRelayStatus(address),
                    gateway: gateway
                )
                SendingHandler.sendCommand(
                    byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF),
                    gateway: gateway
                )
            }
            // Appliance?
            if controlType == ControlType.Relay {
                SendingHandler.sendCommand(
                    byteArray: OutgoingHandler.getLightRelayStatus(address),
                    gateway: gateway
                )
                SendingHandler.sendCommand(
                    byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF),
                    gateway: gateway
                )
            }
            // Curtain?
            if controlType == ControlType.Curtain {
                SendingHandler.sendCommand(
                    byteArray: OutgoingHandler.getLightRelayStatus(address),
                    gateway: gateway
                )
                SendingHandler.sendCommand(
                    byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF),
                    gateway: gateway
                )
            }
        }
    }
    
    func oneTap(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        let device      = devices[tag]
        let controlType = devices[tag].controlType
        
        let address              = [getByte(devices[tag].gateway.addressOne), getByte(devices[tag].gateway.addressTwo), getByte(devices[tag].address)]
        var setDeviceValue:UInt8 = 0
        var skipLevel:UInt8      = 0
        let deviceCurrentValue   = devices[tag].currentValue
        
        // Light
        if controlType == ControlType.Dimmer {
            
            if Int(deviceCurrentValue) > 0 {
                device.oldValue = deviceCurrentValue
                setDeviceValue = UInt8(0)
                skipLevel = 0
            } else {
                if let oldVal = device.oldValue { setDeviceValue = UInt8(round(oldVal.floatValue*100/255)) } else { setDeviceValue = 100 }
                skipLevel = getByte(device.skipState)
            }
            
            device.currentValue = NSNumber(value: Int(setDeviceValue)*255/100)
            print("Device current value: \(deviceCurrentValue)%")
            DispatchQueue.main.async(execute: {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: device.objectID,
                    newCommand: NSNumber(value: setDeviceValue),
                    oldValue: NSNumber(value: setDeviceValue)
                )
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setDeviceValue, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: skipLevel),
                    gateway: device.gateway,
                    device: device,
                    oldValue: Int(deviceCurrentValue),
                    command: NSNumber(value: setDeviceValue)
                )
            })
        }
        
        // Appliance?
        if controlType == ControlType.Relay {
            
            if Int(deviceCurrentValue) > 0 {
                setDeviceValue = UInt8(0)
                device.currentValue = 0
                skipLevel = 0
            } else {
                setDeviceValue = 255
                skipLevel = getByte(device.skipState)
            }
            
            device.currentValue = NSNumber(value: Int(setDeviceValue))
            DispatchQueue.main.async(execute: {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: device.objectID,
                    newCommand: NSNumber(value: setDeviceValue),
                    oldValue: deviceCurrentValue
                )
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setDeviceValue, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: skipLevel),
                    gateway: device.gateway,
                    device: device,
                    oldValue: Int(deviceCurrentValue),
                    command: NSNumber(value: setDeviceValue)
                )
            })
        }
        updateCells()
    }
    
    // CLIMATE
    func setACPowerStatus(_ gesture:UIGestureRecognizer) {
        let tag = gesture.view!.tag
        let device  = devices[tag]

        let address = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        if device.currentValue == 0x00 {
            SendingHandler.sendCommand(
                byteArray: OutgoingHandler.setACStatus(address, channel: getByte(device.channel), status: 0xFF),
                gateway: device.gateway
            )
            
        }
        if device.currentValue == 0xFF {
            SendingHandler.sendCommand(
                byteArray: OutgoingHandler.setACStatus(address, channel: getByte(device.channel), status: 0x00),
                gateway: device.gateway
            )
        }
    }
    
    // CURTAINS
    func openCurtain(_ gestureRecognizer:UITapGestureRecognizer){
        let tag                  = gestureRecognizer.view!.tag
        let device               = devices[tag]
        let controlType          = device.controlType
        let address              = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        let setDeviceValue:UInt8 = 0xFF
        let deviceCurrentValue   = Int(device.currentValue)
        let deviceGroupId        = device.curtainGroupID.intValue
        
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        let allDevices = CoreDataController.sharedInstance.fetchDevicesForGateway(device.gateway)
        var devicePair: Device? = nil
        for deviceTemp in allDevices {
            if deviceTemp.address == devices[tag].address {
                
                if deviceTemp.curtainGroupID == device.curtainGroupID {
                    if deviceTemp.channel.intValue != device.channel.intValue {
                        if deviceTemp.isCurtainModeAllowed.boolValue == true && device.isCurtainModeAllowed.boolValue == true {
                            devicePair = deviceTemp
                        }
                    }
                }
                
            }
        }
        
        if controlType == ControlType.Curtain {
            
            if devicePair == nil { // then this is new module, which works alone
                device.currentValue = 0xFF // We need to set this to 255 because we will always display Channel1 and 2 in devices. Not 3 or 4. And this channel needs to be ON for image to be displayed properly
                CoreDataController.sharedInstance.saveChanges()
                
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setDeviceValue),
                        oldValue: NSNumber(value: deviceCurrentValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setCurtainStatus(
                            address,
                            value: setDeviceValue,
                            groupId:  UInt8(deviceGroupId)),
                        gateway: device.gateway,
                        device: device, oldValue: deviceCurrentValue,
                        command: NSNumber(value: setDeviceValue)
                    )
                })
            } else {
                device.currentValue      = 0xFF // We need to set this to 255 because we will always display Channel1 and 2 in devices. Not 3 or 4. And this channel needs to be ON for image to be displayed properly
                devicePair!.currentValue = 0xFF
                CoreDataController.sharedInstance.saveChanges()
                
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setDeviceValue),
                        oldValue: NSNumber(value: deviceCurrentValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)),
                        gateway: device.gateway,
                        device: device,
                        oldValue: deviceCurrentValue,
                        command: NSNumber(value: setDeviceValue)
                    )
                })
            }
            
        }
        
        updateCells()
    }
    
    func closeCurtain(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag                  = gestureRecognizer.view!.tag
        let device               = devices[tag]
        let controlType          = device.controlType
        let address              = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        let setDeviceValue:UInt8 = 0x00
        let deviceCurrentValue   = Int(device.currentValue)
        let deviceGroupId        = device.curtainGroupID.intValue
        
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        let allDevices = CoreDataController.sharedInstance.fetchDevicesForGateway(device.gateway)
        var devicePair: Device? = nil
        for deviceTemp in allDevices {
            if deviceTemp.address == device.address {
                if deviceTemp.curtainGroupID == device.curtainGroupID {
                    if deviceTemp.channel.intValue != device.channel.intValue {
                        if deviceTemp.isCurtainModeAllowed.boolValue == true && device.isCurtainModeAllowed.boolValue == true {
                            devicePair = deviceTemp
                        }
                    }
                }
            }
        }
        
        if controlType == ControlType.Curtain {
            if devicePair == nil {
                device.currentValue = 0x00
                CoreDataController.sharedInstance.saveChanges()
                
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setDeviceValue),
                        oldValue: NSNumber(value: deviceCurrentValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)),
                        gateway: device.gateway,
                        device: device,
                        oldValue: deviceCurrentValue,
                        command: NSNumber(value: setDeviceValue)
                    ) // vratiti na deviceCurrentValue ovo poslednje
                })
            } else {
                guard let _ = devicePair else { print("Error, no pair device found for curtain relay control"); return }
                device.currentValue       = 0xFF// We need to set this to 255 because we will always display Channel1 and 2 in devices. Not 3 or 4.
                devicePair?.currentValue  = 0
                CoreDataController.sharedInstance.saveChanges()
                
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setDeviceValue),
                        oldValue: NSNumber(value: deviceCurrentValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)),
                        gateway: device.gateway,
                        device: device,
                        oldValue: deviceCurrentValue,
                        command: NSNumber(value: setDeviceValue)
                    ) // vratiti na deviceCurrentValue ovo poslednje
                })
            }
        }
        
        
        
        updateCells()
    }
    
    func stopCurtain(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag                  = gestureRecognizer.view!.tag
        let device               = devices[tag]
        let controlType          = device.controlType
        let address              = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        let setDeviceValue:UInt8 = 0xEF
        let deviceCurrentValue   = Int(device.currentValue)
        let deviceGroupId        = device.curtainGroupID.intValue
        
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        let allDevices = CoreDataController.sharedInstance.fetchDevicesForGateway(device.gateway)
        var devicePair: Device? = nil
        for deviceTemp in allDevices {
            if deviceTemp.address == device.address {
                if deviceTemp.curtainGroupID == device.curtainGroupID {
                    if deviceTemp.channel.intValue != device.channel.intValue {
                        if deviceTemp.isCurtainModeAllowed.boolValue == true && device.isCurtainModeAllowed.boolValue == true {
                            devicePair = deviceTemp
                        }
                    }
                }
            }
        }
        
        if controlType == ControlType.Curtain {
            
            if devicePair == nil {
                device.currentValue = 0xEF
                CoreDataController.sharedInstance.saveChanges()
                
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value:setDeviceValue),
                        oldValue: NSNumber(value: deviceCurrentValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)),
                        gateway: device.gateway,
                        device: device,
                        oldValue: deviceCurrentValue,
                        command: NSNumber(value: setDeviceValue)
                    )
                })
                
            } else {
                device.currentValue       = 0x00
                devicePair?.currentValue  = 0x00
                CoreDataController.sharedInstance.saveChanges()
                
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setDeviceValue),
                        oldValue: NSNumber(value: deviceCurrentValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setCurtainStatus(address, value: setDeviceValue, groupId:  UInt8(deviceGroupId)),
                        gateway: device.gateway,
                        device: device,
                        oldValue: deviceCurrentValue,
                        command: NSNumber(value: setDeviceValue)
                    )
                })
            }
        }
        
        updateCells()
    }
    
    // SALTO
    func lockSalto(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag                   = gestureRecognizer.view!.tag
        let device                = devices[tag]
        let address               = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        let setDeviceValue:UInt8  = 0xFF
        let deviceCurrentValue    = Int(device.currentValue)
        device.currentValue = 0
        CoreDataController.sharedInstance.saveChanges()
        
        DispatchQueue.main.async(execute: {
            RunnableList.sharedInstance.checkForSameDevice(
                device: device.objectID,
                newCommand: NSNumber(value: setDeviceValue),
                oldValue: NSNumber(value: deviceCurrentValue)
            )
            _ = RepeatSendingHandler(
                byteArray: OutgoingHandler.setSaltoAccessMode(address, lockId: device.channel.intValue, mode: 3),
                gateway: device.gateway,
                device: device,
                oldValue: deviceCurrentValue,
                command: NSNumber(value: setDeviceValue)
            )
        })
        updateCells()
    }
    func unlockSalto(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag                   = gestureRecognizer.view!.tag
        let device                = devices[tag]
        let address               = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        let setDeviceValue:UInt8  = 0xFF
        let deviceCurrentValue    = Int(device.currentValue)
        device.currentValue = 1
        CoreDataController.sharedInstance.saveChanges()
        
        DispatchQueue.main.async(execute: {
            RunnableList.sharedInstance.checkForSameDevice(
                device: device.objectID,
                newCommand: NSNumber(value: setDeviceValue),
                oldValue: NSNumber(value: deviceCurrentValue)
            )
            _ = RepeatSendingHandler(
                byteArray: OutgoingHandler.setSaltoAccessMode(address, lockId: device.channel.intValue, mode: 2),
                gateway: device.gateway,
                device: device,
                oldValue: deviceCurrentValue,
                command: NSNumber(value: setDeviceValue)
            )
        })
        updateCells()
    }
    
    func thirdFcnSalto(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag                   = gestureRecognizer.view!.tag
        let device                = devices[tag]
        let address               = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        let setDeviceValue:UInt8  = 0xFF
        let deviceCurrentValue    = Int(device.currentValue)
        device.currentValue = 0
        CoreDataController.sharedInstance.saveChanges()
        
        DispatchQueue.main.async(execute: {
            RunnableList.sharedInstance.checkForSameDevice(
                device: device.objectID,
                newCommand: NSNumber(value: setDeviceValue),
                oldValue: NSNumber(value: deviceCurrentValue)
            )
            _ = RepeatSendingHandler(
                byteArray: OutgoingHandler.setSaltoAccessMode(address, lockId: device.channel.intValue, mode: 1),
                gateway: device.gateway,
                device: device,
                oldValue: deviceCurrentValue,
                command: NSNumber(value: setDeviceValue)
            )
        })
        updateCells()
    }
    
}

// MARK: - Filter PullDown Delegate || Parametar from filter and relaod data
extension DevicesViewController: FilterPullDownDelegate{
    
    // Function is called when filter is defined
    func filterParametars(_ filterItem: FilterItem) {
        filterParametar = filterItem
        updateSubtitle(headerTitleSubtitleView, title: "Devices", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName) // Update the subtitle in navigation in order for user to see what filter parameters are selected.
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.devices) // Saves filter to database for later
        
        checkZoneAndCategoryFromFilter(filterItem)
        
        if let user = userLogged {
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

// MARK: - Big Slider Delegate
extension DevicesViewController: BigSliderDelegate {
    func valueChanged(_ sender: UISlider) {
        changeSliderValue(sender)
    }
    
    func endValueChanged(_ sender: UISlider) {
        changeSliderValueEnded(sender)
    }
    
    func setONOFFDimmer(_ index:Int, turnOff:Bool) {
        let device = devices[index]
        
        if device.controlType == ControlType.Dimmer {
            var setDeviceValue:UInt8 = 0
            var skipLevel:UInt8      = 0
            if turnOff {
                device.oldValue = device.currentValue
                setDeviceValue  = UInt8(0)
                skipLevel       = 0
            } else {
                setDeviceValue = 100
                skipLevel      = getByte(device.skipState)
            }
            
            let address            = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
            let deviceCurrentValue = Int(device.currentValue)
            device.currentValue = NSNumber(value: Int(setDeviceValue)*255/100)
            
            DispatchQueue.main.async(execute: {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: device.objectID,
                    newCommand: NSNumber(value: setDeviceValue),
                    oldValue: NSNumber(value: deviceCurrentValue)
                )
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setDeviceValue, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: skipLevel),
                    gateway: device.gateway,
                    device: device,
                    oldValue: deviceCurrentValue,
                    command: NSNumber(value: setDeviceValue)
                )
            })
        }
    }
}

extension DevicesViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { deviceCollectionView.isUserInteractionEnabled = true } else { deviceCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { deviceCollectionView.isUserInteractionEnabled = true } else { deviceCollectionView.isUserInteractionEnabled = false }
    }
    
}

// MARK: - Gesture Recognizer Delegate
extension DevicesViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view! is UISlider { return false }
        return true
    }
}

