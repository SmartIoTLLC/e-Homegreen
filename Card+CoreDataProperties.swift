//
//  Card+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 9/12/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Card {

    @NSManaged var id: NSNumber?
    @NSManaged var cardName: String?
    @NSManaged var cardId: String?
    @NSManaged var address: NSNumber?
    @NSManaged var gateway: Gateway?

}
