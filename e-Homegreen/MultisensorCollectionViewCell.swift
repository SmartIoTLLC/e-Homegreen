//
//  MultisensorCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 3/5/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit

class MultisensorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var sensorTitle: UILabel!
    @IBOutlet weak var sensorState: UILabel!
    var device:Device!
    
    let sensorIdleImage = UIImage(named: "sensor_idle")
    let sensorMotionImage = UIImage(named: "sensor_motion")
    let sensorThirdImage = UIImage(named: "sensor_third")
    
    func setCell(device: Device, tag: Int ) {
        disabledCellView.tag = tag
        disabledCellView.layer.cornerRadius = 5
        
        if device.isEnabled.boolValue { disabledCellView.isHidden = true } else { disabledCellView.isHidden = false }
        
        self.device = device
        
        sensorState.font = .tahoma(size: 15)
        
        sensorTitle.isUserInteractionEnabled = true
        sensorTitle.text                     = device.cellTitle
        sensorTitle.tag                      = tag
        populateCell(device)
        
        if device.info { infoView.isHidden = false; backView.isHidden = true } else { infoView.isHidden = true; backView.isHidden = false }
    }
    
    func returnDigitalInputModeStateinterpreter (_ device:Device) -> String {
        var digitalInputCurrentValue = " "
        
        if let inputMode = device.digitalInputMode {
            switch inputMode {
                case NSNumber(value: DigitalInput.DigitalInputMode.NormallyOpen)         : digitalInputCurrentValue = DigitalInput.NormallyOpen.description(device.currentValue.intValue)
                case NSNumber(value: DigitalInput.DigitalInputMode.NormallyClosed)       : digitalInputCurrentValue = DigitalInput.NormallyClosed.description(device.currentValue.intValue)
                case NSNumber(value: DigitalInput.DigitalInputMode.Generic)              : digitalInputCurrentValue = DigitalInput.Generic.description(device.currentValue.intValue)
                case NSNumber(value: DigitalInput.DigitalInputMode.ButtonNormallyOpen)   : digitalInputCurrentValue = DigitalInput.ButtonNormallyOpen.description(device.currentValue.intValue)
                case NSNumber(value: DigitalInput.DigitalInputMode.ButtonNormallyClosed) : digitalInputCurrentValue = DigitalInput.ButtonNormallyClosed.description(device.currentValue.intValue)
                case NSNumber(value: DigitalInput.DigitalInputMode.MotionSensor)         : digitalInputCurrentValue = DigitalInput.MotionSensor.description(device.currentValue.intValue)
                default: break
            }
        }

        return digitalInputCurrentValue
    }
    
    func refreshDevice(_ device:Device) {
        sensorState.font = .tahoma(size: 15)
        
        sensorState.text = " "
        populateCell(device)
        
        if device.info { infoView.isHidden = false; backView.isHidden = true } else { infoView.isHidden = true; backView.isHidden = false }
        
        // If device is enabled add all interactions
        if device.isEnabled.boolValue { disabledCellView.isHidden = true } else { disabledCellView.isHidden = false }
    }
    
    func populateCell(_ device:Device) {
        let dValue = device.currentValue.doubleValue
        let value  = device.currentValue
        
        if device.numberOfDevices == 10 {
            switch device.channel {
            case 1, 4 : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value) °C"
            case 2, 3 : sensorImage.image = device.returnImage(dValue); sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 9    : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value)%"
            case 5    : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value) LUX"
            case 6    :
                switch value.intValue {
                case DeviceValue.MotionSensor.Idle        : sensorImage.image = sensorIdleImage; sensorState.text = "Idle"
                case DeviceValue.MotionSensor.Motion      : sensorImage.image = sensorMotionImage; sensorState.text = "Motion"
                case DeviceValue.MotionSensor.IdleWarning : sensorImage.image = sensorThirdImage; sensorState.text = "Idle Warning"
                case DeviceValue.MotionSensor.ResetTimer  : sensorImage.image = sensorThirdImage; sensorState.text = "Reset Timer"
                default: break
                }
            case 7, 8, 10 : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value)"
            default       : sensorState.text  = "..."
            }
        }
        
        if device.numberOfDevices == 6 {
            switch device.channel {
            case 1, 4  : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value) °C"
            case 2, 3 : sensorImage.image = device.returnImage(dValue); sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 5    :
                switch value.intValue {
                case DeviceValue.MotionSensor.Idle          : sensorImage.image = sensorIdleImage; sensorState.text = "Idle"
                case DeviceValue.MotionSensor.Motion        : sensorImage.image = sensorMotionImage; sensorState.text = "Motion"
                case DeviceValue.MotionSensor.IdleWarning   : sensorImage.image = sensorThirdImage; sensorState.text = "Idle Warning"
                case DeviceValue.MotionSensor.ResetTimer    : sensorImage.image = sensorThirdImage; sensorState.text = "Reset Timer"
                default: break
                }
            case 6   : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value)"
            default  : sensorState.text = "..."
            }
        }
        
        if device.numberOfDevices == 5 {
            switch device.channel {
            case 1    : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value) °C"
            case 2, 3 : sensorImage.image = device.returnImage(dValue); sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 4    : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value) \u{00B0}c"
            case 5    : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value)"
            default   : sensorState.text  = "..."
            }
        }
        
        if device.numberOfDevices == 4 { sensorImage.image = device.returnImage(dValue); sensorState.text = returnDigitalInputModeStateinterpreter(device) }
        
        if device.numberOfDevices == 3 {
            switch device.channel {
            case 1    : sensorImage.image = device.returnImage(dValue); sensorState.text = "\(value) °C"
            case 2, 3 : sensorImage.image = device.returnImage(dValue); sensorState.text = returnDigitalInputModeStateinterpreter(device)
            default   : sensorState.text  = "..."
            }
        }
        
    }
    
    func returnDigitalInputMode(_ status:Byte) -> String {
        return ""
    }
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelLevel: UILabel!
    @IBOutlet weak var labelZone: UILabel!

}
