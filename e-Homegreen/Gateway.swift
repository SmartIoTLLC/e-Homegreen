//
//  Gateway.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Gateway: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var remoteIp: String
    @NSManaged var remotePort: NSNumber
    @NSManaged var localIp: String
    @NSManaged var localPort: NSNumber
    @NSManaged var ssid: String
    @NSManaged var addressOne: NSNumber
    @NSManaged var addressTwo: NSNumber
    @NSManaged var device: NSSet

}
