//
//  PCCommand+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Marko Stajic on 8/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PCCommand {

    @NSManaged var comand: String?
    @NSManaged var name: String?
    @NSManaged var commandType: NSNumber?
    @NSManaged var device: Device?

}
