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
// New devices
extension IncomingHandler {
    //  informacije o novim uredjajima
    func acknowledgementAboutNewDevices (byteArray:[Byte]) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDevice) {
            var deviceExists = false
            if let channel = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.channel, let name = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                if devices != [] {
                    for device in devices {
                        if device.address == Int(byteArray[4]) {deviceExists = true}
                    }
                } else {
                    deviceExists = false
                }
                if !deviceExists {
                    for var i=1 ; i<=channel ; i++ {
                        if channel == 10 && name == ControlType.Sensor && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        } else if channel == 6 && name == ControlType.Sensor && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        } else if name == ControlType.Climate {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.currentValue = 0
                            device.runningTime = "00:00:00,0s"
                            device.mode = "AUTO"
                            device.modeState = "Off"
                            device.speed = "AUTO"
                            device.speedState = "Off"
                            device.coolTemperature = 0
                            device.heatTemperature = 0
                            device.roomTemperature = 0
                            device.humidity = 0
                            device.current = 0
                            saveChanges()
                        } else if name == ControlType.Access || name == ControlType.AnalogInput || name == ControlType.AnalogOutput || name == ControlType.DigitalInput || name == ControlType.DigitalOutput || name == ControlType.IRTransmitter {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.currentValue = 0
                            device.runningTime = "00:00:00,0s"
                            device.current = 0
                            saveChanges()
                        } else if channel == 3 && name == ControlType.Gateway && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        }  else if channel == 5 && name == ControlType.HumanInterfaceSeries && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        } else if name == ControlType.Curtain {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.currentValue = 0
                            device.runningTime = "00:00:00,0s"
                            device.current = 0
                            saveChanges()
                        } else if name != ControlType.Climate && name != ControlType.Sensor && name != ControlType.HumanInterfaceSeries {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.runningTime = "00:00:00,0s"
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.delay = 0
                            device.runtime = 0
                            device.skipState = 0
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