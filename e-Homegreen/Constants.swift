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
    "settingsCell"
}
struct UserDefaults {
    static let IsScaningDevice = "kDevicesFromGatewayRequested"
    static let IsScaningDeviceName = "kDevicesFromGatewayRequested"
    static let IsPreloaded = "kDevicesFromGatewayRequested"
    static let RefreshDelayHours = "hourRefresh"
    static let RefreshDelayMinutes = "minRefresh"
    struct Security {
        static let AlarmState = "EHGSecurityAlarmState"
        static let SecurityMode = "EHGSecuritySecurityMode"
        static let AddressOne = "EHGSecurityAddressOne"
        static let AddressTwo = "EHGSecurityAddressTwo"
        static let AddressThree = "EHGSecurityAddressThree"
        static let IsPanic = "EHGSecurityPanic"
    }
//    "firstBool"
//    "menu"
//    "firstItem"
}

struct NotificationKey {
    static let RefreshDevice = "kRefreshDeviceListNotification"
    static let DidFindDevice = "kPLCDidFindDevice"
    static let DidFindDeviceName = "kPLCdidFindNameForDevice"
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
    static let DarkGray = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor
    static let MediumGray = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor
    static let LightGrayColor = UIColor.lightGrayColor().CGColor
    static let VeryLightGrayColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1).CGColor
    static let DarkGrayColor = UIColor.darkGrayColor().CGColor
}