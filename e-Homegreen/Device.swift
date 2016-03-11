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
        self.numberOfDevices = channel
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
}
