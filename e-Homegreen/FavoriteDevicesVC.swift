//
//  FavoriteDevicesVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 2/26/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//
import Foundation

class FavoriteDevicesVC: UIViewController {
    
    var gotRunningTimes: Bool = false
    var isScrolling:Bool = false
    var deviceInControlMode = false
    var changeSliderValueOldValue = 0
    
    var devices: [Device] = []
    var collectionViewCellSize: CGSize = CGSize(width: 113.5, height: 150)
    
    @IBOutlet weak var titleView: NavigationViewFavDevices!
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    var filterParameter: FilterItem = Filter.sharedInstance.returnFilter(forTab: .Device)
    var filterNameType: FavDeviceFilterType! { get { return FavDeviceFilterType(rawValue: defaults.string(forKey: UserDefaults.FavDevicesLabelType)!) } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerDeviceCells()
        addObservers()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavDevices()
        revealViewController().rightViewRevealWidth = 240
    }
}


// MARK: - Logic
extension FavoriteDevicesVC {
    
    @objc func changeSliderValueOnOneTap (_ gesture:UIGestureRecognizer) {
        if let slider = gesture.view as? UISlider {
            deviceInControlMode = false
            if slider.isHighlighted { changeSliderValueEnded(slider); return }
            
            let tag       = slider.tag
            let device    = devices[tag]
            let indexPath = IndexPath(item: tag, section: 0)
            
            let sliderOldValue = slider.value*100
            let pt             = gesture.location(in: slider)
            let percentage     = pt.x/slider.bounds.size.width
            let delta          = Float(percentage) * Float(slider.maximumValue - slider.minimumValue)
            let value          = round((slider.minimumValue + delta)*255)
            
            if !((value/255) >= 0 && (value/255) <= 255) { return }
            
            slider.setValue(value/255, animated: true)
            
            device.oldValue     = device.currentValue
            device.currentValue = NSNumber(value: Int(value))
            
            if let cell = deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell {
                cell.picture.image     = device.returnImage(Double(value))
                cell.lightSlider.value = slider.value
                cell.setNeedsDisplay()
            } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell {
                cell.setImageForDevice(device); cell.setNeedsDisplay()
            }
            changeSliderValueWithTag(tag, withOldValue: Int(sliderOldValue))
        }
    }
    func changeSliderValueWithTag(_ tag:Int, withOldValue:Int) {
        let device      = devices[tag]
        let controlType = device.controlType
        let address     = device.moduleAddress
        
        device.increaseUsageCounterValue()
        deviceInControlMode = false
        
        switch controlType {
        case ControlType.Dimmer: //   Dimmer
            let setValue = UInt8(Int(device.currentValue.doubleValue*100/255))
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setValue),
                        oldValue: NSNumber(value: withOldValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: self.getByte(device.skipState)),
                        gateway: device.gateway,
                        device: device,
                        oldValue: withOldValue,
                        command: NSNumber(value: setValue)
                    )
                })
            })
            
        case ControlType.Curtain: //  Curtain
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
        default: break
        }
    }
    @objc func changeSliderValueStarted (_ sender: UISlider) {
        let tag = sender.tag
        deviceInControlMode       = true
        changeSliderValueOldValue = devices[tag].currentValue.intValue
    }
    
    @objc func changeSliderValueEnded (_ sender:UISlider) {
        let tag         = sender.tag
        let device      = devices[tag]
        let controlType = device.controlType
        let address     = device.moduleAddress
        //   Dimmer
        let v  = device.currentValue.doubleValue
        let v2 = v*100/255
        let v3 = Int(v2)
        let v4 = UInt8(v3)
        
        device.increaseUsageCounterValue()
        
        var newCommand: NSNumber!
        var byteArray: [Byte]!
        
        switch controlType {
        case ControlType.Dimmer:
            byteArray = OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: UInt8(v4), delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: self.getByte(device.skipState))
            newCommand = NSNumber(value: v4)
        case ControlType.Curtain:
            byteArray = OutgoingHandler.setCurtainStatus(address, value: self.getByte(device.currentValue), groupId:  0x00)
            newCommand = device.currentValue
        default: break
        }
        
        DispatchQueue.main.async(execute: {
            RunnableList.sharedInstance.checkForSameDevice(
                device: device.objectID,
                newCommand: newCommand,
                oldValue: NSNumber(value: self.changeSliderValueOldValue)
            )
            _ = RepeatSendingHandler(
                byteArray: byteArray,
                gateway: device.gateway,
                device: device,
                oldValue: self.changeSliderValueOldValue,
                command: device.currentValue
            )
        })
        
        changeSliderValueOldValue = 0
        deviceInControlMode = false
    }
    
    
    
    @objc func changeSliderValue(_ sender: UISlider){
        let tag    = sender.tag
        let device = devices[tag]
        device.currentValue = NSNumber(value: Int(sender.value * 255))   // device values is Int, 0 to 255 (0x00 to 0xFF)
        
        let indexPath = IndexPath(item: tag, section: 0)
        if let cell = deviceCollectionView.cellForItem(at: indexPath) as? DeviceCollectionCell {
            let deviceValue:Double = { return device.currentValue.doubleValue }()
            cell.picture.image     = device.returnImage(Double(deviceValue))
            cell.lightSlider.value = Float(deviceValue/255) // Slider value accepts values from 0 to 1
            cell.setNeedsDisplay()
        } else if let cell = self.deviceCollectionView.cellForItem(at: indexPath) as? CurtainCollectionCell {
            cell.setImageForDevice(device); cell.setNeedsDisplay()
        }
    }
    
    @objc func cellParametarLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            if gestureRecognizer.state == .began {
                let location = gestureRecognizer.location(in: deviceCollectionView)
                if let index = deviceCollectionView.indexPathForItem(at: location) {
                    let controlType = devices[index.row].controlType
                    
                    switch controlType {
                    case ControlType.Dimmer  : showDimmerParametar(tag, devices: devices)
                    case ControlType.Relay   : showRelayParametar(tag, devices: devices)
                    case ControlType.Curtain : showRelayParametar(tag, devices: devices)
                    default                  : showIntelligentSwitchParameter(tag, devices: devices)
                    }
                }
            }
        }
    }
    
    @objc func longTouch(_ gestureRecognizer: UILongPressGestureRecognizer) { // Light
        if let tag = gestureRecognizer.view?.tag {
            if devices[tag].controlType == ControlType.Dimmer {
                if gestureRecognizer.state == .began { showBigSlider(devices[tag], index: tag).delegate = self }
            }
        }
    }
    
    @objc func handleTap (_ gesture:UIGestureRecognizer) {
        let location = gesture.location(in: deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItem(at: location) {
            
            let cell        = deviceCollectionView.cellForItem(at: index)
            let controlType = devices[index.row].controlType
            let options: UIViewAnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
            
            switch controlType {
            case ControlType.Dimmer  : if let cell = cell as? DeviceCollectionCell { UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil) }
            case ControlType.Relay   : if let cell = cell as? ApplianceCollectionCell { UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil) }
            case ControlType.Sensor,
                 ControlType.IntelligentSwitch,
                 ControlType.Gateway : if let cell = cell as? MultiSensorCell { UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil) }
            case ControlType.Climate : if let cell = cell as? ClimateCell { UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil) }
            case ControlType.Curtain : if let cell = cell as? CurtainCollectionCell { UIView.transition(from: cell.backView, to: cell.infoView, duration: 0.5, options: options , completion: nil) }
            default: break
            }
            
            devices[index.row].info = true
        }
    }
    
    @objc func handleTap2 (_ gesture:UIGestureRecognizer) {
        let location = gesture.location(in: deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItem(at: location) {
            
            let cell                            = deviceCollectionView.cellForItem(at: index)
            let controlType                     = devices[index.row].controlType
            let options: UIViewAnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
            
            switch controlType {
            case ControlType.Dimmer      : if let cell = cell as? DeviceCollectionCell { UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil) }
            case ControlType.Relay       : if let cell = cell as? ApplianceCollectionCell { UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil) }
            case ControlType.Sensor,
                 ControlType.IntelligentSwitch,
                 ControlType.Gateway : if let cell = cell as? MultiSensorCell { UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil) }
            case ControlType.Climate     : if let cell = cell as? ClimateCell { UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil) }
            case ControlType.Curtain     : if let cell = cell as? CurtainCollectionCell { UIView.transition(from: cell.infoView, to: cell.backView, duration: 0.5, options: options, completion: nil) }
            default: break
            }
            
            devices[index.row].info = false
        }
    }
    
    func updateDeviceStatus (indexPathRow: Int) {
        let device      = devices[indexPathRow]
        let controlType = device.controlType
        let gateway     = device.gateway
        let channel     = device.channel.intValue
        
        for d in devices { if d.gateway == device.gateway && d.address == device.address { d.stateUpdatedAt = Date() } }
        
        let address = device.moduleAddress
        switch controlType {
        case ControlType.Dimmer,
             ControlType.Relay       : SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
        case ControlType.Climate     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getACStatus(address), gateway: gateway)
        case ControlType.Sensor,
             ControlType.IntelligentSwitch,
             ControlType.Gateway     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getSensorState(address), gateway: gateway)
        case ControlType.Curtain     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: gateway)
        case ControlType.SaltoAccess : SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState(address, lockId: channel), gateway: gateway)
        default: break
        }
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    @objc func refreshVisibleDevicesInScrollView () {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths { updateDeviceStatus (indexPathRow: indexPath.row) }
    }
    
    @objc func refreshCollectionView() {
        deviceCollectionView.reloadData()
    }
    
    @objc func refreshDevice(_ sender:AnyObject) {
        if let button = sender as? UIButton {
            let tag         = button.tag
            let controlType = devices[tag].controlType
            let gateway     = devices[tag].gateway
            let address     = devices[tag].moduleAddress
            
            switch controlType {
            case ControlType.Dimmer:
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            case ControlType.Relay:
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            case ControlType.Curtain:
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            default: break
            }
            
        }
    }
    fileprivate func refreshRunningTimes() {
        if !gotRunningTimes {
            devices.forEach { (device) in
                switch device.controlType {
                case ControlType.Dimmer,
                     ControlType.Relay,
                     ControlType.Curtain:
                    
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(device.moduleAddress, channel: 0xFF), gateway: device.gateway)
                default: break
                }
            }
            gotRunningTimes = true
        }
    }
    
    @objc func oneTap(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        let device               = devices[tag]
        let controlType          = device.controlType
        let address              = device.moduleAddress
        var setDeviceValue:UInt8 = 0
        var skipLevel:UInt8      = 0
        let deviceCurrentValue   = device.currentValue
        
        device.increaseUsageCounterValue()
        
        switch controlType {
        case ControlType.Dimmer:
            if deviceCurrentValue.intValue > 0 {
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
                    byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setDeviceValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: skipLevel),
                    gateway: device.gateway,
                    device: device,
                    oldValue: deviceCurrentValue.intValue,
                    command: NSNumber(value: setDeviceValue)
                )
            })
            
        case ControlType.Relay: // Appliance
            if deviceCurrentValue.intValue > 0 {
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
                    byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setDeviceValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: skipLevel),
                    gateway: device.gateway,
                    device: device,
                    oldValue: deviceCurrentValue.intValue,
                    command: NSNumber(value: setDeviceValue)
                )
            })
            
        default: break
        }
        
        updateCells()
    }
    
    // CLIMATE
    @objc func setACPowerStatus(_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            let device  = devices[tag]
            var command: Byte!
            
            switch device.currentValue {
            case 0x00 : command = 0xFF
            case 0xFF : command = 0x00
            default   : break
            }
            
            device.increaseUsageCounterValue()
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(device.moduleAddress, channel: getByte(device.channel), status: command), gateway: device.gateway)
        }
    }
    
    // CURTAINS
    @objc func openCurtain(_ gestureRecognizer:UITapGestureRecognizer){
        moveCurtain(command: .open, gestureRecognizer: gestureRecognizer)
    }
    @objc func closeCurtain(_ gestureRecognizer:UITapGestureRecognizer) {
        moveCurtain(command: .close, gestureRecognizer: gestureRecognizer)
    }
    @objc func stopCurtain(_ gestureRecognizer:UITapGestureRecognizer) {
        moveCurtain(command: .stop, gestureRecognizer: gestureRecognizer)
    }
    
    private enum CurtainCommand {
        case close
        case open
        case stop
    }
    
    private func moveCurtain(command: CurtainCommand, gestureRecognizer: UITapGestureRecognizer) {
        var commandValue: Byte!
        var commandsForPair: [Byte]
        switch command {
        case .open:
            commandValue = 0xFF
            commandsForPair = [0xFF, 0xFF]
        case .close:
            commandValue = 0x00
            commandsForPair = [0xFF, 0x00]
        case .stop:
            commandValue = 0xEF
            commandsForPair = [0x00, 0x00]
        }
        
        let tag                  = gestureRecognizer.view!.tag
        let device               = devices[tag]
        let controlType          = device.controlType
        let address              = device.moduleAddress
        let setDeviceValue:UInt8 = commandValue
        let deviceCurrentValue   = device.currentValue.intValue
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
            device.increaseUsageCounterValue()
            
            if devicePair == nil {
                device.currentValue = NSNumber(value: setDeviceValue)
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
                device.currentValue       = NSNumber(value: commandsForPair[0])
                devicePair?.currentValue  = NSNumber(value: commandsForPair[1])
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
    @objc func lockSalto(_ gestureRecognizer:UITapGestureRecognizer) {
        engageSalto(command: .lock, gestureRecognizer: gestureRecognizer)
    }
    @objc func unlockSalto(_ gestureRecognizer:UITapGestureRecognizer) {
        engageSalto(command: .unlock, gestureRecognizer: gestureRecognizer)
    }
    @objc func thirdFcnSalto(_ gestureRecognizer:UITapGestureRecognizer) {
        engageSalto(command: .third, gestureRecognizer: gestureRecognizer)
    }
    
    private enum SaltoCommand {
        case lock
        case unlock
        case third
    }
    private func engageSalto(command: SaltoCommand, gestureRecognizer: UITapGestureRecognizer) {
        var commandValue: NSNumber!
        var mode: Int!
        switch command {
        case .lock:
            commandValue = 0
            mode = 3
        case .unlock:
            commandValue = 1
            mode = 2
        case .third:
            commandValue = 0
            mode = 1
        }
        
        let tag                   = gestureRecognizer.view!.tag
        let device                = devices[tag]
        let address               = device.moduleAddress
        let setDeviceValue:UInt8  = 0xFF
        let deviceCurrentValue    = device.currentValue.intValue
        device.currentValue = commandValue
        CoreDataController.sharedInstance.saveChanges()
        
        device.increaseUsageCounterValue()
        
        DispatchQueue.main.async(execute: {
            RunnableList.sharedInstance.checkForSameDevice(
                device: device.objectID,
                newCommand: NSNumber(value: setDeviceValue),
                oldValue: NSNumber(value: deviceCurrentValue)
            )
            _ = RepeatSendingHandler(
                byteArray: OutgoingHandler.setSaltoAccessMode(address, lockId: device.channel.intValue, mode: mode),
                gateway: device.gateway,
                device: device,
                oldValue: deviceCurrentValue,
                command: NSNumber(value: setDeviceValue)
            )
        })
        updateCells()
    }
    
    
    
}

// MARK: - Setup views
extension FavoriteDevicesVC {
    fileprivate func registerDeviceCells() {
//        deviceCollectionView.register(UINib(nibName: String(describing: DeviceCollectionCell.self), bundle: nil), forCellWithReuseIdentifier: DeviceCollectionCell.reuseIdentifier)
//        deviceCollectionView.register(UINib(nibName: String(describing: ApplianceCollectionCell.self), bundle: nil), forCellWithReuseIdentifier: ApplianceCollectionCell.reuseIdentifier)
//        deviceCollectionView.register(UINib(nibName: String(describing: CurtainCollectionCell.self), bundle: nil), forCellWithReuseIdentifier: CurtainCollectionCell.reuseIdentifier)
//        deviceCollectionView.register(UINib(nibName: String(describing: ClimateCell.self), bundle: nil), forCellWithReuseIdentifier: ClimateCell.reuseIdentifier)
//        deviceCollectionView.register(UINib(nibName: String(describing: MultiSensorCell.self), bundle: nil), forCellWithReuseIdentifier: MultiSensorCell.reuseIdentifier)
//        deviceCollectionView.register(UINib(nibName: String(describing: SaltoAccessCell.self), bundle: nil), forCellWithReuseIdentifier: SaltoAccessCell.reuseIdentifier)
//        deviceCollectionView.register(UINib(nibName: String(describing: DefaultCell.self), bundle: nil), forCellWithReuseIdentifier: DefaultCell.reuseIdentifier)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadFavDevices), name: .favoriteDeviceToggled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceNamesAccordingToFilter), name: .favDeviceFilterTypeChanged, object: nil)
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .black
        deviceCollectionView.backgroundColor = .clear
        
        deviceCollectionView.delegate = self
        deviceCollectionView.dataSource = self
    }
    
    fileprivate func setCellSize() {
        collectionViewCellSize = calculateCellSizeForFavorites { deviceCollectionView.collectionViewLayout.invalidateLayout() }
    }
    
    @objc fileprivate func loadFavDevices() {
        if let devices = DatabaseDeviceController.shared.getDevices() {
            self.devices = devices.filter({ (device) -> Bool in device.isFavorite!.boolValue == true })
            updateDeviceNamesAccordingToFilter()
            deviceCollectionView.reloadData()
        }
    }
    
    @objc fileprivate func updateDeviceNamesAccordingToFilter() {
        devices.forEach({ (device) in device.cellTitle = DatabaseDeviceController.shared.returnNameForFavoriteDevice(filterParameter: filterParameter, nameType: filterNameType, device: device) })
        deviceCollectionView.reloadData()
    }
    
    func updateCells() {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell   = deviceCollectionView.cellForItem(at: indexPath)
            let device = devices[indexPath.row]
            let tag    = indexPath.row
            
            if let cell = cell as? DeviceCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = cell as? CurtainCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = cell as? MultiSensorCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = cell as? ClimateCell { cell.setCell(device: device, tag: tag); cell.setNeedsDisplay() }
            else if let cell = cell as? ApplianceCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = cell as? SaltoAccessCell { cell.setCell(device: device, tag: tag); cell.setNeedsDisplay() }
        }
    }
}

// MARK: - Gesture Recognizer Delegate
extension FavoriteDevicesVC: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view! is UISlider { return false }
        return true
    }
}

// MARK: - Big Slider Delegate
extension FavoriteDevicesVC: BigSliderDelegate {
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
            
            let address            = device.moduleAddress
            let deviceCurrentValue = device.currentValue.intValue
            device.currentValue = NSNumber(value: Int(setDeviceValue)*255/100)
            
            device.increaseUsageCounterValue()
            
            DispatchQueue.main.async(execute: {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: device.objectID,
                    newCommand: NSNumber(value: setDeviceValue),
                    oldValue: NSNumber(value: deviceCurrentValue)
                )
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setDeviceValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: skipLevel),
                    gateway: device.gateway,
                    device: device,
                    oldValue: deviceCurrentValue,
                    command: NSNumber(value: setDeviceValue)
                )
            })
        }
    }
}

extension Notification.Name {
    static let favoriteDeviceToggled = Notification.Name("favoriteDeviceToggled")
}
