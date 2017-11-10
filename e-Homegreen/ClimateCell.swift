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
    
    let animationImages:[UIImage] = [UIImage(named: "h1")!, UIImage(named: "h2")!, UIImage(named: "h3")!, UIImage(named: "h4")!, UIImage(named: "h5")!, UIImage(named: "h6")!, UIImage(named: "h7")!, UIImage(named: "h8")!]
    let fanLowImage = UIImage(named: "fanlow")
    let fanMediumImage = UIImage(named: "fanmedium")
    let fanHighImage = UIImage(named: "fanhigh")
    let fanOffImage = UIImage(named: "fanoff")
    let fanCoolImage = #imageLiteral(resourceName: "cool")
    let fanHeatImage = #imageLiteral(resourceName: "heat")
    let fanAutoImage = #imageLiteral(resourceName: "fanauto")
    
    let powerOffImage = UIImage(named: "poweroff")
    let powerOnImage = UIImage(named: "poweron")
    
    let degrees = "\u{00B0}c"
    
    var device:Device?
    
    @IBAction func switchAllowEnergySaving(_ sender: AnyObject) {
        guard let switchAES = sender as? UISwitch else { return }
        device?.allowEnergySaving = NSNumber(value: switchAES.isOn as Bool)
        let address = [UInt8(Int(device!.gateway.addressOne)),UInt8(Int(device!.gateway.addressTwo)),UInt8(Int(device!.address))]
        let status:Byte = switchAES.isOn ? 0x01 : 0x00
        SendingHandler.sendCommand(byteArray: OutgoingHandler.setACEnergySaving(address, channel: Byte(Int(device!.channel)), status: status), gateway: device!.gateway)
    }
    
    func setCell(device: Device, tag: Int) {
        self.device = device
        energySavingImage.isHidden = device.allowEnergySaving == NSNumber(value: true) ? false : true
        
        climateName.text = device.cellTitle
        climateName.tag = tag
        
        temperature.font = UIFont.tahoma(size: 15)
        temperature.text = "\(device.roomTemperature) \(degrees)"
        
        temperatureSetPoint.font = UIFont.tahoma(size: 15)
        temperatureSetPoint.text = "00 \(degrees)"
        
        climateMode.text = device.mode
        climateSpeed.text = device.speed
        climateName.isUserInteractionEnabled = true

        modeImage.animationImages = animationImages
        modeImage.animationRepeatCount = 0
        
        imageOnOff.tag = tag
        imageOnOff.isUserInteractionEnabled = true
        
        disabledCellView.layer.cornerRadius = 5
        
        var fanSpeed = 0.0
        let speedState = device.speedState
        let modeState = device.modeState
        let mode = device.mode
        
        if device.filterWarning { backView.colorTwo = Colors.DirtyRedColor } else { backView.colorTwo = Colors.MediumGray }
        
        if device.currentValue == 255 {
            switch speedState {
            case "Low": fanSpeedImage.image = fanLowImage; fanSpeed = 1.0
            case "Med": fanSpeedImage.image = fanMediumImage; fanSpeed = 0.3
            case "High": fanSpeedImage.image = fanHighImage; fanSpeed = 0.1
            default: fanSpeedImage.image = fanOffImage; fanSpeed = 0.0
            }
            
            switch modeState {
            case "Cool": modeImage.stopAnimating(); modeImage.image = fanCoolImage; temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
            case "Heat": modeImage.stopAnimating(); modeImage.image = fanHeatImage; temperatureSetPoint.text = "\(device.heatTemperature) \(degrees)"
            case "Fan": temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
                if fanSpeed == 0 { modeImage.image = fanAutoImage; modeImage.stopAnimating() }
                else { modeImage.image = animationImages.first; modeImage.animationDuration = TimeInterval(fanSpeed); modeImage.startAnimating() }
            case "Off": modeImage.stopAnimating(); modeImage.image = nil
                switch mode {
                case "Cool": temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
                case "Heat": temperatureSetPoint.text = "\(device.heatTemperature) \(degrees)"
                case "Fan": temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
                case "Auto": temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
                default: break
                }
                
            default: break
            }
            
        } else {
            fanSpeedImage.image = fanOffImage; modeImage.stopAnimating()
        }
        // TODO: - Bug sa mode indikatorom
        if device.currentValue == 0 { imageOnOff.image = powerOffImage; modeImage.image = nil } else { imageOnOff.image = powerOnImage }
        if device.info { infoView.isHidden = false; backView.isHidden = true } else { infoView.isHidden = true; backView.isHidden = false }
        if device.isEnabled.boolValue { disabledCellView.isHidden = true } else { disabledCellView.isHidden = false }
    }
    
    
    func refreshDevice(_ device:Device) {
        self.device = device
        temperature.font = UIFont.tahoma(size: 15)
        temperature.text = "\(device.roomTemperature) \(degrees)"
        energySavingImage.isHidden = device.allowEnergySaving == NSNumber(value: true as Bool) ? false : true
        if device.filterWarning { backView.colorTwo = Colors.DirtyRedColor } else { backView.colorTwo = Colors.MediumGray }
        climateMode.text = device.mode
        climateSpeed.text = device.speed
        var fanSpeed = 0.0
        let speedState = device.speedState
        let modeState = device.modeState
        let mode = device.mode

        if device.currentValue == 255 {
            switch speedState {
            case "Low": fanSpeedImage.image = fanLowImage; fanSpeed = 1.0
            case "Med": fanSpeedImage.image = fanMediumImage; fanSpeed = 0.3
            case "High": fanSpeedImage.image = fanHighImage; fanSpeed = 0.1
            default: fanSpeedImage.image = fanOffImage; fanSpeed = 0.0
            }
            
            switch modeState {
            case "Cool": modeImage.stopAnimating(); modeImage.image = fanCoolImage; temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
            case "Heat": modeImage.stopAnimating(); modeImage.image = fanHeatImage; temperatureSetPoint.text = "\(device.heatTemperature) \(degrees)"
            case "Fan": temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
            if fanSpeed == 0 { modeImage.image = fanAutoImage; modeImage.stopAnimating() }
            else { modeImage.image = animationImages.first; modeImage.animationDuration = TimeInterval(fanSpeed); modeImage.startAnimating() }
                
            default: modeImage.stopAnimating(); modeImage.image = nil
            switch mode {
            case "Cool": temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
            case "Heat": temperatureSetPoint.text = "\(device.heatTemperature) \(degrees)"
            case "Fan": temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
            default: temperatureSetPoint.text = "\(device.coolTemperature) \(degrees)"
                }
            }
            
        } else {
            fanSpeedImage.image = fanOffImage; modeImage.stopAnimating()
        }
        
        
        if device.currentValue == 0 { imageOnOff.image = UIImage(named: "poweroff"); modeImage.image = nil } else { imageOnOff.image = UIImage(named: "poweron") }
        if device.info { infoView.isHidden = false; backView.isHidden = true } else { infoView.isHidden = true; backView.isHidden = false }
        if device.isEnabled.boolValue { disabledCellView.isHidden = true } else { disabledCellView.isHidden = false }
    }
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
