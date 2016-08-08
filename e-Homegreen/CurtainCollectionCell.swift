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
        
//        let tapGesture = UITapGestureRecognizer(target: self.curtainImage, action: Selector("stopCurtainMotor:"))
//        self.curtainImage.addGestureRecognizer(tapGesture)
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
//            if Double(device.currentValue) > 100 {
//                return Double(device.currentValue) / 255
//            } else {
                return Double(device.currentValue) / 255
//            }
        }()
        
        
        // Find the device that is the pair of this device for reley control
        // First or second channel will always be presented (not 3 and 4), so we are looking for 3 and 4 channels
        self.getDevices(device.gateway)
        var devicePair: Device? = nil
        for deviceTemp in devices{
            if deviceTemp.address == device.address {
                if ((device.channel.integerValue == 1 && deviceTemp.channel.integerValue == 3) || (device.channel.integerValue == 3 && deviceTemp.channel.integerValue == 1) || (device.channel.integerValue == 2 && deviceTemp.channel.integerValue == 4) || (device.channel.integerValue == 4 && deviceTemp.channel.integerValue == 2)) {
                 
                    devicePair = deviceTemp
                }
            }
        }
        
        guard let _ = devicePair else{
            print("Error, no pair device found for curtain relay control")
            return
        }
        
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

// Other. Helper
    var devices: [Device] = []
    func getDevices(gateway: Gateway){
        var appDel:AppDelegate!
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let predicate = NSPredicate(format: "gateway == %@", gateway.objectID)
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            self.devices = fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
        }
    }
}

