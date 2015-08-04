//
//  Device.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 8/3/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Device: NSManagedObject {

    @NSManaged var address: NSNumber
    @NSManaged var amp: String
    @NSManaged var channel: NSNumber
    @NSManaged var coolTemperature: NSNumber
    @NSManaged var current: NSNumber
    @NSManaged var currentValue: NSNumber
    @NSManaged var heatTemperature: NSNumber
    @NSManaged var humidity: NSNumber
    @NSManaged var mode: String
    @NSManaged var modeState: String
    @NSManaged var name: String
    @NSManaged var numberOfDevices: NSNumber
    @NSManaged var roomTemperature: NSNumber
    @NSManaged var runningTime: String
    @NSManaged var speed: String
    @NSManaged var speedState: String
    @NSManaged var temperature: NSNumber
    @NSManaged var type: String
    @NSManaged var voltage: NSNumber
    @NSManaged var stateUpdatedAt: NSDate
    @NSManaged var gateway: Gateway
    var opening:Bool = true
    var on:Bool = false

}
