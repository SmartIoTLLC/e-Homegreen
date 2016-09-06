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
    @NSManaged var isLocalcast: NSNumber
    @NSManaged var sceneId: NSNumber
    @NSManaged var sceneImageOneCustom: String?
    @NSManaged var sceneImageOneDefault: String?
    @NSManaged var sceneImageTwoCustom: String?
    @NSManaged var sceneImageTwoDefault: String?
    @NSManaged var sceneName: String
    @NSManaged var entityLevel: String?
    @NSManaged var entityLevelId: NSNumber?
    @NSManaged var sceneZone: String?
    @NSManaged var sceneZoneId: NSNumber?
    @NSManaged var sceneCategory: String?
    @NSManaged var sceneCategoryId: NSNumber?
    @NSManaged var gateway: Gateway

}
