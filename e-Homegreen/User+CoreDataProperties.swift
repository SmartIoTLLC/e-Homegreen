//
//  User+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/1/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var customImageId: String?
    @NSManaged public var defaultImage: String?
    @NSManaged public var isLocked: NSNumber
    @NSManaged public var isSuperUser: NSNumber
    @NSManaged public var lastScreenId: NSNumber?
    @NSManaged public var openLastScreen: NSNumber!
    @NSManaged public var password: String?
    @NSManaged public var username: String?
    @NSManaged public var filters: NSSet?
    @NSManaged public var images: NSSet?
    @NSManaged public var locations: NSSet?
    @NSManaged public var menu: NSSet?
    
    @NSManaged func addImagesObject(_ value:Image)

}

// MARK: Generated accessors for filters
extension User {

    @objc(addFiltersObject:)
    @NSManaged public func addToFilters(_ value: FilterParametar)

    @objc(removeFiltersObject:)
    @NSManaged public func removeFromFilters(_ value: FilterParametar)

    @objc(addFilters:)
    @NSManaged public func addToFilters(_ values: NSSet)

    @objc(removeFilters:)
    @NSManaged public func removeFromFilters(_ values: NSSet)

}

// MARK: Generated accessors for images
extension User {

//    @objc(addImagesObject:)
//    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

// MARK: Generated accessors for locations
extension User {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

// MARK: Generated accessors for menu
extension User {

    @objc(addMenuObject:)
    @NSManaged public func addToMenu(_ value: MenuItem)

    @objc(removeMenuObject:)
    @NSManaged public func removeFromMenu(_ value: MenuItem)

    @objc(addMenu:)
    @NSManaged public func addToMenu(_ values: NSSet)

    @objc(removeMenu:)
    @NSManaged public func removeFromMenu(_ values: NSSet)

}
