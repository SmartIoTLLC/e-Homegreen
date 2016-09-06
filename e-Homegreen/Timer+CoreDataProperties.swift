//
//  Timer+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Timer {

    @NSManaged var address: NSNumber
    @NSManaged var entityLevel: String?
    @NSManaged var entityLevelId: NSNumber?
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var isLocalcast: NSNumber
    @NSManaged var timerCategory: String?
    @NSManaged var timerCategoryId: NSNumber?
    @NSManaged var timerId: NSNumber
    @NSManaged var id: String
    @NSManaged var timerImageOneCustom: String?
    @NSManaged var timerImageOneDefault: String?
    @NSManaged var timerImageTwoCustom: String?
    @NSManaged var timerImageTwoDefault: String?
    @NSManaged var timerName: String
    @NSManaged var timerState: NSNumber
    @NSManaged var timeZone: String?
    @NSManaged var timeZoneId: NSNumber?
    @NSManaged var type: String
    @NSManaged var count: NSNumber
    @NSManaged var gateway: Gateway

}
