//
//  Device.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Device: NSManagedObject {

    @NSManaged var address: NSNumber
    @NSManaged var amp: String
    @NSManaged var channel: NSNumber
    @NSManaged var current: NSNumber
    @NSManaged var currentValue: NSNumber
    @NSManaged var name: String
    @NSManaged var numberOfDevices: NSNumber
    @NSManaged var runningTime: String
    @NSManaged var temperature: NSNumber
    @NSManaged var type: String
    @NSManaged var voltage: NSNumber
    @NSManaged var mode: String
    @NSManaged var modeState: String
    @NSManaged var speed: String
    @NSManaged var speedState: String
    @NSManaged var coolTemperature: NSNumber
    @NSManaged var heatTemperature: NSNumber
    @NSManaged var roomTemperature: NSNumber
    @NSManaged var humidity: NSNumber
    @NSManaged var gateway: Gateway
    var opening:Bool = true
    var on:Bool = false

}
