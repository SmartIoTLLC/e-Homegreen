//
//  Sequence+CoreDataProperties.swift
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

extension Sequence {

    @NSManaged var address: NSNumber
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var isLocalcast: NSNumber
    @NSManaged var sequenceCycles: NSNumber
    @NSManaged var sequenceId: NSNumber
    @NSManaged var sequenceImageOneCustom: String?
    @NSManaged var sequenceImageOneDefault: String?
    @NSManaged var sequenceImageTwoCustom: String?
    @NSManaged var sequenceImageTwoDefault: String?
    @NSManaged var sequenceName: String
    @NSManaged var entityLevel: String?
    @NSManaged var entityLevelId: NSNumber?
    @NSManaged var sequenceZone: String?
    @NSManaged var sequenceZoneId: NSNumber?
    @NSManaged var sequenceCategory: String?
    @NSManaged var sequenceCategoryId: NSNumber?
    @NSManaged var gateway: Gateway

}
