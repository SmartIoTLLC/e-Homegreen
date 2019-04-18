//
//  SliderCurtainCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/14/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let titleLabelInset: CGFloat = 4
    static let titleLabelHeight: CGFloat = 18.5
    static let valueLabelHeight: CGFloat = 17
    static let buttonHeight: CGFloat = 28
    static let itemSpacing: CGFloat = 8
    static let imageInset: CGFloat = 20
    static let verticalItemSpacing: CGFloat = 3
    static let titleLabelFontSize: CGFloat = 15
    static let sliderHeight: CGFloat = 31
}

class SliderCurtainCollectionViewCell: BaseDeviceCollectionViewCell {
    
    static let reuseIdentifier: String = "SliderCurtainCollectionViewCell"
    
    private var sliderOldValue: Int?
    
    // MARK: - UI components declaration
    private let backTitleLabel: MarqueeLabel = MarqueeLabel()
    private let backCurtainImage: UIImageView = UIImageView()
    private let backCurtainSlider: UISlider = UISlider()
    
    private let infoAddressTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoAddressValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoLevelTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoLevelValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoZoneTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoZoneValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoCategoryTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoCategoryValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addBackTitleLabel()
        addBackCurtainImage()
        addBackSlider()
        
        addInfoAddressTitleLabel()
        addInfoAddressValueLabel()
        addInfoZoneValueLabel()
        addInfoZoneTitleLabel()
        addInfoLevelTitleLabel()
        addInfoLevelValueLabel()
        addInfoCategoryTitleLabel()
        addInfoCategoryValueLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: - Setup views
    // Back View components
    private func addBackTitleLabel() {
        backTitleLabel.font = .tahoma(size: 15)
        backTitleLabel.textAlignment = .center
        backTitleLabel.isUserInteractionEnabled = true
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showDeviceParameters(_:)))
        lpgr.minimumPressDuration = 0.5
        backTitleLabel.addGestureRecognizer(lpgr)
        
        backView.addSubview(backTitleLabel)
    }
    
    private func addBackCurtainImage() {
        backCurtainImage.contentMode = .scaleAspectFit
        backCurtainImage.isUserInteractionEnabled = true
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showBigSlider(_:)))
        lpgr.minimumPressDuration = 0.5
        backCurtainImage.addGestureRecognizer(lpgr)
        
        backView.addSubview(backCurtainImage)
    }
    
    private func addBackSlider() {
        backCurtainSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        backCurtainSlider.addTarget(self, action: #selector(sliderEnded(_:)), for: .touchUpInside)
        backCurtainSlider.addTarget(self, action: #selector(sliderStarted(_:)), for: .touchDown)
        backCurtainSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
        
        backView.addSubview(backCurtainSlider)
    }
    
    
    // Info View components
    private func addInfoAddressTitleLabel() {
        infoAddressTitleLabel.setText("Address:", fontSize: LocalConstants.titleLabelFontSize)
        
        infoView.addSubview(infoAddressTitleLabel)
    }
    private func addInfoAddressValueLabel() {
        infoView.addSubview(infoAddressValueLabel)
    }
    private func addInfoLevelTitleLabel() {
        infoLevelTitleLabel.setText("Level:", fontSize: LocalConstants.titleLabelFontSize)
        
        infoView.addSubview(infoLevelTitleLabel)
    }
    private func addInfoLevelValueLabel() {
        infoView.addSubview(infoLevelValueLabel)
    }
    private func addInfoZoneTitleLabel() {
        infoZoneTitleLabel.setText("Zone:", fontSize: LocalConstants.titleLabelFontSize)
        
        infoView.addSubview(infoZoneTitleLabel)
    }
    private func addInfoZoneValueLabel() {
        infoView.addSubview(infoZoneValueLabel)
    }
    private func addInfoCategoryTitleLabel() {
        infoCategoryTitleLabel.setText("Category:", fontSize: LocalConstants.titleLabelFontSize)
        
        infoView.addSubview(infoCategoryTitleLabel)
    }
    private func addInfoCategoryValueLabel() {
        infoView.addSubview(infoCategoryValueLabel)
    }
    
    private func setupConstraints() {
        backTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
        backCurtainImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(LocalConstants.imageInset)
            make.trailing.equalToSuperview().inset(LocalConstants.imageInset)
            make.height.equalTo(backCurtainImage.snp.width)
        }
        
        backCurtainSlider.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(LocalConstants.itemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.imageInset)
            make.trailing.equalToSuperview().inset(LocalConstants.imageInset)
            make.height.equalTo(LocalConstants.sliderHeight)
        }
        
        infoAddressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
        infoAddressValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoAddressTitleLabel.snp.bottom).offset(LocalConstants.verticalItemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.valueLabelHeight)
        }
        
        infoLevelTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoAddressValueLabel.snp.bottom).offset(LocalConstants.verticalItemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
        infoLevelValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoLevelTitleLabel.snp.bottom).offset(LocalConstants.verticalItemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.valueLabelHeight)
        }
        
        infoZoneTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoLevelValueLabel.snp.bottom)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
        infoZoneValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoZoneTitleLabel.snp.bottom)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.valueLabelHeight)
        }
        
        infoCategoryTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoZoneValueLabel.snp.bottom).offset(LocalConstants.verticalItemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
        infoCategoryValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoCategoryTitleLabel.snp.bottom).offset(LocalConstants.verticalItemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.valueLabelHeight)
        }
    }
    
    override func setCell(with device: Device, tag: Int) {
        super.setCell(with: device, tag: tag)
        
        infoAddressValueLabel.setText(String(describing: device.moduleAddress), fontSize: LocalConstants.titleLabelFontSize)
        infoCategoryValueLabel.setText(device.controlType, fontSize: LocalConstants.titleLabelFontSize)
        backTitleLabel.attributedText = NSAttributedString(string: device.cellTitle, attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        backTitleLabel.tag  = tag
        backCurtainImage.tag = tag
        backCurtainSlider.tag = tag
        setDeviceImage(with: device)
        
        backCurtainImage.addTap {
            self.toggleDeviceOnOff(at: tag)
        }
        
        print("device current value: \(device.currentValue.floatValue)")
        let deviceValue = device.currentValue.doubleValue
        backCurtainSlider.value = Float(deviceValue) / 255
    }
    
    private func setDeviceImage(with device: Device) {
        let devices = CoreDataController.sharedInstance.fetchDevicesByGatewayAndAddress(device.gateway, address: device.address)
        var devicePair: Device? = nil
        
        for dbDevice in devices {
            if device.address == dbDevice.address {
                if device.curtainGroupID == dbDevice.curtainGroupID {
                    if device.channel.intValue != dbDevice.channel.intValue {
                        if device.isCurtainModeAllowed.boolValue && dbDevice.isCurtainModeAllowed.boolValue {
                            devicePair = dbDevice
                            break
                        }
                    }
                }
            }
        }
        
        if var deviceImages = device.deviceImages?.allObjects as? [DeviceImage] {
            deviceImages.sort { (one, two) -> Bool in
                if let stateOne = one.state, let stateTwo = two.state {
                    if stateOne.intValue < stateTwo.intValue { return true }
                }
                
                return false
            }
            
            var imageName: String?
            
            if let devicePair = devicePair {
                /* Old relay for curtain control
                 
                 Present adequate image depending on the states of channels
                 Closing state:  Ch1 == on (255), Ch3 == off(0)
                 Opening state:  Ch1 == on (255), Ch3 == on(255)
                 Stop state:     Ch1 == off (0), Ch3 == on(255)
                 */
                if device.currentValue.intValue == 255 && devicePair.currentValue.intValue == 0 {
                    if deviceImages.count > 0 { imageName = deviceImages[0].defaultImage }
                    
                } else if device.currentValue.intValue == 255 && devicePair.currentValue.intValue == 255 {
                    if deviceImages.count > 2 { imageName = deviceImages[2].defaultImage }
                    
                } else {
                    if deviceImages.count > 1 { imageName = deviceImages[1].defaultImage }
                }
            } else {
                /* Three-state module */
                
                switch device.currentValue.intValue {
                case 255 : imageName = deviceImages[2].defaultImage
                case 0   : imageName = deviceImages[0].defaultImage
                default  : imageName = deviceImages[1].defaultImage
                }
            }
            
            if let imageName = imageName, let image = UIImage(named: imageName) {
                backCurtainImage.image = image
            }
        }
    }
    
    // MARK: - Logic
    @objc private func showDeviceParameters(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            if gestureRecognizer.state == .began {
                if let dvc = self.parentViewController as? DevicesViewController {
                    dvc.showRelayParametar(tag, devices: dvc.devices)
                } else if let dvc = self.parentViewController as? FavoriteDevicesVC {
                    dvc.showRelayParametar(tag, devices: dvc.devices)
                }
            }
        }
    }
    
    // MARK: - Logic
    @objc private func showBigSlider(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let device = self.getDeviceFromGesture(gestureRecognizer) {
//            if device.controlType == ControlType.Dimmer {
                if gestureRecognizer.state == .began {
                    if let devicesViewController = self.parentViewController as? DevicesViewController {
                        if let index = gestureRecognizer.view?.tag {
                            devicesViewController.showBigSlider(device, index: index).delegate = self
                        }
                    } else if let devicesViewController = self.parentViewController as? FavoriteDevicesVC {
                        if let index = gestureRecognizer.view?.tag {
                            devicesViewController.showBigSlider(device, index: index).delegate = self
                        }
                    }
                }
//            }
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
            setDeviceImage(with: device)
            backCurtainSlider.value = Float(deviceValue / 255)
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
                        byteArray: OutgoingHandler.setCurtainStatus(device.moduleAddress, value: valueToSet, groupId: device.curtainGroupID.byteValue),
                        gateway: device.gateway,
                        device: device,
                        oldValue: sliderOldValue,
                        command: NSNumber(value: valueToSet)
                    )
//                    _ = RepeatSendingHandler(
//                        byteArray: OutgoingHandler.setCurtainStatus(device.moduleAddress, value: valueToSet, groupId: device.curtainGroupID.byteValue),
//                        gateway: device.gateway,
//                        device: device,
//                        oldValue: sliderOldValue,
//                        command: NSNumber(value: valueToSet)
//                    )
                }
            }
            
            sliderOldValue = nil
            self.setDeviceInControlMode(to: false)
            self.reloadDeviceCell(at: sender.tag)
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
                
