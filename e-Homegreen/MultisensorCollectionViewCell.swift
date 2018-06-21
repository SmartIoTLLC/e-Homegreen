//
//  MultisensorCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/12/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let titleLabelHeight: CGFloat = 18.5
    static let imageInset: CGFloat = 20
    static let itemPadding: CGFloat = 8
    static let infoLabelHeight: CGFloat = 17
    static let verticalSpacing: CGFloat = 13
    static let horizontalSpacing: CGFloat = 5
    static let sensorStateLabelHeight: CGFloat = 20.5
    static let deviceInfoFontSize: CGFloat = 14
    static let deviceInfoValueFontSize: CGFloat = 12
}

class MultisensorCollectionViewCell: BaseDeviceCollectionViewCell {
    
    static let reuseIdentifier: String = "MultisensorCollectionViewCell"
    
    // MARK: - UI components declaration
    private let backTitleLabel: MarqueeLabel = MarqueeLabel()
    private let backSensorImageView: UIImageView = UIImageView()
    private let backSensorStateLabel: DeviceInfoLabel = DeviceInfoLabel()
    
    private let infoIDTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoIDValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoNameTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoNameValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoCategoryTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoCategoryValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoLevelTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoLevelValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoZoneTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoZoneValueLabel: DeviceInfoLabel = DeviceInfoLabel()
    
    private let sensorIdleImage = UIImage(named: "sensor_idle")
    private let sensorMotionImage = UIImage(named: "sensor_motion")
    private let sensorThirdImage = UIImage(named: "sensor_third")
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addBackTitleLabel()
        addBackSensorImageView()
        addBackSensorStateLabel()
        
        addInfoIDTitleLabel()
        addInfoIDValueLabel()
        addInfoNameTitleLabel()
        addInfoNameValueLabel()
        addInfoCategoryTitleLabel()
        addInfoCategoryValueLabel()
        addInfoLevelTitleLabel()
        addInfoLevelValueLabel()
        addInfoZoneTitleLabel()
        addInfoZoneValueLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addBackTitleLabel()
        addBackSensorImageView()
        addBackSensorStateLabel()
        
        addInfoIDTitleLabel()
        addInfoIDValueLabel()
        addInfoNameTitleLabel()
        addInfoNameValueLabel()
        addInfoCategoryTitleLabel()
        addInfoCategoryValueLabel()
        addInfoLevelTitleLabel()
        addInfoLevelValueLabel()
        addInfoZoneTitleLabel()
        addInfoZoneValueLabel()
        
