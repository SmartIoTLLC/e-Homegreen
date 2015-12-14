//
//  Constants.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/18/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

struct Common {
    static let screenWidth:CGFloat! = UIScreen.mainScreen().bounds.size.width
    static let screenHeight:CGFloat! = UIScreen.mainScreen().bounds.size.height
}

typealias Byte = UInt8

//struct MainScreenSize {
//    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
//    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
//    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
//    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
//}

enum InputError: ErrorType {
    case InputMissing
    case IdIncorrect
}
struct ReuseIdentifier {
//    "settingsCell"
}
struct UserDefaults {
    static let IsScaningDevice = "PLCDidFindDevice"
    static let IsScaningDeviceName = "PLCdidFindNameForDevice"
    static let IsPreloaded = "EHGisPreloaded"
    static let RefreshDelayHours = "hourRefresh"
    static let RefreshDelayMinutes = "minRefresh"
    struct Security {
        static let AlarmState = "EHGSecurityAlarmState"
        static let SecurityMode = "EHGSecuritySecurityMode"
        static let AddressOne = "EHGSecurityAddressOne"
        static let AddressTwo = "EHGSecurityAddressTwo"
        static let AddressThree = "EHGSecurityAddressThree"
        static let IsPanic = "EHGSecurityPanic"
//        "firstBool"
//        "menu"
//        "firstItem"
    }
}
class FilterParametars {
    let gatewayName:String
    let levelId:Int
    let levelName:String
    let zoneId:Int
    let zoneName:String
    let categoryId:Int
    let categoryName:String
    init(gatewayName:String,levelId:Int,levelName:String, zoneId:Int, zoneName:String, categoryId:Int, categoryName:String) {
        self.gatewayName = gatewayName
        self.levelId = levelId
        self.levelName = levelName
        self.zoneId = zoneId
        self.zoneName = zoneName
        self.categoryId = categoryId
        self.categoryName = categoryName
    }
}
struct NotificationKey {
    static let RefreshDevice = "kRefreshDeviceListNotification"
    static let DidFindDevice = "kPLCDidFindDevice"
    static let DidFindDeviceName = "kPLCdidFindNameForDevice"
    static let DidFindSensorParametar = "kPLCDidFindSensorParametar"
    static let DidRefreshDeviceInfo = "btnRefreshDevicesClicked"
    static let DidReceiveDataForRepeatSendingHandler = "repeatSendingHandlerNotification"
    
    static let RefreshTimer = "kRefreshTimerListNotification"
    static let RefreshFlag = "kRefreshFlagListNotification"
    static let RefreshInterface = "refreshInterfaceParametar"
    static let RefreshClimate = "refreshClimateController"
    static let RefreshSecurity = "refreshSecurityNotificiation"
    static let RefreshSequence = "refreshSequenceListNotification"
    static let RefreshEvent = "refreshEventListNotification"
    static let RefreshScene = "refreshSceneListNotification"
    static let RefreshSurveillance = "refreshSurveillanceListNotification"
    
    struct Surveillance {
        static let Refresh = "refreshSurveillanceListNotification"
        static let Run = "runTimer"
        static let Stop = "stopTimer"
    }
    
    struct Gateway {
        static let Refresh = "updateGatewayListNotification"
        static let DidReceiveData = "didReceiveMessageFromGateway"
        static let DidSendData = "didSendMessageToGateway"
    }
    
    static let RefreshFilter = "kRefreshLocalParametarsNotification"
    
    static let RefreshIBeacon = "refreshIBeaconList"
}

struct SegueIdentifier {
    static let some = ""
//    "menuSettings"
//    "connectionSettings"
//    "surveillanceSettings"
//    "securitySettings"
//    "iBeaconSettings"
}

struct Colors {
    static let DarkGray = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor    //   #262626
    static let MediumGray = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor
    static let LightGrayColor = UIColor.lightGrayColor().CGColor
    static let VeryLightGrayColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1).CGColor
    static let DarkGrayColor = UIColor.darkGrayColor().CGColor
    static let DirtyBlueColor = UIColor(red: 91/255, green: 182/255, blue: 229/225, alpha: 1.0).CGColor    //   #5bb7e5
    static let DirtyRedColor = UIColor(red: 251/255, green: 87/255, blue: 87/255, alpha: 1.0).CGColor    //   #fb5757
}
//extension for UIColor

//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//
//}

//UIApplication.sharedApplication().idleTimerDisabled = true