//
//  MenuItem+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 4/27/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MenuItem {

    @NSManaged var id: NSNumber
    @NSManaged var orderId: NSNumber
    @NSManaged var isVisible: NSNumber
    @NSManaged var user: User

}
