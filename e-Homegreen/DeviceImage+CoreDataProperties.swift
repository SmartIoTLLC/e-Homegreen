//
//  DeviceImage+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/26/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DeviceImage {

    @NSManaged var state: NSNumber?
    @NSManaged var device: Device?
    @NSManaged var image: Image?

}
