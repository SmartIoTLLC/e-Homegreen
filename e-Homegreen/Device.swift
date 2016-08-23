//
//  Device.swift
//  e-Homegreen
//
//  Created by Marko Stajic on 8/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

enum EmployeeStatus: Int {
    case ReadyForHire, Hired, Retired, Resigned, Fired, Deceased
}
class Device: NSManagedObject {
    var interfaceParametar:[UInt8] = []
    var warningState:Int = 0
    var opening:Bool = true
    var on:Bool = false
    var info:Bool = false
    var cellTitle:String = ""
    var filterWarning:Bool = false
    var pcVolume:Byte = 0
    lazy var moduleAddress:[Byte] = {
        return [Byte(Int(self.gateway.addressOne)), Byte(Int(self.gateway.addressTwo)), Byte(Int(self.address))]
    }()
    convenience init(context: NSManagedObjectContext, specificDeviceInformation information:DeviceInformation) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.name = "Unknown"
        self.address = information.address
        self.channel = information.channel
        self.numberOfDevices = information.numberOfDevices
        self.runningTime = "00:00:00,0s"
        self.currentValue = 0
        self.oldValue = 0
        self.current = 0
        self.amp = ""
        self.type = information.type
        self.controlType = information.type
        self.voltage = 0
        self.temperature = 0
        self.gateway = information.gateway
        self.isVisible = false
        self.isEnabled = false
        self.mac = information.mac
        if information.isClimate {
            self.mode = "AUTO"
            self.modeState = "Off"
            self.speed = "AUTO"
            self.speedState = "Off"
            self.coolTemperature = 0
            self.heatTemperature = 0
            self.roomTemperature = 0
            self.humidity = 0
            self.humidityVisible = true
            self.temperatureVisible = true
            self.coolModeVisible = true
            self.heatModeVisible = true
            self.fanModeVisible = true
            self.autoModeVisible = true
            self.lowSpeedVisible = true
            self.medSpeedVisible = true
            self.highSpeedVisible = true
            self.autoSpeedVisible = true
        }
        self.notificationType = 0
        self.notificationPosition = 1
        self.notificationDelay = 0
        self.notificationDisplayTime = 5
        let defaultDeviceImages = DefaultDeviceImages().getNewImagesForDevice(self)
        for defaultDeviceImage in defaultDeviceImages {
            let deviceImage = DeviceImage(context: context)
            deviceImage.defaultImage = defaultDeviceImage.defaultImage
            deviceImage.state = NSNumber(integer:defaultDeviceImage.state)
            deviceImage.device = self
            deviceImage.text = defaultDeviceImage.text
        }
    }
    func resetImages(context:NSManagedObjectContext) {
        if self.deviceImages?.count > 0 {
            for image in self.deviceImages! {
                context.deleteObject(image as! DeviceImage)
            }
        }
        let defaultDeviceImages = DefaultDeviceImages().getNewImagesForDevice(self)
        for defaultDeviceImage in defaultDeviceImages {
            let deviceImage = DeviceImage(context: context)
            deviceImage.defaultImage = defaultDeviceImage.defaultImage
            deviceImage.state = NSNumber(integer:defaultDeviceImage.state)
            deviceImage.device = self
            deviceImage.text = defaultDeviceImage.text
        }
    }
    struct Result {
        let stateValue:Double
        let imageData:UIImage?
        let defaultImage:UIImage?
    }
    // MARK: Return image for specific state
    func returnImage(newDeviceValue:Double) -> UIImage {
        // Convert device images to array
        let deviceValue: Double = {
            return Double(newDeviceValue)
        }()
        guard let checkDeviceImages = self.deviceImages else {
            return UIImage(named: "")!
        }
        guard let devImages = Array(checkDeviceImages) as? [DeviceImage] else {
            return UIImage(named: "")!
        }
        let sumOfDeviceImages = devImages.count
        let dblSection:Double = 100/Double(sumOfDeviceImages)
        // sort by state: 1 2 3 4 5 6
        let preSort = devImages.sort { (let result1, let result2) -> Bool in
            if result1.state?.integerValue < result2.state?.integerValue {return true}
            return false
        }
        let mapedResult = preSort.enumerate().map { (let index, let deviceImage) -> Result in
            let defaultImageNamed = deviceImage.defaultImage!
            let stateValue = (Double(index) + 1) * dblSection
            
            if let id = deviceImage.customImageId{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        let image = UIImage(data: data)
                        return Result(stateValue: stateValue, imageData: image, defaultImage: UIImage(named: defaultImageNamed)!)
                    }
                }
            }
            
//            if let imageData = deviceImage.image?.imageData {
//                let image = UIImage(data: imageData)
//                return Result(stateValue: stateValue, imageData: image, defaultImage: UIImage(named: defaultImageNamed)!)
//            }
            
            return Result(stateValue: stateValue, imageData: nil, defaultImage: UIImage(named: defaultImageNamed)!)
        }
        // Compares state value (example: 20, 40, 60, 80, 100 for 5 images) with device value (which is in percent 0-100)
        let filteredMapedresult = mapedResult.filter { (let result) -> Bool in
            if result.stateValue >= (deviceValue/255*100) {return true} //
            return false
        }
        let sortedFilteredMapedResult = filteredMapedresult.sort { (let result1, let result2) -> Bool in
            if result1.stateValue < result2.stateValue {return true}
            return false
        }
        if sortedFilteredMapedResult.count > 0{
            let result = sortedFilteredMapedResult[0]
            if let image = result.imageData {
                return image
            }
            if let image = result.defaultImage {
                return image
            }
        }
        
        return UIImage(named: "optionsss")!
    }
}
