//
//  DeviceCollectionViewCells.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/3/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

//Light
class DeviceCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var typeOfLight: MarqueeLabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var lightSlider: UISlider!
    
    @IBOutlet weak var disabledCellView: UIView!
    var device:Device?
    func getDevice (device:Device) {
        self.device = device
    }
    func refreshDevice(device:Device) {
//        let deviceValue = Double(device.currentValue) / 100
        let deviceValue:Double = {
            if Double(device.currentValue) <= 100 {
                return Double(device.currentValue)/100
            } else {
                return Double(device.currentValue)/255
            }
        }()
        picture.image = device.returnImage(Double(device.currentValue))
        lightSlider.value = Float(deviceValue)
        lblElectricity.text = "\(Float(device.current) * 0.01) A"
        lblVoltage.text = "\(Float(device.voltage)) V"
        labelPowrUsege.text = "\(Float(device.current) * Float(device.voltage) * 0.01)" + " W"
        labelRunningTime.text = device.runningTime
        if device.info {
            infoView.hidden = false
            backView.hidden = true
        }else {
            infoView.hidden = true
            backView.hidden = false
        }
        if device.warningState == 0 {
            backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor
        } else if device.warningState == 1 {
            // Uppet state
            backView.colorTwo = Colors.DirtyRedColor
        } else if device.warningState == 2 {
            // Lower state
            backView.colorTwo = Colors.DirtyBlueColor
        }
        // If device is enabled add all interactions
        if device.isEnabled.boolValue {
            disabledCellView.hidden = true
        } else {
            disabledCellView.hidden = false
        }
    }
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    @IBAction func btnRefresh(sender: AnyObject) {
        let address = [UInt8(Int(device!.gateway.addressOne)),UInt8(Int(device!.gateway.addressTwo)),UInt8(Int(device!.address))]
        SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: device!.gateway)
        SendingHandler.sendCommand(byteArray: Function.resetRunningTime(address, channel: 0xFF), gateway: device!.gateway)
    }
}
//Appliance on/off
class ApplianceCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var onOff: UIButton!
    
    func refreshDevice(device:Device) {
        let deviceValue:Double = {
            if Double(device.currentValue) <= 100 {
                return Double(device.currentValue)/100
            } else {
                return Double(device.currentValue)/255
            }
        }()
        image.image = device.returnImage(Double(device.currentValue))
        if deviceValue == 1 {
            onOff.setTitle("ON", forState: .Normal)
        } else if device.currentValue == 0 {
            onOff.setTitle("OFF", forState: .Normal)
        }
        if device.info {
            infoView.hidden = false
            backView.hidden = true
        }else {
            infoView.hidden = true
            backView.hidden = false
        }
        labelRunningTime.text = "\(device.runningTime)"
        lblElectricity.text = "\(Float(device.current) * 0.01) A"
        lblVoltage.text = "\(Float(device.voltage)) V"
        labelPowrUsege.text = "\(Float(device.current) * Float(device.voltage) * 0.01)" + " W"
        // If device is enabled add all interactions
        if device.isEnabled.boolValue {
            disabledCellView.hidden = true
        } else {
            disabledCellView.hidden = false
        }
    }
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
//curtain
class CurtainCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var curtainName: UILabel!
    @IBOutlet weak var curtainImage: UIImageView!
    @IBOutlet weak var curtainSlider: UISlider!
    @IBOutlet weak var curtainState: MarqueeLabel!
    
    func refreshDevice(device:Device) {
        let deviceValue:Double = {
            if Double(device.currentValue) > 100 {
                return Double(device.currentValue) / 255
            } else {
                return Double(device.currentValue) / 100
            }
        }()
        curtainImage.image = device.returnImage(Double(device.currentValue))
        curtainState.text = "\(CurtainModuleState.returnState(Int(device.currentValue)))"
        if device.filterWarning {
            backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor
        } else {
            backView.colorTwo = Colors.DirtyRedColor
        }
        curtainSlider.value = Float(deviceValue)
//        labelRunningTime.text = "\(device.runningTime)"
//        lblElectricity.text = "\(Float(device.current) * 0.01) A"
//        lblVoltage.text = "\(Float(device.voltage)) V"
//        labelPowrUsege.text = "\(Float(device.current) * Float(device.voltage) * 0.01)" + " W"
        
//        lblAddress.text = "\(device.channel)" 
        lblLevel.text = "\(DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), gateway: device.gateway))"
        lblZone.text = "\(DatabaseHandler.returnZoneWithId(Int(device.zoneId), gateway: device.gateway))"
        lblCategory.text = "\(DatabaseHandler.returnCategoryWithId(Int(device.categoryId), gateway: device.gateway))"
        // If device is enabled add all interactions
        if device.isEnabled.boolValue {
            disabledCellView.hidden = true
        } else {
            disabledCellView.hidden = false
        }
        if device.info {
            infoView.hidden = false
            backView.hidden = true
        }else {
            infoView.hidden = true
            backView.hidden = false
        }
    }
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
}
//Door
class DefaultCell: UICollectionViewCell {
    @IBOutlet weak var defaultLabel: UILabel!
}
//Clima
class ClimateCell: UICollectionViewCell {
    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var imageOnOff: UIImageView!
    @IBOutlet weak var climateName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var temperatureSetPoint: UILabel!
    @IBOutlet weak var climateMode: UILabel!
    @IBOutlet weak var modeImage: UIImageView!
    @IBOutlet weak var climateSpeed: UILabel!
    @IBOutlet weak var fanSpeedImage: UIImageView!
    @IBOutlet weak var energySavingImage: UIImageView!
    var device:Device?
    @IBAction func switchAllowEnergySaving(sender: AnyObject) {
        guard let switchAES = sender as? UISwitch else {return}
        device?.allowEnergySaving = NSNumber(bool: switchAES.on)
        let address = [UInt8(Int(device!.gateway.addressOne)),UInt8(Int(device!.gateway.addressTwo)),UInt8(Int(device!.address))]
        let status:Byte = switchAES.on ? 0x01 : 0x00
        SendingHandler.sendCommand(byteArray: Function.setACEnergySaving(address, channel: Byte(Int(device!.channel)), status: status), gateway: device!.gateway)
        
    }
    func refreshDevice(device:Device) {
        self.device = device
        temperature.font = UIFont(name: "DBLCDTempBlack", size: 16)
        temperature.text = "\(device.roomTemperature) \u{00B0}c"
        energySavingImage.hidden = device.allowEnergySaving == NSNumber(bool: true) ? false : true
        if device.filterWarning {
            backView.colorTwo = Colors.DirtyRedColor
        } else {
            backView.colorTwo = Colors.MediumGray
        }
        climateMode.text = device.mode
        climateSpeed.text = device.speed
        var fanSpeed = 0.0
        let speedState = device.speedState
        if device.currentValue == 255 {
            switch speedState {
            case "Low":
                fanSpeedImage.image = UIImage(named: "fanlow")
                fanSpeed = 1
            case "Med" :
                fanSpeedImage.image = UIImage(named: "fanmedium")
                fanSpeed = 0.3
            case "High":
                fanSpeedImage.image = UIImage(named: "fanhigh")
                fanSpeed = 0.1
            default:
                fanSpeedImage.image = UIImage(named: "fanoff")
                fanSpeed = 0.0
            }
            let animationImages:[UIImage] = [UIImage(named: "h1")!, UIImage(named: "h2")!, UIImage(named: "h3")!, UIImage(named: "h4")!, UIImage(named: "h5")!, UIImage(named: "h6")!, UIImage(named: "h7")!, UIImage(named: "h8")!]
            temperatureSetPoint.font = UIFont(name: "DBLCDTempBlack", size: 16)
            let modeState = device.modeState
            switch modeState {
            case "Cool":
                modeImage.stopAnimating()
                modeImage.image = UIImage(named: "cool")
                temperatureSetPoint.text = "\(device.coolTemperature) \u{00B0}c"
            case "Heat":
                modeImage.stopAnimating()
                modeImage.image = UIImage(named: "heat")
                temperatureSetPoint.text = "\(device.heatTemperature) \u{00B0}c"
            case "Fan":
                temperatureSetPoint.text = "\(device.coolTemperature) \u{00B0}c"
                if fanSpeed == 0 {
                    modeImage.image = UIImage(named: "fanauto")
                    modeImage.stopAnimating()
                } else {
                    modeImage.animationImages = animationImages
                    modeImage.animationDuration = NSTimeInterval(fanSpeed)
                    modeImage.animationRepeatCount = 0
                    modeImage.startAnimating()
                }
            default:
                modeImage.stopAnimating()
                modeImage.image = nil
                let mode = device.mode
                temperatureSetPoint.font = UIFont(name: "DBLCDTempBlack", size: 16)
                switch mode {
                case "Cool":
                    temperatureSetPoint.text = "\(device.coolTemperature) \u{00B0}c"
                    
                case "Heat":
                    temperatureSetPoint.text = "\(device.heatTemperature) \u{00B0}c"
                case "Fan":
                    temperatureSetPoint.text = "\(device.coolTemperature) \u{00B0}c"
                default:
                    //  Hoce i tu da zezne
                    temperatureSetPoint.text = "\(device.coolTemperature) \u{00B0}c"
                }
            }
        } else {
            fanSpeedImage.image = UIImage(named: "fanoff")
            modeImage.stopAnimating()
        }
        if device.currentValue == 0 {
            imageOnOff.image = UIImage(named: "poweroff")
            modeImage.image = nil
        } else {
            imageOnOff.image = UIImage(named: "poweron")
        }
        labelPowrUsege.text = "\(Float(device.current) * Float(device.voltage) * 0.01)" + " W"
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
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
//Multisensor 10 in 1 and 6 in 1
class MultiSensorCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var sensorTitle: UILabel!
    @IBOutlet weak var sensorState: UILabel!
    var device:Device!
    func populateCellWithData(sensorDevice:Device, tag:Int) {
        device = sensorDevice
        if device.channel == 1 || device.channel == 4 {
            sensorState.font = UIFont(name: "DBLCDTempBlack", size: 16)
        } else {
            sensorState.font = UIFont(name: "Tahoma", size: 17)
        }
        sensorTitle.userInteractionEnabled = true
        sensorTitle.text = device.cellTitle
        sensorTitle.tag = tag
        populateCell(device)
        labelID.text = "\(device.channel)"
        labelName.text = "\(device.name)"
        labelCategory.text = "\(DatabaseHandler.returnCategoryWithId(Int(device.categoryId), gateway: device.gateway))"
        labelLevel.text = "\(DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), gateway: device.gateway))"
        labelZone.text = "\(DatabaseHandler.returnZoneWithId(Int(device.zoneId), gateway: device.gateway))"
        if device.info {
            infoView.hidden = false
            backView.hidden = true
        } else {
            infoView.hidden = true
            backView.hidden = false
        }
    }
    func returnDigitalInputModeStateinterpreter (device:Device) -> String {
        print(device.digitalInputMode)
        print(Int(device.currentValue))
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
        if device.channel == 1 || device.channel == 4 {
            sensorState.font = UIFont(name: "DBLCDTempBlack", size: 16)
        } else {
            sensorState.font = UIFont(name: "Tahoma", size: 17)
        }
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
                sensorState.text = "\(device.currentValue) C"
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
                sensorState.text = "\(device.currentValue) C"
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
                sensorState.text = "\(device.currentValue) C"
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
                sensorState.text = "\(device.currentValue) C"
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
        if device.numberOfDevices == 3 {
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
class CurtainModule:UICollectionViewCell {
    @IBOutlet weak var title: MarqueeLabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var leftButton: CustomGradientButtonWhite!
    @IBOutlet weak var rightButton: CustomGradientButtonWhite!
    
    func refreshDevice(device:Device) {
        
    }
    
    @IBOutlet weak var channel: MarqueeLabel!
    @IBOutlet weak var name: MarqueeLabel!
    @IBOutlet weak var category: MarqueeLabel!
    @IBOutlet weak var level: MarqueeLabel!
    @IBOutlet weak var deviceZone: MarqueeLabel!
    
}

