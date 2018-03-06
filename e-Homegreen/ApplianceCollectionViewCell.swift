//
//  ApplianceCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 3/5/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit

class ApplianceCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var onOff: UIButton!
    
    func setCell(device: Device, tag: Int) {
        name.text = device.cellTitle
        name.tag = tag
        
        let deviceValue:Double = { return device.currentValue.doubleValue }()
        
        image.image = device.returnImage(device.currentValue.doubleValue)
        
        if deviceValue == 255 { onOff.setTitle("ON", for: UIControlState()) } else if device.currentValue == 0 { onOff.setTitle("OFF", for: UIControlState()) }
        
        onOff.tag = tag
        
        if device.info { infoView.isHidden = false; backView.isHidden = true } else { infoView.isHidden = true; backView.isHidden = false }
        
        labelRunningTime.text = "\(device.runningTime)"
        lblElectricity.text   = "\(device.current.floatValue * 0.01) A"
        lblVoltage.text       = "\(device.voltage.floatValue) V"
        labelPowrUsege.text   = "\(device.current.floatValue * device.voltage.floatValue * 0.01)" + " W"
        
        disabledCellView.layer.cornerRadius = 5
        
        if device.isEnabled.boolValue {
            name.isUserInteractionEnabled = true
            image.tag = tag
            image.isUserInteractionEnabled = true
            onOff.isUserInteractionEnabled = true
            btnRefresh.tag = tag
            disabledCellView.isHidden = true
        } else {
            disabledCellView.isHidden = false
        }
    }
    
    func refreshDevice(_ device:Device) {
        let deviceValue:Double = { return device.currentValue.doubleValue }()
        
        image.image = device.returnImage(device.currentValue.doubleValue)
        
        if deviceValue == 255 { onOff.setTitle("ON", for: UIControlState()) } else if device.currentValue == 0 { onOff.setTitle("OFF", for: UIControlState()) }
        
        if device.info { infoView.isHidden = false; backView.isHidden = true } else { infoView.isHidden = true; backView.isHidden = false }
        
        labelRunningTime.text = "\(device.runningTime)"
        lblElectricity.text   = "\(device.current.floatValue * 0.01) A"
        lblVoltage.text       = "\(device.voltage.floatValue) V"
        labelPowrUsege.text   = "\(device.current.floatValue * device.voltage.floatValue * 0.01)" + " W"
        
        // If device is enabled add all interactions
        if device.isEnabled.boolValue { disabledCellView.isHidden = true } else { disabledCellView.isHidden = false }
    }
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!

}
