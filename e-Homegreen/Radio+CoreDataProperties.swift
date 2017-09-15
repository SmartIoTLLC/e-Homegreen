//
//  Radio+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/14/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData


extension Radio {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Radio> {
        return NSFetchRequest<Radio>(entityName: "Radio")
    }

    @NSManaged public var stationName: String?
    @NSManaged public var area: String?
    @NSManaged public var city: String?
    @NSManaged public var genre: String?
    @NSManaged public var url: String?
    @NSManaged public var isWorking: NSNumber?
    @NSManaged public var radioDescription: String?

}
