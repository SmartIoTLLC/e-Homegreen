//
//  DeviceCVCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 3/10/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import UIKit

class DeviceCVCell: UICollectionViewCell {
    
  //  override var reuseIdentifier: String? = "deviceVCCell"
    
    let disabledCellView: UIView! = UIView()
    
    let backView: CustomGradientBackground! = CustomGradientBackground()
    let typeOfLight: MarqueeLabel! = MarqueeLabel()
    let picture: UIImageView! = UIImageView()
    let lightSlider: UISlider! = UISlider()
    
    let infoView: CustomGradientBackground! = CustomGradientBackground()
    let lblPowerUsageTitle: UILabel! = UILabel()
    let lblPowerUsage: UILabel! = UILabel()
    let lblVoltage: UILabel! = UILabel()
    let lblElectricity: UILabel! = UILabel()
    let labelRunningTimeTitle: UILabel! = UILabel()
    let labelRunningTime: UILabel! = UILabel()
    
    var refreshButton: CustomGradientButton! = CustomGradientButton()
    
    var device: Device!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupViews()
//        translatesAutoresizingMaskIntoConstraints = false
//        backgroundColor = .red
//    }
    
    func setupViews() {
        setupDisabledView()
        setupInfoViews()
        setupBackViews()
    }
    
    fileprivate func setupBackViews() {
        backView.translatesAutoresizingMaskIntoConstraints = false
        typeOfLight.translatesAutoresizingMaskIntoConstraints = false
        picture.translatesAutoresizingMaskIntoConstraints = false
        lightSlider.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backView)
        backView.addSubview(typeOfLight)
        backView.addSubview(picture)
        backView.addSubview(lightSlider)
        
        setupBackViewConstraints()
        
        picture.contentMode = .scaleAspectFit
        picture.image = #imageLiteral(resourceName: "lightBulb")
        
        typeOfLight.font = .tahoma(size: 15)
        lightSlider.maximumValue = 100
    }
    
    fileprivate func setupInfoViews() {
        infoView.translatesAutoresizingMaskIntoConstraints = false
        lblVoltage.translatesAutoresizingMaskIntoConstraints = false
        lblElectricity.translatesAutoresizingMaskIntoConstraints = false
        labelRunningTime.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoView)
        infoView.addSubview(labelRunningTimeTitle)
        infoView.addSubview(labelRunningTime)
        infoView.addSubview(lblPowerUsage)
        infoView.addSubview(lblPowerUsageTitle)
        infoView.addSubview(lblElectricity)
        infoView.addSubview(lblVoltage)
        infoView.addSubview(refreshButton)

        setupInfoViewConstraints()
        
        labelRunningTimeTitle.text = "Running Time:"
        labelRunningTimeTitle.font = .tahoma(size: 12)
        labelRunningTime.font = .tahoma(size: 10)
        lblPowerUsageTitle.text = "Power usage:"
        lblPowerUsageTitle.font = .tahoma(size: 12)
        lblPowerUsage.font = .tahoma(size: 10)
        lblElectricity.font = .tahoma(size: 10)
        lblVoltage.font = .tahoma(size: 10)
        
        refreshButton.addTarget(self, action: #selector(refreshDeviceStatus), for: .touchUpInside)
    }
    
    fileprivate func setupDisabledView() {
        disabledCellView.translatesAutoresizingMaskIntoConstraints = false
        disabledCellView.isHidden = true
        contentView.addSubview(disabledCellView)
    }
    
    func setCell(device: Device, tag: Int) {
        self.device = device
        
        typeOfLight.text = device.cellTitle
        typeOfLight.tag  = tag
        
        lightSlider.isContinuous = true
        lightSlider.tag          = tag
        
        let deviceValue:Double = { return device.currentValue.doubleValue }() ///255
        
        picture.image                    = device.returnImage(device.currentValue.doubleValue)
        lightSlider.value                = Float(deviceValue)/255 // Slider accepts values 0-1
        picture.isUserInteractionEnabled = true
        picture.tag                      = tag
        
        lblElectricity.text   = "\(device.current.floatValue * 0.01) A"
        lblVoltage.text       = "\(device.voltage.floatValue) V"
        lblPowerUsage.text   = "\(device.current.floatValue * device.voltage.floatValue * 0.01)" + " W"
        labelRunningTime.text = device.runningTime
        
        switch device.info {
        case true:
            infoView.isHidden = false
            backView.isHidden = true
        case false:
            infoView.isHidden = true
            backView.isHidden = false
        }
        
        switch device.warningState {
        case 0: backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor
        case 1: backView.colorTwo = Colors.DirtyRedColor // Upper state
        case 2: backView.colorTwo = Colors.DirtyBlueColor // Lower state
        default: break
        }
        disabledCellView.layer.cornerRadius  = 5
        
        switch device.isEnabled.boolValue {
        case true  :
            disabledCellView.isHidden = true
            typeOfLight.isUserInteractionEnabled = true
        case false :
            disabledCellView.isHidden = false
        }
    }
    
    func refreshDevice(_ device:Device) {
        let deviceValue:Double = { return device.currentValue.doubleValue }() ///255
        
        picture.image = device.returnImage(device.currentValue.doubleValue)
        lightSlider.value = Float(deviceValue/255)  // Slider accepts values from 0 to 1
        
        lblElectricity.text   = "\(device.current.floatValue * 0.01) A"
        lblVoltage.text       = "\(device.voltage.floatValue) V"
        lblPowerUsage.text   = "\(device.current.floatValue * device.voltage.floatValue * 0.01)" + " W"
        labelRunningTime.text = device.runningTime
        
        switch device.info {
        case true:
            infoView.isHidden = false
            backView.isHidden = true
        case false:
            infoView.isHidden = true
            backView.isHidden = false
        }
        
        switch device.warningState {
        case 0: backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor
        case 1: backView.colorTwo = Colors.DirtyRedColor // Upper state
        case 2: backView.colorTwo = Colors.DirtyBlueColor // Lower state
        default: break
        }
        
        switch device.isEnabled.boolValue {
        case true  : disabledCellView.isHidden = true
        case false : disabledCellView.isHidden = false
        }
        
    }
    
    @objc fileprivate func refreshDeviceStatus() {
        let address = device!.getAddress()
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: device!.gateway)
        SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: device!.gateway)
    }
    
}


