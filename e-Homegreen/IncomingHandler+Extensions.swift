//
//  IncomingHandler+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

// Curtain
extension IncomingHandler {
    func ackonowledgementAboutCurtainState(byteArray:[Byte]) {
        fetchDevices()
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) {
                device.currentValue = Int(byteArray[8])
                let data = ["deviceDidReceiveSignalFromGateway":device]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveDataForRepeatSendingHandler, object: self, userInfo: data)
                break
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
}
struct DeviceInformation {
    let address:Int
    let channel:Int
    let numberOfDevices:Int
    let type:String
    let gateway:Gateway
    let mac:NSData
    let isClimate:Bool
}
// New devices
extension IncomingHandler {
    //  informacije o novim uredjajima
    func acknowledgementAboutNewDevices (byteArray:[Byte]) {
         if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDevice) {
            var deviceExists = false
            if let channel = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.channel, let name = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                let MAC:[Byte] = Array(byteArray[9...14])
                if devices != [] {
                    for device in devices {
                        if device.address == Int(byteArray[4]) {deviceExists = true}
                    }
                } else {deviceExists = false}
                if !deviceExists {
                    for var i=1 ; i<=channel ; i++ {
                        var isClimate = false
                        if name == ControlType.Climate {
                            isClimate = true
                        }
                        let deviceInformation = DeviceInformation(address: Int(byteArray[4]), channel: i, numberOfDevices: channel, type: name, gateway: gateways[0], mac: NSData(bytes: MAC, length: MAC.count), isClimate:isClimate)
                        if channel == 10 && name == ControlType.Sensor && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            //FIXME:
                            saveChanges()
                        } else if channel == 6 && name == ControlType.Sensor && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            saveChanges()
                        } else if name == ControlType.Climate {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            saveChanges()
                        } else if name == ControlType.Access || name == ControlType.AnalogInput || name == ControlType.AnalogOutput || name == ControlType.DigitalInput || name == ControlType.DigitalOutput || name == ControlType.IRTransmitter {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            saveChanges()
                        } else if channel == 3 && name == ControlType.Gateway && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            saveChanges()
                        }  else if channel == 5 && name == ControlType.HumanInterfaceSeries && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            saveChanges()
                        } else if name == ControlType.Curtain {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            saveChanges()
                        } else if name != ControlType.PC {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            saveChanges()
                        } else if name != ControlType.Climate && name != ControlType.Sensor && name != ControlType.HumanInterfaceSeries {
                            let device = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            saveChanges()
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
                    }
                    let data = ["deviceAddresInGateway":Int(byteArray[4])]
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDevice, object: self, userInfo: data)
                }
            }
        }
    }

}