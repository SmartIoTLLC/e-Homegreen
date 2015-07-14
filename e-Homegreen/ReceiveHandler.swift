
//  ReceiveHandler.swift
//  new
//
//  Created by Teodor Stevic on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData



//class CommonViewController: UIViewController {
//

//  Mozda incoming handler
class ReceiveHandler: NSObject {
    var byteArray:[UInt8]!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    
    init (byteArrayToHandle: [UInt8]) {
        super.init()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
        
        self.byteArray = byteArrayToHandle
        // Check if byteArray is correct one (check byte also, which is missing)
        if byteArray[0] == 0xAA && byteArray[byteArray.count-1] == 0x10 {
            
            //  ACKNOWLEDGMENT ABOUT NEW DEVICES
            if byteArray[5] == 0xF1 && byteArray[6] == 0x01 {
                acknowledgementAboutNewDevices(byteArray)
            }
            
            //  ACKNOWLEDGEMENT ABOUT CHANNEL PARAMETAR (Get Channel Parametar)
            if byteArray[5] == 0xF3 && byteArray[6] == 0x01 {
                acknowledgementAboutChannelParametar (byteArray)
                
            }
            
            //  ACKNOWLEDGMENT ABOUT CHANNEL STATE (Get Channel State)
            //  Dolaze dva odgovora
            if byteArray[5] == 0xF3 && byteArray[6] == 0x06 {
                ackonowledgementAboutChannelState(byteArray)
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
            
            //
            if byteArray[5] == 0xF5 && byteArray[6] == 0x01 {
                ackADICmdGetInterfaceStatus(byteArray)
            }
            
            //
            if byteArray[5] == 0xF5 && byteArray[6] == 0x04 {
                ackADICmdGetInterfaceName(byteArray)
            }
            
        }
    }
    func fetchDevices () {
        var fetchRequest = NSFetchRequest(entityName: "Device")
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            
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
        for var i = 0; i < Model.sharedInstance.deviceArray.count; i++ {
            if devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                var channel = Int(devices[i].channel)
                devices[i].name = string
            }
        }
        saveChanges()
    }
    //  informacije o parametrima (statusu) urdjaja na MULTISENSORU
    func ackADICmdGetInterfaceStatus (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].address == Int(byteArray[4]) {
                var channel = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[7+channel])
            }
        }
        saveChanges()
    }
    //  informacije o novim uredjajima
    func acknowledgementAboutNewDevices (byteArray:[UInt8]) {
        var deviceExists = false
        if let channel = UserDefaults().deviceChannel[byteArray[7]]?.channel, let name = UserDefaults().deviceChannel[byteArray[7]]?.name {
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
                        device.name = UserDefaults().inputInterface10in1[i]!
                        device.address = Int(byteArray[4])
                        device.channel = i
                        device.gateway = Int(byteArray[2])
                        device.numberOfDevices = channel
                        device.runningTime = ""
                        device.currentValue = 0
                        device.current = ""
                        device.amp = ""
                        device.runningTime = ""
                        device.type = name
                        saveChanges()
                    } else if channel == 6 && name == "sensor" {
                        var device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
                        device.name = UserDefaults().inputInterface6in1[i]!
                        device.address = Int(byteArray[4])
                        device.channel = i
                        device.gateway = Int(byteArray[2])
                        device.numberOfDevices = channel
                        device.runningTime = ""
                        device.currentValue = 0
                        device.current = ""
                        device.amp = ""
                        device.runningTime = ""
                        device.type = name
                        saveChanges()
                    } else {
                        var device = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as! Device
                        device.name = name
                        device.address = Int(byteArray[4])
                        device.channel = i
                        device.gateway = Int(byteArray[2])
                        device.numberOfDevices = channel
                        device.runningTime = ""
                        device.currentValue = 0
                        device.current = ""
                        device.amp = ""
                        device.runningTime = ""
                        device.type = name
                        saveChanges()
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("testNotificationCenter", object: self, userInfo: nil)
                }
            }
        }
    }
    //  informacije o stanjima na uredjajima
    func ackonowledgementAboutChannelState (byteArray:[UInt8]) {
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].address == Int(byteArray[4]) {
                var channelNumber = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+5*(channelNumber-1)]) //lightning state
//                devices[i].current = byteArray[9] // current
//                devices[i].voltage = byteArray[10] // current
//                devices[i].temperature = byteArray[11] // voltage
//                devices[i] = byteArray[12] // temperature
            } else {
                
            }
        }
//        NSNotificationCenter.defaultCenter().postNotificationName("testNotificationCenter", object: self, userInfo: nil)
        saveChanges()
    }
    //  informacije o parametrima kanala
    func acknowledgementAboutChannelParametar (byteArray:[UInt8]){
        fetchDevices()
        for var i = 0; i < devices.count; i++ {
            if devices[i].numberOfDevices == Int(byteArray[7]) && devices[i].address == Int(byteArray[4]) {
                var string:String = ""
                for var i = 8+47; i < byteArray.count-2; i++ {
                    string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
                }
                devices[i].name = string
            }
        }
        saveChanges()
    }
    
}
