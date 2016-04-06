//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 4/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category {

    @NSManaged var categoryDescription: String?
    @NSManaged var id: NSNumber?
    @NSManaged var isVisible: NSNumber?
    @NSManaged var name: String?
    @NSManaged var orderId: NSNumber?
    @NSManaged var location: Location?

}
