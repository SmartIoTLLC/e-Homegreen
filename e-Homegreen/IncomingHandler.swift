
//  ReceiveHandler.swift
//  new
//
//  Created by Teodor Stevic on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class IncomingHandler: NSObject {
    var byteArray:[Byte]!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var error:NSError? = nil
    var host:String = ""
    var port:UInt16 = 0
    deinit {
        print("UPRAVO SE GASIM - class IncomingHandler: NSObject")
    }
    init (byteArrayToHandle: [Byte], host:String, port:UInt16) {
        super.init()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.Gateway.DidReceiveData, object: self, userInfo: nil)
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        self.host = host
        self.port = port
        fetchGateways(host, port: port)
        
        //  Checks if there are any gateways
        if gateways != [] {
            fetchDevices()
            self.byteArray = byteArrayToHandle
                // Check if byteArray is correct one (check byte also, which is missing)
                if self.byteArray[0] == 0xAA && self.byteArray[self.byteArray.count-1] == 0x10 {
                    print("Uslo je u incoming handler.")
                    
                    //  ACKNOWLEDGMENT ABOUT NEW DEVICES
                    if self.byteArray[5] == 0xF1 && self.byteArray[6] == 0x01 {
                        self.acknowledgementAboutNewDevices(self.byteArray)
                    }
                    
                    //  ACKNOWLEDGEMENT ABOUT CHANNEL PARAMETAR (Get Channel Parametar) IMENA
                    if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x01 {
                        self.acknowledgementAboutChannelParametar (self.byteArray)
                    }
                    
                    //  ACKNOWLEDGMENT ABOUT CHANNEL STATE (Get Channel State)
                    if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x06 && self.byteArray[7] == 0xFF { // OVO NE MOZE OVAKO DA BUDE
                        self.ackonowledgementAboutChannelsState(self.byteArray)
                    }
//                    if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x06 {
//                        self.ackonowledgementAboutChannelState(self.byteArray)
//                    }
                    
//            //  ACKNOWLEDGMENT ABOUT LIGHT RELAY STATUS (Get channel state (output) Lightning control action)
//            if byteArray[5] == 0xF3 && byteArray[6] == 0x07 {
//
//            }
                    
                    //  ACKNOWLEDGMENT ABOUT RUNNING TIME (Get Channel On Time Count)
                    if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x0C {
                        self.ackDimmerGetRunningTime(self.byteArray)
                    }
                    
                    //  ACKNOWLEDGMENT ABOUT CHANNEL WARNINGS (Get Channel On Last Current Change Warning)
                    if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x10 {
                        self.ackChannelWarnings(self.byteArray)
                    }
                    
                    //  ACKNOWLEDGMENET ABOUT AC CONTROL PARAMETAR
                    if self.byteArray[5] == 0xF4 && self.byteArray[6] == 0x01 {
                        self.ackACParametar(self.byteArray)
                    }
                    //  ACKNOWLEDGMENT ABOUT AC CONTROL STATUS
                    if self.byteArray[5] == 0xF4 && self.byteArray[6] == 0x03 && self.byteArray[7] == 0xFF  {
                        self.ackACstatus(self.byteArray)
                    }
                    //                if byteArray[5] == 0xF4 && byteArray[6] == 0x {
                    //
                    //                }
                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x02 {
                        self.ackADICmdGetInterfaceParametar(self.byteArray)
                    }
                    // - Ovo je izgleda u redu
                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 && self.byteArray[7] == 0xFF { // OVO NE MOZE OVAKO DA BUDE
                        self.ackADICmdGetInterfaceStatus(self.byteArray)
                    }
//                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 { // OVO NE MOZE OVAKO DA BUDE
//                        self.ackADICmdGetInterfaceStatus(self.byteArray)
//                    }
//                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 {
//                        
//                    }
                    
                    // - Ovo je izgleda u redu
                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 {
                        self.securityFeedbackHandler(self.byteArray)
                    }
                    
                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x03 {
                        self.ackInterfaceEnableStatus(self.byteArray)
                    }
                    
                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x04 {
                        self.ackADICmdGetInterfaceName(self.byteArray)
                    }
                    
                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x17 && self.byteArray[7] == 0xFF {
                        self.ackTimerStatus(self.byteArray)
                    }
                    
                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x06 && self.byteArray[7] == 0xFF {
                        self.ackFlagStatus(self.byteArray)
                    }
                }
        }
    }
    
    func refreshSecurityStatus (byteArray:[Byte]) {
        
    }
    func ackChannelWarnings (byteArray:[Byte]) {
        fetchDevices()
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) {
//                var number = Int(byteArray[6+5*Int(device.channel)])
                print("\(6+6*Int(device.channel)) - \(Int(device.channel)) - \(Int(byteArray[6+5+6*(Int(device.channel)-1)]))")
                device.warningState = Int(byteArray[6+5+6*(Int(device.channel)-1)])
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func fetchDevices () {
        // OVDE ISKACE BUD NA ANY
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let predicate = NSPredicate(format: "gateway == %@", gateways[0].objectID)
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            devices = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func fetchDevices (addressOne:Int, addressTwo:Int, addressThree:Int, channel:Int) {
//        devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7])
        // OVDE ISKACE BUD NA ANY
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let predicateOne = NSPredicate(format: "gateway == %@", gateways[0].objectID)
        let predicateTwo = NSPredicate(format: "gateway.addressOne == %@", addressOne)
        let predicateThree = NSPredicate(format: "gateway.addressTwo == %@", addressTwo)
        let predicateFour = NSPredicate(format: "address == %@", addressThree)
        let predicateFive = NSPredicate(format: "channel == %@", channel)
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateTwo, predicateThree, predicateFour, predicateFive])
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            devices = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func fetchGateways (host:String, port:UInt16) {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "remoteIpInUse == %@ AND remotePort == %@", host, NSNumber(unsignedShort: port))
        let predicateThree = NSPredicate(format: "localIp == %@ AND localPort == %@", host, NSNumber(unsignedShort: port))
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicateTwo,predicateThree])
        fetchRequest.predicate = NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne,compoundPredicate])
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
            gateways = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func ackACstatus (byteArray:[Byte]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                let channel = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+13*(channel-1)])
                if let mode = DeviceInfo.setMode[Int(byteArray[9+13*(channel-1)])], let modeState = DeviceInfo.modeState[Int(byteArray[10+13*(channel-1)])], let speed = DeviceInfo.setSpeed[Int(byteArray[11+13*(channel-1)])], let speedState = DeviceInfo.speedState[Int(byteArray[12+13*(channel-1)])] {
                    devices[i].mode = mode
                    devices[i].modeState = modeState
                    devices[i].speed = speed
                    devices[i].speedState = speedState
                } else {
                    devices[i].mode = "Auto"
                    devices[i].modeState = "Off"
                    devices[i].speed = "Auto"
                    devices[i].speedState = "Off"
                }
                devices[i].coolTemperature = Int(byteArray[13+13*(channel-1)])
                devices[i].heatTemperature = Int(byteArray[14+13*(channel-1)])
                devices[i].roomTemperature = Int(byteArray[15+13*(channel-1)])
                devices[i].humidity = Int(byteArray[16+13*(channel-1)])
                devices[i].current = Int(byteArray[19+13*(channel-1)]) + Int(byteArray[20+13*(channel-1)])
                let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveDataForRepeatSendingHandler, object: self, userInfo: data)
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshClimate, object: self, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func ackDimmerGetRunningTime (byteArray:[Byte]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                if byteArray[7] != 0xFF && byteArray[7] != 0xF0 {
                    devices[i].runningTime = returnRunningTime([byteArray[8], byteArray[9], byteArray[10], byteArray[11]])
                } else if byteArray[7] == 0xF0 {
                    
                } else {
                    let channelNumber = Int(devices[i].channel)
                    print(Int(devices[i].channel))
                    devices[i].runningTime = returnRunningTime([byteArray[8+4*(channelNumber-1)], byteArray[9+4*(channelNumber-1)], byteArray[10+4*(channelNumber-1)], byteArray[11+4*(channelNumber-1)]])
                    print(devices[i].type)
                    print(devices[i].runningTime)
                }
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func bytesToUInt(byteArray: [Byte]) -> UInt {
        assert(byteArray.count <= 4)
        var result: UInt = 0
        for idx in 0..<(byteArray.count) {
            let shiftAmount = UInt((byteArray.count) - idx - 1) * 8
            result += UInt(byteArray[idx]) << shiftAmount
        }
        return result
    }
    
    func returnRunningTime (runningTimeByteArray:[Byte]) -> String {
        print(runningTimeByteArray)
        let x = Int(bytesToUInt(runningTimeByteArray))
//        var z = UnsafePointer<UInt16>(runningTimeByteArray).memory
//        var y = Int(runningTimeByteArray[0])*1*256 + Int(runningTimeByteArray[1])*1*256 + Int(runningTimeByteArray[2])*1*256 + Int(runningTimeByteArray[3])
        var seconds = x / 10
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        seconds = seconds % 60
        let secdiv = (x % 60) % 10
        return "\(returnTwoPlaces(hours)):\(returnTwoPlaces(minutes)):\(returnTwoPlaces(seconds)),\(secdiv)s"
    }
    
    func returnTwoPlaces (number:Int) -> String {
        return String(format: "%02d",number)
    }
    
    //  informacije o imenima uredjaja na MULTISENSORU
    func ackADICmdGetInterfaceName (byteArray:[Byte]) {
        print(NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName))
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            fetchDevices()
            var string:String = ""
            for var j = 9; j < byteArray.count-2; j++ {
                string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
            }
            for var i = 0; i < devices.count; i++ {
                if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
//                var channel = Int(devices[i].channel)
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDeviceName, object: self, userInfo: data)
                }
            }
            saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
    }
    func ackInterfaceEnableStatus (byteArray: [Byte]) {
        fetchDevices()
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) && device.channel == Int(byteArray[7]) {
                if byteArray[8] >= 0x80 {
                    device.isEnabled = NSNumber(bool: true)
                } else {
                    device.isEnabled = NSNumber(bool: false)
                }
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func ackADICmdGetInterfaceParametar (byteArray:[Byte]) {
        fetchDevices()
        var counter = 0
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) && device.channel == Int(byteArray[7]) {
                device.zoneId = Int(byteArray[9])
                device.parentZoneId = Int(byteArray[10])
                device.categoryId = Int(byteArray[8])
//                var interfaceParametar:[Byte] = []
//                for var i = 7; i < byteArray.count-2; i++ {
//                    interfaceParametar.append(byteArray[i])
//                }
//                device.interfaceParametar = interfaceParametar
                if byteArray[11] >= 0x80 {
                    device.isEnabled = NSNumber(bool: true)
                    device.isVisible = NSNumber(bool: true)
                } else {
                    device.isEnabled = NSNumber(bool: false)
                    device.isVisible = NSNumber(bool: false)
                }
                let data = ["sensorIndexForFoundParametar":counter]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshInterface, object: self, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindSensorParametar, object: self, userInfo: data)
                
            }
            counter = counter + 1
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func ackACParametar (byteArray:[Byte]) {
        print(NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName))
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            fetchDevices()
            var string:String = ""
            for var i = 9; i < byteArray.count-2; i++ {
                string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
                print(string)
            }
            for var i = 0; i < devices.count; i++ {
                if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                    var string:String = ""
                    for var j = 42; j < byteArray.count-2; j++ {
                        string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
                    }
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    devices[i].zoneId = Int(byteArray[33])
                    devices[i].parentZoneId = Int(byteArray[34])
                    devices[i].categoryId = Int(byteArray[32])
//                    devices[i].enabled = ""
//                    if byteArray[22] == 0x01 {
//                        devices[i].isEnabled = NSNumber(bool: true)
//                    } else {
//                        devices[i].isEnabled = NSNumber(bool: false)
//                    }
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDeviceName, object: self, userInfo: data)
                }
            }
            saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
    }
    
    //  informacije o parametrima (statusu) urdjaja na MULTISENSORU - MISLIM DA JE OVO U REDU
    func ackADICmdGetInterfaceStatus (byteArray:[Byte]) {
        self.fetchDevices()
        print(byteArray)
        for var i = 0; i < self.devices.count; i++ {
            if self.devices[i].gateway.addressOne == Int(byteArray[2]) && self.devices[i].gateway.addressTwo == Int(byteArray[3]) && self.devices[i].address == Int(byteArray[4]) {
                let channel = Int(self.devices[i].channel)
                self.devices[i].currentValue = Int(byteArray[7+channel])
            }
            self.saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
    }
    //  informacije o novim uredjajima
    func acknowledgementAboutNewDevices (byteArray:[Byte]) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDevice) {
            var deviceExists = false
            print(byteArray[7])
            print(byteArray[8])
            print(DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name)
            print(DeviceInfo.deviceChannel[byteArray[7]]?.name)
//            if let channel = DeviceInfo.deviceChannel[byteArray[7]]?.channel, let name = DeviceInfo.deviceChannel[byteArray[7]]?.name {
            if let channel = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.channel, let name = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                if devices != [] {
                    for device in devices {
                        if device.address == Int(byteArray[4]) {
                            deviceExists = true
                        }
                    }
                } else {
                    deviceExists = false
                }
                if !deviceExists {
                    for var i=1 ; i<=channel ; i++ {
                        if channel == 10 && name == "sensor" && i > 1 {
                            let device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        } else if channel == 6 && name == "sensor" && i > 1 {
                            let device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        } else if name == "hvac" {
                            let device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.amp = ""
                            device.type = name
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
                        } else if name != "hvac" && name != "sensor" {
                            let device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
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
    //  informacije o stanjima na uredjajima
    func ackonowledgementAboutChannelState (byteArray:[Byte]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                let channelNumber = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+5*(channelNumber-1)]) //  lightning state
                devices[i].current = Int(byteArray[9+5*(channelNumber-1)]) + Int(byteArray[10+5*(channelNumber-1)]) // current
                devices[i].voltage = Int(byteArray[11+5*(channelNumber-1)]) // voltage
                devices[i].temperature = Int(byteArray[12+5*(channelNumber-1)]) // temperature
            } else {
                
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    //  informacije o stanjima na uredjajima
    func ackonowledgementAboutChannelsState (byteArray:[Byte]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                let channelNumber = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+5*(channelNumber-1)]) //  lightning state
//                let data = NSData(bytes: [byteArray[9+5*(channelNumber-1)], byteArray[10+5*(channelNumber-1)]], length: 2)
                devices[i].current = Int(UInt16(byteArray[9+5*(channelNumber-1)])*256 + UInt16(byteArray[10+5*(channelNumber-1)])) // current
                devices[i].voltage = Int(byteArray[11+5*(channelNumber-1)]) // voltage
                devices[i].temperature = Int(byteArray[12+5*(channelNumber-1)]) // temperature
                let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveDataForRepeatSendingHandler, object: self, userInfo: data)
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    //  informacije o parametrima kanala
    func acknowledgementAboutChannelParametar (byteArray:[Byte]){
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            fetchDevices()
            for var i = 0; i < devices.count; i++ {
                if  devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                    var string:String = ""
                    for var j = 8+47; j < byteArray.count-2; j++ {
                        string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
                    }
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    devices[i].overrideControl1 = Int(byteArray[23])
                    devices[i].overrideControl2 = Int(byteArray[24])
                    devices[i].overrideControl3 = Int(byteArray[25])
                    if Int(byteArray[10]) == 0 {
                        devices[i].zoneId = 0
                        devices[i].parentZoneId = Int(byteArray[9])
                    } else {
                        devices[i].zoneId = Int(byteArray[9])
                        devices[i].parentZoneId = Int(byteArray[10])
                    }
                    devices[i].categoryId = Int(byteArray[8])
                    if byteArray[22] == 0x01 {
                        devices[i].isEnabled = NSNumber(bool: true)
                    } else {
                        devices[i].isEnabled = NSNumber(bool: false)
                        devices[i].isVisible = NSNumber(bool: false)
                    }
//                    devices[i].allowCurtainMode = Int(byteArray[33])
                    devices[i].curtainGroupID = Int(byteArray[34])
//                    This is for curatin COntrol Mode: 1 NC, 2 NO, 3 NC and Reset, 4 NO and Reset
                    devices[i].curtainControlMode = Int(byteArray[35])
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDeviceName, object: self, userInfo: data)
                }
            }
            saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
        
    }
    //  0x00 Waiting = 0
    //  0x01 Started = 1
    //  0xF0 Elapsed = 240
    //  0xEE Suspend = 238
    //  informacije o parametrima kanala
    func ackTimerStatus (byteArray:[Byte]){
        print("AOOO")
        print(byteArray)
        fetchEntities("Timer")
        for var i = 1; i <= 16; i++ {
            print(timers.count)
            for item in timers {
                if  item.gateway.addressOne == Int(byteArray[2]) && item.gateway.addressTwo == Int(byteArray[3]) && item.address == Int(byteArray[4]) && item.timerId == Int(i) {
                        item.timerState = NSNumber(integer: Int(byteArray[7+i]))
                    saveChanges()
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshTimer, object: self, userInfo: nil)
                }
            }
        }
    }
    //  informacije o parametrima kanala
    func ackFlagStatus (byteArray:[Byte]){
        print("AOOO 2")
        print(byteArray)
        fetchEntities("Flag")
        for var i = 1; i <= 32; i++ {
            print(flags.count)
            for item in flags {
                if  item.gateway.addressOne == Int(byteArray[2]) && item.gateway.addressTwo == Int(byteArray[3]) && item.address == Int(byteArray[4]) && item.flagId == Int(i) {
                    print("alo \(NSNumber(integer: Int(byteArray[7+i])))")
                    if Int(byteArray[7+i]) == 1 {
                        item.setState = NSNumber(bool: false)
                    } else if Int(byteArray[7+i]) == 0 {
                        item.setState = NSNumber(bool: true)
                    }
                    saveChanges()
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFlag, object: self, userInfo: nil)
                }
            }
        }
        
    }
    func securityFeedbackHandler (byteArray:[Byte]) {
        print("AOOO 3")
        print(byteArray)
        fetchEntities("Security")
        let address = [Byte(Int(securities[0].addressOne)), Byte(Int(securities[0].addressTwo)), Byte(Int(securities[0].addressThree))]
        if byteArray[2] == address[0] && byteArray[3] == address[1] && byteArray[4] == address[2] {
            let defaults = NSUserDefaults.standardUserDefaults()
            if byteArray[7] == 0x02 {
                switch byteArray[8] {
                case 0x00:
                    defaults.setValue("Disarm", forKey: UserDefaults.Security.SecurityMode)
                case 0x01:
                    defaults.setValue("Away", forKey: UserDefaults.Security.SecurityMode)
                case 0x02:
                    defaults.setValue("Nigth", forKey: UserDefaults.Security.SecurityMode)
                case 0x03:
                    defaults.setValue("Day", forKey: UserDefaults.Security.SecurityMode)
                case 0x04:
                    defaults.setValue("Vacation", forKey: UserDefaults.Security.SecurityMode)
                default: break
                }
            }
            if byteArray[7] == 0x03 {
                switch byteArray[8] {
                case 0x00:
                    defaults.setValue("Idle", forKey: UserDefaults.Security.AlarmState)
                case 0x01:
                    defaults.setValue("Trouble", forKey: UserDefaults.Security.AlarmState)
                case 0x02:
                    defaults.setValue("Alert", forKey: UserDefaults.Security.AlarmState)
                case 0x03:
                    defaults.setValue("Alarm", forKey: UserDefaults.Security.AlarmState)
                default: break
                }
            }
            if byteArray[7] == 0x04 {
                switch byteArray[8] {
                case 0x00:
                    defaults.setBool(true, forKey: UserDefaults.Security.IsPanic)
                case 0x01:
                    defaults.setBool(false, forKey: UserDefaults.Security.IsPanic)
                default: break
                }
            }
            print("EHGSecuritySeczurityMode - \(defaults.valueForKey(UserDefaults.Security.SecurityMode)) *** EHGSecurityAlarmState - \(defaults.valueForKey(UserDefaults.Security.AlarmState)) *** EHGSecurityPanic - \(defaults.boolForKey(UserDefaults.Security.IsPanic))")
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshSecurity, object: self, userInfo: nil)
        }
    }
    var timers:[Timer] = []
    var flags:[Flag] = []
    var securities:[Security] = []
    func fetchEntities (whatToFetch:String) {
        if whatToFetch == "Flag" {
            let fetchRequest = NSFetchRequest(entityName: "Flag")
            let sortDescriptors = NSSortDescriptor(key: "flagName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Flag]
                print(results.count)
                flags = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Timer" {
            let fetchRequest = NSFetchRequest(entityName: "Timer")
            let sortDescriptors = NSSortDescriptor(key: "timerName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Timer]
                timers = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Security" {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Security")
            let sortDescriptorTwo = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorTwo]
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Security]
                securities = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}
