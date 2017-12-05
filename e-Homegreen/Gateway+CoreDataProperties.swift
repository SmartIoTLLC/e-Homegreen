//
//  Gateway+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/13/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData
//import e_Homegreen

extension Gateway {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gateway> {
        return NSFetchRequest<Gateway>(entityName: "Gateway")
    }
    
    @NSManaged var addressOne: NSNumber
    @NSManaged var addressThree: NSNumber
    @NSManaged var addressTwo: NSNumber
    @NSManaged var autoReconnectDelay: NSNumber?
    @NSManaged var autoReconnectDelayLast: NSDate?
    @NSManaged var gatewayDescription: String
    @NSManaged var gatewayId: String?
    @NSManaged var gatewayType: NSNumber
    @NSManaged var localIp: String
    @NSManaged var localPort: NSNumber
    @NSManaged var name: String
    @NSManaged var remoteIp: String
    @NSManaged var remoteIpInUse: String
    @NSManaged var remotePort: NSNumber
    @NSManaged var turnedOn: NSNumber
    @NSManaged var cards: NSSet
    @NSManaged var devices: NSSet
    @NSManaged var events: NSSet
    @NSManaged var flags: NSSet
    @NSManaged var scenes: NSSet
    @NSManaged var sequences: NSSet
    @NSManaged var timers: NSSet
    @NSManaged var location: Location


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
