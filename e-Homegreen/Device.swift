//
//  Device.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/10/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData
enum EmployeeStatus: Int {
    case ReadyForHire, Hired, Retired, Resigned, Fired, Deceased
}
class Device: NSManagedObject {


    var interfaceParametar:[UInt8] = []
    var warningState:Int = 0
    var opening:Bool = true
    var on:Bool = false
    var info:Bool = false
    
    var cellTitle:String = ""

    var status: EmployeeStatus {
        get {
            return EmployeeStatus(rawValue: Int(self.address))!
        }
        set {
            self.address = NSNumber(integer:newValue.rawValue)
        }
    }
}
