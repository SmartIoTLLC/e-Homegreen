//
//  Device+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/26/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Device {

//    @NSManaged var address: NSNumber?
//    @NSManaged var amp: String?
//    @NSManaged var categoryId: NSNumber?
//    @NSManaged var categoryName: String?
//    @NSManaged var channel: NSNumber?
//    @NSManaged var controlType: String?
//    @NSManaged var coolTemperature: NSNumber?
//    @NSManaged var current: NSNumber?
//    @NSManaged var currentValue: NSNumber?
//    @NSManaged var curtainControlMode: NSNumber?
//    @NSManaged var curtainGroupID: NSNumber?
//    @NSManaged var delay: NSNumber?
//    @NSManaged var heatTemperature: NSNumber?
//    @NSManaged var humidity: NSNumber?
//    @NSManaged var isCurtainModeAllowed: NSNumber?
//    @NSManaged var isDimmerModeAllowed: NSNumber?
//    @NSManaged var isEnabled: NSNumber?
//    @NSManaged var isVisible: NSNumber?
//    @NSManaged var mode: String?
//    @NSManaged var modeState: String?
//    @NSManaged var name: String?
//    @NSManaged var numberOfDevices: NSNumber?
//    @NSManaged var overrideControl1: NSNumber?
//    @NSManaged var overrideControl2: NSNumber?
//    @NSManaged var overrideControl3: NSNumber?
//    @NSManaged var parentZoneId: NSNumber?
//    @NSManaged var roomTemperature: NSNumber?
//    @NSManaged var runningTime: String?
//    @NSManaged var runtime: NSNumber?
//    @NSManaged var skipState: NSNumber?
//    @NSManaged var speed: String?
//    @NSManaged var speedState: String?
//    @NSManaged var stateUpdatedAt: NSDate?
//    @NSManaged var temperature: NSNumber?
//    @NSManaged var type: String?
//    @NSManaged var voltage: NSNumber?
//    @NSManaged var zoneId: NSNumber?
//    @NSManaged var gateway: Gateway?
//    @NSManaged var images: NSSet?
    @NSManaged var deviceImages: NSMutableSet?
    @NSManaged var address: NSNumber
    @NSManaged var amp: String
    @NSManaged var categoryId: NSNumber
    @NSManaged var categoryName: String
    @NSManaged var channel: NSNumber
    @NSManaged var coolTemperature: NSNumber
    @NSManaged var current: NSNumber
    @NSManaged var currentValue: NSNumber
    @NSManaged var delay: NSNumber
    @NSManaged var heatTemperature: NSNumber
    @NSManaged var humidity: NSNumber
    @NSManaged var isEnabled: NSNumber
    @NSManaged var isDimmerModeAllowed: NSNumber
    @NSManaged var isCurtainModeAllowed: NSNumber
    @NSManaged var mode: String
    @NSManaged var modeState: String
    @NSManaged var name: String
    @NSManaged var numberOfDevices: NSNumber
    @NSManaged var overrideControl1: NSNumber
    @NSManaged var overrideControl2: NSNumber
    @NSManaged var overrideControl3: NSNumber
    @NSManaged var parentZoneId: NSNumber
    @NSManaged var roomTemperature: NSNumber
    @NSManaged var runningTime: String
    @NSManaged var runtime: NSNumber
    @NSManaged var skipState: NSNumber
    @NSManaged var speed: String
    @NSManaged var speedState: String
    @NSManaged var stateUpdatedAt: NSDate?
    @NSManaged var temperature: NSNumber
    @NSManaged var type: String
    @NSManaged var controlType: String
    @NSManaged var voltage: NSNumber
    @NSManaged var zoneId: NSNumber
    @NSManaged var isVisible: NSNumber
    @NSManaged var gateway: Gateway
    @NSManaged var curtainGroupID: NSNumber
    @NSManaged var curtainControlMode: NSNumber
}
////
////  Device+CoreDataProperties.swift
////  e-Homegreen
////
////  Created by Teodor Stevic on 2/9/16.
////  Copyright © 2016 Teodor Stevic. All rights reserved.
////
////  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
////  to delete and recreate this implementation file for your updated model.
////
//
//import Foundation
//import CoreData
//
//extension Device {
//    
//    //    @NSManaged var address: NSNumber?
//    //    @NSManaged var amp: String?
//    //    @NSManaged var categoryId: NSNumber?
//    //    @NSManaged var categoryName: String?
//    //    @NSManaged var channel: NSNumber?
//    //    @NSManaged var controlType: String?
//    //    @NSManaged var coolTemperature: NSNumber?
//    //    @NSManaged var current: NSNumber?
//    //    @NSManaged var currentValue: NSNumber?
//    //    @NSManaged var curtainControlMode: NSNumber?
//    //    @NSManaged var curtainGroupID: NSNumber?
//    //    @NSManaged var delay: NSNumber?
//    //    @NSManaged var heatTemperature: NSNumber?
//    //    @NSManaged var humidity: NSNumber?
//    //    @NSManaged var isCurtainModeAllowed: NSNumber?
//    //    @NSManaged var isDimmerModeAllowed: NSNumber?
//    //    @NSManaged var isEnabled: NSNumber?
//    //    @NSManaged var isVisible: NSNumber?
//    //    @NSManaged var mode: String?
//    //    @NSManaged var modeState: String?
//    //    @NSManaged var name: String?
//    //    @NSManaged var numberOfDevices: NSNumber?
//    //    @NSManaged var overrideControl1: NSNumber?
//    //    @NSManaged var overrideControl2: NSNumber?
//    //    @NSManaged var overrideControl3: NSNumber?
//    //    @NSManaged var parentZoneId: NSNumber?
//    //    @NSManaged var roomTemperature: NSNumber?
//    //    @NSManaged var runningTime: String?
//    //    @NSManaged var runtime: NSNumber?
//    //    @NSManaged var skipState: NSNumber?
//    //    @NSManaged var speed: String?
////    @NSManaged var speedState: String?
////    @NSManaged var stateUpdatedAt: NSDate?
////    @NSManaged var temperature: NSNumber?
////    @NSManaged var type: String?
////    @NSManaged var voltage: NSNumber?
////    @NSManaged var zoneId: NSNumber?
////    @NSManaged var gateway: Gateway?
//    @NSManaged var images: NSManagedObject?
//    @NSManaged var address: NSNumber
//    @NSManaged var amp: String
//    @NSManaged var categoryId: NSNumber
//    @NSManaged var categoryName: String
//    @NSManaged var channel: NSNumber
//    @NSManaged var coolTemperature: NSNumber
//    @NSManaged var current: NSNumber
//    @NSManaged var currentValue: NSNumber
//    @NSManaged var delay: NSNumber
//    @NSManaged var heatTemperature: NSNumber
//    @NSManaged var humidity: NSNumber
//    @NSManaged var isEnabled: NSNumber
//    @NSManaged var isDimmerModeAllowed: NSNumber
//    @NSManaged var isCurtainModeAllowed: NSNumber
//    @NSManaged var mode: String
//    @NSManaged var modeState: String
//    @NSManaged var name: String
//    @NSManaged var numberOfDevices: NSNumber
//    @NSManaged var overrideControl1: NSNumber
//    @NSManaged var overrideControl2: NSNumber
//    @NSManaged var overrideControl3: NSNumber
//    @NSManaged var parentZoneId: NSNumber
//    @NSManaged var roomTemperature: NSNumber
//    @NSManaged var runningTime: String
//    @NSManaged var runtime: NSNumber
//    @NSManaged var skipState: NSNumber
//    @NSManaged var speed: String
//    @NSManaged var speedState: String
//    @NSManaged var stateUpdatedAt: NSDate?
//    @NSManaged var temperature: NSNumber
//    @NSManaged var type: String
//    @NSManaged var controlType: String
//    @NSManaged var voltage: NSNumber
//    @NSManaged var zoneId: NSNumber
//    @NSManaged var isVisible: NSNumber
//    @NSManaged var gateway: Gateway
//    @NSManaged var curtainGroupID: NSNumber
//    @NSManaged var curtainControlMode: NSNumber
//    
//}
////
////  Device.swift
////  e-Homegreen
////
////  Created by Teodor Stevic on 9/10/15.
////  Copyright (c) 2015 Teodor Stevic. All rights reserved.
////
//
//import Foundation
//import CoreData
//enum EmployeeStatus: Int {
//    case ReadyForHire, Hired, Retired, Resigned, Fired, Deceased
//}
//class Device: NSManagedObject {
//    
//    
//    var interfaceParametar:[UInt8] = []
//    var warningState:Int = 0
//    var opening:Bool = true
//    var on:Bool = false
//    var info:Bool = false
//    
//    var cellTitle:String = ""
//    
//    var status: EmployeeStatus {
//        get {
//            return EmployeeStatus(rawValue: Int(self.address))!
//        }
//        set {
//            self.address = NSNumber(integer:newValue.rawValue)
//        }
//    }
//}
