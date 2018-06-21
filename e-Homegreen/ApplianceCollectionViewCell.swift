//
//  ApplianceCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let itemPadding: CGFloat = 8
    static let titleLabelHeight: CGFloat = 18.5
    static let onOffButtonSize: CGSize = CGSize(width: 60, height: 30)
    static let imageInset: CGFloat = 20
    static let infoTitleLabelHeight: CGFloat = 14
    static let infoValueLabelHeight: CGFloat = 12
    static let refreshButtonSize: CGSize = CGSize(width: 92, height: 30)
    static let infoTitleFontSize: CGFloat = 12
    static let infoValueFontSize: CGFloat = 10
}

class ApplianceCollectionViewCell: BaseDeviceCollectionViewCell {
    
    static let reuseIdentifier: String = "ApplianceCollectionViewCell"
    
    // MARK: - UI components declaration
    private let backTitleLabel: MarqueeLabel = MarqueeLabel()
    private let backOnOffButton: DeviceActionButton = DeviceActionButton()
    private let backApplianceImageView: UIImageView = UIImageView()
    
    private let infoRunningTimeTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoRunningTimeValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoPowerUsageTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoElectricityLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoVoltageLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoPowerUsageValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoRefreshButton: DeviceActionButton = DeviceActionButton()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addBackTitleLabel()
        addBackOnOfButton()
        addApplianceImageView()
        
        addInfoRunningTimeTitleLabel()
        addInfoRunningTimeValueLabel()
        addInfoPowerUsageTitleLabel()
        addInfoPowerUsageValueLabel()
        addInfoElectricityLabel()
        addInfoVoltageLabel()
        addInfoRefreshButton()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addBackTitleLabel()
        addBackOnOfButton()
        addApplianceImageView()
        
