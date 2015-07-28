//
//  Gateway.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/28/15.
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
    @NSManaged var remotePort: NSNumber
    @NSManaged var ssid: String
    @NSManaged var turnedOn: NSNumber
    @NSManaged var remoteIpInUse: String
    @NSManaged var device: NSSet

}
