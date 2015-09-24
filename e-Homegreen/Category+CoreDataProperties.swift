//
//  Category+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/24/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category {

    @NSManaged var categoryDescription: String
    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var isVisible: NSNumber
    @NSManaged var gateway: Gateway

}
