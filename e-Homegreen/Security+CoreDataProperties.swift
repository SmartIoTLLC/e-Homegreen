//
//  Security+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Security {

    @NSManaged var securityName: String?
    @NSManaged var securityDescription: String?
    @NSManaged var addressOne: NSNumber
    @NSManaged var addressTwo: NSNumber
    @NSManaged var addressThree: NSNumber
    @NSManaged var gatewayId: String?
    @NSManaged var location: Location?

}
