//
//  IncomingHandler+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

struct DeviceInformation {
    let address:Int
    let channel:Int
    let numberOfDevices:Int
    let type:String
    let gateway:Gateway
    let mac:NSData
    let isClimate:Bool
}

// Curtain
extension IncomingHandler {
    func ackonowledgementAboutCurtainState(byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) {
                device.currentValue = Int(byteArray[8])
                let data = ["deviceDidReceiveSignalFromGateway":device]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveDataForRepeatSendingHandler, object: self, userInfo: data)
                break
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
}
// New devices
extension IncomingHandler {
    //  informacije o novim uredjajima
    func acknowledgementAboutNewDevices (byteArray:[Byte]) {
        print(NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDevice))
         if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDevice) {
            var deviceExists = false
            if let channel = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.channel,
                let controlType = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                
                let MAC:[Byte] = Array(byteArray[9...14])
                if devices != [] {
                    for device in devices {
                        if device.address == Int(byteArray[4]) {deviceExists = true}
                    }
                } else {deviceExists = false}
                if !deviceExists {
                    for var i=1 ; i<=channel ; i++ {
                        var isClimate = false
                        if controlType == ControlType.Climate {
                            isClimate = true
                        }
                        let deviceInformation = DeviceInformation(address: Int(byteArray[4]), channel: i, numberOfDevices: channel, type: controlType, gateway: gateways[0], mac: NSData(bytes: MAC, length: MAC.count), isClimate:isClimate)
                        
                        if (controlType == ControlType.Sensor ||
                            controlType == ControlType.Gateway ||
                            controlType == ControlType.IntelligentSwitch) && i > 1{
                            
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            
                        }else if controlType == ControlType.Climate ||
                            controlType == ControlType.Access ||
                            controlType == ControlType.AnalogInput ||
                            controlType == ControlType.AnalogOutput ||
                            controlType == ControlType.DigitalInput ||
                            controlType == ControlType.DigitalOutput ||
                            controlType == ControlType.IRTransmitter ||
                            controlType == ControlType.Curtain ||
                            controlType == ControlType.PC ||
                            controlType == ControlType.Relay ||
                            controlType == ControlType.Dimmer{
                            
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                        }
                        
                        CoreDataController.shahredInstance.saveChanges()
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
                    }
                    let data = ["deviceAddresInGateway":Int(byteArray[4])]
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDevice, object: self, userInfo: data)
                }
            }
        }
    }

}