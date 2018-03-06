//
//  Device+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 3/5/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//
//

import Foundation
import CoreData
import e_Homegreen

extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }
    @NSManaged public var usageCounter: NSNumber?
    @NSManaged public var isFavorite: NSNumber?

    @NSManaged var deviceImages: NSSet?
    @NSManaged var address: NSNumber
    @NSManaged var allowEnergySaving: NSNumber
    @NSManaged var amp: String
    @NSManaged var categoryId: NSNumber
    @NSManaged var categoryName: String
    @NSManaged var channel: NSNumber
    @NSManaged var coolTemperature: NSNumber
    @NSManaged var current: NSNumber
    @NSManaged var deviceIdForScanningScreen: NSNumber  // This parameter is used for sorting devices in ScanDeviceViewController. Problem is with SaltoAccess bcause Channels could change. In other devices channels are scanned and written while scanning (adding) device. Salto Access channels chang depending which one is selected (from 1 to 16). This parameter is now channel, and has values that are collected from PLC (i.e. channel parameter for all devices except saltoAccess), and by this parameter we sort Devices in ScannDeviceViewController. In saltoAccess channels are later changed but this parameter stays as it was when scanned (1 to 4).
    
    // Current value is the current value of the device. In app it always ranges from - to 255. When sending it and receveing it from PLC range can be 0-100 or 0-255, depending on device type.100
    // If device is dimmer then value is in range from 0-100
    // If device is something else, then device has only two states and value can be 0 or 255
    @NSManaged var currentValue: NSNumber
    // OldValue must be stored because of Khalifa's request. When in Device menu, light can be changed with slider and ON/OFF. If value is set to be X, and OFF is pressed, and again ON, value must return to the value that was before OFF is pressed. That is why we must store old value.
    @NSManaged var oldValue: NSNumber?
    @NSManaged var delay: NSNumber              // Number of seconds after which device will be turned on
    @NSManaged var heatTemperature: NSNumber
    @NSManaged var humidity: NSNumber
    @NSManaged var isEnabled: NSNumber
    @NSManaged var isDimmerModeAllowed: NSNumber
    @NSManaged var isCurtainModeAllowed: NSNumber   // If ControlType is 'Relay' and isCurtainModeAllowed value is 'true' -> ControlType must be set to 'Curtain'
    @NSManaged var mode: String                     // Mode for clima. Heat/Cold/Auto
    @NSManaged var modeState: String                // Mode for clima. Heat/Cold/Auto
    @NSManaged var name: String
    @NSManaged var numberOfDevices: NSNumber
    @NSManaged var overrideControl1: NSNumber
    @NSManaged var overrideControl2: NSNumber
    @NSManaged var overrideControl3: NSNumber
    @NSManaged var parentZoneId: NSNumber
    @NSManaged var roomTemperature: NSNumber
    @NSManaged var runningTime: String              // Number of seconds for which device should be ON
    @NSManaged var runtime: NSNumber
    @NSManaged var skipState: NSNumber
    @NSManaged var speed: String
    @NSManaged var speedState: String
    @NSManaged var stateUpdatedAt: Date?
    @NSManaged var temperature: NSNumber
    // Original type of the device
    // This is important because Dimmer can behave as Relay, but dimmer can't change Cotrol mode. Relay (original Relay) can change Control mode (NO or NC)
    @NSManaged var type: String
    // Local type of the device
    // This is the type that user can change. If he wants to change control type (e.g. change Dimmer to be Relay) then this field changes.
    @NSManaged var controlType: String
    @NSManaged var voltage: NSNumber
    @NSManaged var zoneId: NSNumber
    @NSManaged var isVisible: NSNumber
    @NSManaged var gateway: Gateway
    @NSManaged var curtainGroupID: NSNumber
    @NSManaged var curtainControlMode: NSNumber
    @NSManaged var digitalInputMode: NSNumber?
    @NSManaged var pcCommands: NSSet?
    @NSManaged var mac: Data?
    @NSManaged var humidityVisible: NSNumber?
    @NSManaged var temperatureVisible: NSNumber?
    @NSManaged var coolModeVisible: NSNumber?
    @NSManaged var heatModeVisible: NSNumber?
    @NSManaged var fanModeVisible: NSNumber?
    @NSManaged var autoModeVisible: NSNumber?
    @NSManaged var lowSpeedVisible: NSNumber?
    @NSManaged var medSpeedVisible: NSNumber?
    @NSManaged var highSpeedVisible: NSNumber?
    @NSManaged var autoSpeedVisible: NSNumber?
    @NSManaged var notificationType: NSNumber?
    @NSManaged var notificationPosition: NSNumber?
    @NSManaged var notificationDelay: NSNumber?
    @NSManaged var notificationDisplayTime: NSNumber?

}

// MARK: Generated accessors for deviceImages
extension Device {

    @objc(addDeviceImagesObject:)
    @NSManaged public func addToDeviceImages(_ value: DeviceImage)

    @objc(removeDeviceImagesObject:)
    @NSManaged public func removeFromDeviceImages(_ value: DeviceImage)

    @objc(addDeviceImages:)
    @NSManaged public func addToDeviceImages(_ values: NSSet)

    @objc(removeDeviceImages:)
    @NSManaged public func removeFromDeviceImages(_ values: NSSet)

}

// MARK: Generated accessors for pcCommands
extension Device {

    @objc(addPcCommandsObject:)
    @NSManaged public func addToPcCommands(_ value: PCCommand)

    @objc(removePcCommandsObject:)
    @NSManaged public func removeFromPcCommands(_ value: PCCommand)

    @objc(addPcCommands:)
    @NSManaged public func addToPcCommands(_ values: NSSet)

    @objc(removePcCommands:)
    @NSManaged public func removeFromPcCommands(_ values: NSSet)

}
