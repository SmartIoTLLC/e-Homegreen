//
//  Reciter+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/18/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData


extension Reciter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reciter> {
        return NSFetchRequest<Reciter>(entityName: "Reciter")
    }

    @NSManaged public var count: String?
    @NSManaged public var id: String?
    @NSManaged public var letter: String?
    @NSManaged public var name: String?
    @NSManaged public var rewaya: String?
    @NSManaged public var server: String?
    @NSManaged public var suras: String?
    @NSManaged public var recitersSuras: NSSet?

}

// MARK: Generated accessors for recitersSuras
extension Reciter {

    @objc(addRecitersSurasObject:)
    @NSManaged public func addToRecitersSuras(_ value: Sura)

    @objc(removeRecitersSurasObject:)
    @NSManaged public func removeFromRecitersSuras(_ value: Sura)

    @objc(addRecitersSuras:)
    @NSManaged public func addToRecitersSuras(_ values: NSSet)

    @objc(removeRecitersSuras:)
    @NSManaged public func removeFromRecitersSuras(_ values: NSSet)

}
