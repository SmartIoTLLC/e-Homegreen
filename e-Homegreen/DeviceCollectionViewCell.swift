//
//  DeviceCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 3/5/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit

class DeviceCollectionViewCell: UICollectionViewCell {

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
        
        let deviceValue:Double = { return device.currentValue.doubleValue }() ///255
        
        picture.image                    = device.returnImage(device.currentValue.doubleValue)
        lightSlider.value                = Float(deviceValue)/255 // Slider accepts values 0-1
        picture.isUserInteractionEnabled = true
        picture.tag                      = tag
        
        lblElectricity.text   = "\(device.current.floatValue * 0.01) A"
        lblVoltage.text       = "\(device.voltage.floatValue) V"
        labelPowrUsege.text   = "\(device.current.floatValue * device.voltage.floatValue * 0.01)" + " W"
        labelRunningTime.text = device.runningTime
        
        switch device.info {
        case true:
            infoView.isHidden = false
            backView.isHidden = true
        case false:
            infoView.isHidden = true
            backView.isHidden = false
        }
        
        switch device.warningState {
            case 0: backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor
            case 1: backView.colorTwo = Colors.DirtyRedColor // Upper state
            case 2: backView.colorTwo = Colors.DirtyBlueColor // Lower state
            default: break
        }
        disabledCellView.layer.cornerRadius  = 5
        
        switch device.isEnabled.boolValue {
            case true  :
                disabledCellView.isHidden = true
                typeOfLight.isUserInteractionEnabled = true
            case false :
                disabledCellView.isHidden = false
        }

    }
    
    func getDevice (_ device:Device) {
        self.device = device
    }
    
    func refreshDevice(_ device:Device) {
        let deviceValue:Double = { return device.currentValue.doubleValue }() ///255
        
        picture.image = device.returnImage(device.currentValue.doubleValue)
        lightSlider.value = Float(deviceValue/255)  // Slider accepts values from 0 to 1
        
        lblElectricity.text   = "\(device.current.floatValue * 0.01) A"
        lblVoltage.text       = "\(device.voltage.floatValue) V"
        labelPowrUsege.text   = "\(device.current.floatValue * device.voltage.floatValue * 0.01)" + " W"
        labelRunningTime.text = device.runningTime
        
        switch device.info {
            case true:
                infoView.isHidden = false
                backView.isHidden = true
            case false:
                infoView.isHidden = true
                backView.isHidden = false
        }
        
        switch device.warningState {
            case 0: backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor
            case 1: backView.colorTwo = Colors.DirtyRedColor // Upper state
            case 2: backView.colorTwo = Colors.DirtyBlueColor // Lower state
            default: break
        }
        
        switch device.isEnabled.boolValue {
            case true  : disabledCellView.isHidden = true
            case false : disabledCellView.isHidden = false
        }

    }
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    
    @IBAction func btnRefresh(_ sender: AnyObject) {
        let address = device!.getAddress()        
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: device!.gateway)
        SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: device!.gateway)
    }

}
