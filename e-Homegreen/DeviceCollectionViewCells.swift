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
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelLevel: UILabel!
    @IBOutlet weak var labelZone: UILabel!
}


