//
//  Location+CoreDataProperties.swift
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

extension Location {

    @NSManaged var latitude: NSNumber?
    @NSManaged var locationDescription: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var radius: NSNumber?
    @NSManaged var categories: NSSet?
    @NSManaged var gateways: NSSet?
    @NSManaged var ssids: NSSet?
    @NSManaged var surveillances: NSSet?
    @NSManaged var timer: Timer?
    @NSManaged var user: User?
    @NSManaged var zones: NSSet?

}
