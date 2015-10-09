//
//  Scene+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/6/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Scene {

    @NSManaged var address: NSNumber
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var sceneId: NSNumber
    @NSManaged var sceneImageOne: NSData
    @NSManaged var sceneImageTwo: NSData
    @NSManaged var sceneName: String
    @NSManaged var sceneZone: String?
    @NSManaged var sceneCategory: String?
    @NSManaged var gateway: Gateway

}
