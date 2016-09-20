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
    func populateCellWithData(sensorDevice:Device, tag:Int) {
        device = sensorDevice

        sensorState.font = UIFont(name: "Tahoma", size: 17)

        sensorTitle.userInteractionEnabled = true
        sensorTitle.text = device.cellTitle
        sensorTitle.tag = tag
        populateCell(device)
        labelID.text = "\(device.channel)"
        labelName.text = "\(device.name)"
        labelCategory.text = "\(DatabaseHandler.sharedInstance.returnCategoryWithId(Int(device.categoryId), location: device.gateway.location))"
        
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location), let name = zone.name{
            labelLevel.text = "\(name)"
        }else{
            labelLevel.text = ""
        }
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.zoneId), location: device.gateway.location), let name = zone.name{
            labelZone.text = "\(name)"
        }else{
            labelZone.text = ""
        }
        if device.info {
            infoView.hidden = false
            backView.hidden = true
        } else {
            infoView.hidden = true
            backView.hidden = false
        }
    }
    func returnDigitalInputModeStateinterpreter (device:Device) -> String {
        var digitalInputCurrentValue = " "
        if device.digitalInputMode == NSNumber(integer: DigitalInput.DigitalInputMode.NormallyOpen) {
            digitalInputCurrentValue = DigitalInput.NormallyOpen.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(integer: DigitalInput.DigitalInputMode.NormallyClosed) {
            digitalInputCurrentValue = DigitalInput.NormallyClosed.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(integer: DigitalInput.DigitalInputMode.Generic) {
            digitalInputCurrentValue = DigitalInput.Generic.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(integer: DigitalInput.DigitalInputMode.ButtonNormallyOpen) {
            digitalInputCurrentValue = DigitalInput.ButtonNormallyOpen.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(integer: DigitalInput.DigitalInputMode.ButtonNormallyClosed) {
            digitalInputCurrentValue = DigitalInput.ButtonNormallyClosed.description(Int(device.currentValue))
        } else if device.digitalInputMode == NSNumber(integer: DigitalInput.DigitalInputMode.MotionSensor) {
            digitalInputCurrentValue = DigitalInput.MotionSensor.description(Int(device.currentValue))
        }
        return digitalInputCurrentValue
    }
    func refreshDevice(device:Device) {
        sensorState.font = UIFont(name: "Tahoma", size: 17)

        sensorState.text = " "
        populateCell(device)
        labelID.text = "\(device.channel)"
        labelName.text = "\(device.name)"
        labelCategory.text = "\(device.categoryId)"
        labelLevel.text = "\(device.parentZoneId)"
        labelZone.text = "\(device.zoneId)"
        if device.info {
            infoView.hidden = false
            backView.hidden = true
        }else {
            infoView.hidden = true
            backView.hidden = false
        }
        // If device is enabled add all interactions
        if device.isEnabled.boolValue {
            disabledCellView.hidden = true
        } else {
            disabledCellView.hidden = false
        }
    }
    func populateCell(device:Device) {
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
                switch device.currentValue {
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
                switch device.currentValue {
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
    
    func returnDigitalInputMode(status:Byte) -> String {
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
