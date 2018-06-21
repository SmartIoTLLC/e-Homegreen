//
//  CurtainCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/11/18.
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
}

class CurtainCollectionViewCell: BaseDeviceCollectionViewCell {
    
    static let reuseIdentifier: String = "CurtainCollectionViewCell"
    
    // MARK: - UI components declaration
    private let backTitleLabel: MarqueeLabel = MarqueeLabel()
    private let backCurtainImage: UIImageView = UIImageView()
    private let backCloseButton: DeviceActionButton = DeviceActionButton()
    private let backOpenButton: DeviceActionButton = DeviceActionButton()
    
    private let infoAddressTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoAddressValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoLevelTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoLevelValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoZoneTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoZoneValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoCategoryTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoCategoryValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addBackTitleLabel()
        addBackCurtainImage()
        addBackCloseButton()
        addBackOpenButton()
        
        addInfoAddressTitleLabel()
        addInfoAddressValueLabel()
        addInfoLevelTitleLabel()
        addInfoLevelValueLabel()
        addInfoZoneTitleLabel()
        addInfoZoneValueLabel()
        addInfoCategoryTitleLabel()
        addInfoCategoryValueLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addBackTitleLabel()
        addBackCurtainImage()
        addBackCloseButton()
        addBackOpenButton()
        
        addInfoAddressTitleLabel()
        addInfoAddressValueLabel()
        addInfoLevelTitleLabel()
        addInfoLevelValueLabel()
        addInfoZoneTitleLabel()
        addInfoZoneValueLabel()
        addInfoCategoryTitleLabel()
        addInfoCategoryValueLabel()
        
        setupConstraints()
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
        backCurtainImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stopCurtain(_:))))
        
        backView.addSubview(backCurtainImage)
    }
    
    private func addBackCloseButton() {
        backCloseButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeCurtain(_:))))
        backCloseButton.setTitle("CLOSE", fontSize: 11)
        
        backView.addSubview(backCloseButton)
    }
    
    private func addBackOpenButton() {
        backOpenButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCurtain(_:))))
        backOpenButton.setTitle("OPEN", fontSize: 11)
        
        backView.addSubview(backOpenButton)
    }
    
    // Info View components
    private func addInfoAddressTitleLabel() {
//        infoAddressTitleLabel.setText("Address:", fontSize: LocalConstants.titleLabelFontSize)
        
        infoView.addSubview(infoAddressTitleLabel)
    }
    private func addInfoAddressValueLabel() {
        infoView.addSubview(infoAddressValueLabel)
    }
    private func addInfoLevelTitleLabel() {
//        infoLevelTitleLabel.setText("Level:", fontSize: LocalConstants.titleLabelFontSize)
        
        infoView.addSubview(infoLevelTitleLabel)
    }
    private func addInfoLevelValueLabel() {
        infoView.addSubview(infoLevelValueLabel)
    }
    private func addInfoZoneTitleLabel() {
//        infoZoneTitleLabel.setText("Zone:", fontSize: LocalConstants.titleLabelFontSize)
        
        infoView.addSubview(infoZoneTitleLabel)
    }
    private func addInfoZoneValueLabel() {
        infoView.addSubview(infoZoneValueLabel)
    }
    private func addInfoCategoryTitleLabel() {
//        infoCategoryTitleLabel.setText("Category:", fontSize: LocalConstants.titleLabelFontSize)
        
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
        
        backCloseButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-LocalConstants.itemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.itemSpacing)
            make.trailing.equalTo(self.snp.centerX).inset(-(LocalConstants.itemSpacing / 2))
            make.height.equalTo(LocalConstants.buttonHeight)
        }
        
        backOpenButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-LocalConstants.itemSpacing)
            make.trailing.equalToSuperview().inset(LocalConstants.itemSpacing)
            make.leading.equalTo(self.snp.centerX).offset(LocalConstants.itemSpacing / 2)
            make.height.equalTo(LocalConstants.buttonHeight)
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
        
        backTitleLabel.attributedText = NSAttributedString(string: device.cellTitle, attributes:[NSForegroundColorAttributeName: UIColor.white])
        backTitleLabel.tag  = tag
        backCurtainImage.tag = tag
        backOpenButton.tag = tag
        backCloseButton.tag = tag
        
        setDeviceImage(with: device)                                
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
    
    // CURTAINS
    @objc private func openCurtain(_ gestureRecognizer:UITapGestureRecognizer){
        moveCurtain(command: .open, gestureRecognizer: gestureRecognizer)
    }
    @objc private func closeCurtain(_ gestureRecognizer:UITapGestureRecognizer) {
        moveCurtain(command: .close, gestureRecognizer: gestureRecognizer)
    }
    @objc private func stopCurtain(_ gestureRecognizer:UITapGestureRecognizer) {
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
        
        if let device = self.getDeviceFromGesture(gestureRecognizer) {
            let setDeviceValue:UInt8 = commandValue
            let deviceCurrentValue   = device.currentValue.intValue
            let deviceGroupId        = Byte(device.curtainGroupID.intValue)
            
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
            
            device.increaseUsageCounterValue()
            
            if devicePair == nil {
                device.currentValue = NSNumber(value: setDeviceValue)
            } else {
                device.currentValue       = NSNumber(value: commandsForPair[0])
                devicePair?.currentValue  = NSNumber(value: commandsForPair[1])
            }
            CoreDataController.sharedInstance.saveChanges()
            
            DispatchQueue.main.async {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: device.objectID,
                    newCommand: NSNumber(value: setDeviceValue),
                    oldValue: NSNumber(value: deviceCurrentValue)
                )
                
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setCurtainStatus(device.moduleAddress, value: setDeviceValue, groupId: deviceGroupId),
                    gateway: device.gateway,
                    device: device,
                    oldValue: deviceCurrentValue,
                    command: NSNumber(value: setDeviceValue)
                )
            }
            
            reloadDeviceCell(via: gestureRecognizer)
        }
                
    }
    
}
