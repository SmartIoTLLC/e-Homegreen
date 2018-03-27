//
//  Macro+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/27/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//
//

import Foundation
import CoreData


extension Macro {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Macro> {
        return NSFetchRequest<Macro>(entityName: "Macro")
    }

    @NSManaged public var macro_category: String?
    @NSManaged public var macro_level: String?
    @NSManaged public var macro_location: NSNumber?
    @NSManaged public var macro_zone: String?
    @NSManaged public var name: String?
    @NSManaged public var negative_image: String?
    @NSManaged public var positive_image: String?
    @NSManaged public var type: String?
    @NSManaged public var macro_actions: NSSet?

}

// MARK: Generated accessors for macro_actions
extension Macro {

    @objc(addMacro_actionsObject:)
    @NSManaged public func addToMacro_actions(_ value: Macro_action)

    @objc(removeMacro_actionsObject:)
    @NSManaged public func removeFromMacro_actions(_ value: Macro_action)

    @objc(addMacro_actions:)
    @NSManaged public func addToMacro_actions(_ values: NSSet)

    @objc(removeMacro_actions:)
    @NSManaged public func removeFromMacro_actions(_ values: NSSet)

}
