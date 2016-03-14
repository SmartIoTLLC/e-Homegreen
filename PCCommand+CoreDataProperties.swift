//
//  PCCommand+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 3/14/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PCCommand {

    @NSManaged var comand: String?
    @NSManaged var isRunCommand: NSNumber?
    @NSManaged var name: String?
    @NSManaged var device: Device?

}
