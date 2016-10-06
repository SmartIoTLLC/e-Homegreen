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

    @NSManaged public var name: String
    @NSManaged public var macroId: NSNumber
    @NSManaged var location: Location

}
