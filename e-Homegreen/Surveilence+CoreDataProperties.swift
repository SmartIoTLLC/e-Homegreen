//
//  Surveilence+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/1/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Surveilence {

    @NSManaged var ip: String?
    @NSManaged var isVisible: NSNumber?
    @NSManaged var password: String?
    @NSManaged var port: NSNumber?
    @NSManaged var username: String?
    @NSManaged var localIp: String?
    @NSManaged var localPort: String?
    @NSManaged var name: String?
    @NSManaged var ssid: String?
    @NSManaged var location: String?

}