//                backDeviceImageView.image = device.returnImage(Double(value))
                
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
                        byteArray: OutgoingHandler.setCurtainStatus(device.moduleAddress, value: setValue, groupId: device.curtainGroupID.byteValue),
                        gateway: device.gateway,
                        device: device,
                        oldValue: Int(sliderOldValue),
                        command: NSNumber(value: setValue)
                    )
//                    _ = RepeatSendingHandler(
//                        byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: setValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: device.skipState.byteValue),
//                        gateway: device.gateway,
//                        device: device,
//                        oldValue: Int(sliderOldValue),
//                        command: NSNumber(value: setValue)
//                    )
                    
                    self.reloadDeviceCell(via: gestureRecognizer)
                }
                
            }
        }
        
    }
}

extension SliderCurtainCollectionViewCell: BigSliderDelegate {
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
            
            /* TODO: check */
            let setDeviceValue: Byte = turnOff ? 0 : 100
//            let skipLevel: Byte = turnOff ? 0 : device.skipState.byteValue
            
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
                    byteArray: OutgoingHandler.setCurtainStatus(device.moduleAddress, value: setDeviceValue, groupId: device.curtainGroupID.byteValue),
                    gateway: device.gateway,
                    device: device,
                    oldValue: deviceCurrentValue,
                    command: NSNumber(value: setDeviceValue)
                )
//                _ = RepeatSendingHandler(
//                    byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: setDeviceValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: skipLevel),
//                    gateway: device.gateway,
//                    device: device,
//                    oldValue: deviceCurrentValue,
//                    command: NSNumber(value: setDeviceValue)
//                )
                
                self.reloadDeviceCell(at: index)
            })
            
        }
        
    }
    
    fileprivate func toggleDeviceOnOff(at index: Int) {
        var device: Device?
        
        if let dvc = self.parentViewController as? DevicesViewController {
            device = dvc.devices[index]
        } else if let fdvc = self.parentViewController as? FavoriteDevicesVC {
            device = fdvc.devices[index]
        }
        
        setONOFFDimmer(index, turnOff: device?.currentValue != 0)
    }
    
}