        setupConstraints()
    }
    
    // MARK: - Setup views
    // Back View components
    private func addBackTitleLabel() {
        backTitleLabel.textAlignment = .center
        backTitleLabel.isUserInteractionEnabled = true
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showDeviceParameters(_:)))
        lpgr.minimumPressDuration = 0.5
        backTitleLabel.addGestureRecognizer(lpgr)
        
        backView.addSubview(backTitleLabel)
    }
    private func addBackSensorImageView() {
        backSensorImageView.contentMode = .scaleAspectFit
        
        backView.addSubview(backSensorImageView)
    }
    private func addBackSensorStateLabel() {
        backView.addSubview(backSensorStateLabel)
    }
    
    // Info View components
    private func addInfoIDTitleLabel() {
        infoIDTitleLabel.setText("ID:", fontSize: LocalConstants.deviceInfoFontSize)
        infoIDTitleLabel.textAlignment = .left
        
        infoView.addSubview(infoIDTitleLabel)
    }
    private func addInfoIDValueLabel() {
        infoIDValueLabel.textAlignment = .right
        infoIDValueLabel.adjustsFontSizeToFitWidth = true
        
        infoView.addSubview(infoIDValueLabel)
    }
    private func addInfoNameTitleLabel() {
        infoNameTitleLabel.setText("Name:", fontSize: LocalConstants.deviceInfoFontSize)
        infoNameTitleLabel.textAlignment = .left
        
        infoView.addSubview(infoNameTitleLabel)
    }
    private func addInfoNameValueLabel() {
        infoNameValueLabel.textAlignment = .right
        infoNameValueLabel.adjustsFontSizeToFitWidth = true
        
        infoView.addSubview(infoNameValueLabel)
    }
    private func addInfoCategoryTitleLabel() {
        infoCategoryTitleLabel.textAlignment = .left
        infoCategoryTitleLabel.setText("Category:", fontSize: LocalConstants.deviceInfoFontSize)
        
        infoView.addSubview(infoCategoryTitleLabel)
    }
    private func addInfoCategoryValueLabel() {
        infoCategoryValueLabel.textAlignment = .right
        infoCategoryValueLabel.adjustsFontSizeToFitWidth = true
        
        infoView.addSubview(infoCategoryValueLabel)
    }
    private func addInfoLevelTitleLabel() {
        infoLevelTitleLabel.textAlignment = .left
        infoLevelTitleLabel.setText("Level:", fontSize: LocalConstants.deviceInfoFontSize)
        
        infoView.addSubview(infoLevelTitleLabel)
    }
    private func addInfoLevelValueLabel() {
        infoLevelValueLabel.textAlignment = .right
        infoLevelValueLabel.adjustsFontSizeToFitWidth = true
        
        infoView.addSubview(infoLevelValueLabel)
    }
    private func addInfoZoneTitleLabel() {
        infoZoneTitleLabel.textAlignment = .left
        infoZoneTitleLabel.setText("Zone:", fontSize: LocalConstants.deviceInfoFontSize)
        
        infoView.addSubview(infoZoneTitleLabel)
    }
    private func addInfoZoneValueLabel() {
        infoZoneValueLabel.textAlignment = .right
        infoZoneValueLabel.adjustsFontSizeToFitWidth = true
        
        infoView.addSubview(infoZoneValueLabel)
    }
    
    private func setupConstraints() {
        // Back View
        backTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemPadding)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
        backSensorImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(LocalConstants.imageInset)
            make.trailing.equalToSuperview().inset(LocalConstants.imageInset)
            make.centerY.equalToSuperview()
            make.height.equalTo(backSensorImageView.snp.width)
        }
        
        backSensorStateLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.sensorStateLabelHeight)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
        }
        
        // Info View
        infoCategoryTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoLabelHeight)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(infoCategoryValueLabel.snp.leading).inset(-LocalConstants.horizontalSpacing)
        }
        infoCategoryValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoLabelHeight)
            make.leading.equalTo(infoCategoryTitleLabel.snp.trailing)
        }
        
        infoNameTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(infoCategoryTitleLabel.snp.top).offset(-LocalConstants.verticalSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalTo(infoNameValueLabel.snp.leading).inset(-LocalConstants.horizontalSpacing)
            make.height.equalTo(LocalConstants.infoLabelHeight)
        }
        
        infoNameValueLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(infoCategoryValueLabel.snp.top).offset(-LocalConstants.verticalSpacing)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoLabelHeight)
            make.leading.equalTo(infoNameTitleLabel.snp.trailing)
        }
        
        infoIDTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(infoNameTitleLabel.snp.top).offset(-LocalConstants.verticalSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalTo(infoIDValueLabel.snp.leading).inset(-LocalConstants.horizontalSpacing)
            make.height.equalTo(LocalConstants.infoLabelHeight)
        }
        
        infoIDValueLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(infoNameValueLabel.snp.top).offset(-LocalConstants.verticalSpacing)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoLabelHeight)
            make.leading.equalTo(infoIDTitleLabel.snp.trailing)
        }
        
        infoLevelTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoCategoryTitleLabel.snp.bottom).offset(LocalConstants.verticalSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalTo(infoLevelValueLabel.snp.leading).inset(-LocalConstants.horizontalSpacing)
            make.height.equalTo(LocalConstants.infoLabelHeight)
        }
        
        infoLevelValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoCategoryValueLabel.snp.bottom).offset(LocalConstants.verticalSpacing)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoLabelHeight)
            make.leading.equalTo(infoLevelTitleLabel.snp.trailing)
        }
        
        infoZoneTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoLevelTitleLabel.snp.bottom).offset(LocalConstants.verticalSpacing)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalTo(infoZoneValueLabel.snp.leading).inset(-LocalConstants.horizontalSpacing)
            make.height.equalTo(LocalConstants.infoLabelHeight)
        }
        
        infoZoneValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoLevelValueLabel.snp.bottom).offset(LocalConstants.verticalSpacing)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoLabelHeight)
            make.leading.equalTo(infoZoneTitleLabel.snp.trailing)
        }
    }
    
    // MARK: - Logic
    override func setCell(with device: Device, tag: Int) {
        super.setCell(with: device, tag: tag)
        
        backTitleLabel.tag = tag
        backTitleLabel.attributedText = NSAttributedString(string: device.cellTitle, attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        infoIDValueLabel.setText("\(device.address.intValue)", fontSize: LocalConstants.deviceInfoValueFontSize)
        infoNameValueLabel.setText("\(device.name)", fontSize: LocalConstants.deviceInfoValueFontSize)
        infoCategoryValueLabel.setText("\(device.categoryName)", fontSize: LocalConstants.deviceInfoValueFontSize)
        // TODO: Level & Zone names
        
        setSensorImage(with: device)
        setSensorStateText(with: device)
    }
    
    private func returnDigitalInputModeStateinterpreter(of device: Device) -> String {
        var digitalInputCurrentValue = " "
        
        if let inputMode = device.digitalInputMode?.intValue {
            switch inputMode {
                case DigitalInput.DigitalInputMode.NormallyOpen         : digitalInputCurrentValue = DigitalInput.NormallyOpen.description(device.currentValue.intValue)
                case DigitalInput.DigitalInputMode.NormallyClosed       : digitalInputCurrentValue = DigitalInput.NormallyClosed.description(device.currentValue.intValue)
                case DigitalInput.DigitalInputMode.Generic              : digitalInputCurrentValue = DigitalInput.Generic.description(device.currentValue.intValue)
                case DigitalInput.DigitalInputMode.ButtonNormallyOpen   : digitalInputCurrentValue = DigitalInput.ButtonNormallyOpen.description(device.currentValue.intValue)
                case DigitalInput.DigitalInputMode.ButtonNormallyClosed : digitalInputCurrentValue = DigitalInput.ButtonNormallyClosed.description(device.currentValue.intValue)
                case DigitalInput.DigitalInputMode.MotionSensor         : digitalInputCurrentValue = DigitalInput.MotionSensor.description(device.currentValue.intValue)
                default:
                    break
            }
        }
        
        return digitalInputCurrentValue
    }
    
    private func setSensorStateText(with device: Device) {
        let value  = device.currentValue
        
        var sensorStateText: String?
        
        if device.numberOfDevices == 10 {
            switch device.channel {
                case 1, 4 : sensorStateText = "\(value) °C"
                case 2, 3 : sensorStateText = returnDigitalInputModeStateinterpreter(of: device)
                case 9    : sensorStateText = "\(value)%"
                case 5    : sensorStateText = "\(value) LUX"
                case 6    :
                    switch value.intValue {
                    case DeviceValue.MotionSensor.Idle        : sensorStateText = "Idle"
                    case DeviceValue.MotionSensor.Motion      : sensorStateText = "Motion"
                    case DeviceValue.MotionSensor.IdleWarning : sensorStateText = "Idle Warning"
                    case DeviceValue.MotionSensor.ResetTimer  : sensorStateText = "Reset Timer"
                    default: break
                    }
                case 7, 8, 10 : sensorStateText = "\(value)"
                default       : sensorStateText  = "..."
            }
        }
        
        if device.numberOfDevices == 6 {
            switch device.channel {
                case 1, 4 : sensorStateText = "\(value) °C"
                case 2, 3 : sensorStateText = returnDigitalInputModeStateinterpreter(of: device)
                case 5    :
                    switch value.intValue {
                    case DeviceValue.MotionSensor.Idle          : sensorStateText = "Idle"
                    case DeviceValue.MotionSensor.Motion        : sensorStateText = "Motion"
                    case DeviceValue.MotionSensor.IdleWarning   : sensorStateText = "Idle Warning"
                    case DeviceValue.MotionSensor.ResetTimer    : sensorStateText = "Reset Timer"
                    default: break
                    }
                case 6   : sensorStateText = "\(value)"
                default  : sensorStateText = "..."
            }
        }
        
        if device.numberOfDevices == 5 {
            switch device.channel {
                case 1    : sensorStateText = "\(value) °C"
                case 2, 3 : sensorStateText = returnDigitalInputModeStateinterpreter(of: device)
                case 4    : sensorStateText = "\(value) \u{00B0}c"
                case 5    : sensorStateText = "\(value)"
                default   : sensorStateText  = "..."
            }
        }
        
        if device.numberOfDevices == 4 {
            sensorStateText = returnDigitalInputModeStateinterpreter(of: device)
        }
        
        if device.numberOfDevices == 3 {
            switch device.channel {
                case 1    : sensorStateText = "\(value) °C"
                case 2, 3 : sensorStateText = returnDigitalInputModeStateinterpreter(of: device)
                default   : sensorStateText  = "..."
            }
        }
        
        if let sensorStateText = sensorStateText {
            backSensorStateLabel.setText(sensorStateText, fontSize: 17)
        }
    }
    
    private func setSensorImage(with device: Device) {
        let dValue = Double(device.currentValue)
        let value  = device.currentValue
        
        var sensorImage: UIImage?
        
        if device.numberOfDevices == 10 {
            switch device.channel {
                case 1, 4 : sensorImage = device.returnImage(dValue)
                case 2, 3 : sensorImage = device.returnImage(dValue)
                case 9    : sensorImage = device.returnImage(dValue)
                case 5    : sensorImage = device.returnImage(dValue)
                case 6    :
                    switch value.intValue {
                        case DeviceValue.MotionSensor.Idle        : sensorImage = sensorIdleImage
                        case DeviceValue.MotionSensor.Motion      : sensorImage = sensorMotionImage
                        case DeviceValue.MotionSensor.IdleWarning : sensorImage = sensorThirdImage
                        case DeviceValue.MotionSensor.ResetTimer  : sensorImage = sensorThirdImage
                        default: break
                    }
                case 7, 8, 10 : sensorImage = device.returnImage(dValue)
                default       : break
            }
        }
        
        if device.numberOfDevices == 6 {
            switch device.channel {
                case 1, 4 : sensorImage = device.returnImage(dValue)
                case 2, 3 : sensorImage = device.returnImage(dValue)
                case 5    :
                    switch value.intValue {
                        case DeviceValue.MotionSensor.Idle          : sensorImage = sensorIdleImage
                        case DeviceValue.MotionSensor.Motion        : sensorImage = sensorMotionImage
                        case DeviceValue.MotionSensor.IdleWarning   : sensorImage = sensorThirdImage
                        case DeviceValue.MotionSensor.ResetTimer    : sensorImage = sensorThirdImage
                        default: break
                    }
                case 6   : sensorImage = device.returnImage(dValue)
                default  : break
            }
        }
        
        if device.numberOfDevices == 5 {
            switch device.channel {
                case 1    : sensorImage = device.returnImage(dValue)
                case 2, 3 : sensorImage = device.returnImage(dValue)
                case 4    : sensorImage = device.returnImage(dValue)
                case 5    : sensorImage = device.returnImage(dValue)
                default   : break
            }
        }
        
        if device.numberOfDevices == 4 {
            sensorImage = device.returnImage(dValue)
        }
        
        if device.numberOfDevices == 3 {
            switch device.channel {
                case 1    : sensorImage = device.returnImage(dValue)
                case 2, 3 : sensorImage = device.returnImage(dValue)
                default   : break
            }
        }
        
        backSensorImageView.image = sensorImage
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
}
