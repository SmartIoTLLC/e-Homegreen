//
//  CurtainCollectionCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

//curtain
class CurtainCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var curtainName: UILabel!
    @IBOutlet weak var curtainImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    
    override func awakeFromNib() {
        closeButton.layer.cornerRadius = 5
        openButton.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self.curtainImage, action: Selector("stopCurtainMotor:"))
        self.curtainImage.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func openCurtain(sender: AnyObject) {
//        // This is handeled with gestures: DevicesViewController + Extensions
//        curtainImage.image = UIImage(named: "curtain0")
    }
    
    @IBAction func cloaseCurtain(sender: AnyObject) {
//        // This is handeled with gestures: DevicesViewController + Extensions
//        curtainImage.image = UIImage(named: "curtain4")
    }
    
    func stopCurtainMotor(gesture:UITapGestureRecognizer){
//        // This is handeled with gestures: DevicesViewController + Extensions
//        curtainImage.image = UIImage(named: "curtain2")
    }
    
    func refreshDevice(device:Device) {
        
        let deviceValue:Double = {
            return Double(device.currentValue)
//            if Double(device.currentValue) > 100 {
//                return Double(device.currentValue) / 255
//            } else {
//                return Double(device.currentValue) / 100
//            }
        }()
        curtainImage.image = device.returnImage(Double(device.currentValue))
//        curtainImage.image = UIImage(named: "curtain2") // TODO: Delete this when functionality is implemented
        if device.filterWarning {
            backView.colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor
        } else {
            backView.colorTwo = Colors.DirtyRedColor
        }
        //        labelRunningTime.text = "\(device.runningTime)"
        //        lblElectricity.text = "\(Float(device.current) * 0.01) A"
        //        lblVoltage.text = "\(Float(device.voltage)) V"
        //        labelPowrUsege.text = "\(Float(device.current) * Float(device.voltage) * 0.01)" + " W"
        
        //        lblAddress.text = "\(device.channel)"
        lblLevel.text = "\(DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location))"
        lblZone.text = "\(DatabaseHandler.returnZoneWithId(Int(device.zoneId), location: device.gateway.location))"
        lblCategory.text = "\(DatabaseHandler.returnCategoryWithId(Int(device.categoryId), location: device.gateway.location))"
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
