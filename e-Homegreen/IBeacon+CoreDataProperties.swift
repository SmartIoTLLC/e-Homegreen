//
//  IBeacon+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/13/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension IBeacon {

    @NSManaged var name: String?
    @NSManaged var uuid: String?
    @NSManaged var major: NSNumber?
    @NSManaged var minor: NSNumber?
    @NSManaged var iBeaconZone: Zone?

}
