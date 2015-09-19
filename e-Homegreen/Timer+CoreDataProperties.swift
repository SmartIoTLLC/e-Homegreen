//
//  Timer+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Timer {

    @NSManaged var address: NSNumber
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var timerId: NSNumber
    @NSManaged var timerName: String
    @NSManaged var timerImageOne: NSData
    @NSManaged var timerImageTwo: NSData
    @NSManaged var gateway: Gateway

}
