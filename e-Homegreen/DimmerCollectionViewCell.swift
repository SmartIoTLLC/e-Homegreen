//
//  DimmerCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation

class DimmerCollectionViewCell: BaseDeviceCollectionViewCell {
    
    static let reuseIdentifier: String = "DimmerCollectionViewCell"
    
    private var sliderOldValue: Int?
    
    // MARK: UI components declaration
    private let backTitleLabel: MarqueeLabel = MarqueeLabel()
    private let backLightSlider: SICSlider = SICSlider()
    private let backDeviceImageView: UIImageView = UIImageView()
    
    private let infoTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoRunningTimeLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoRefreshButton: CustomGradientButton = CustomGradientButton()
    private let infoPowerUsageTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoPowerUsageValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoElectricityLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoVoltageLabel: DeviceInfoLabel = DeviceInfoLabel()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addInfoView()
        addBackView()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addInfoView()
        addBackView()
        
        setupConstraints()
    }
    
    // MARK: - Setup views
    private func addInfoView() {
        addInfoTitleLabel()
        addInfoRunningTimeLabel()
        addInfoRefreshButton()
        addInfoPowerUsageTitleLabel()
        addInfoPowerUsageValueLabel()
        addInfoElectricityLabel()
        addInfoVoltageLabel()
    }
    private func addBackView() {
        addBackViewTitleLabel()
        addBackDeviceImageView()
        addBackLightSlider()
    }
    
    // Back View components
    private func addBackViewTitleLabel() {
        backTitleLabel.font = .tahoma(size: 15)
        backTitleLabel.textAlignment = .center
        backTitleLabel.isUserInteractionEnabled = true
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showDeviceParameters(_:)))
        lpgr.minimumPressDuration = 0.5
        backTitleLabel.addGestureRecognizer(lpgr)
        
        backView.addSubview(backTitleLabel)
    }
    private func addBackLightSlider() {
        backLightSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        backLightSlider.addTarget(self, action: #selector(sliderEnded(_:)), for: .touchUpInside)
        backLightSlider.addTarget(self, action: #selector(sliderStarted(_:)), for: .touchDown)
        backLightSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
        
        backView.addSubview(backLightSlider)
    }
    private func addBackDeviceImageView() {
        backDeviceImageView.contentMode = .scaleAspectFit
        backDeviceImageView.isUserInteractionEnabled = true
        let deviceImageLongPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showBigSlider(_:)))
        deviceImageLongPressGesture.minimumPressDuration = 0.5
        if let dvc = self.parentViewController as? DevicesViewController {
            deviceImageLongPressGesture.delegate = dvc
        }
        backDeviceImageView.addGestureRecognizer(deviceImageLongPressGesture)
        backDeviceImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deviceImageTapped(_:))))
        
        backView.addSubview(backDeviceImageView)
    }
    
    // Info View components
    private func addInfoTitleLabel() {
        infoTitleLabel.setText("Running Time:", fontSize: 15)
        
        infoView.addSubview(infoTitleLabel)
    }
    private func addInfoRunningTimeLabel() {
        infoView.addSubview(infoRunningTimeLabel)
    }
    private func addInfoRefreshButton() {
        infoRefreshButton.setAttributedTitle(
            NSAttributedString(
                string: "Refresh",
                attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.tahoma(size: 15)]
            )
            , for: UIControlState()
        )
        
        infoView.addSubview(infoRefreshButton)
    }
    private func addInfoPowerUsageTitleLabel() {
        infoPowerUsageTitleLabel.setText("Power Usage:", fontSize: 12)
        
        infoView.addSubview(infoPowerUsageTitleLabel)
    }
    private func addInfoPowerUsageValueLabel() {
        infoView.addSubview(infoPowerUsageValueLabel)
    }
    private func addInfoElectricityLabel() {
        infoView.addSubview(infoElectricityLabel)
    }
    private func addInfoVoltageLabel() {
        infoView.addSubview(infoVoltageLabel)
    }
    
    private func setupConstraints() {
        // Back View components
        backTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().inset(4)
            make.height.equalTo(18.5)
        }
        
        backDeviceImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(backDeviceImageView.snp.width)
        }
        
        backLightSlider.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(31)
        }
        
        // Info View components
        infoTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(18.5)
        }
        
        infoRunningTimeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(12)
        }
        
        infoRefreshButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(92)
        }
        
        infoPowerUsageTitleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.top.equalTo(infoRunningTimeLabel.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview()
        }
        
        infoElectricityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoPowerUsageTitleLabel.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(12)
        }
        
        infoVoltageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoElectricityLabel.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(12)
        }
        
        infoPowerUsageValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoVoltageLabel.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(12)
        }
        
    }
    
    override func setCell(with device: Device, tag: Int) {
        super.setCell(with: device, tag: tag)
        
        backTitleLabel.attributedText = NSAttributedString(string: device.cellTitle, attributes:[NSForegroundColorAttributeName: UIColor.white])
        backTitleLabel.tag  = tag
        
        let deviceValue:Double = { return Double(device.currentValue) }() // 255
        
        backDeviceImageView.image   = device.returnImage(Double(device.currentValue))
        backDeviceImageView.tag = tag
        
        backLightSlider.value = Float(deviceValue)/255 // Slider accepts values 0-1
        backLightSlider.tag   = tag
        
        infoElectricityLabel.setText("\(Float(device.current) * 0.01) A", fontSize: 10)
        infoVoltageLabel.setText("\(Float(device.voltage)) V", fontSize: 10)
        infoPowerUsageValueLabel.setText("\(Float(device.current) * Float(device.voltage) * 0.01)" + " W", fontSize: 10)
        infoRunningTimeLabel.setText(device.runningTime, fontSize: 10)
        
        switch device.warningState {
            case 0: backView.colorTwo = Colors.MediumGray
            case 1: backView.colorTwo = Colors.DirtyRedColor
            case 2: backView.colorTwo = Colors.DirtyBlueColor
            default: break
        }
        
        infoRefreshButton.addTap {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(device.moduleAddress), gateway: device.gateway)
            SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(device.moduleAddress, channel: 0xFF), gateway: device.gateway)
        }
        
    }
    
    // MARK: - Logic
    @objc private func showBigSlider(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let device = self.getDeviceFromGesture(gestureRecognizer) {
            if device.controlType == ControlType.Dimmer {
                if gestureRecognizer.state == .began {
                    if let devicesViewController = self.parentViewController as? DevicesViewController {
                        if let index = gestureRecognizer.view?.tag {
                            devicesViewController.showBigSliderViewController(for: device, at: index)
//                            devicesViewController.showBigSlider(device, index: index).delegate = self
                        }
                    } else if let devicesViewController = self.parentViewController as? FavoriteDevicesVC {
                        if let index = gestureRecognizer.view?.tag {
                            devicesViewController.showBigSliderViewController(for: device, at: index)
//                            devicesViewController.showBigSlider(device, index: index).delegate = self
                        }
                    }
                }
            }
        }
    }
    
    @objc private func sliderStarted(_ sender: UISlider) {
        if let device = self.getDevice(from: sender) {
            self.setDeviceInControlMode(to: true)
            sliderOldValue = device.currentValue.intValue
        }
    }
    
    @objc fileprivate func sliderValueChanged(_ sender: UISlider) {
        if let device = self.getDevice(from: sender) {
            device.currentValue = NSNumber(value: Int(sender.value * 255))
            
            let deviceValue = device.currentValue.doubleValue
            backDeviceImageView.image = device.returnImage(deviceValue)
            backLightSlider.value = Float(deviceValue / 255)
        }
    }
    
    @objc fileprivate func sliderEnded(_ sender: UISlider) {
        if let device = self.getDevice(from: sender) {
            let valueToSet: Byte = UInt8(Int(device.currentValue.doubleValue * (100/255)))
            
            device.increaseUsageCounterValue()
            
            if let sliderOldValue = sliderOldValue {
                DispatchQueue.main.async {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: valueToSet),
                        oldValue: NSNumber(value: sliderOldValue)
                    )
                    
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: valueToSet, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: device.skipState.byteValue),
                        gateway: device.gateway,
                        device: device,
                        oldValue: sliderOldValue,
                        command: NSNumber(value: valueToSet)
                    )
                }
            }
            
            sliderOldValue = 0
            self.setDeviceInControlMode(to: false)
        }
    }
    
    @objc private func sliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        if let slider = gestureRecognizer.view as? UISlider {
            if let device = self.getDeviceFromGesture(gestureRecognizer) {
                self.setDeviceInControlMode(to: false)
                
                if slider.isHighlighted {
                    sliderEnded(slider)
                    return
                }
                
                let sliderOldValue: Float = slider.value * 100
                let point = gestureRecognizer.location(in: slider)
                let percentage = point.x / slider.bounds.size.width
                let delta = Float(percentage) * Float(slider.maximumValue - slider.minimumValue)
                let value = round((slider.minimumValue + delta) * 255)
                
                if ((value/255) >= 0 && (value/255) <= 255) == false {
                    return
                }
                
                slider.setValue(value / 255, animated: true)
                
                device.oldValue = device.currentValue
                device.currentValue = NSNumber(value: Int(value))
                
                backDeviceImageView.image = device.returnImage(Double(value))
                
                let setValue = UInt8(Int(device.currentValue.doubleValue*100/255))
                
                device.increaseUsageCounterValue()
                
                self.setDeviceInControlMode(to: false)
                
                DispatchQueue.main.async {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setValue),
                        oldValue: NSNumber(value: sliderOldValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: setValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: device.skipState.byteValue),
                        gateway: device.gateway,
                        device: device,
                        oldValue: Int(sliderOldValue),
                        command: NSNumber(value: setValue)
                    )
                }
                
                reloadDeviceCell(via: gestureRecognizer)
            }
        }
        
    }
    
    @objc private func deviceImageTapped(_ gestureRecognizer: UIGestureRecognizer) {
        if let device = self.getDeviceFromGesture(gestureRecognizer) {
            let deviceCurrentValue = device.currentValue
            var setDeviceValue: Byte = 0
            var skipLevel: Byte = 0
            
            if deviceCurrentValue.intValue > 0 {
                device.oldValue = deviceCurrentValue
                setDeviceValue = Byte(0)
            } else {
                if let oldValue = device.oldValue {
                    setDeviceValue = Byte(round(oldValue.floatValue*100/255))
                } else {
                    setDeviceValue = 100
                }
                skipLevel = device.skipState.byteValue
            }
            
            device.currentValue = NSNumber(value: Int(setDeviceValue)*255/100)
            
            DispatchQueue.main.async {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: device.objectID,
                    newCommand: NSNumber(value: setDeviceValue),
                    oldValue: deviceCurrentValue
                )
                
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: setDeviceValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: skipLevel),
                    gateway: device.gateway,
                    device: device,
                    oldValue: deviceCurrentValue.intValue,
                    command: NSNumber(value: setDeviceValue)
                )
            }
            
            reloadDeviceCell(via: gestureRecognizer)
        }
    }
    
    @objc private func showDeviceParameters(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            if gestureRecognizer.state == .began {
                if let dvc = self.parentViewController as? DevicesViewController {
                    dvc.showDimmerParametar(tag, devices: dvc.devices)
                } else if let dvc = self.parentViewController as? FavoriteDevicesVC {
                    dvc.showDimmerParametar(tag, devices: dvc.devices)
                }
            }
        }
    }
}

