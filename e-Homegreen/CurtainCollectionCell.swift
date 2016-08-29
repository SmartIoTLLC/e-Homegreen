//
//  CurtainCollectionCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

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
    }
    
    func refreshDevice(device:Device) {
        setImageForDevice(device)
        if let zone = DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location), let name = zone.name{
            lblLevel.text = "\(name)"
        }else{
            lblLevel.text = ""
        }
        if let zone = DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location), let name = zone.name{
            lblZone.text = "\(name)"
        }else{
            lblZone.text = ""
        }
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

// Other. Helper
    
    func setImageForDevice(device: Device){
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        let devices = CoreDataController.shahredInstance.fetchDevicesForGateway(device.gateway)
        var devicePair: Device? = nil
        for deviceTemp in devices{
            if deviceTemp.address == device.address {
                if ((device.channel.integerValue == 1 && deviceTemp.channel.integerValue == 3) ||
                    (device.channel.integerValue == 3 && deviceTemp.channel.integerValue == 1) ||
                    (device.channel.integerValue == 2 && deviceTemp.channel.integerValue == 4) ||
                    (device.channel.integerValue == 4 && deviceTemp.channel.integerValue == 2)) &&
                deviceTemp.isCurtainModeAllowed.boolValue == true &&
                device.isCurtainModeAllowed.boolValue == true{
                    
                    devicePair = deviceTemp
                }
            }
        }
        if devicePair == nil { // new module
            guard let devImages = Array(device.deviceImages!) as? [DeviceImage] else {
                print("error")
                return
            }
            let preSort = devImages.sort { (let result1, let result2) -> Bool in
                if result1.state?.integerValue < result2.state?.integerValue {return true}
                return false
            }
            if device.currentValue.integerValue == 255{
                curtainImage.image = UIImage(named: preSort[2].defaultImage!)
            }else if device.currentValue.integerValue == 0{
                curtainImage.image = UIImage(named: preSort[0].defaultImage!)
            }else {//device.currentValue.integerValue == 0{
                curtainImage.image = UIImage(named: preSort[1].defaultImage!)
            }
        }else{
            guard let devImages = Array(device.deviceImages!) as? [DeviceImage] else {
                print("error")
                return
            }
            let preSort = devImages.sort { (let result1, let result2) -> Bool in
                if result1.state?.integerValue < result2.state?.integerValue {return true}
                return false
            }
            
            // Present adequate image depending on the states of channels
            // Closing state:  Ch1 == on (255), Ch3 == off(0)
            // Opening state:  Ch1 == on (255), Ch3 == on(255)
            // Stop state:     Ch1 == off (0), Ch3 == on(255)
            if device.currentValue.integerValue == 255 && devicePair!.currentValue.integerValue == 0{
                curtainImage.image = UIImage(named: preSort[0].defaultImage!)
            }else if device.currentValue.integerValue == 255 && devicePair!.currentValue.integerValue == 255{
                curtainImage.image = UIImage(named: preSort[2].defaultImage!)
            }else {//device.currentValue.integerValue == 0{
                curtainImage.image = UIImage(named: preSort[1].defaultImage!)
            }
        }
    }
}

