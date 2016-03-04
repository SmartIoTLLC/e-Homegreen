//
//  Surveilence+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/4/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Surveilence {

    @NSManaged var autSpanStep: NSNumber?
    @NSManaged var dwellTime: NSNumber?
    @NSManaged var ip: String?
    @NSManaged var isVisible: NSNumber?
    @NSManaged var level: String?
    @NSManaged var localIp: String?
    @NSManaged var localPort: String?
    @NSManaged var locationDELETETHIS: String?
    @NSManaged var name: String?
    @NSManaged var panStep: NSNumber?
    @NSManaged var password: String?
    @NSManaged var port: NSNumber?
    @NSManaged var ssid: String?
    @NSManaged var surveillanceCategory: String?
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

}
