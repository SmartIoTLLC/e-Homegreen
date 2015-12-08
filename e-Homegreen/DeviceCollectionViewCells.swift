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
    @IBOutlet weak var typeOfLight: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var lightSlider: UISlider!
    
    @IBOutlet weak var disabledCellView: UIView!
    var device:Device?
    func getDevice (device:Device) {
        self.device = device
    }
    func refreshDevice(device:Device) {
        let deviceValue = Double(device.currentValue) / 100
        if let image = ImageHandler.returnPictures(Int(device.categoryId), deviceValue: deviceValue, motionSensor: false) {
            picture.image = image
        } else {
            if deviceValue == 0 {
                picture.image = UIImage(named: "lightBulb")
            } else if deviceValue > 0 && deviceValue < 0.1 {
                picture.image = UIImage(named: "lightBulb1")
            } else if deviceValue >= 0.1 && deviceValue < 0.2 {
                picture.image = UIImage(named: "lightBulb2")
            } else if deviceValue >= 0.2 && deviceValue < 0.3 {
                picture.image = UIImage(named: "lightBulb3")
            } else if deviceValue >= 0.3 && deviceValue < 0.4 {
                picture.image = UIImage(named: "lightBulb4")
            } else if deviceValue >= 0.4 && deviceValue < 0.5 {
                picture.image = UIImage(named: "lightBulb5")
            } else if deviceValue >= 0.5 && deviceValue < 0.6 {
                picture.image = UIImage(named: "lightBulb6")
            } else if deviceValue >= 0.6 && deviceValue < 0.7 {
                picture.image = UIImage(named: "lightBulb7")
            } else if deviceValue >= 0.7 && deviceValue < 0.8 {
                picture.image = UIImage(named: "lightBulb8")
            } else if deviceValue >= 0.8 && deviceValue < 0.9 {
                picture.image = UIImage(named: "lightBulb9")
            } else {
                picture.image = UIImage(named: "lightBulb10")
            }
        }
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
            backView.colorTwo = UIColor.redColor().CGColor
        } else if device.warningState == 2 {
            // Lower state
            backView.colorTwo = UIColor.blueColor().CGColor
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
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var onOff: UIButton!
    
    func refreshDevice(device:Device) {
        let deviceValue = Double(device.currentValue)/255
        if let image = ImageHandler.returnPictures(Int(device.categoryId), deviceValue: deviceValue, motionSensor: false) {
            self.image.image = image
        } else {
            if device.currentValue == 255 {
                image.image = UIImage(named: "applianceon")
            }
            if device.currentValue == 0{
                image.image = UIImage(named: "applianceoff")
            }
        }
        if device.currentValue == 255 {
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
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var curtainName: UILabel!
    @IBOutlet weak var curtainImage: UIImageView!
    @IBOutlet weak var curtainSlider: UISlider!
    
    func refreshDevice(device:Device) {
        let deviceValue = Double(device.currentValue) / 100
        if let image = ImageHandler.returnPictures(Int(device.categoryId), deviceValue: deviceValue, motionSensor: false) {
            curtainImage.image = image
        } else {
            if deviceValue >= 0 && deviceValue < 0.2 {
                curtainImage.image = UIImage(named: "curtain0")
            } else if deviceValue >= 0.2 && deviceValue < 0.4 {
                curtainImage.image = UIImage(named: "curtain1")
            } else if deviceValue >= 0.4 && deviceValue < 0.6 {
                curtainImage.image = UIImage(named: "curtain2")
            } else if deviceValue >= 0.6 && deviceValue < 0.8 {
                curtainImage.image = UIImage(named: "curtain3")
            } else {
                curtainImage.image = UIImage(named: "curtain4")
            }
        }
        curtainSlider.value = Float(deviceValue)
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
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
//Door
class AccessControllCell: UICollectionViewCell {
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var accessImage: UIImageView!
    
    func refreshDevice(device:Device) {
        
    }
}
//Clima
class ClimateCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageOnOff: UIImageView!
    @IBOutlet weak var climateName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var temperatureSetPoint: UILabel!
    @IBOutlet weak var climateMode: UILabel!
    @IBOutlet weak var modeImage: UIImageView!
    @IBOutlet weak var climateSpeed: UILabel!
    @IBOutlet weak var fanSpeedImage: UIImageView!
    
    func refreshDevice(device:Device) {
        temperature.text = "\(device.roomTemperature) C"
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
            let modeState = device.modeState
            switch modeState {
            case "Cool":
                modeImage.stopAnimating()
                modeImage.image = UIImage(named: "cool")
                temperatureSetPoint.text = "\(device.coolTemperature) C"
            case "Heat":
                modeImage.stopAnimating()
                modeImage.image = UIImage(named: "heat")
                temperatureSetPoint.text = "\(device.heatTemperature) C"
            case "Fan":
                temperatureSetPoint.text = "\(device.coolTemperature) C"
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
                switch mode {
                case "Cool":
                    temperatureSetPoint.text = "\(device.coolTemperature) C"
                case "Heat":
                    temperatureSetPoint.text = "\(device.heatTemperature) C"
                case "Fan":
                    temperatureSetPoint.text = "\(device.coolTemperature) C"
                default:
                    //  Hoce i tu da zezne
                    temperatureSetPoint.text = "\(device.coolTemperature) C"
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
        sensorTitle.userInteractionEnabled = true
        sensorTitle.text = device.cellTitle
        sensorTitle.tag = tag
        if device.numberOfDevices == 10 {
            switch device.channel {
            case 1:
                if let image = ImageHandler.returnPictures(Int(device.categoryId), deviceValue: Double(device.currentValue)/255, motionSensor: false) {
                    sensorImage.image = image
                } else {
                    sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                }
                sensorState.text = "\(device.currentValue) C"
            case 2:
                if device.currentValue == 0 {
                    sensorImage.image = UIImage(named: "applianceoff")
                } else {
                    sensorImage.image = UIImage(named: "applianceon")
                }
                sensorState.text = "\(device.currentValue)"
            case 3:
                if device.currentValue == 0 {
                    sensorImage.image = UIImage(named: "applianceoff")
                } else {
                    sensorImage.image = UIImage(named: "applianceon")
                }
                sensorState.text = "\(device.currentValue)"
            case 4:
                if let image = ImageHandler.returnPictures(Int(device.categoryId), deviceValue: Double(device.currentValue)/255, motionSensor: false) {
                    sensorImage.image = image
                } else {
                    sensorImage.image = UIImage(named: "sensor")
                }
                sensorState.text = "\(device.currentValue)%"
            case 5:
                sensorImage.image = UIImage(named: "sensor_temperature")
                sensorState.text = "\(device.currentValue) C"
            case 6:
                if let image = ImageHandler.returnPictures(2, deviceValue: Double(device.currentValue)/100, motionSensor: false) {
                    sensorImage.image = image
                } else {
                    sensorImage.image = UIImage(named: "sensor_brightness")
                }
                sensorState.text = "\(device.currentValue) LUX"
            case 7:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "sensor_motion")
                } else if device.currentValue == 0 {
                    sensorImage.image = UIImage(named: "sensor_idle")
                } else {
                    sensorImage.image = UIImage(named: "sensor_third")
                }
                if device.currentValue == 1 {
                    sensorState.text = "Motion"
                } else if device.currentValue == 0 {
                    sensorState.text = "Idle"
                } else {
                    sensorState.text = ""
                }
            case 8:
                sensorImage.image = UIImage(named: "sensor_ir_receiver")
                sensorState.text = "\(device.currentValue)"
            case 9:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "tamper_on")
                } else {
                    sensorImage.image = UIImage(named: "tamper_off")
                }
                sensorState.text = "\(device.currentValue)"
            case 10:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "sensor_noise")
                } else {
                    sensorImage.image = UIImage(named: "sensor_no_noise")
                }
                sensorState.text = "\(device.currentValue)"
                sensorState.text = "\(device.currentValue)"
            default:
                sensorState.text = "..."
            }
        }
        if device.numberOfDevices == 6 {
            switch device.channel {
            case 1:
                sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                sensorState.text = "\(device.currentValue) C"
            case 2:
                sensorImage.image = UIImage(named: "sensor")
                sensorState.text = "\(device.currentValue)"
            case 3:
                sensorImage.image = UIImage(named: "sensor")
                sensorState.text = "\(device.currentValue)"
            case 4:
                sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                sensorState.text = "\(device.currentValue) C"
            case 5:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "sensor_motion")
                    sensorState.text = "Motion"
                } else {
                    sensorImage.image = UIImage(named: "sensor_idle")
                    sensorState.text = "Idle"
                }
            case 6:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "tamper_on")
                } else {
                    sensorImage.image = UIImage(named: "tamper_off")
                }
                sensorState.text = "\(device.currentValue)"
            default:
                sensorState.text = "..."
            }
        }
        labelID.text = "\(tag + 1)"
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
    }
    func refreshDevice(device:Device) {
        if device.numberOfDevices == 10 {
            switch device.channel {
            case 1:
                if let image = ImageHandler.returnPictures(Int(device.categoryId), deviceValue: Double(device.currentValue)/255, motionSensor: false) {
                    sensorImage.image = image
                } else {
                    sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                }
                sensorState.text = "\(device.currentValue) C"
            case 2:
                if device.currentValue == 0 {
                    sensorImage.image = UIImage(named: "applianceoff")
                } else {
                    sensorImage.image = UIImage(named: "applianceon")
                }
                sensorState.text = "\(device.currentValue)"
            case 3:
                if device.currentValue == 0 {
                    sensorImage.image = UIImage(named: "applianceoff")
                } else {
                    sensorImage.image = UIImage(named: "applianceon")
                }
                sensorState.text = "\(device.currentValue)"
            case 4:
                if let image = ImageHandler.returnPictures(Int(device.categoryId), deviceValue: Double(device.currentValue)/255, motionSensor: false) {
                    sensorImage.image = image
                } else {
                    sensorImage.image = UIImage(named: "sensor")
                }
                sensorState.text = "\(device.currentValue)%"
            case 5:
                sensorImage.image = UIImage(named: "sensor_temperature")
                sensorState.text = "\(device.currentValue) C"
            case 6:
                if let image = ImageHandler.returnPictures(2, deviceValue: Double(device.currentValue)/100, motionSensor: false) {
                    sensorImage.image = image
                } else {
                    sensorImage.image = UIImage(named: "sensor_brightness")
                }
                sensorState.text = "\(device.currentValue) LUX"
            case 7:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "sensor_motion")
                } else if device.currentValue == 0 {
                    sensorImage.image = UIImage(named: "sensor_idle")
                } else {
                    sensorImage.image = UIImage(named: "sensor_third")
                }
                if device.currentValue == 1 {
                    sensorState.text = "Motion"
                } else if device.currentValue == 0 {
                    sensorState.text = "Idle"
                } else {
                    sensorState.text = ""
                }
            case 8:
                sensorImage.image = UIImage(named: "sensor_ir_receiver")
                sensorState.text = "\(device.currentValue)"
            case 9:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "tamper_on")
                } else {
                    sensorImage.image = UIImage(named: "tamper_off")
                }
                sensorState.text = "\(device.currentValue)"
            case 10:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "sensor_noise")
                } else {
                    sensorImage.image = UIImage(named: "sensor_no_noise")
                }
                sensorState.text = "\(device.currentValue)"
            default:
                sensorState.text = "..."
            }
        }
        if device.numberOfDevices == 6 {
            switch device.channel {
            case 1:
                sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                sensorState.text = "\(device.currentValue) C"
            case 2:
                sensorImage.image = UIImage(named: "sensor")
                sensorState.text = "\(device.currentValue)"
            case 3:
                sensorImage.image = UIImage(named: "sensor")
                sensorState.text = "\(device.currentValue)"
            case 4:
                sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                sensorState.text = "\(device.currentValue) C"
            case 5:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "sensor_motion")
                    sensorState.text = "Motion"
                } else {
                    sensorImage.image = UIImage(named: "sensor_idle")
                    sensorState.text = "Idle"
                }
            case 6:
                if device.currentValue == 1 {
                    sensorImage.image = UIImage(named: "tamper_on")
                } else {
                    sensorImage.image = UIImage(named: "tamper_off")
                }
                sensorState.text = "\(device.currentValue)"
            default:
                sensorState.text = "..."
            }
        }
        labelID.text = "\(0 + 1)"
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
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelLevel: UILabel!
    @IBOutlet weak var labelZone: UILabel!
}

