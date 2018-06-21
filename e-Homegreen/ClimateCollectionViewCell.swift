//
//  ClimateCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/12/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let infoTitleLabelHeight: CGFloat = 16
    static let infoValueLabelHeight: CGFloat = 12
    static let energySavingLabelSize: CGSize = CGSize(width: 60, height: 34)
    static let itemPadding: CGFloat = 8
    static let backTitleLabelHeight: CGFloat = 18.5
    static let onOffImageSize: CGFloat = 25
    static let temperatureLabelHeight: CGFloat = 21
    static let energySavingImageSize: CGSize = CGSize(width: 17, height: 25)
    static let modeFanImageSize: CGFloat = 46
    static let temperatureLabelSize: CGSize = CGSize(width: 40, height: 21)
    static let switchSize: CGSize = CGSize(width: 51, height: 31)
    static let saveButtonSize: CGSize = CGSize(width: 92, height: 25)
    
    static let temperatureFontSize: CGFloat = 15
    static let deviceInfoFontSize: CGFloat = 10
}

enum ClimateSpeedState: String {
    case low = "Low"
    case med = "Med"
    case high = "High"
    case off = "Off"
}

enum ClimateModeState: String {
    case cool = "Cool"
    case heat = "Heat"
    case fan = "Fan"
    case off = "Off"
}

enum ClimateMode: String {
    case cool = "Cool"
    case heat = "Heat"
    case fan = "Fan"
    case auto = "Auto"
}

private enum ClimateFanSpeed: Double {
    case low = 1.0
    case medium = 0.3
    case high = 0.1
    case off = 0.0
}

class ClimateCollectionViewCell: BaseDeviceCollectionViewCell {
    
    static let reuseIdentifier: String = "ClimateCollectionViewCell"
    
    // MARK: - UI components declaration
    private let backClimateNameLabel: MarqueeLabel = MarqueeLabel()
    private let backOnOffButton: UIButton = UIButton()
    private let backTemperatureLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let backEnergySavingImageView: UIImageView = UIImageView()
    private let backTemperatureSetPointLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let backClimateModeImageView: UIImageView = UIImageView()
    private let backClimateModeLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let backClimateSpeedLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let backFanSpeedImageView: UIImageView = UIImageView()
    
    private let infoPowerUsageTitleLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoElectricityLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoVoltageLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoEnergySavingLabel: DeviceInfoLabel = DeviceInfoLabel()
    private let infoEnergySavingSwitch: UISwitch = UISwitch()
    private let infoSaveButton: CustomGradientButton = CustomGradientButton()
    
    private let animationImages:[UIImage] = [UIImage(named: "h1")!, UIImage(named: "h2")!, UIImage(named: "h3")!, UIImage(named: "h4")!, UIImage(named: "h5")!, UIImage(named: "h6")!, UIImage(named: "h7")!, UIImage(named: "h8")!]
    private let fanLowImage = UIImage(named: "fanlow")
    private let fanMediumImage = UIImage(named: "fanmedium")
    private let fanHighImage   = UIImage(named: "fanhigh")
    private let fanOffImage    = UIImage(named: "fanoff")
    private let fanCoolImage   = #imageLiteral(resourceName: "cool")
    private let fanHeatImage   = #imageLiteral(resourceName: "heat")
    private let fanAutoImage   = #imageLiteral(resourceName: "fanauto")
    private let powerOffImage  = UIImage(named: "poweroff")
    private let powerOnImage   = UIImage(named: "poweron")
    
    private let degrees = "\u{00B0}c"
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addBackClimateNameLabel()
        addBackOnOffButton()
        addBackTemperatureLabel()
        addBackTemperatureSetPointLabel()
        addBackEnergySavingImageView()
        addBackClimateModeImageView()
        addBackClimateModeLabel()
        addBackClimateSpeedLabel()
        addBackFanSpeedImageView()
        
        addInfoPowerUsageTitleLabel()
        addInfoElectricityLabel()
        addInfoVoltageLabel()
        addInfoEnergySavingLabel()
        addInfoEnergySavingSwitch()
        addInfoSaveButton()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addBackClimateNameLabel()
        addBackOnOffButton()
        addBackTemperatureLabel()
        addBackTemperatureSetPointLabel()
        addBackEnergySavingImageView()
        addBackClimateModeImageView()
        addBackClimateModeLabel()
        addBackClimateSpeedLabel()
        addBackFanSpeedImageView()
        
