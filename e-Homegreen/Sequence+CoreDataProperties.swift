//
//  Sequence+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/5/15.
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
    @NSManaged var sequenceCycles: NSNumber
    @NSManaged var sequenceId: NSNumber
    @NSManaged var sequenceImageOne: NSData
    @NSManaged var sequenceImageTwo: NSData
    @NSManaged var sequenceName: String
    @NSManaged var gateway: Gateway
    @NSManaged var gatewayZone: Zone
    @NSManaged var gatewayCategory: Category

}