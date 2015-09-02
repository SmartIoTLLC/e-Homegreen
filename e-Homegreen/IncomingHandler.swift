
//  ReceiveHandler.swift
//  new
//
//  Created by Teodor Stevic on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class IncomingHandler: NSObject {
    var byteArray:[UInt8]!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var error:NSError? = nil
    var host:String = ""
    var port:UInt16 = 0
    
    init (byteArrayToHandle: [UInt8], host:String, port:UInt16) {
        super.init()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        self.host = host
        self.port = port
        fetchGateways(host, port: port)
        
        //  Checks if there are any gateways
        if gateways != [] {
            fetchDevices()
            self.byteArray = byteArrayToHandle
            TryCatch.try({
                // Check if byteArray is correct one (check byte also, which is missing)
                if self.byteArray[0] == 0xAA && self.byteArray[self.byteArray.count-1] == 0x10 {
                    println("Uslo je u incoming handler.")
                    
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
                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x04 {
                        self.ackADICmdGetInterfaceName(self.byteArray)
                    }
                    
                }
                }, catch: {error in
                    println("NEKI EROR COVECE MOJ, PA STA SE OVO DESAVA SADA, KAZE DA JE OVO: \(error)")
                }, finally: {
            
            })
        }
    }
    func fetchDevices () {
        // OVDE ISKACE BUD NA ANY
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let predicate = NSPredicate(format: "gateway == %@", gateways[0].objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
    }
    func fetchDevices (addressOne:Int, addressTwo:Int, addressThree:Int, channel:Int) {
//        devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7])
        // OVDE ISKACE BUD NA ANY
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let predicateOne = NSPredicate(format: "gateway == %@", gateways[0].objectID)
        let predicateTwo = NSPredicate(format: "gateway.addressOne == %@", addressOne)
        let predicateThree = NSPredicate(format: "gateway.addressTwo == %@", addressTwo)
        let predicateFour = NSPredicate(format: "address == %@", addressThree)
        let predicateFive = NSPredicate(format: "channel == %@", channel)
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateTwo, predicateThree, predicateFour, predicateFive])
        fetchRequest.predicate = compoundPredicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
    }
    func fetchGateways (host:String, port:UInt16) {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "remoteIpInUse == %@ AND remotePort == %@", host, NSNumber(unsignedShort: port))
        let predicateThree = NSPredicate(format: "localIp == %@ AND localPort == %@", host, NSNumber(unsignedShort: port))
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicateTwo,predicateThree])
        fetchRequest.predicate = NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne,compoundPredicate])
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Gateway]
        if let results = fetResults {
            gateways = results
        } else {
            println("Nije htela...")
        }
    }
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func ackACstatus (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                var channel = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+13*(channel-1)])
                if let mode = DeviceInfo().setMode[Int(byteArray[9+13*(channel-1)])], let modeState = DeviceInfo().modeState[Int(byteArray[10+13*(channel-1)])], let speed = DeviceInfo().setSpeed[Int(byteArray[11+13*(channel-1)])], let speedState = DeviceInfo().speedState[Int(byteArray[12+13*(channel-1)])] {
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
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshClimateController", object: self, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    func ackDimmerGetRunningTime (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                if byteArray[7] != 0xFF {
                    devices[i].runningTime = returnRunningTime([byteArray[8], byteArray[9], byteArray[10], byteArray[11]])
                } else {
                    var channelNumber = Int(devices[i].channel)
                    devices[i].runningTime = returnRunningTime([byteArray[8+4*(channelNumber-1)], byteArray[9+4*(channelNumber-1)], byteArray[10+4*(channelNumber-1)], byteArray[11+4*(channelNumber-1)]])
                    println(devices[i].runningTime)
                }
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    func bytesToUInt(byteArray: [UInt8]) -> UInt {
        assert(byteArray.count <= 4)
        var result: UInt = 0
        for idx in 0..<(byteArray.count) {
            let shiftAmount = UInt((byteArray.count) - idx - 1) * 8
            result += UInt(byteArray[idx]) << shiftAmount
        }
        return result
    }
    func returnRunningTime (runningTimeByteArray:[UInt8]) -> String {
        println(runningTimeByteArray)
        var x = Int(bytesToUInt(runningTimeByteArray))
        var z = UnsafePointer<UInt16>(runningTimeByteArray).memory
        var y = Int(runningTimeByteArray[0])*1*256 + Int(runningTimeByteArray[1])*1*256 + Int(runningTimeByteArray[2])*1*256 + Int(runningTimeByteArray[3])
        var seconds = x / 10
        var hours = seconds / 3600
        var minutes = (seconds % 3600) / 60
        seconds = seconds % 60
        var secdiv = (x % 60) % 10
        return "\(returnTwoPlaces(hours)):\(returnTwoPlaces(minutes)):\(returnTwoPlaces(seconds)),\(secdiv)s"
    }
    func returnTwoPlaces (number:Int) -> String {
        return String(format: "%02d",number)
    }
    //  informacije o imenima uredjaja na MULTISENSORU
    func ackADICmdGetInterfaceName (byteArray:[UInt8]) {
        fetchDevices()
        var string:String = ""
        for var i = 9; i < byteArray.count-2; i++ {
            string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
        }
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                var channel = Int(devices[i].channel)
                if string != "" {
                    devices[i].name = string
                } else {
                    devices[i].name = "Unknown"
                }
                var data = ["deviceIndexForFoundName":i]
                NSNotificationCenter.defaultCenter().postNotificationName("PLCdidFindNameForDevice", object: self, userInfo: data)
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    func ackADICmdGetInterfaceParametar (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                devices[i].zoneId = Int(byteArray[9])
                devices[i].parentZoneId = Int(byteArray[10])
                devices[i].categoryId = Int(byteArray[8])
//            devices[i].categoryName = DeviceInfo().categoryList[Int(byteArray[8])]!
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    func ackACParametar (byteArray:[UInt8]) {
        fetchDevices()
        var string:String = ""
        for var i = 9; i < byteArray.count-2; i++ {
            string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
        }
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                var string:String = ""
                for var i = 42; i < byteArray.count-2; i++ {
                    string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
                }
                if string != "" {
                    devices[i].name = string
                } else {
                    devices[i].name = "Unknown"
                }
//                devices[i].zoneId = Int(byteArray[71])
//                devices[i].parentZoneId = Int(byteArray[72])
//                devices[i].categoryId = Int(byteArray[70])
                devices[i].zoneId = Int(byteArray[33])
                devices[i].parentZoneId = Int(byteArray[34])
                devices[i].categoryId = Int(byteArray[32])
//                devices[i].categoryName = DeviceInfo().categoryList[Int(byteArray[70])]!
                var data = ["deviceIndexForFoundName":i]
                NSNotificationCenter.defaultCenter().postNotificationName("PLCdidFindNameForDevice", object: self, userInfo: data)
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    
    //  informacije o parametrima (statusu) urdjaja na MULTISENSORU - MISLIM DA JE OVO U REDU
    func ackADICmdGetInterfaceStatus (byteArray:[UInt8]) {
        TryCatch.try({
            self.fetchDevices()
            for var i = 0; i < self.devices.count; i++ {
                if self.devices[i].gateway.addressOne == Int(byteArray[2]) && self.devices[i].gateway.addressTwo == Int(byteArray[3]) && self.devices[i].address == Int(byteArray[4]) {
                    var channel = Int(self.devices[i].channel)
                    println("osluskuj 1")
                    self.devices[i].currentValue = Int(byteArray[7+channel])
                    println("osluskuj 2")
                }
            }
            self.saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
            }, catch: { error in
                println("NEKI EROR COVECE MOJ, PA STA SE OVO DESAVA SADA, KAZE DA JE OVO: \(error)")
            }, finally: {
                
        })
    }
    //  informacije o novim uredjajima
    func acknowledgementAboutNewDevices (byteArray:[UInt8]) {
        var deviceExists = false
        if let channel = DeviceInfo().deviceChannel[byteArray[7]]?.channel, let name = DeviceInfo().deviceChannel[byteArray[7]]?.name {
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
                    if channel == 10 && name == "sensor" {
                        var device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
//                        device.name = DeviceInfo().inputInterface10in1[i]!
                        device.name = "Unknown"
                        device.address = Int(byteArray[4])
                        device.channel = i
                        //                        device.gateway = Int(byteArray[2])
                        device.numberOfDevices = channel
                        device.runningTime = ""
                        device.currentValue = 0
                        device.current = 0
                        device.amp = ""
                        device.type = name
                        device.voltage = 0
                        device.temperature = 0
                        device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                        saveChanges()
                    } else if channel == 6 && name == "sensor" {
                        var device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
//                        device.name = DeviceInfo().inputInterface6in1[i]!
                        device.name = "Unknown"
                        device.address = Int(byteArray[4])
                        device.channel = i
                        //                        device.gateway = Int(byteArray[2])
                        device.numberOfDevices = channel
                        device.runningTime = ""
                        device.currentValue = 0
                        device.current = 0
                        device.amp = ""
                        device.type = name
                        device.voltage = 0
                        device.temperature = 0
                        device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                        saveChanges()
                    } else if name == "hvac" {
                        var device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
//                        device.name = name + " \(i)"
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
                    } else {
                        var device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
//                        device.name = name + " \(i)"
                        device.name = "Unknown"
                        device.address = Int(byteArray[4])
                        device.channel = i
                        //                        device.gateway = Int(byteArray[2])
                        device.numberOfDevices = channel
                        device.runningTime = ""
                        device.currentValue = 0
                        device.current = 0
                        device.amp = ""
                        device.runningTime = ""
                        device.type = name
                        device.voltage = 0
                        device.temperature = 0
                        device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                        device.delay = 0
                        device.runtime = 0
                        device.skipState = 0
                        saveChanges()
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
                }
                NSNotificationCenter.defaultCenter().postNotificationName("PLCDidFindDevice", object: self, userInfo: nil)
            }
        }
    }
    //  informacije o stanjima na uredjajima
    func ackonowledgementAboutChannelState (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                var channelNumber = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+5*(channelNumber-1)]) //  lightning state
                devices[i].current = Int(byteArray[9+5*(channelNumber-1)]) + Int(byteArray[10+5*(channelNumber-1)]) // current
                devices[i].voltage = Int(byteArray[11+5*(channelNumber-1)]) // voltage
                devices[i].temperature = Int(byteArray[12+5*(channelNumber-1)]) // temperature
            } else {
                
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    //  informacije o stanjima na uredjajima
    func ackonowledgementAboutChannelsState (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                var channelNumber = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+5*(channelNumber-1)]) //  lightning state
                let data = NSData(bytes: [byteArray[9+5*(channelNumber-1)], byteArray[10+5*(channelNumber-1)]], length: 2)
                devices[i].current = Int(UInt16(byteArray[9+5*(channelNumber-1)])*256 + UInt16(byteArray[10+5*(channelNumber-1)])) // current
                devices[i].voltage = Int(byteArray[11+5*(channelNumber-1)]) // voltage
                devices[i].temperature = Int(byteArray[12+5*(channelNumber-1)]) // temperature
            } else {
                
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    //  informacije o parametrima kanala
    func acknowledgementAboutChannelParametar (byteArray:[UInt8]){
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if  devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                var string:String = ""
                for var i = 8+47; i < byteArray.count-2; i++ {
                    string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
                }
                if string != "" {
                    devices[i].name = string
                } else {
                    devices[i].name = "Unknown"
                }
                devices[i].overrideControl1 = Int(byteArray[23])
                devices[i].overrideControl2 = Int(byteArray[24])
                devices[i].overrideControl3 = Int(byteArray[25])
                devices[i].zoneId = Int(byteArray[9])
                devices[i].parentZoneId = Int(byteArray[10])
                devices[i].categoryId = Int(byteArray[8])
//                devices[i].categoryName = DeviceInfo().categoryList[Int(byteArray[8])]!
                var data = ["deviceIndexForFoundName":i]
                NSNotificationCenter.defaultCenter().postNotificationName("PLCdidFindNameForDevice", object: self, userInfo: data)
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
        
    }
}
