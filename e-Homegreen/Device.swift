//
//  Device.swift
//  e-Homegreen
//
//  Created by Marko Stajic on 8/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum EmployeeStatus: Int {
    case readyForHire, hired, retired, resigned, fired, deceased
}
class Device: NSManagedObject {
    var interfaceParametar:[UInt8] = []
    var warningState:Int = 0
    var info:Bool = false
    var cellTitle:String = ""
    var filterWarning:Bool = false
    var pcVolume:Byte = 0
    var bateryStatus: Int = 0
    var saltoMode: Int = -1
    
    var cacheImage:UIImage?
    
    lazy var moduleAddress:[Byte] = {
        return [Byte(Int(self.gateway.addressOne)), Byte(Int(self.gateway.addressTwo)), Byte(Int(self.address))]
    }()
    convenience init(context: NSManagedObjectContext, specificDeviceInformation information:DeviceInformation) {
        self.init(context: context)
        self.name = "Unknown"
        self.address = NSNumber(value: information.address)
        self.channel = NSNumber(value: information.channel)
        self.deviceIdForScanningScreen = NSNumber(value: information.channel)
        self.numberOfDevices = NSNumber(value: information.numberOfDevices)
        self.runningTime = "00:00:00,0s"
        self.currentValue = 0
        self.oldValue = 255
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
        self.zoneId = -1
        self.parentZoneId = -1
        self.categoryId = -1
        self.bateryStatus = -1
        
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
            deviceImage.state = NSNumber(value: defaultDeviceImage.state as Int)
            deviceImage.device = self
            deviceImage.text = defaultDeviceImage.text
        }
    }
    
    // Used only for creating SaltoAccess Device
    // the name must be different
    convenience init(context: NSManagedObjectContext, specificDeviceInformation information:DeviceInformation, channelName: String) {
        self.init(context: context)
        self.name = channelName
        self.address = NSNumber(value: information.address)
        self.channel = NSNumber(value: information.channel)
        self.deviceIdForScanningScreen = NSNumber(value: information.channel)
        self.numberOfDevices = NSNumber(value: information.numberOfDevices)
        self.runningTime = "00:00:00,0s"
        self.currentValue = 0
        self.oldValue = 255
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
        self.zoneId = -1
        self.parentZoneId = -1
        self.categoryId = -1
        self.bateryStatus = -1
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
            deviceImage.state = NSNumber(value: defaultDeviceImage.state as Int)
            deviceImage.device = self
            deviceImage.text = defaultDeviceImage.text
        }
    }
    func resetImages(_ context:NSManagedObjectContext) {
        if self.deviceImages?.count > 0 {
            for image in self.deviceImages! {
                context.delete(image as! DeviceImage)
            }
        }
        let defaultDeviceImages = DefaultDeviceImages().getNewImagesForDevice(self)
        for defaultDeviceImage in defaultDeviceImages {
            let deviceImage = DeviceImage(context: context)
            deviceImage.defaultImage = defaultDeviceImage.defaultImage
            deviceImage.state = NSNumber(value: defaultDeviceImage.state as Int)
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
    func returnImage(_ newDeviceValue:Double) -> UIImage {
        // Convert device images to array
        guard let preSort = self.deviceImages?.allObjects.sorted(by: { (result1, result2) -> Bool in
            return (result1 as! DeviceImage).state?.intValue < (result2 as! DeviceImage).state?.intValue
        }) as? [DeviceImage] else {
            return UIImage(named: "")!
        }
        
        let sumOfDeviceImages = preSort.count
        let dblSection:Double = 100/Double(sumOfDeviceImages)
        let mapedResult = preSort.enumerated().map { ( index, deviceImage) -> Result in
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
            
            return Result(stateValue: stateValue, imageData: nil, defaultImage: UIImage(named: defaultImageNamed)!)
        }
        // Compares state value (example: 20, 40, 60, 80, 100 for 5 images) with device value (which is in percent 0-100)
        let filteredMapedresult = mapedResult.filter { ( result) -> Bool in
            return result.stateValue >= (newDeviceValue/255*100)
        }
        if filteredMapedresult.count > 0{
            let result = filteredMapedresult[0]
            if let image = result.imageData {
                self.cacheImage = image
                return image
            }
            if let image = result.defaultImage {
                self.cacheImage = image
                return image
            }
        }
        
        return UIImage(named: "optionsss")!
    }
}
