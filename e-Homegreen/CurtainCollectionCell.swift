//
//  CurtainCollectionCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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
    
    func refreshDevice(_ device:Device) {
        setImageForDevice(device)
        // If device is enabled add all interactions
        if device.isEnabled.boolValue {
            disabledCellView.isHidden = true
        } else {
            disabledCellView.isHidden = false
        }
        if device.info {
            infoView.isHidden = false
            backView.isHidden = true
        }else {
            infoView.isHidden = true
            backView.isHidden = false
        }
    }
    @IBOutlet weak var disabledCellView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!

// Other. Helper
    
    func setImageForDevice(_ device: Device){
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        let devices = CoreDataController.shahredInstance.fetchDevicesForGateway(device.gateway)
        var devicePair: Device? = nil
        for deviceTemp in devices{
            if deviceTemp.address == device.address {
                if ((device.channel.intValue == 1 && deviceTemp.channel.intValue == 3) ||
                    (device.channel.intValue == 3 && deviceTemp.channel.intValue == 1) ||
                    (device.channel.intValue == 2 && deviceTemp.channel.intValue == 4) ||
                    (device.channel.intValue == 4 && deviceTemp.channel.intValue == 2)) &&
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
            let preSort = devImages.sorted { (result1, result2) -> Bool in
                if result1.state?.intValue < result2.state?.intValue {return true}
                return false
            }
            if device.currentValue.intValue == 255{
                curtainImage.image = UIImage(named: preSort[2].defaultImage!)
            }else if device.currentValue.intValue == 0{
                curtainImage.image = UIImage(named: preSort[0].defaultImage!)
            }else {//device.currentValue.integerValue == 0{
                curtainImage.image = UIImage(named: preSort[1].defaultImage!)
            }
        }else{
            guard let devImages = Array(device.deviceImages!) as? [DeviceImage] else {
                print("error")
                return
            }
            let preSort = devImages.sorted { (result1, result2) -> Bool in
                if result1.state?.intValue < result2.state?.intValue {return true}
                return false
            }
            
            // Present adequate image depending on the states of channels
            // Closing state:  Ch1 == on (255), Ch3 == off(0)
            // Opening state:  Ch1 == on (255), Ch3 == on(255)
            // Stop state:     Ch1 == off (0), Ch3 == on(255)
            if device.currentValue.intValue == 255 && devicePair!.currentValue.intValue == 0{
                if preSort.count > 0{
                    curtainImage.image = UIImage(named: preSort[0].defaultImage!)
                }
            }else if device.currentValue.intValue == 255 && devicePair!.currentValue.intValue == 255{
                if preSort.count > 2{
                    curtainImage.image = UIImage(named: preSort[2].defaultImage!)
                }
            }else {//device.currentValue.integerValue == 0{
                if preSort.count > 1{
                    curtainImage.image = UIImage(named: preSort[1].defaultImage!)
                }
            }
        }
    }
}

