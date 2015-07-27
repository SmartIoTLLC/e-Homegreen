
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
            // Check if byteArray is correct one (check byte also, which is missing)
            if byteArray[0] == 0xAA && byteArray[byteArray.count-1] == 0x10 {
                println("Uslo je u incoming handler.")
                
                //  ACKNOWLEDGMENT ABOUT NEW DEVICES
                if byteArray[5] == 0xF1 && byteArray[6] == 0x01 {
                    acknowledgementAboutNewDevices(byteArray)
                }
                
                //  ACKNOWLEDGEMENT ABOUT CHANNEL PARAMETAR (Get Channel Parametar) IMENA
                if byteArray[5] == 0xF3 && byteArray[6] == 0x01 {
                    acknowledgementAboutChannelParametar (byteArray)
                    
                }
                
                //  ACKNOWLEDGMENT ABOUT CHANNEL STATE (Get Channel State)
                if byteArray[5] == 0xF3 && byteArray[6] == 0x06 && byteArray[7] == 0xFF { // OVO NE MOZE OVAKO DA BUDE
                    ackonowledgementAboutChannelState(byteArray)
                                    }
                if byteArray[5] == 0xF3 && byteArray[6] == 0x06 {
                    
                }
                
                //            //  ACKNOWLEDGMENT ABOUT LIGHT RELAY STATUS (Get channel state (output) Lightning control action)
                //            if byteArray[5] == 0xF3 && byteArray[6] == 0x07 {
                //
                //            }
                
                //  ACKNOWLEDGMENT ABOUT RUNNING TIME (Get Channel On Time Count)
                if byteArray[5] == 0xF3 && byteArray[6] == 0x0C {
                    
                }
                
                //  ACKNOWLEDGMENT ABOUT CHANNEL WARNINGS (Get Channel On Last Current Change Warning)
                if byteArray[5] == 0xF3 && byteArray[6] == 0x10 {
                    
                }
                //  ACKNOWLEDGMENET ABOUT AC CONTROL PARAMETAR
                if byteArray[5] == 0xF4 && byteArray[6] == 0x01 {
                    ackACname(byteArray)
                }
                //  ACKNOWLEDGMENT ABOUT AC CONTROL STATUS
                if byteArray[5] == 0xF4 && byteArray[6] == 0x03 && byteArray[7] == 0xFF  {
                    ackACstatus(byteArray)
                }
//                if byteArray[5] == 0xF4 && byteArray[6] == 0x {
//                    
//                }
                // - Ovo je izgleda u redu
                if byteArray[5] == 0xF5 && byteArray[6] == 0x01 && byteArray[7] == 0xFF { // OVO NE MOZE OVAKO DA BUDE
                    ackADICmdGetInterfaceStatus(byteArray)
                }
                if byteArray[5] == 0xF5 && byteArray[6] == 0x01 {
                    
                }
                
                // - Ovo je izgleda u redu
                if byteArray[5] == 0xF5 && byteArray[6] == 0x04 {
                    ackADICmdGetInterfaceName(byteArray)
                }
                
            }
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
    func fetchGateways (host:String, port:UInt16) {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "remoteIp == %@ AND remotePort == %@", host, NSNumber(unsignedShort: port))
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
                devices[i].currentValue = Int(byteArray[8+2*(channel-1)])
                if let mode = DeviceInfo().setMode[Int(byteArray[9+2*(channel-1)])], let modeState = DeviceInfo().modeState[Int(byteArray[10+2*(channel-1)])], let speed = DeviceInfo().setSpeed[Int(byteArray[11+2*(channel-1)])], let speedState = DeviceInfo().modeState[Int(byteArray[12+2*(channel-1)])] {
                    devices[i].mode = DeviceInfo().setMode[Int(byteArray[9+2*(channel-1)])]!
                    devices[i].modeState = DeviceInfo().modeState[Int(byteArray[10+2*(channel-1)])]!
                    devices[i].speed = DeviceInfo().setSpeed[Int(byteArray[11+2*(channel-1)])]!
                    devices[i].speedState = DeviceInfo().modeState[Int(byteArray[12+2*(channel-1)])]!
                } else {
                    devices[i].mode = "AUTO"
                    devices[i].modeState = "Off"
                    devices[i].speed = "AUTO"
                    devices[i].speedState = "Off"
                }
                devices[i].coolTemperature = Int(byteArray[13+2*(channel-1)])
                devices[i].heatTemperature = Int(byteArray[14+2*(channel-1)])
                devices[i].roomTemperature = Int(byteArray[15+2*(channel-1)])
                devices[i].humidity = Int(byteArray[16+2*(channel-1)])
                devices[i].current = Int(byteArray[19+2*(channel-1)]) + Int(byteArray[20+2*(channel-1)])
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
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
                devices[i].name = string
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    
    func ackACname (byteArray:[UInt8]) {
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
                devices[i].name = string
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    
    //  informacije o parametrima (statusu) urdjaja na MULTISENSORU - MISLIM DA JE OVO U REDU
    func ackADICmdGetInterfaceStatus (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                var channel = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[7+channel])
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
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
                        device.name = DeviceInfo().inputInterface10in1[i]!
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
                        saveChanges()
                    } else if channel == 6 && name == "sensor" {
                        var device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
                        device.name = DeviceInfo().inputInterface6in1[i]!
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
                        saveChanges()
                    } else if name == "hvac" {
                        var device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
                        device.name = name + " \(i)"
                        device.address = Int(byteArray[4])
                        device.channel = i
                        device.numberOfDevices = channel
                        device.runningTime = ""
                        device.amp = ""
                        device.runningTime = ""
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
                        device.name = name + " \(i)"
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
                        saveChanges()
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
                }
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
    //  informacije o parametrima kanala
    func acknowledgementAboutChannelParametar (byteArray:[UInt8]){
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if  devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                var string:String = ""
                for var i = 8+47; i < byteArray.count-2; i++ {
                    string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
                }
                devices[i].name = string
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    
    func returnIpAddress (url:String) -> String {
        let host = CFHostCreateWithName(nil,url).takeRetainedValue();
        CFHostStartInfoResolution(host, .Addresses, nil);
        var success: Boolean = 0;
        if let test = CFHostGetAddressing(host, &success) {
            let addresses = test.takeUnretainedValue() as NSArray
            if (addresses.count > 0){
                let theAddress = addresses[0] as! NSData;
                var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                if getnameinfo(UnsafePointer(theAddress.bytes), socklen_t(theAddress.length),
                    &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        if let numAddress = String.fromCString(hostname) {
                            println(numAddress)
                            return numAddress
                        }
                }
            }
        }
        return ""
    }
}