// MARK: - Constraints
extension DeviceCVCell {
    fileprivate func setupInfoViewConstraints() {
        addConstraints(
            [NSLayoutConstraint(item: infoView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: infoView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: infoView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: infoView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)]
        )
        
        infoView.addConstraints(
            [NSLayoutConstraint(item: labelRunningTimeTitle, attribute: .top, relatedBy: .equal, toItem: infoView, attribute: .top, multiplier: 1.0, constant: 10),
             NSLayoutConstraint(item: labelRunningTimeTitle, attribute: .leading, relatedBy: .equal, toItem: infoView, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: labelRunningTimeTitle, attribute: .trailing, relatedBy: .equal, toItem: infoView, attribute: .trailing, multiplier: 1.0, constant: 0)]
        )
        infoView.addConstraints(
            [NSLayoutConstraint(item: labelRunningTime, attribute: .leading, relatedBy: .equal, toItem: infoView, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: labelRunningTime, attribute: .trailing, relatedBy: .equal, toItem: infoView, attribute: .trailing, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: labelRunningTime, attribute: .top, relatedBy: .equal, toItem: labelRunningTimeTitle, attribute: .bottom, multiplier: 1.0, constant: 5)]
        )
        infoView.addConstraints(
            [NSLayoutConstraint(item: lblPowerUsageTitle, attribute: .top, relatedBy: .equal, toItem: labelRunningTime, attribute: .bottom, multiplier: 1.0, constant: 17),
             NSLayoutConstraint(item: lblPowerUsageTitle, attribute: .leading, relatedBy: .equal, toItem: infoView, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: lblPowerUsageTitle, attribute: .trailing, relatedBy: .equal, toItem: infoView, attribute: .trailing, multiplier: 1.0, constant: 0)]
        )
        infoView.addConstraints(
            [NSLayoutConstraint(item: lblElectricity, attribute: .top, relatedBy: .equal, toItem: lblPowerUsageTitle, attribute: .bottom, multiplier: 1.0, constant: 3),
             NSLayoutConstraint(item: lblElectricity, attribute: .leading, relatedBy: .equal, toItem: infoView, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: lblElectricity, attribute: .trailing, relatedBy: .equal, toItem: infoView, attribute: .trailing, multiplier: 1.0, constant: 0)]
        )
        infoView.addConstraints(
            [NSLayoutConstraint(item: lblVoltage, attribute: .top, relatedBy: .equal, toItem: lblElectricity, attribute: .bottom, multiplier: 1.0, constant: 3),
             NSLayoutConstraint(item: lblVoltage, attribute: .leading, relatedBy: .equal, toItem: infoView, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: lblVoltage, attribute: .trailing, relatedBy: .equal, toItem: infoView, attribute: .trailing, multiplier: 1.0, constant: 0)]
        )
        infoView.addConstraints(
            [NSLayoutConstraint(item: lblPowerUsage, attribute: .top, relatedBy: .equal, toItem: lblVoltage, attribute: .bottom, multiplier: 1.0, constant: 3),
             NSLayoutConstraint(item: lblPowerUsage, attribute: .leading, relatedBy: .equal, toItem: infoView, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: lblPowerUsage, attribute: .trailing, relatedBy: .equal, toItem: infoView, attribute: .trailing, multiplier: 1.0, constant: 0)
            ]
        )
        
        refreshButton.addConstraints(
            [NSLayoutConstraint(item: refreshButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 92),
             NSLayoutConstraint(item: refreshButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)]
        )
        infoView.addConstraints(
            [NSLayoutConstraint(item: refreshButton, attribute: .bottom, relatedBy: .equal, toItem: infoView, attribute: .bottom, multiplier: 1.0, constant: 8),
             NSLayoutConstraint(item: refreshButton, attribute: .centerX, relatedBy: .equal, toItem: infoView, attribute: .centerX, multiplier: 1.0, constant: 0)]
        )
    }
    
