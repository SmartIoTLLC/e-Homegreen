//
//  Gateway.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 8/26/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Gateway: NSManagedObject {

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
    @NSManaged var device: NSSet
    @NSManaged var scene: NSSet

}
