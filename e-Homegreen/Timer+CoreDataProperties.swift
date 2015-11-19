//
//  Timer+CoreDataProperties.swift
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

extension Timer {

    @NSManaged var address: NSNumber
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var isLocalcast: NSNumber
    @NSManaged var timerId: NSNumber
    @NSManaged var timerImageOne: NSData
    @NSManaged var timerImageTwo: NSData
    @NSManaged var timerName: String
    @NSManaged var type: String
    @NSManaged var timerState: NSNumber
    @NSManaged var entityLevel: String?
    @NSManaged var timeZone: String?
    @NSManaged var timerCategory: String?
    @NSManaged var gateway: Gateway

}
