//
//  Image+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 8/17/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Image {

    @NSManaged var imageData: Data?
    @NSManaged var imageId: String?
    @NSManaged var user: User?
    
//    @NSManaged func addUsersObject(value:User)

}
