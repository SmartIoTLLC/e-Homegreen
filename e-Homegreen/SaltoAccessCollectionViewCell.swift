//
//  SaltoAccessCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/12/18.
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

class SaltoAccessCollectionViewCell: BaseDeviceCollectionViewCell {
    
    static let reuseIdentifier: String = "SaltoAccessCollectionViewCell"
    
    // MARK: - UI components declaration
    private let backTitleLabel: MarqueeLabel = MarqueeLabel()
    private let backSaltoImage: UIImageView = UIImageView()
    private let backLockButton: DeviceActionButton = DeviceActionButton()
    private let backUnlockButton: DeviceActionButton = DeviceActionButton()
    
    private let infoAddressTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoAddressValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoLevelTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoLevelValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoZoneTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoZoneValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoCategoryTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoCategoryValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    
    private let image0 = UIImage(named: "14 Security - Lock - 00")
    private let image1 = UIImage(named: "14 Security - Lock - 01")
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addBackTitleLabel()
        addBackSaltoImage()
        addBackLockButton()
        addBackUnlockButton()
        
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
        addBackSaltoImage()
        addBackLockButton()
        addBackUnlockButton()
        
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
    
    private func addBackSaltoImage() {
        backSaltoImage.contentMode = .scaleAspectFit
        backSaltoImage.isUserInteractionEnabled = true
        backSaltoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thirdFcnSalto(_:))))
        
        backView.addSubview(backSaltoImage)
    }
    
    private func addBackLockButton() {
        backLockButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lockSalto(_:))))
        backLockButton.setTitle("LOCK", fontSize: 11)
        
        backView.addSubview(backLockButton)
    }
    
    private func addBackUnlockButton() {
        backUnlockButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unlockSalto(_:))))
        backUnlockButton.setTitle("UNLOCK", fontSize: 11)
        
        backView.addSubview(backUnlockButton)
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
    
    @objc private func showDeviceParameters(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            if gestureRecognizer.state == .began {
                if let dvc = self.parentViewController as? DevicesViewController {
                    dvc.showIntelligentSwitchParameter(tag, devices: dvc.devices)
                } else if let dvc = self.parentViewController as? FavoriteDevicesVC {
                    dvc.showIntelligentSwitchParameter(tag, devices: dvc.devices)
                }
            }
        }
    }
    
    private func setupConstraints() {
        backTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.titleLabelInset)
            make.trailing.equalToSuperview().inset(LocalConstants.titleLabelInset)
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
        backSaltoImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(LocalConstants.imageInset)
            make.trailing.equalToSuperview().inset(LocalConstants.imageInset)
            make.height.equalTo(backSaltoImage.snp.width)
        }
        
        backLockButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-LocalConstants.itemSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.itemSpacing)
            make.trailing.equalTo(self.snp.centerX).inset(-(LocalConstants.itemSpacing / 2))
            make.height.equalTo(LocalConstants.buttonHeight)
        }
        
        backUnlockButton.snp.makeConstraints { (make) in
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
    
    // MARK: - Logic
    override func setCell(with device: Device, tag: Int) {
        super.setCell(with: device, tag: tag)
        
        backTitleLabel.attributedText = NSAttributedString(string: device.cellTitle, attributes:[NSForegroundColorAttributeName: UIColor.white])
        backTitleLabel.tag   = tag
        backSaltoImage.tag   = tag
        backUnlockButton.tag = tag
        backLockButton.tag   = tag
        
        backSaltoImage.image = (device.currentValue == 0) ? image0 : image1
    }
    
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
        
        if let device = self.getDeviceFromGesture(gestureRecognizer) {
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
        }

        reloadDeviceCell(via: gestureRecognizer)        
    }
}
