//
//  MultiSensorCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

// Multisensor 10 in 1 and 6 in 1
class MultiSensorCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var sensorTitle: UILabel!
    @IBOutlet weak var sensorState: UILabel!
    var device:Device!
    func populateCellWithData(_ sensorDevice:Device, tag:Int) {
        device = sensorDevice

        sensorState.font = UIFont(name: "Tahoma", size: 17)

        sensorTitle.isUserInteractionEnabled = true
        sensorTitle.text = device.cellTitle
        sensorTitle.tag = tag
        populateCell(device)
        if device.info {
            infoView.isHidden = false
            backView.isHidden = true
        } else {
            infoView.isHidden = true
            backView.isHidden = false
        }
    }
    func returnDigitalInputModeStateinterpreter (_ device:Device) -> String {
        var digitalInputCurrentValue = " "
        if device.digitalInputMode == NSNumber(value: DigitalInput.DigitalInputMode.NormallyOpen as Int) {
            digitalInputCurrentValue = DigitalInput.NormallyOpen.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(value: DigitalInput.DigitalInputMode.NormallyClosed as Int) {
            digitalInputCurrentValue = DigitalInput.NormallyClosed.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(value: DigitalInput.DigitalInputMode.Generic as Int) {
            digitalInputCurrentValue = DigitalInput.Generic.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(value: DigitalInput.DigitalInputMode.ButtonNormallyOpen as Int) {
            digitalInputCurrentValue = DigitalInput.ButtonNormallyOpen.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(value: DigitalInput.DigitalInputMode.ButtonNormallyClosed as Int) {
            digitalInputCurrentValue = DigitalInput.ButtonNormallyClosed.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(value: DigitalInput.DigitalInputMode.MotionSensor as Int) {
            digitalInputCurrentValue = DigitalInput.MotionSensor.description(Int(device.currentValue))
        }
        return digitalInputCurrentValue
    }
    func refreshDevice(_ device:Device) {
        sensorState.font = UIFont(name: "Tahoma", size: 17)

        sensorState.text = " "
        populateCell(device)
        if device.info {
            infoView.isHidden = false
            backView.isHidden = true
        }else {
            infoView.isHidden = true
            backView.isHidden = false
        }
        // If device is enabled add all interactions
        if device.isEnabled.boolValue {
            disabledCellView.isHidden = true
        } else {
            disabledCellView.isHidden = false
        }
    }
    func populateCell(_ device:Device) {
        if device.numberOfDevices == 10 {
            switch device.channel {
            case 1:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue) °C"
            case 2:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 3:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 9:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue)%"
            case 4:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue) °C"
            case 5:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue) LUX"
            case 6:
                switch Int(device.currentValue) {
                case DeviceValue.MotionSensor.Idle:
                    sensorImage.image = UIImage(named: "sensor_idle")
                    sensorState.text = "Idle"
                case DeviceValue.MotionSensor.Motion:
                    sensorImage.image = UIImage(named: "sensor_motion")
                    sensorState.text = "Motion"
                case DeviceValue.MotionSensor.IdleWarning:
                    sensorImage.image = UIImage(named: "sensor_third")
                    sensorState.text = "Idle Warning"
                case DeviceValue.MotionSensor.ResetTimer:
                    sensorImage.image = UIImage(named: "sensor_third")
                    sensorState.text = "Reset Timer"
                default: break
                }
            case 8:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue)"
            case 7:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue)"
            case 10:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue)"
            default:
                sensorState.text = "..."
            }
        }
        if device.numberOfDevices == 6 {
            switch device.channel {
            case 1:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue) C"
            case 2:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 3:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 4:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue) °C"
            case 5:
                switch Int(device.currentValue) {
                case DeviceValue.MotionSensor.Idle:
                    sensorImage.image = UIImage(named: "sensor_idle")
                    sensorState.text = "Idle"
                case DeviceValue.MotionSensor.Motion:
                    sensorImage.image = UIImage(named: "sensor_motion")
                    sensorState.text = "Motion"
                case DeviceValue.MotionSensor.IdleWarning:
                    sensorImage.image = UIImage(named: "sensor_third")
                    sensorState.text = "Idle Warning"
                case DeviceValue.MotionSensor.ResetTimer:
                    sensorImage.image = UIImage(named: "sensor_third")
                    sensorState.text = "Reset Timer"
                default: break
                }
            case 6:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue)"
            default:
                sensorState.text = "..."
            }
        }
        if device.numberOfDevices == 5 {
            switch device.channel {
            case 1:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue) °C"
            case 2:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 3:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 4:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue) \u{00B0}c"
            case 5:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue)"
            default:
                sensorState.text = "..."
            }
        }
        if device.numberOfDevices == 4 {
            sensorImage.image = device.returnImage(Double(device.currentValue))
            sensorState.text = returnDigitalInputModeStateinterpreter(device)
        }
        if device.numberOfDevices == 3 {
            switch device.channel {
            case 1:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = "\(device.currentValue) °C"
            case 2:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = returnDigitalInputModeStateinterpreter(device)
            case 3:
                sensorImage.image = device.returnImage(Double(device.currentValue))
                sensorState.text = returnDigitalInputModeStateinterpreter(device)
            default:
                sensorState.text = "..."
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
