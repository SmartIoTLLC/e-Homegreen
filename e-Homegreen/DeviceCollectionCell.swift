//
//  DeviceCollectionCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
import UIKit
//Light
class DeviceCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var typeOfLight: MarqueeLabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var lightSlider: UISlider!
    
    @IBOutlet weak var disabledCellView: UIView!
    var device:Device?
    
    func setCell(device: Device, tag: Int) {
        self.device = device
        
        typeOfLight.text = device.cellTitle
        typeOfLight.tag  = tag
        
        lightSlider.isContinuous = true
        lightSlider.tag          = tag
        
        let deviceValue:Double = { return Double(device.currentValue) }() ///255
        picture.image                    = device.returnImage(Double(device.currentValue))
        lightSlider.value                = Float(deviceValue)/255 // Slider accepts values 0-1
        picture.isUserInteractionEnabled = true
        picture.tag                      = tag
        
        lblElectricity.text   = "\(Float(device.current) * 0.01) A"
        lblVoltage.text       = "\(Float(device.voltage)) V"
        labelPowrUsege.text   = "\(Float(device.current) * Float(device.voltage) * 0.01)" + " W"
        labelRunningTime.text = device.runningTime
        
        if device.info { infoView.isHidden = false; backView.isHidden = true
        } else { infoView.isHidden = true; backView.isHidden = false }
        
        if device.warningState == 0 { backView.colorTwo = Colors.MediumGray }
        else if device.warningState == 1 { backView.colorTwo = Colors.DirtyRedColor } // Upper state
        else if device.warningState == 2 { backView.colorTwo = Colors.DirtyBlueColor } // Lower state
        
        if device.isEnabled.boolValue {
            typeOfLight.isUserInteractionEnabled = true
            disabledCellView.isHidden            = true
            disabledCellView.layer.cornerRadius  = 5
        } else {
            disabledCellView.isHidden           = false
            disabledCellView.layer.cornerRadius = 5
        }
        
    }
    
    func getDevice (_ device:Device) {
        self.device = device
    }
    
    func refreshDevice(_ device:Device) {
        let deviceValue:Double = { return Double(device.currentValue) }() ///255
        
        picture.image = device.returnImage(Double(device.currentValue))
        lightSlider.value = Float(deviceValue/255)  // Slider accepts values from 0 to 1
        
        lblElectricity.text   = "\(Float(device.current) * 0.01) A"
        lblVoltage.text       = "\(Float(device.voltage)) V"
        labelPowrUsege.text   = "\(Float(device.current) * Float(device.voltage) * 0.01)" + " W"
        labelRunningTime.text = device.runningTime
        
        if device.info {
            infoView.isHidden = false
            backView.isHidden = true
        }else {
            infoView.isHidden = true
            backView.isHidden = false
        }
        
        if device.warningState == 0 {
            backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor
        } else if device.warningState == 1 {
            // Uppet state
            backView.colorTwo = Colors.DirtyRedColor
        } else if device.warningState == 2 {
            // Lower state
            backView.colorTwo = Colors.DirtyBlueColor
        }
        
        // If device is enabled add all interactions
        if device.isEnabled.boolValue {
            disabledCellView.isHidden = true
        } else {
            disabledCellView.isHidden = false
        }
    }
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    
    @IBAction func btnRefresh(_ sender: AnyObject) {
        let address = [UInt8(Int(device!.gateway.addressOne)),UInt8(Int(device!.gateway.addressTwo)),UInt8(Int(device!.address))]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: device!.gateway)
        SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: device!.gateway)
    }
}
