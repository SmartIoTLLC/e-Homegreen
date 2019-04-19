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

private struct LocalConstants {
    static let cellSize: CGSize = CellSize.calculateCellSize()
    static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 20, right: 0)
    static let itemSpacing: CGFloat = 5
    static let ZACChiddenStateConstraint: CGFloat = 154
    static let ZACCViewHeight: CGFloat = 193.5
}

class DevicesViewController: PopoverVC {
    
    private var refreshTimer: Foundation.Timer?
    
    fileprivate func startRefreshTimer() {
        refreshTimer = Foundation.Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(refreshVisibleDevicesInScrollView), userInfo: nil, repeats: true)
    }
    fileprivate func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    fileprivate var panStartPoint: CGPoint!
    private let backgroundView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    
    fileprivate var scrollView = FilterPullDown()
    fileprivate var isScrolling:Bool = false
    
    var deviceInControlMode = false
    
    //zone and category control
    fileprivate let zaccView: ZoneAndCategoryControlView = ZoneAndCategoryControlView()
    fileprivate var panRecognizer:UIPanGestureRecognizer!
    fileprivate var startingBottomConstraint:CGFloat?
    
    var devices:[Device] = []
    
    fileprivate var storedIBeaconBarButtonItem: UIBarButtonItem!
    
    fileprivate var filterParametar:FilterItem = FilterItem.loadEmptyFilter()
    
    fileprivate let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    //Zone and category control
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var zoneCategoryControl: UISegmentedControl!
    @IBOutlet weak var zoneAndCategorySlider: UISlider!
    @IBOutlet weak var iBeaconButton: UIButton!
    @IBOutlet weak var iBeaconBarButton: UIBarButtonItem!
    @IBOutlet weak var fullscreenBarButton: UIBarButtonItem!
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        addTitleView()
        addScrollView()
        addBackgroundView()
        addCollectionView()
        addBottomView()
        
        setupConstraints()
        
        setupViews()
        
        loadFilter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DevicesViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerDevices), object: nil)
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setContentOffset(for: scrollView)
        
        setTitleView(view: headerTitleSubtitleView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deviceCollectionView.isUserInteractionEnabled = true
        
        updateDeviceList()
        
        changeFullscreenImage(fullscreenButton: fullScreenButton)
        startRefreshTimer()
        
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.setContentOffset(CGPoint(x: 0, y: GlobalConstants.screenSize.height - (GlobalConstants.statusBarHeight + navigationBarHeight) - 2), animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.refreshVisibleDevicesInScrollView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObservers()
        stopRefreshTimer()
    }
    
    // MARK: - Setup views
    private func loadFilter() {
        if let filter = FilterItem.loadFilter(type: .Device) {
            filterParametars(filter)
        }
    }
    
    private func addTitleView() {
        storedIBeaconBarButtonItem = iBeaconBarButton
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Devices", subtitle: "All All All")
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
    }
    
    private func addScrollView() {
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        
        updateConstraints(item: scrollView)
        
        scrollView.setItem(self.view)
        scrollView.setFilterItem(Menu.devices)
    }
    
    private func addBottomView() {
        bottomView.isHidden = true
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DevicesViewController.panView(_:)))
        panRecognizer.delegate = self
        bottomView.addGestureRecognizer(panRecognizer)
    }
    
    private func addBackgroundView() {
        backgroundView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
    }
    
    private func addCollectionView() {
        deviceCollectionView.delaysContentTouches = false
        deviceCollectionView.delegate = self
        
        deviceCollectionView.register(DimmerCollectionViewCell.self, forCellWithReuseIdentifier: DimmerCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(CurtainCollectionViewCell.self, forCellWithReuseIdentifier: CurtainCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(ApplianceCollectionViewCell.self, forCellWithReuseIdentifier: ApplianceCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(ClimateCollectionViewCell.self, forCellWithReuseIdentifier: ClimateCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(MultisensorCollectionViewCell.self, forCellWithReuseIdentifier: MultisensorCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(SaltoAccessCollectionViewCell.self, forCellWithReuseIdentifier: SaltoAccessCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(SliderCurtainCollectionViewCell.self, forCellWithReuseIdentifier: SliderCurtainCollectionViewCell.reuseIdentifier)
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        deviceCollectionView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            if #available(iOS 11, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }

    }
    
    // MARK: - Logic
    func refreshRunningTime(of device: Device) {
        switch device.controlType {
            case ControlType.Dimmer,
                 ControlType.Relay,
                 ControlType.Curtain:
                
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(device.moduleAddress, channel: 0xFF), gateway: device.gateway)
            default: break
        }
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }

    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            scrollView.setDefaultFilterItem(Menu.devices)
        }
    }
    
    @objc func refreshLocalParametars () {
        filterParametar = FilterItem.loadFilter(type: .Device) ?? FilterItem.loadEmptyFilter()
        deviceCollectionView.reloadData()
    }

    func changeSliderValueWithTag(_ tag:Int, withOldValue:Int) {
        let device      = devices[tag]
        let controlType = device.controlType
        let address     = device.moduleAddress

        device.increaseUsageCounterValue()
        deviceInControlMode = false
        //   Dimmer
        if controlType == ControlType.Dimmer {
            /* TODO: REMOVE
             logic is moved to its proper place (DeviceCollectionViewCell)
             */
            
            let setValue = UInt8(Int(device.currentValue.doubleValue*100/255))
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setValue),
                        oldValue: NSNumber(value: withOldValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setValue, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: self.getByte(device.skipState)),
                        gateway: device.gateway,
                        device: device,
                        oldValue: withOldValue,
                        command: NSNumber(value: setValue)
                    )
                })
            })
        }
        
        // TODO: Ne postoji celija sa sliderom za zavesu. Napraviti i BigSlider koji umesto on/off ima open/close
        //  Curtain
        if controlType == ControlType.Curtain {
            let deviceGroupId = devices[tag].curtainGroupID.intValue
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: device.currentValue,
                        oldValue: NSNumber(value: withOldValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setCurtainStatus(address, value: self.getByte(device.currentValue), groupId:  UInt8(deviceGroupId)),
                        gateway: device.gateway,
                        device: device,
                        oldValue: withOldValue,
                        command: device.currentValue
                    )
                })
            })
        }
    }
    
    func changeSliderValue(_ sender: UISlider){
        let tag    = sender.tag
        let device = devices[tag]
        device.currentValue = NSNumber(value: Int(sender.value * 255))   // device values is Int, 0 to 255 (0x00 to 0xFF)

        let indexPath = IndexPath(item: tag, section: 0)
        if let cell = deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell {
            /* TODO: REMOVE
             logic is moved to its proper place (DeviceCollectionViewCell)
             */
            
            let deviceValue:Double = { return Double(device.currentValue) }()
            cell.picture.image     = device.returnImage(Double(deviceValue))
            cell.lightSlider.value = Float(deviceValue/255) // Slider value accepts values from 0 to 1
            cell.setNeedsDisplay()
        } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell {
            cell.setImageForDevice(device); cell.setNeedsDisplay()
        }
    }
    
    @objc func refreshDeviceList() {
        if !deviceInControlMode {
            if !isScrolling { self.reloadItemsAtVisibleIndexPaths() } // TODO: change to reload data
        }
    }
    
    //MARK: Zone and category controll
    
    //gesture delegate function
    @objc func panView(_ gesture:UIPanGestureRecognizer){
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
                
                if !panningUp { if deltaX == 0 { self.resetConstraintContstants() } }
                else {
                    if panStartPoint.x > self.bottomView.center.x - 75 && panStartPoint.x < self.bottomView.center.x + 75 {
                        if deltaX < -154 { self.setConstraintsToShowBottomView() } else { self.bottomConstraint.constant = -154 - deltaX }
                    }
                }
                
            } else {
                if !panningUp {
                    if -deltaX > -154 { self.bottomConstraint.constant = -deltaX } else { self.resetConstraintContstants() }
                } else {
                    if deltaX <= 0 { self.setConstraintsToShowBottomView() } else { self.bottomConstraint.constant = -154 - deltaX }
                }
            }
            
            break
            
        case .ended:
            if self.startingBottomConstraint == -154 {
                if bottomConstraint.constant >= -100 { self.setConstraintsToShowBottomView() } else { self.resetConstraintContstants() }
                
            } else {
                if bottomConstraint.constant <= -30 { self.resetConstraintContstants() } else { self.setConstraintsToShowBottomView() }
            }
            
            break
            
        case .cancelled:
            
            if self.startingBottomConstraint == -154 { self.resetConstraintContstants() } else { self.setConstraintsToShowBottomView() }
            break
            
        default: break
        }
        
    }
    
    @objc private func njahPanView(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
            case .began:
                self.panStartPoint = gestureRecognizer.location(in: self.bottomView)
            
            
            case .changed:
                break
            case .ended:
                break
            case .cancelled:
                break
            default:
                break
        }
    }
    
    func resetConstraintContstants() {
//        setZACCViewConstraintsWith(bottomValue: LocalConstants.ZACChiddenStateConstraint)

        if self.startingBottomConstraint == -154 && self.bottomConstraint.constant == -154 { return }

        self.bottomConstraint.constant = -154

        self.updateConstraintsIfNeeded(true, completion: { (finished) -> Void in
            self.bottomConstraint.constant = -154

            self.updateConstraintsIfNeeded(true, completion: { (finished) -> Void in
                self.startingBottomConstraint = self.bottomConstraint.constant
            })
        })
    }
    func setConstraintsToShowBottomView() {
//        setZACCViewConstraintsWith(bottomValue: 0)

        if self.startingBottomConstraint == 0 && self.bottomConstraint.constant == 0 { return }

        self.bottomConstraint.constant =  0

        self.updateConstraintsIfNeeded(true) { (finished) -> Void in
            self.bottomConstraint.constant = 0

            self.updateConstraintsIfNeeded(true, completion: { (finished) -> Void in
                self.startingBottomConstraint = self.bottomConstraint.constant
            })
        }

    }
    
    private func setZACCViewConstraintsWith(bottomValue bottom: CGFloat) {
        bottomView.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview().offset(bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.ZACCViewHeight)
        }
        self.startingBottomConstraint = bottom
    }
    
    func updateConstraintsIfNeeded(_ animated:Bool, completion:@escaping (_ finished: Bool) -> Void){
        var duration:Float = 0
        if animated { duration = 0.1 }
        
        UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(0), options: UIView.AnimationOptions.curveEaseOut, animations:{ self.bottomView.layoutIfNeeded() }, completion: {
            success in
            completion(success)
        })
        
    }
    
    @objc func changeGroupSliderValueOnOneTap (_ gesture:UIGestureRecognizer) {
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
    @objc func setDefaultFilterFromTimer(){
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
                    if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) { print("category exists")
                        print("category allow option \(category.allowOption.intValue)")
                        if category.allowOption.intValue == TypeOfControl.allowed.rawValue { print("category allowed")
                            ZoneAndCategoryControl.shared.changeValueByCategory(filterParametar.categoryId, location: filterParametar.location, value: sliderValue);print("category func")
                        } else if category.allowOption.intValue == TypeOfControl.confirm.rawValue {
                            showOKAlertView(sender, message: "Are you sure you want to proced with this control?", completion: { (action) in
                                if action == ReturnedValueFromAlertView.ok {print("category confirm")
                                    ZoneAndCategoryControl.shared.changeValueByCategory(self.filterParametar.zoneId, location: self.filterParametar.location, value: sliderValue);print("category func")
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
        // TODO: ova funkcija (well, duh)
    }
    

    
}

// MARK: - View setup
extension DevicesViewController {
    

    
    func setupViews() {
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        zoneAndCategorySlider.isContinuous = false
        
        zoneAndCategorySlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.changeGroupSliderValueOnOneTap(_:))))
        
    }
    
    //    This has to be done, because we dont receive updates immmediately from gateway
    func reloadItemsAtVisibleIndexPaths() {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
            
        for indexPath in indexPaths {
            
            let cell   = deviceCollectionView.cellForItem(at: indexPath)
            let device = devices[indexPath.row]
            let tag    = indexPath.row
            
            if let cell = cell as? DimmerCollectionViewCell { cell.setCell(with: device, tag: tag) }
            else if let cell = cell as? CurtainCollectionViewCell { cell.setCell(with: device, tag: tag) }
            else if let cell = cell as? MultisensorCollectionViewCell { cell.setCell(with: device, tag: tag) }
            else if let cell = cell as? ClimateCollectionViewCell { cell.setCell(with: device, tag: tag) }
            else if let cell = cell as? ApplianceCollectionViewCell { cell.setCell(with: device, tag: tag) }
            else if let cell = cell as? SaltoAccessCollectionViewCell { cell.setCell(with: device, tag: tag) }
        }
    }
    
    fileprivate func toggleIBeaconButtonVisibility() {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            
            var shouldHide: Bool = true
            
            navigationItem.setRightBarButtonItems([fullscreenBarButton, refreshBarButton, storedIBeaconBarButtonItem], animated: false)
            
            if let locations = user.locations?.allObjects as? [Location] {
                var pickedLocation: Location?
                
                locations.forEach({ (location) in if location.name == filterParametar.location { pickedLocation = location } })
                
                if let location = pickedLocation {
                    if let zones = location.zones?.allObjects as? [Zone] {
                        var pickedZone: Zone?
                        
                        zones.forEach({ (zone) in if zone.name == filterParametar.zoneName { pickedZone = zone } })
                        
                        if let zone = pickedZone {
                            if let _ = zone.iBeacon {
                                shouldHide = false
                            }
                        }
                    }
                }
            }
            if shouldHide { navigationItem.setRightBarButtonItems([fullscreenBarButton, refreshBarButton], animated: false) }
        }
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
    
    @objc private func refreshCollectionView() {
        deviceCollectionView.reloadData()
    }
}

// MARK: - Logic
extension DevicesViewController {
    
    // GENERAL
    func updateDeviceList() {
        var loggedUser: User?
        
        if AdminController.shared.isAdminLogged() {
            if let user = DatabaseUserController.shared.getOtherUser() {
                loggedUser = user
            }
        } else {
            if let user = DatabaseUserController.shared.getLoggedUser() {
                loggedUser = user
            }
        }
        
        if let user = loggedUser {
            if let devices = DatabaseDeviceController.shared.getDevicesOnDevicesScreen(filterParametar: filterParametar, user: user) {
                self.devices = devices
            }
        } else {
            devices = []
        }
        
        deviceCollectionView.reloadData()
    }
    
    func refreshDevice(_ sender:AnyObject) {
        if let button = sender as? UIButton {
            let tag         = button.tag
            let controlType = devices[tag].controlType
            let gateway     = devices[tag].gateway
            let address     = devices[tag].moduleAddress
            
            // Light
            if controlType == ControlType.Dimmer {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            }
            // Appliance?
            if controlType == ControlType.Relay {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            }
            // Curtain?
            if controlType == ControlType.Curtain {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            }
        }
    }
    
}

// MARK: - Filter PullDown Delegate || Parametar from filter and relaod data
extension DevicesViewController: FilterPullDownDelegate{
    
    // Function is called when filter is defined
    func filterParametars(_ filterItem: FilterItem) {
        filterParametar = filterItem
        updateSubtitle(headerTitleSubtitleView, title: "Devices", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.devices)
        FilterItem.saveFilter(filterItem, type: .Device)
        
        checkZoneAndCategoryFromFilter(filterItem)
        
        updateDeviceList()
        reloadItemsAtVisibleIndexPaths()
        
        toggleIBeaconButtonVisibility()
        
        TimerForFilter.shared.counterDevices = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.devices)
        TimerForFilter.shared.startTimer(type: Menu.devices)
        
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension DevicesViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition) {
        deviceCollectionView.isUserInteractionEnabled = (position == .left) ? true : false
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        deviceCollectionView.isUserInteractionEnabled = (position == .left) ? true : false
    }
    
}

