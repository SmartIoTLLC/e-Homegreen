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
    @NSManaged var flagImageOne: NSData
    @NSManaged var flagImageTwo: NSData
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var flagZone: String?
    @NSManaged var flagCategory: String?
    @NSManaged var address: NSNumber
    @NSManaged var gateway: Gateway

}
