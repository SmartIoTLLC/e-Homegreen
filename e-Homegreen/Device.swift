//
//  Device.swift
//  new
//
//  Created by Teodor Stevic on 7/2/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class Device: NSObject {
    var deviceId:UInt8?
    var subId:UInt8?
    var productDescription:String?
    var category:UInt8?
    var macOfDevice:[UInt8] = []
    init (deviceId:UInt8, subId:UInt8, macOfDevice:[UInt8]) {
        self.deviceId = deviceId
        self.subId = subId
        self.macOfDevice = macOfDevice
    }
}