// MARK: - Gesture Recognizer Delegate
extension DevicesViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view! is UISlider { return false }
        return true
    }
}

// MARK: - Collection View Delegate Flow Layout & Delegate
extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return LocalConstants.itemSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return LocalConstants.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return LocalConstants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return LocalConstants.cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let device = devices[indexPath.row]
        
        if device.isEnabled.boolValue && device.controlType == ControlType.Climate {
            showClimaSettings(indexPath.row, devices: devices)
            
            // Dumb solution for the climate mode icon issue, but it'll work until we find the correct fix
            deviceCollectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - Collection View Data Source
extension DevicesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let device      = devices[indexPath.row]
        let controlType = device.controlType
        let tag         = indexPath.row
        
        switch controlType {
        case ControlType.Dimmer:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DimmerCollectionViewCell.reuseIdentifier, for: indexPath) as? DimmerCollectionViewCell {
                
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.Curtain:

            if device.curtainNeedsSlider.boolValue {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SliderCurtainCollectionViewCell.reuseIdentifier, for: indexPath) as? SliderCurtainCollectionViewCell {
                    cell.setCell(with: device, tag: tag)
                    return cell
                }
            } else {
                
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurtainCollectionViewCell.reuseIdentifier, for: indexPath) as? CurtainCollectionViewCell {
                    cell.setCell(with: device, tag: tag)
                    return cell
                }
            }
            
        case ControlType.SaltoAccess:
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SaltoAccessCollectionViewCell.reuseIdentifier, for: indexPath) as? SaltoAccessCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.Relay,
             ControlType.DigitalOutput:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ApplianceCollectionViewCell.reuseIdentifier, for: indexPath) as? ApplianceCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.Climate:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClimateCollectionViewCell.reuseIdentifier, for: indexPath) as? ClimateCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.Sensor,
             ControlType.IntelligentSwitch,
             ControlType.Gateway,
             ControlType.DigitalInput:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultisensorCollectionViewCell.reuseIdentifier, for: indexPath) as? MultisensorCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
        default:
            break
        }
        
        return UICollectionViewCell()
    }
}