        addInfoPowerUsageTitleLabel()
        addInfoElectricityLabel()
        addInfoVoltageLabel()
        addInfoEnergySavingLabel()
        addInfoEnergySavingSwitch()
        addInfoSaveButton()
        
        setupConstraints()
    }
    
    // MARK: - Setup views
    // Back View components
    private func addBackClimateNameLabel() {
        backClimateNameLabel.font = .tahoma(size: 15)
        backClimateNameLabel.isUserInteractionEnabled = true
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showDeviceParameters(_:)))
        lpgr.minimumPressDuration = 0.5
        backClimateNameLabel.addGestureRecognizer(lpgr)
        
        backView.addSubview(backClimateNameLabel)
    }
    private func addBackOnOffButton() {
        backOnOffButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setACPowerStatus(_:))))
        
        backView.addSubview(backOnOffButton)
    }
    private func addBackTemperatureLabel() {
        backTemperatureLabel.textAlignment = .left
        
        backView.addSubview(backTemperatureLabel)
    }
    private func addBackEnergySavingImageView() {
        backEnergySavingImageView.contentMode = .scaleAspectFit
        backEnergySavingImageView.image = #imageLiteral(resourceName: "green leaf")
        
        backView.addSubview(backEnergySavingImageView)
    }
    private func addBackTemperatureSetPointLabel() {
        backTemperatureSetPointLabel.textAlignment = .right
        
        backView.addSubview(backTemperatureSetPointLabel)
    }
    private func addBackClimateModeImageView() {
        backClimateModeImageView.animationImages = animationImages
        backClimateModeImageView.animationRepeatCount = 0
        
        backView.addSubview(backClimateModeImageView)
    }
    private func addBackClimateModeLabel() {
        backClimateModeLabel.textAlignment = .right
        
        backView.addSubview(backClimateModeLabel)
    }
    private func addBackClimateSpeedLabel() {
        backClimateSpeedLabel.textAlignment = .right
        
        backView.addSubview(backClimateSpeedLabel)
    }
    private func addBackFanSpeedImageView() {
        backView.addSubview(backFanSpeedImageView)
    }
    
    // Info View components
    private func addInfoPowerUsageTitleLabel() {
        infoPowerUsageTitleLabel.setText("Power Usage:", fontSize: 13)
        
        infoView.addSubview(infoPowerUsageTitleLabel)
    }
    private func addInfoElectricityLabel() {
        infoView.addSubview(infoElectricityLabel)
    }
    private func addInfoVoltageLabel() {
        infoView.addSubview(infoVoltageLabel)
    }
    private func addInfoEnergySavingLabel() {
        infoEnergySavingLabel.numberOfLines = 0
        infoEnergySavingLabel.textAlignment = .left
        infoEnergySavingLabel.adjustsFontSizeToFitWidth = true
        infoEnergySavingLabel.setText("Allow energy saving:", fontSize: 12)
        
        infoView.addSubview(infoEnergySavingLabel)
    }
    private func addInfoEnergySavingSwitch() {
        infoView.addSubview(infoEnergySavingSwitch)
    }
    private func addInfoSaveButton() {
        infoSaveButton.setAttributedTitle(
            NSAttributedString(
                string: "Save",
                attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.tahoma(size: 10)]
            )
            , for: UIControlState()
        )
        
        
        infoView.addSubview(infoSaveButton)
    }
    
    private func setupConstraints() {
        backOnOffButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemPadding)
            make.width.height.equalTo(LocalConstants.onOffImageSize)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
        }
        
        backClimateNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backOnOffButton.snp.centerY)
            make.height.equalTo(LocalConstants.backTitleLabelHeight)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalTo(backOnOffButton.snp.leading).inset(-LocalConstants.itemPadding)
        }
        
        backTemperatureLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backClimateNameLabel.snp.bottom).offset(LocalConstants.itemPadding)
            make.leading.equalTo(backClimateNameLabel.snp.leading)
            make.width.equalTo(LocalConstants.temperatureLabelSize.width)
            make.height.equalTo(LocalConstants.temperatureLabelSize.height)
        }
        
        backTemperatureSetPointLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backTemperatureLabel.snp.centerY)
            make.trailing.equalTo(backOnOffButton.snp.trailing)
            make.width.equalTo(LocalConstants.temperatureLabelSize.width)
            make.height.equalTo(LocalConstants.temperatureLabelSize.height)
        }
        
        backEnergySavingImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(backTemperatureSetPointLabel.snp.centerY)
            make.width.equalTo(LocalConstants.energySavingImageSize.width)
            make.height.equalTo(LocalConstants.energySavingImageSize.height)
            make.trailing.equalTo(backTemperatureSetPointLabel.snp.leading).inset(-(LocalConstants.itemPadding / 2))
        }
        
        backClimateModeImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(backTemperatureLabel.snp.leading)
            make.width.height.equalTo(LocalConstants.modeFanImageSize)
        }
        
        backClimateModeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backClimateModeImageView.snp.centerY)
            make.height.equalTo(LocalConstants.temperatureLabelHeight)
            make.trailing.equalTo(backTemperatureSetPointLabel.snp.trailing)
            make.leading.equalTo(backClimateModeImageView.snp.trailing).offset(LocalConstants.itemPadding)
        }
        
        backFanSpeedImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(backClimateModeImageView.snp.leading)
            make.width.height.equalTo(LocalConstants.modeFanImageSize)
            make.bottom.equalToSuperview().offset(-LocalConstants.itemPadding)
        }
        
        backClimateSpeedLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backFanSpeedImageView.snp.centerY)
            make.trailing.equalTo(backClimateModeLabel.snp.trailing)
            make.height.equalTo(LocalConstants.temperatureLabelHeight)
            make.leading.equalTo(backFanSpeedImageView.snp.trailing).offset(LocalConstants.itemPadding)
        }
        
        infoPowerUsageTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemPadding)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoTitleLabelHeight)
        }
        
        infoElectricityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoPowerUsageTitleLabel.snp.bottom).offset(LocalConstants.itemPadding)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoValueLabelHeight)
        }
        
        infoVoltageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoElectricityLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.height.equalTo(LocalConstants.infoValueLabelHeight)
        }
        
        infoEnergySavingLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(LocalConstants.energySavingLabelSize.height)
            make.leading.equalTo(infoVoltageLabel.snp.leading)
            make.trailing.equalTo(infoEnergySavingSwitch.snp.leading).inset(-2)
        }
        
        infoEnergySavingSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.width.equalTo(LocalConstants.switchSize.width)
            make.height.equalTo(LocalConstants.switchSize.height)
        }
        
        infoSaveButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(LocalConstants.itemPadding)
            make.centerX.equalToSuperview()
            make.width.equalTo(LocalConstants.saveButtonSize.width)
            make.height.equalTo(LocalConstants.saveButtonSize.height)
        }
    }
    
    // MARK: - Logic
    override func setCell(with device: Device, tag: Int) {
        super.setCell(with: device, tag: tag)
        
        infoEnergySavingSwitch.tag = tag
        infoEnergySavingSwitch.isOn = device.allowEnergySaving.boolValue
        
        backEnergySavingImageView.isHidden = device.allowEnergySaving.boolValue ? false : true
        
        backClimateNameLabel.attributedText = NSAttributedString(string: device.cellTitle, attributes:[NSForegroundColorAttributeName: UIColor.white])
        backClimateNameLabel.tag = tag
        
        backTemperatureLabel.setText("\(device.roomTemperature) \(degrees)", fontSize: LocalConstants.temperatureFontSize)
        
        backTemperatureSetPointLabel.setText("00 \(degrees)", fontSize: LocalConstants.temperatureFontSize)
        
        backClimateModeLabel.text  = device.mode
        backClimateSpeedLabel.text = device.speed
        
        infoElectricityLabel.setText("\(Float(device.current) * 0.01) A", fontSize: LocalConstants.deviceInfoFontSize)
        infoVoltageLabel.setText("\(Float(device.voltage)) V", fontSize: LocalConstants.deviceInfoFontSize)
        
        backOnOffButton.tag = tag
        backOnOffButton.setImage((device.currentValue == 0) ? powerOffImage : powerOnImage, for: UIControlState())
        
        infoSaveButton.addTap {
            self.saveEnergySavingSettings(of: device)
        }
        
        var fanSpeed   = 0.0
        
        var speedState: ClimateSpeedState = .off
        if let speedStateValue = ClimateSpeedState(rawValue: device.speedState) {
            speedState = speedStateValue
        }
        
        var modeState: ClimateModeState = .off
        if let modeStateValue  = ClimateModeState(rawValue: device.modeState) {
            modeState = modeStateValue
        }
        
        var mode: ClimateMode = .auto
        if let modeValue = ClimateMode(rawValue: device.mode) {
            mode = modeValue
        }
        
        backView.colorTwo = device.filterWarning ? Colors.DirtyRedColor : Colors.MediumGray
        
        if device.currentValue == 255 {
            switch speedState {
                case .low  :
                    backFanSpeedImageView.image = fanLowImage
                    fanSpeed = ClimateFanSpeed.low.rawValue // 1.0
                case .med  :
                    backFanSpeedImageView.image = fanMediumImage
                    fanSpeed = ClimateFanSpeed.medium.rawValue // 0.3
                case .high :
                    backFanSpeedImageView.image = fanHighImage
                    fanSpeed = ClimateFanSpeed.high.rawValue // 0.1
                case .off  :
                    backFanSpeedImageView.image = fanOffImage
                    fanSpeed = ClimateFanSpeed.off.rawValue // 0.0
            }
            
            switch modeState {
                case .cool :
                    backClimateModeImageView.stopAnimating();
                    backClimateModeImageView.image = fanCoolImage;
                    backTemperatureSetPointLabel.text = "\(device.coolTemperature) \(degrees)"
                
                case .heat :
                    backClimateModeImageView.stopAnimating();
                    backClimateModeImageView.image = fanHeatImage;
                    backTemperatureSetPointLabel.text = "\(device.heatTemperature) \(degrees)"
                
                case .fan  :
                    backTemperatureSetPointLabel.text = "\(device.coolTemperature) \(degrees)"
                    backClimateModeImageView.image = (fanSpeed == 0) ? fanAutoImage : animationImages.first
                    
                    backClimateModeImageView.animationDuration = TimeInterval(fanSpeed)
                    
                    (fanSpeed == 0) ? backClimateModeImageView.stopAnimating() :  backClimateModeImageView.startAnimating()
                
                case .off  : backClimateModeImageView.stopAnimating(); backClimateModeImageView.image = nil
                
                switch mode {
                    case .cool : backTemperatureSetPointLabel.text = "\(device.coolTemperature) \(degrees)"
                    case .heat : backTemperatureSetPointLabel.text = "\(device.heatTemperature) \(degrees)"
                    case .fan  : backTemperatureSetPointLabel.text = "\(device.coolTemperature) \(degrees)"
                    case .auto : backTemperatureSetPointLabel.text = "\(device.coolTemperature) \(degrees)"
                }
            }
            
        } else {
            backFanSpeedImageView.image = fanOffImage
            backClimateModeImageView.stopAnimating()
        }
        
    }
    
    private func saveEnergySavingSettings(of device: Device) {
        device.allowEnergySaving = NSNumber(value: infoEnergySavingSwitch.isOn)
        
        let energySavingStatus: Byte = infoEnergySavingSwitch.isOn ? 0x01 : 0x00
        SendingHandler.sendCommand(
            byteArray: OutgoingHandler.setACEnergySaving(device.moduleAddress, channel: device.channel.byteValue, status: energySavingStatus),
            gateway: device.gateway
        )
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
    
    @objc private func setACPowerStatus(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let device = self.getDeviceFromGesture(gestureRecognizer) {
            
            let command: Byte = (device.currentValue == 0x00) ? 0xFF : 0x00
            device.increaseUsageCounterValue()
            
            SendingHandler.sendCommand(
                byteArray: OutgoingHandler.setACStatus(device.moduleAddress, channel: device.channel.byteValue, status: command),
                gateway: device.gateway
            )
        }
    }
}
