//
//  Device.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/10/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
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
        }
        let defaultDeviceImages = DefaultDeviceImages().getNewImagesForDevice(self)
        for defaultDeviceImage in defaultDeviceImages {
            let deviceImage = DeviceImage(context: context)
            deviceImage.defaultImage = defaultDeviceImage.defaultImage
            deviceImage.state = NSNumber(integer:defaultDeviceImage.state)
            deviceImage.device = self
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
            if newDeviceValue <= 100 {
                return Double(newDeviceValue)
            } else {
                return Double(newDeviceValue)/255 * 100
            }
        }()
        guard let checkDeviceImages = self.deviceImages else {
            return UIImage(named: "")!
        }
        guard let devImages = Array(checkDeviceImages) as? [DeviceImage] else {
            return UIImage(named: "")!
        }
        let sumOfDeviceImages = devImages.count
        let dblSection:Double = 100/Double(sumOfDeviceImages)
        let preSort = devImages.sort { (let result1, let result2) -> Bool in
            if result1.state?.integerValue < result2.state?.integerValue {return true}
            return false
        }
        let mapedResult = preSort.enumerate().map { (let index, let deviceImage) -> Result in
            let defaultImageNamed = deviceImage.defaultImage!
            let stateValue = (Double(index) + 1) * dblSection
            if let imageData = deviceImage.image?.imageData {
                let image = UIImage(data: imageData)
                return Result(stateValue: stateValue, imageData: image, defaultImage: UIImage(named: defaultImageNamed)!)
            }
            
            return Result(stateValue: stateValue, imageData: nil, defaultImage: UIImage(named: defaultImageNamed)!)
        }
        let filteredMapedresult = mapedResult.filter { (let result) -> Bool in
            if result.stateValue >= deviceValue {return true}
            return false
        }
        let sortedFilteredMapedResult = filteredMapedresult.sort { (let result1, let result2) -> Bool in
            if result1.stateValue < result2.stateValue {return true}
            return false
        }
         let result = sortedFilteredMapedResult[0]
        if let image = result.imageData {
            return image
        }
        if let image = result.defaultImage {
            return image
        }
        return UIImage(named: "")!
    }
}
