//
//  Macro+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/6/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

extension Macro {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Macro> {
        return NSFetchRequest<Macro>(entityName: "Macro");
    }

    @NSManaged var name: String
    @NSManaged var macroId: NSNumber
    @NSManaged var location: Location
    @NSManaged var macroImageOneCustom: String?
    @NSManaged var macroImageOneDefault: String?
    @NSManaged var macroImageTwoCustom: String?
    @NSManaged var macroImageTwoDefault: String?
    @NSManaged var entityLevelId: NSNumber?
    @NSManaged var macroZoneId: NSNumber?
    @NSManaged var macroCategoryId: NSNumber?

}
