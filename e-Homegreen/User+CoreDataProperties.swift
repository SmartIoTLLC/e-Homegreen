//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var password: String?
    @NSManaged var profilePicture: NSData?
    @NSManaged var username: String?
    @NSManaged var isSuperUser: NSNumber?
    @NSManaged var isLocked: NSNumber?
    @NSManaged var locations: NSSet?
    @NSManaged var menu: NSSet?
    @NSManaged var openLastScreen: NSNumber
    @NSManaged var lastScreenId: NSNumber?

}