extension DimmerCollectionViewCell: BigSliderDelegate {
    func valueChanged(_ sender: UISlider) {
        sliderValueChanged(sender)
    }
    
    func endValueChanged(_ sender: UISlider) {
        sliderEnded(sender)
    }
    
    func setONOFFDimmer(_ index: Int, turnOff: Bool) {
        var device: Device?
        
        if let dvc = self.parentViewController as? DevicesViewController {
            device = dvc.devices[index]
        } else if let fdvc = self.parentViewController as? FavoriteDevicesVC {
            device = fdvc.devices[index]
        }
        
        if let device = device {
            if device.controlType == ControlType.Dimmer {
                let setDeviceValue: Byte = turnOff ? 0 : 100
                let skipLevel: Byte = turnOff ? 0 : device.skipState.byteValue
                
                if turnOff {
                    device.oldValue = device.currentValue
                }
                
                let deviceCurrentValue = device.currentValue.intValue
                device.currentValue = NSNumber(value: Int(setDeviceValue)*255/100)
                
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setDeviceValue),
                        oldValue: NSNumber(value: deviceCurrentValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: setDeviceValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: skipLevel),
                        gateway: device.gateway,
                        device: device,
                        oldValue: deviceCurrentValue,
                        command: NSNumber(value: setDeviceValue)
                    )
                })
            }
        }
        
    }
    
}
