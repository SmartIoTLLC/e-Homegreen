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
    @IBOutlet weak var awitchAllowEnergySaving: UISwitch!
    var device:Device?
    
    @IBAction func switchAllowEnergySaving(_ sender: AnyObject) {
        guard let switchAES = sender as? UISwitch else {return}
        device?.allowEnergySaving = NSNumber(value: switchAES.isOn as Bool)
    }
    func refreshDevice(_ device:Device) {
        self.device = device
        temperature.font = UIFont(name: "Tahoma", size: 17)
        temperature.text = "\(device.roomTemperature) \u{00B0}c"
        energySavingImage.isHidden = device.allowEnergySaving == NSNumber(value: true as Bool) ? false : true
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
            temperatureSetPoint.font = UIFont(name: "Tahoma", size: 16)
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
                    modeImage.animationDuration = TimeInterval(fanSpeed)
                    modeImage.animationRepeatCount = 0
                    modeImage.startAnimating()
                }
            default:
                modeImage.stopAnimating()
                modeImage.image = nil
                let mode = device.mode
                temperatureSetPoint.font = UIFont(name: "Tahoma", size: 17)
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
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
