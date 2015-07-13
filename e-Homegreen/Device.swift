//
//  Device.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/10/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Device: NSManagedObject {

    @NSManaged var address: NSNumber
    @NSManaged var amp: String
    @NSManaged var channel: NSNumber
    @NSManaged var current: String
    @NSManaged var currentValue: NSNumber
    @NSManaged var gateway: NSNumber
    @NSManaged var name: String
    @NSManaged var numberOfDevices: NSNumber
    @NSManaged var runningTime: String
    @NSManaged var type: String
    var opening: Bool = true
    var on: Bool = false

}
