//
//  Remote+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/14/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData


extension Remote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Remote> {
        return NSFetchRequest<Remote>(entityName: "Remote")
    }

    @NSManaged public var addressOne: NSNumber?
    @NSManaged public var addressThree: NSNumber?
    @NSManaged public var addressTwo: NSNumber?
    @NSManaged public var buttonColor: String?
    @NSManaged public var buttonHeight: NSNumber?
    @NSManaged public var buttonShape: String?
    @NSManaged public var buttonWidth: NSNumber?
    @NSManaged public var channel: NSNumber?
    @NSManaged public var columns: NSNumber?
    @NSManaged public var marginBottom: NSNumber?
    @NSManaged public var marginTop: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var parentZoneId: NSNumber?
    @NSManaged public var zoneId: NSNumber?
    @NSManaged public var rows: NSNumber?
    @NSManaged var location: Location?
    @NSManaged public var buttons: NSSet?

}

// MARK: Generated accessors for buttons
extension Remote {

    @objc(addButtonsObject:)
    @NSManaged public func addToButtons(_ value: RemoteButton)

    @objc(removeButtonsObject:)
    @NSManaged public func removeFromButtons(_ value: RemoteButton)

    @objc(addButtons:)
    @NSManaged public func addToButtons(_ values: NSSet)

    @objc(removeButtons:)
    @NSManaged public func removeFromButtons(_ values: NSSet)

}
