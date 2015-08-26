//
//  Device.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 8/26/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Device: NSManagedObject {

    @NSManaged var address: NSNumber
    @NSManaged var amp: String
    @NSManaged var categoryId: NSNumber
    @NSManaged var categoryName: String
    @NSManaged var channel: NSNumber
    @NSManaged var coolTemperature: NSNumber
    @NSManaged var current: NSNumber
    @NSManaged var currentValue: NSNumber
    @NSManaged var heatTemperature: NSNumber
    @NSManaged var humidity: NSNumber
    @NSManaged var level: NSNumber
    @NSManaged var mode: String
    @NSManaged var modeState: String
    @NSManaged var name: String
    @NSManaged var numberOfDevices: NSNumber
    @NSManaged var parentZoneId: NSNumber
    @NSManaged var roomTemperature: NSNumber
    @NSManaged var runningTime: String
    @NSManaged var speed: String
    @NSManaged var speedState: String
    @NSManaged var stateUpdatedAt: NSDate
    @NSManaged var temperature: NSNumber
    @NSManaged var type: String
    @NSManaged var voltage: NSNumber
    @NSManaged var zoneId: NSNumber
    @NSManaged var runtime: NSNumber
    @NSManaged var delay: NSNumber
    @NSManaged var skipState: NSNumber
    @NSManaged var isEnabled: NSNumber
    @NSManaged var overrideControl1: NSNumber
    @NSManaged var overrideControl2: NSNumber
    @NSManaged var overrideControl3: NSNumber
    @NSManaged var gateway: Gateway
    var opening:Bool = true
    var on:Bool = false
    var info:Bool = false


}