        addInfoRunningTimeTitleLabel()
        addInfoRunningTimeValueLabel()
        addInfoPowerUsageTitleLabel()
        addInfoPowerUsageValueLabel()
        addInfoElectricityLabel()
        addInfoVoltageLabel()
        addInfoRefreshButton()
        
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
    private func addApplianceImageView() {
        backApplianceImageView.contentMode = .scaleAspectFit
        backApplianceImageView.isUserInteractionEnabled = true
        backApplianceImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleDeviceState(_:))))
        
        backView.addSubview(backApplianceImageView)
    }
    private func addBackOnOfButton() {
        backOnOffButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleDeviceState(_:))))
        
        backView.addSubview(backOnOffButton)
    }
    
    // Info View components
    private func addInfoRunningTimeTitleLabel() {
        infoRunningTimeTitleLabel.setText("Running Time:", fontSize: LocalConstants.infoTitleFontSize)
        
        infoView.addSubview(infoRunningTimeTitleLabel)
    }
    private func addInfoRunningTimeValueLabel() {
        infoView.addSubview(infoRunningTimeValueLabel)
    }
    private func addInfoPowerUsageTitleLabel() {
        infoPowerUsageTitleLabel.setText("Power Usage:", fontSize: LocalConstants.infoTitleFontSize)
        
        infoView.addSubview(infoPowerUsageTitleLabel)
    }
    private func addInfoElectricityLabel() {
        infoView.addSubview(infoElectricityLabel)
    }
    private func addInfoVoltageLabel() {
        infoView.addSubview(infoVoltageLabel)
    }
    private func addInfoPowerUsageValueLabel() {
        infoView.addSubview(infoPowerUsageValueLabel)
    }
    private func addInfoRefreshButton() {
        infoRefreshButton.setTitle("Refresh", fontSize: LocalConstants.infoValueFontSize)
        
        infoView.addSubview(infoRefreshButton)
    }
    
    private func setupConstraints() {
        backTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemPadding)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding / 2)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding / 2)
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
        backApplianceImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(LocalConstants.imageInset)
            make.trailing.equalToSuperview().inset(LocalConstants.imageInset)
            make.width.equalTo(backApplianceImageView.snp.width)
        }
        
        backOnOffButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-LocalConstants.itemPadding)
            make.width.equalTo(LocalConstants.onOffButtonSize.width)
            make.height.equalTo(LocalConstants.onOffButtonSize.height)
            make.centerX.equalToSuperview()
        }
        
        infoRunningTimeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemPadding)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding / 2)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding / 2)
            make.height.equalTo(LocalConstants.infoTitleLabelHeight)
        }
        
        infoRunningTimeValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoRunningTimeTitleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding / 2)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding / 2)
            make.height.equalTo(LocalConstants.infoValueLabelHeight)
        }
        
        infoPowerUsageTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoRunningTimeValueLabel.snp.bottom).offset(17)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding / 2)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding / 2)
            make.height.equalTo(LocalConstants.infoTitleLabelHeight)
        }
        
        infoElectricityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoPowerUsageTitleLabel.snp.bottom).offset(1)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding / 2)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding / 2)
            make.height.equalTo(LocalConstants.infoValueLabelHeight)
        }
        
        infoVoltageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoElectricityLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding / 2)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding / 2)
            make.height.equalTo(LocalConstants.infoValueLabelHeight)
        }
        
        infoPowerUsageValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoVoltageLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding / 2)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding / 2)
            make.height.equalTo(LocalConstants.infoValueLabelHeight)
        }
        
        infoRefreshButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-LocalConstants.itemPadding)
            make.centerX.equalToSuperview()
            make.width.equalTo(LocalConstants.refreshButtonSize.width)
            make.height.equalTo(LocalConstants.refreshButtonSize.height)
        }
    }
    
    // MARK: - Logic
    override func setCell(with device: Device, tag: Int) {
        super.setCell(with: device, tag: tag)
        
        backTitleLabel.attributedText = NSAttributedString(string: device.cellTitle, attributes:[NSForegroundColorAttributeName: UIColor.white])
        backTitleLabel.tag = tag
        
        let deviceValue:Double = { return Double(device.currentValue) }()
        
        backApplianceImageView.image = device.returnImage(Double(device.currentValue))
        backApplianceImageView.tag = tag
        
        backOnOffButton.tag = tag
        backOnOffButton.setTitle((deviceValue == 255) ? "ON" : "OFF", fontSize: LocalConstants.infoTitleFontSize)
        
        infoRunningTimeValueLabel.setText("\(device.runningTime)", fontSize: LocalConstants.infoValueFontSize)
        infoElectricityLabel.setText("\(Float(device.current) * 0.01) A", fontSize: LocalConstants.infoValueFontSize)
        infoVoltageLabel.setText("\(Float(device.voltage)) V", fontSize: LocalConstants.infoValueFontSize)
        infoPowerUsageValueLabel.setText("\(Float(device.current) * Float(device.voltage) * 0.01)" + " W", fontSize: LocalConstants.infoValueFontSize)

        infoRefreshButton.addTap {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(device.moduleAddress), gateway: device.gateway)
            SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(device.moduleAddress, channel: 0xFF), gateway: device.gateway)
        }

    }
    
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
    
    @objc private func toggleDeviceState(_ gestureRecognizer: UIGestureRecognizer) {
        if let device = self.getDeviceFromGesture(gestureRecognizer) {
            
            let deviceCurrentValue   = device.currentValue
            
            device.increaseUsageCounterValue()
            
            let setDeviceValue: Byte = (deviceCurrentValue.intValue > 0) ? 0 : 255
            let skipLevel: Byte = (deviceCurrentValue.intValue > 0) ? 0 : device.skipState.byteValue
            
            device.currentValue = NSNumber(value: Int(setDeviceValue))
            
            DispatchQueue.main.async(execute: {
                RunnableList.sharedInstance.checkForSameDevice(
                    device: device.objectID,
                    newCommand: NSNumber(value: setDeviceValue),
                    oldValue: deviceCurrentValue
                )
                _ = RepeatSendingHandler(
                    byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: setDeviceValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: skipLevel),
                    gateway: device.gateway,
                    device: device,
                    oldValue: Int(deviceCurrentValue),
                    command: NSNumber(value: setDeviceValue)
                )
            })
            
            reloadDeviceCell(via: gestureRecognizer)            
        }

    }
}
