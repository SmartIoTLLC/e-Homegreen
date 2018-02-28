//
//  FilterParametar+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 7/25/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FilterParametar {

    @NSManaged var filterId: NSNumber
    @NSManaged var isDefault: NSNumber
    @NSManaged var isDefaultForAllTabs: Bool
    @NSManaged var locationId: String
    @NSManaged var levelId: String
    @NSManaged var zoneId: String
    @NSManaged var categoryId: String
    @NSManaged var user: User
    @NSManaged var timerDuration: NSNumber

}
