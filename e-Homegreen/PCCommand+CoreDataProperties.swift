//
//  PCCommand+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PCCommand {

    @NSManaged var name: String?
    @NSManaged var comand: String?
    @NSManaged var isRunCommand: NSNumber?
    @NSManaged var device: Device?

}
