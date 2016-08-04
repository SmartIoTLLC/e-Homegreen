//
//  ClimateCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

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
//        labelPowrUsege.text = "\(Float(device.current) * Float(device.voltage) * 0.01)" + " W"
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
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
