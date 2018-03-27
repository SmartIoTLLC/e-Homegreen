//
//  Macro_action+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/27/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//
//

import Foundation
import CoreData

extension Macro_action {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Macro_action> {
        return NSFetchRequest<Macro_action>(entityName: "Macro_action")
    }

    @NSManaged public var command: NSNumber?
    @NSManaged public var control_type: NSNumber?
    @NSManaged public var delay: NSNumber?
    @NSManaged public var name: String?
    @NSManaged private var device: Device?
    @NSManaged private var gateway: Gateway?
    @NSManaged public var macro: Macro?

}
