//
//  Location+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/13/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var filterOnLocation: NSNumber?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var locationDescription: String?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var orderId: NSNumber?
    @NSManaged public var radius: NSNumber?
    @NSManaged public var timerId: String?
    @NSManaged public var categories: NSSet?
    @NSManaged public var gateways: NSSet?
    @NSManaged public var security: NSSet?
    @NSManaged public var ssids: NSSet?
    @NSManaged public var surveillances: NSSet?
    @NSManaged public var user: User?
    @NSManaged public var zones: NSSet?
    @NSManaged public var remotes: NSSet?

}

// MARK: Generated accessors for categories
extension Location {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Category)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Category)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}

// MARK: Generated accessors for gateways
extension Location {

    @objc(addGatewaysObject:)
    @NSManaged public func addToGateways(_ value: Gateway)

    @objc(removeGatewaysObject:)
    @NSManaged public func removeFromGateways(_ value: Gateway)

    @objc(addGateways:)
    @NSManaged public func addToGateways(_ values: NSSet)

    @objc(removeGateways:)
    @NSManaged public func removeFromGateways(_ values: NSSet)

}

// MARK: Generated accessors for security
extension Location {

    @objc(addSecurityObject:)
    @NSManaged public func addToSecurity(_ value: Security)

    @objc(removeSecurityObject:)
    @NSManaged public func removeFromSecurity(_ value: Security)

    @objc(addSecurity:)
    @NSManaged public func addToSecurity(_ values: NSSet)

    @objc(removeSecurity:)
    @NSManaged public func removeFromSecurity(_ values: NSSet)

}

// MARK: Generated accessors for ssids
extension Location {

    @objc(addSsidsObject:)
    @NSManaged public func addToSsids(_ value: SSID)

    @objc(removeSsidsObject:)
    @NSManaged public func removeFromSsids(_ value: SSID)

    @objc(addSsids:)
    @NSManaged public func addToSsids(_ values: NSSet)

    @objc(removeSsids:)
    @NSManaged public func removeFromSsids(_ values: NSSet)

}

// MARK: Generated accessors for surveillances
extension Location {

    @objc(addSurveillancesObject:)
    @NSManaged public func addToSurveillances(_ value: Surveillance)

    @objc(removeSurveillancesObject:)
    @NSManaged public func removeFromSurveillances(_ value: Surveillance)

    @objc(addSurveillances:)
    @NSManaged public func addToSurveillances(_ values: NSSet)

    @objc(removeSurveillances:)
    @NSManaged public func removeFromSurveillances(_ values: NSSet)

}

// MARK: Generated accessors for zones
extension Location {

    @objc(addZonesObject:)
    @NSManaged public func addToZones(_ value: Zone)

    @objc(removeZonesObject:)
    @NSManaged public func removeFromZones(_ value: Zone)

    @objc(addZones:)
    @NSManaged public func addToZones(_ values: NSSet)

    @objc(removeZones:)
    @NSManaged public func removeFromZones(_ values: NSSet)

}

// MARK: Generated accessors for remotes
extension Location {

    @objc(addRemotesObject:)
    @NSManaged public func addToRemotes(_ value: Remote)

    @objc(removeRemotesObject:)
    @NSManaged public func removeFromRemotes(_ value: Remote)

    @objc(addRemotes:)
    @NSManaged public func addToRemotes(_ values: NSSet)

    @objc(removeRemotes:)
    @NSManaged public func removeFromRemotes(_ values: NSSet)

}
