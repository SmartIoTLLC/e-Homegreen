//
//  Flag+CoreDataProperties.swift
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

extension Flag {

    @NSManaged var flagId: NSNumber
    @NSManaged var flagName: String
    @NSManaged var setState: NSNumber
    @NSManaged var flagImageOneCustom: String?
    @NSManaged var flagImageOneDefault: String?
    @NSManaged var flagImageTwoCustom: String?
    @NSManaged var flagImageTwoDefault: String?
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var isLocalcast: NSNumber
    @NSManaged var entityLevel: String?
    @NSManaged var entityLevelId: NSNumber?
    @NSManaged var flagZone: String?
    @NSManaged var flagZoneId: NSNumber?
    @NSManaged var flagCategory: String?
    @NSManaged var flagCategoryId: NSNumber?
    @NSManaged var address: NSNumber
    @NSManaged var gateway: Gateway

}
