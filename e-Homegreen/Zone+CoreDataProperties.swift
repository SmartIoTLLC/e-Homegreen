//
//  Zone+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/22/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Zone {

    @NSManaged var id: NSNumber?
    @NSManaged var isVisible: NSNumber?
    @NSManaged var level: NSNumber?
    @NSManaged var name: String?
    @NSManaged var zoneDescription: String?
    @NSManaged var iBeacon: IBeacon?
    @NSManaged var location: Location?

}
