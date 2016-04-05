//
//  Zone+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 4/5/16.
//
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
    @NSManaged var orderId: NSNumber?
    @NSManaged var iBeacon: IBeacon?
    @NSManaged var location: Location?

}
