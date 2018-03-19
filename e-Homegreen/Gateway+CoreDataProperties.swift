//
//  Gateway+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 3/11/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//
//

import Foundation
import CoreData

extension Gateway {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gateway> {
        return NSFetchRequest<Gateway>(entityName: "Gateway")
    }

    @NSManaged public var addressOne: NSNumber
    @NSManaged public var addressThree: NSNumber
    @NSManaged public var addressTwo: NSNumber
    @NSManaged public var autoReconnectDelay: NSNumber?
    @NSManaged public var autoReconnectDelayLast: NSDate?
    @NSManaged public var gatewayDescription: String
    @NSManaged public var gatewayId: String?
    @NSManaged public var gatewayType: NSNumber
    @NSManaged public var localIp: String
    @NSManaged public var localPort: NSNumber
    @NSManaged public var name: String
    @NSManaged public var remoteIp: String
    @NSManaged public var remoteIpInUse: String
    @NSManaged public var remotePort: NSNumber
    @NSManaged public var turnedOn: NSNumber
    @NSManaged public var cards: NSSet
    @NSManaged public var devices: NSSet
    @NSManaged public var events: NSSet
    @NSManaged public var flags: NSSet
    @NSManaged public var location: Location
    @NSManaged public var scenes: NSSet
    @NSManaged public var sequences: NSSet
    @NSManaged public var timers: NSSet

}

// MARK: Generated accessors for cards
extension Gateway {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}

// MARK: Generated accessors for devices
extension Gateway {

    @objc(addDevicesObject:)
    @NSManaged public func addToDevices(_ value: Device)

    @objc(removeDevicesObject:)
    @NSManaged public func removeFromDevices(_ value: Device)

    @objc(addDevices:)
    @NSManaged public func addToDevices(_ values: NSSet)

    @objc(removeDevices:)
    @NSManaged public func removeFromDevices(_ values: NSSet)

}

// MARK: Generated accessors for events
extension Gateway {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

// MARK: Generated accessors for flags
extension Gateway {

    @objc(addFlagsObject:)
    @NSManaged public func addToFlags(_ value: Flag)

    @objc(removeFlagsObject:)
    @NSManaged public func removeFromFlags(_ value: Flag)

    @objc(addFlags:)
    @NSManaged public func addToFlags(_ values: NSSet)

    @objc(removeFlags:)
    @NSManaged public func removeFromFlags(_ values: NSSet)

}

// MARK: Generated accessors for scenes
extension Gateway {

    @objc(addScenesObject:)
    @NSManaged public func addToScenes(_ value: Scene)

    @objc(removeScenesObject:)
    @NSManaged public func removeFromScenes(_ value: Scene)

    @objc(addScenes:)
    @NSManaged public func addToScenes(_ values: NSSet)

    @objc(removeScenes:)
    @NSManaged public func removeFromScenes(_ values: NSSet)

}

// MARK: Generated accessors for sequences
extension Gateway {

    @objc(addSequencesObject:)
    @NSManaged public func addToSequences(_ value: Sequence)

    @objc(removeSequencesObject:)
    @NSManaged public func removeFromSequences(_ value: Sequence)

    @objc(addSequences:)
    @NSManaged public func addToSequences(_ values: NSSet)

    @objc(removeSequences:)
    @NSManaged public func removeFromSequences(_ values: NSSet)

}

// MARK: Generated accessors for timers
extension Gateway {

    @objc(addTimersObject:)
    @NSManaged public func addToTimers(_ value: Timer)

    @objc(removeTimersObject:)
    @NSManaged public func removeFromTimers(_ value: Timer)

    @objc(addTimers:)
    @NSManaged public func addToTimers(_ values: NSSet)

    @objc(removeTimers:)
    @NSManaged public func removeFromTimers(_ values: NSSet)

}
