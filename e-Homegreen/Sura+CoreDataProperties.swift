//
//  Sura+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/18/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData


extension Sura {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sura> {
        return NSFetchRequest<Sura>(entityName: "Sura")
    }

    @NSManaged public var id: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var reciter: Reciter?

}
