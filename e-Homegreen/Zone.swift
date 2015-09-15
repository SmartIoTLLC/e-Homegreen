//
//  Zone.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Zone: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var level: NSNumber
    @NSManaged var name: String
    @NSManaged var zoneDescription: String
    @NSManaged var gateway: Gateway

}
