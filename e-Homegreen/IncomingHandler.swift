
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
//                //  ACKNOWLEDGMENT ABOUT AC CONTROL STATUS
//                if byteArray[5] == 0xF4 && byteArray[6] == 0x03 {
//                    
//                }
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
                let data = ["selection":i]
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
            }
        }
        saveChanges()
//        let data = ["selection":-1]
//        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
    }
    
    func ackACname (byteArray:[UInt8]) {        fetchDevices()
        var string:String = ""
        for var i = 9; i < byteArray.count-2; i++ {
            string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
        }
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                var string:String = ""
                for var i = 8; i < byteArray.count-2; i++ {
                    string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
                }
                devices[i].name = string
                let data = ["selection":i]
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
            }
        }
        saveChanges()
    }
    
    //  informacije o parametrima (statusu) urdjaja na MULTISENSORU - MISLIM DA JE OVO U REDU
    func ackADICmdGetInterfaceStatus (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                var channel = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[7+channel])
                let data = ["selection":i]
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
            }
        }
        saveChanges()
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
                    let data = ["selection":-1]
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
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
                saveChanges()
                let data = ["selection":i]
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
            } else {
                
            }
        }
//        let data = ["selection":-1]
//        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
//        saveChanges()
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
                let data = ["selection":i]
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
            }
        }
//        let data = ["selection":-1]
//        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: data)
        saveChanges()
    }
    
}