// MARK: - Logic
extension DevicesViewController {
    func updateDeviceStatus (indexPathRow: Int) {
        for device in devices { if device.gateway == devices[indexPathRow].gateway && device.address == devices[indexPathRow].address { device.stateUpdatedAt = Date() } }
        
        let device      = devices[indexPathRow]
        let controlType = device.controlType
        let gateway     = device.gateway
        let channel     = device.channel.intValue
        
        let address = device.moduleAddress
        
        switch controlType {
        case ControlType.Dimmer,
             ControlType.Relay:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
        case ControlType.Climate:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getACStatus(address), gateway: gateway)
        case ControlType.Sensor,
             ControlType.IntelligentSwitch,
             ControlType.Gateway:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getSensorState(address), gateway: gateway)
        case ControlType.Curtain:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: gateway)
        case ControlType.SaltoAccess:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState(address, lockId: channel), gateway: gateway)
        default:
            break
        }
        
        switch device.controlType {
        case ControlType.Dimmer,
             ControlType.Relay,
             ControlType.Curtain:
            
            SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(device.moduleAddress, channel: 0xFF), gateway: device.gateway)
        default: break
        }
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    @objc func refreshVisibleDevicesInScrollView () {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths { updateDeviceStatus (indexPathRow: indexPath.row) }
    }
    
}

// MARK: - Scroll View Delegate
extension DevicesViewController {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateDeviceState(in: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateDeviceState(in: scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    private func updateDeviceState(in scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            let indexPaths = collectionView.indexPathsForVisibleItems
            for indexPath in indexPaths {
                if let stateUpdatedAt = devices[indexPath.row].stateUpdatedAt as Date? {
                    if let hourValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayHours) as? Int,
                        let minuteValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayMinutes) as? Int {
                        let minutes = (hourValue * 60 + minuteValue) * 60
                        
                        if Date().timeIntervalSince(stateUpdatedAt.addingTimeInterval(TimeInterval(NSNumber(value: minutes as Int)))) >= 0 {
                            
                            updateDeviceStatus (indexPathRow: indexPath.row)
                            refreshRunningTime(of: devices[indexPath.row])
                        }
                    }
                } else {
                    updateDeviceStatus (indexPathRow: indexPath.row)
                    refreshRunningTime(of: devices[indexPath.row])
                }
            }
        }
        isScrolling = false
    }
}
