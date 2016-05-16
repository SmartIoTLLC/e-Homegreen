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
    @NSManaged var eventImageOne: NSData
    @NSManaged var eventImageTwo: NSData
    @NSManaged var eventName: String
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var isLocalcast: NSNumber    
    @NSManaged var report: NSNumber
    @NSManaged var entityLevel: String?
    @NSManaged var eventZone: String?
    @NSManaged var eventCategory: String?
    @NSManaged var gateway: Gateway

}
