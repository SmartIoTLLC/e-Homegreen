//
//  Information+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/17/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var username: String
    @NSManaged var password: String
    @NSManaged var databaseName: String?
    @NSManaged var databaseAlias: String?
    @NSManaged var profilePicture: NSData?
    @NSManaged var superUser: User?

}
