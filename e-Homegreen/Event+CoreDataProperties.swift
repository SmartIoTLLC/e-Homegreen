//
//  Event+CoreDataProperties.swift
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

extension Event {

    @NSManaged var address: NSNumber
    @NSManaged var eventId: NSNumber
    @NSManaged var eventImageOneCustom: String?
    @NSManaged var eventImageOneDefault: String?
    @NSManaged var eventImageTwoCustom: String?
    @NSManaged var eventImageTwoDefault: String?
    @NSManaged var eventName: String
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var isLocalcast: NSNumber    
    @NSManaged var report: NSNumber
    @NSManaged var entityLevelId: NSNumber?
    @NSManaged var eventZoneId: NSNumber?
    @NSManaged var eventCategoryId: NSNumber?
    @NSManaged var gateway: Gateway

}
