//
//  Gateway+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/6/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Gateway {

    @NSManaged var addressOne: NSNumber
    @NSManaged var addressThree: NSNumber
    @NSManaged var addressTwo: NSNumber
    @NSManaged var gatewayDescription: String
    @NSManaged var localIp: String
    @NSManaged var localPort: NSNumber
    @NSManaged var name: String
    @NSManaged var remoteIp: String
    @NSManaged var remoteIpInUse: String
    @NSManaged var remotePort: NSNumber
    @NSManaged var ssid: String
    @NSManaged var turnedOn: NSNumber
    @NSManaged var categories: NSSet
    @NSManaged var devices: NSSet
    @NSManaged var events: NSSet
    @NSManaged var scenes: NSSet
    @NSManaged var security: NSSet
    @NSManaged var sequences: NSSet
    @NSManaged var timers: NSSet
    @NSManaged var zones: NSSet
    @NSManaged var flags: NSSet

}
