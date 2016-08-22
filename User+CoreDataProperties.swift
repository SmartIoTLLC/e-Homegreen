//
//  User+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 8/22/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var isLocked: NSNumber?
    @NSManaged var isSuperUser: NSNumber?
    @NSManaged var lastScreenId: NSNumber?
    @NSManaged var openLastScreen: NSNumber?
    @NSManaged var password: String?
    @NSManaged var username: String?
    @NSManaged var customImageId: String?
    @NSManaged var defaultImage: String?
    @NSManaged var filters: NSSet?
    @NSManaged var images: NSSet?
    @NSManaged var locations: NSSet?
    @NSManaged var menu: NSSet?

}
