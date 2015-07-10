//
//  Device.swift
//  new
//
//  Created by Teodor Stevic on 7/2/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class DeviceOld: NSObject {
    
    var name:String
    var value:String
    var address:UInt8
    var channel:UInt8
    var gateway:Int
    var level:Int
//    var zone:Int
    var no_of_dev:Int
    var type:String
    
    init (name: String, value:String, address:UInt8, channel:UInt8, gateway:Int, level:Int, zone:Int, no_of_dev:Int, type:String) {
        self.name = name
        self.value = value
        self.address = address
        self.channel = channel
        self.gateway = gateway
        self.level = level
//        self.zone = zone
        self.no_of_dev = no_of_dev
        self.type = type
    }
    
    //  DEVICE AKNOWLEDGMENTS (INFO)
    var currentValue = 0
    var runningTime:String = "00:00:00"
    var current:String = "0.00"
    var amp:String = "0.00"
}
