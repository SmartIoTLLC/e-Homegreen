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
}

struct NotificationKey {
    static let RefreshDevice = "kRefreshDeviceListNotification"
    static let DidFindDevice = "kPLCDidFindDevice"
    static let DidFindDeviceName = "kPLCdidFindNameForDevice"
    static let RefreshTimer = "kRefreshTimerListNotification"
    static let RefreshFlag = "kRefreshFlagListNotification"
    static let RefreshInterface = "refreshInterfaceParametar"
    static let RefreshClimate = "refreshClimateController"
    static let RefreshSecurity = "refreshSecurityNotificiation"
    static let RefreshFilter = "kRefreshLocalParametarsNotification"
}

struct SegueIdentifier {
    static let some = ""
}

struct Colors {
    
}