    fileprivate func setupBackViewConstraints() {
        addConstraints(
            [NSLayoutConstraint(item: backView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: backView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: backView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: backView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)]
        )
        
        backView.addConstraints(
            [NSLayoutConstraint(item: typeOfLight, attribute: .top, relatedBy: .equal, toItem: backView, attribute: .top, multiplier: 1.0, constant: 8),
             NSLayoutConstraint(item: typeOfLight, attribute: .leading, relatedBy: .equal, toItem: backView, attribute: .leading, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: typeOfLight, attribute: .trailing, relatedBy: .equal, toItem: backView, attribute: .trailing, multiplier: 1.0, constant: 0)]
        )
        
        backView.addConstraints(
            [NSLayoutConstraint(item: picture, attribute: .centerY, relatedBy: .equal, toItem: backView, attribute: .centerY, multiplier: 1.0, constant: 0),
             NSLayoutConstraint(item: picture, attribute: .leading, relatedBy: .equal, toItem: backView, attribute: .leading, multiplier: 1.0, constant: 20),
             NSLayoutConstraint(item: picture, attribute: .trailing, relatedBy: .equal, toItem: backView, attribute: .trailing, multiplier: 1.0, constant: 20)]
        )
        picture.frame = CGRect(x: 20, y: 35, width: 110, height: 110)
        picture.addConstraint(NSLayoutConstraint(item: picture, attribute: .height, relatedBy: .equal, toItem: picture, attribute: .width, multiplier: picture.frame.size.height / picture.frame.size.width, constant: 0))
        
        backView.addConstraints(
            [NSLayoutConstraint(item: lightSlider, attribute: .leading, relatedBy: .equal, toItem: backView, attribute: .leading, multiplier: 1.0, constant: 20),
             NSLayoutConstraint(item: lightSlider, attribute: .trailing, relatedBy: .equal, toItem: backView, attribute: .trailing, multiplier: 1.0, constant: 20),
             NSLayoutConstraint(item: lightSlider, attribute: .bottom, relatedBy: .equal, toItem: backView, attribute: .bottom, multiplier: 1.0, constant: 5)]
        )
    }
}
