//
//  IncomingHandler+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

struct DeviceInformation {
    let address:Int
    let channel:Int
    let numberOfDevices:Int
    let type:String
    let gateway:Gateway
    let mac:Data
    let isClimate:Bool
    let curtainNeedsSlider: Bool
}

