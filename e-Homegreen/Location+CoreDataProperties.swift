//
//  Location+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var locationDescription: String?
    @NSManaged var name: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var radius: NSNumber?
    @NSManaged var gateways: NSSet?
    @NSManaged var ssids: NSSet?
    @NSManaged var surveillances: NSSet?
    @NSManaged var timer: Timer?

}
