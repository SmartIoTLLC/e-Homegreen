//
//  Surveillance+CoreDataProperties.swift
//  
//
//  Created by Vladimir Zivanov on 4/20/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Surveillance {

    @NSManaged var autSpanStep: NSNumber?
    @NSManaged var dwellTime: NSNumber?
    @NSManaged var ip: String?
    @NSManaged var isVisible: NSNumber?
    @NSManaged var localIp: String?
    @NSManaged var localPort: String?
    @NSManaged var name: String?
    @NSManaged var panStep: NSNumber?
    @NSManaged var password: String?
    @NSManaged var port: NSNumber?
    @NSManaged var surveillanceCategory: String?
    @NSManaged var surveillanceLevel: String?
    @NSManaged var surveillanceZone: String?
    @NSManaged var tiltStep: NSNumber?
    @NSManaged var urlAutoPan: String?
    @NSManaged var urlAutoPanStop: String?
    @NSManaged var urlGetImage: String?
    @NSManaged var urlHome: String?
    @NSManaged var urlMoveDown: String?
    @NSManaged var urlMoveLeft: String?
    @NSManaged var urlMoveRight: String?
    @NSManaged var urlMoveUp: String?
    @NSManaged var urlPresetSequence: String?
    @NSManaged var urlPresetSequenceStop: String?
    @NSManaged var username: String?
    @NSManaged var location: Location?
    @NSManaged var cameraZone: Zone?
    @NSManaged var cameraLevel: Zone?
    @NSManaged var cameraCategory: Category?

}
