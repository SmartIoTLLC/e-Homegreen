//
//  ReceiveHandler.swift
//  new
//
//  Created by Teodor Stevic on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

//  Mozda incoming handler
class ReceiveHandler: NSObject {
    var byteArray:[UInt8]!
    init (byteArrayToHandle: [UInt8]) {
        super.init()
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
    //  informacije o imenima uredjaja na MULTISENSORU
    func ackADICmdGetInterfaceName (byteArray:[UInt8]) {
        var string:String = ""
        for var i = 9; i < byteArray.count-2; i++ {
            string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
        }
        println("ID: \(byteArray[7]) Name: \(string) Address: \(byteArray[2]) \(byteArray[3]) \(byteArray[4])")
        for var i = 0; i < Model.sharedInstance.deviceArray.count; i++ {
            if Model.sharedInstance.deviceArray[i].address == byteArray[4] && Model.sharedInstance.deviceArray[i].channel == byteArray[7] {
                var channel = Int(Model.sharedInstance.deviceArray[i].channel)
                Model.sharedInstance.deviceArray[i].name = string
            }
        }
    }
    //  informacije o parametrima (statusu) urdjaja na MULTISONSORU
    func ackADICmdGetInterfaceStatus (byteArray:[UInt8]) {
        println("informacije o parametrima (statusu) urdjaja na MULTISONSORU: \(byteArray)")
        for var i = 0; i < Model.sharedInstance.deviceArray.count; i++ {
            if Model.sharedInstance.deviceArray[i].address == byteArray[4] {
                var channel = Int(Model.sharedInstance.deviceArray[i].channel)
                Model.sharedInstance.deviceArray[i].currentValue = Int(byteArray[7+channel])
            }
        }
    }
    //  informacije o novim uredjajima
    func acknowledgementAboutNewDevices (byteArray:[UInt8]) {
        var deviceExists = false
        if let channel = UserDefaults().deviceChannel[byteArray[7]]?.channel, let name = UserDefaults().deviceChannel[byteArray[7]]?.name {
            if Model.sharedInstance.deviceArray != [] {
                for device in Model.sharedInstance.deviceArray {
                    if device.address == byteArray[4] {
                        deviceExists = true
                    }
                }
            } else {
                deviceExists = false
            }
            if !deviceExists {
                for var i=1 ; i<=channel ; i++ {
                    Model.sharedInstance.deviceArray.append(Device(name: name, value: "", address: byteArray[4], channel: UInt8(i), gateway: 0, level: 0, zone: 0, no_of_dev: 0, type: ""))
                }
            }
        }
    }
    //  informacije o stanjima na uredjajima
    func ackonowledgementAboutChannelState (byteArray:[UInt8]) {
        for var i = 0; i < Model.sharedInstance.deviceArray.count; i++ {
            if byteArray[4] == Model.sharedInstance.deviceArray[i].address {
                var channelNumber = Int(Model.sharedInstance.deviceArray[i].channel)
                Model.sharedInstance.deviceArray[i].currentValue = Int(byteArray[8+5*(channelNumber-1)]) // lightning state
//                Model.sharedInstance.deviceArray[i].current = byteArray[9] // current
//                Model.sharedInstance.deviceArray[i].current = byteArray[10] // current
//                Model.sharedInstance.deviceArray[i] = byteArray[11] // voltage
//                Model.sharedInstance.deviceArray[i] = byteArray[12] // temperature
            } else {
                
            }
        }
    }
    //  informacije o parametrima kanala
    func acknowledgementAboutChannelParametar (byteArray:[UInt8]){
        for var i = 0; i < Model.sharedInstance.deviceArray.count; i++ {
            if UInt8(Model.sharedInstance.deviceArray[i].no_of_dev) == byteArray[7] && Model.sharedInstance.deviceArray[i].address == byteArray[4] {
                var string:String = ""
                for var i = 8+47; i < byteArray.count-2; i++ {
                    string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
                }
                Model.sharedInstance.deviceArray[i].name = string
            }
        }
    }
    
}
