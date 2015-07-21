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

    @NSManaged var addressOne: NSNumber
    @NSManaged var addressTwo: NSNumber
    @NSManaged var localIp: String
    @NSManaged var localPort: NSNumber
    @NSManaged var name: String
    @NSManaged var remoteIp: String
    @NSManaged var remotePort: NSNumber
    @NSManaged var ssid: String
    @NSManaged var turnedOn: NSNumber
    @NSManaged var device: NSSet
    
    // Computed properties
//    var ipInUse:String {
//        get {
//            return ""
//        }
//        set (value) {
//            self.ipInUse = value
//        }
//    }
//    var portInUse:NSNumber {
//        get {
//            return NSNumber(int: 0)
//        }
//        set (value) {
//            self.portInUse = value
//        }
//    }
    var ipInUse:String = "o"
    var portInUse:NSNumber = NSNumber(int: 0)

}
