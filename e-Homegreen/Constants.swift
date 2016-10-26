//
//  Constants.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/18/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

struct Common {
    static let screenWidth:CGFloat! = UIScreen.main.bounds.size.width
    static let screenHeight:CGFloat! = UIScreen.main.bounds.size.height
}

typealias Byte = UInt8

enum InputError: Error {
    case notConvertibleToInt
    case fromBiggerThanTo
    case notPositiveNumbers
    case inputMissing
    case idIncorrect
    case numbersAreNegative
    case nothingToSearchFor
    case outOfRange
    case specifyRange
}
extension InputError: CustomStringConvertible {
    var description: String {
        switch self {
        case .notConvertibleToInt: return "Not convertible to number."
        case .fromBiggerThanTo: return "From is bigger then to."
        case .notPositiveNumbers: return "Numbers must be positive."
        case .inputMissing: return "Missing input."
        case .idIncorrect: return "Id is incorrect."
        case .numbersAreNegative: return "Numbers cab't be negative."
        case .nothingToSearchFor: return "There is nothing to search for."
        case .outOfRange: return "Search range is out of range."
        case .specifyRange: return "You need to specify range."
        }
    }
}

//00 Closed
//FE Closing
//FF Opening
//64 Opened
//00 - 64 je procenat
//EF Stoped - Tada ne pisemo nista

struct CurtainModuleState {
    static func returnState(_ byte:Int) -> String {
        var state = ""
        switch byte {
        case 0x00:
            state = "Closed"
        case 0xFE:
            state = "Closing"
        case 0xFF:
            state = "Opening"
        case 0x64:
            state = "Opened"
        default:
            state = "\(byte)%"
        }
        return state
    }
}

//  0x00 Waiting = 0
//  0x01 Started = 1
//  0xF0 Elapsed = 240
//  0xEE Suspend = 238
struct CurtainControlMode {
    static let NC = 0x01
    static let NO = 0x02
    static let NCAndReset = 0x03
    static let NOAndReset = 0x04
}
struct SecurityControlMode {
    static let Away = "Away"
    static let Day = "Day"
    static let Night = "Night"
    static let Vacation = "Vacation"
    static let Disarm = "Disarm"
    static let Panic = "Panic"
}
struct AlarmState {
    static let Idle = "Idle"
    static let Trouble = "Trouble"
    static let Alarm = "Alarm"
    static let Alert = "Alert"
}

struct Messages {
    struct Security{
        static let NeedToDisarmFirst = "Attention! You need to disarm the security system before you can select the curent security mode."
    }
    
}

//MARK:- Multisensor
struct DigitalInput {
    // This is used to populate
    enum DigitalInputNames: String {
        case Generic
        case NormalyOpen
        case NormalyClosed
        case MotionSensor
        case ButtonNormallyOpen
        case ButtonNormallyClosed
        
    }
    struct ControlMode {
        static func returnControlModeForId(_ id:Int) -> String {
            switch id {
            case 2:
                return "Normally Open"
            case 4:
                return "Normally Closed"
            default:
                return "Normally Open"
            }
        }
    }
    static let modeInfo: [Int:String] = [
        0x00:DigitalInput.Generic.description(),
        0x01:DigitalInput.NormallyOpen.description(),
        0x02:DigitalInput.NormallyClosed.description(),
        0x03:DigitalInput.ButtonNormallyOpen.description(),
        0x83:DigitalInput.ButtonNormallyClosed.description(),
        0x04:DigitalInput.MotionSensor.description(),
        0x84:DigitalInput.MotionSensor.description()]
    static let modeInfoReverse: [String:Int] = [DigitalInput.Generic.description():0x00,
        DigitalInput.NormallyOpen.description():0x01,
        DigitalInput.NormallyClosed.description():0x02,
        DigitalInput.ButtonNormallyOpen.description():0x03,
        DigitalInput.ButtonNormallyClosed.description():0x83,
        DigitalInput.MotionSensor.description():0x04]
//        DigitalInput.MotionSensor.description():0x84]
    
    struct Generic {
        static let Open = 0x00
        static let Close = 0x01
        static func description()->String {return "Generic"}
        static func description(_ state:Int) -> String {
            return state == 0x00 ? "Open" : "Close"
        }
    }
    struct NormallyOpen {
        static let Ready = 0x00
        static let Triggerd = 0x01
        static func description()->String {return "Normally Open"}
        static func description(_ state:Int) -> String {
            return state == 0x00 ? "Ready" : "Triggerd"
        }
    }
    struct NormallyClosed {
        static let Triggered = 0x00
        static let Ready = 0x01
        static func description()->String {return "Normally Closed"}
        static func description(_ state:Int) -> String {
            return state == 0x00 ? "Triggered" : "Ready"
        }
    }
    struct MotionSensor {
        static let Idle = 0x00
        static let Motion = 0x01
        static func description()->String {return "Motion Sensor"}
        static func description(_ state:Int) -> String {
            return state == 0x00 ? "Idle" : "Motion"
        }
    }
    struct ButtonNormallyOpen {
        static let Press = 0x00
        static let Release = 0x01
        static func description()->String {return "Button(NormallyOpen)"}
        static func description(_ state:Int) -> String {
            return state == 0x00 ? "Press" : "Release"
        }
    }
    struct ButtonNormallyClosed {
        static let Release = 0x00
        static let Press = 0x01
        static func description()->String {return "Button(NormallyClosed)"}
        static func description(_ state:Int) -> String {
            return state == 0x00 ? "Release" : "Press"
        }
    }
    struct DigitalInputMode {
        static let NormallyOpen = 0x00
        static let NormallyClosed = 0x01
        static let Generic = 0x02
        static let ButtonNormallyOpen = 0x03
        static let ButtonNormallyClosed = 0x83
        static let MotionSensor = 0x04
//        static let MultiSensorNormallyClosed = 0x84
    }
}


struct UserDefaults {
    static let IsScaningDevice = "PLCDidFindDevice"
    static let IsScaningDeviceName = "PLCdidFindNameForDevice"
    static let IsScaningSensorParametars = "PLCDidFindSensorParametar"
    static let IsScaningTimerNames = "PLCDidFindTimerName"
    static let IsScaningTimerParameters = "PLCDidFindTimerParameters"
    static let IsScaningSceneNameAndParameters = "PLCDidFindSceneParameters"
    static let IsScaningSequencesNameAndParameters = "PLCDidFindSequenceParameters"
    static let IsScaningEventsNameAndParameters = "PLCDidFindSequenceParameters"
    static let IsScaningFlagNames = "PLCDidFindFlagName"
    static let IsScaningFlagParameters = "PLCDidFindFlagParameters"
    static let IsScaningCardNames = "PLCDidFindCardName"
    static let IsScaningCardParameters = "PLCDidFindCardParameters"
    static let IsPreloaded = "EHGisPreloaded"
    static let RefreshDelayHours = "hourRefresh"
    static let RefreshDelayMinutes = "minRefresh"
    static let OpenLastScreen = "EHGIsLastScreenOpened"
    static let IsScaningForZones = "EHGIsScanningForZones"
    static let IsScaningForCategories = "EHGIsScanningForCategories"
    static let GalleryContentOffset = "GalleryContentOffset"
    struct Security {
        static let AlarmState = "EHGSecurityAlarmState"
        static let SecurityMode = "EHGSecuritySecurityMode"
        static let AddressOne = "EHGSecurityAddressOne"
        static let AddressTwo = "EHGSecurityAddressTwo"
        static let AddressThree = "EHGSecurityAddressThree"
        static let IsPanic = "EHGSecurityPanic"
//        "menu"
//        "firstItem"
    }
}
struct CoreDataPreload {
    static let galleryList:[String] = ["04 Climate Control - Air Freshener - 00",
        "04 Climate Control - Air Freshener - 01",
        "04 Climate Control - HVAC - 00",
        "04 Climate Control - HVAC - 01",
        "11 Lighting - Bulb - 00",
        "11 Lighting - Bulb - 01",
        "11 Lighting - Bulb - 02",
        "11 Lighting - Bulb - 03",
        "11 Lighting - Bulb - 04",
        "11 Lighting - Bulb - 05",
        "11 Lighting - Bulb - 06",
        "11 Lighting - Bulb - 07",
        "11 Lighting - Bulb - 08",
        "11 Lighting - Bulb - 09",
        "11 Lighting - Bulb - 10",
        "11 Lighting - Flood Light - 00",
        "11 Lighting - Flood Light - 01",
        "12 Appliance - Bell - 00",
        "12 Appliance - Bell - 01",
        "12 Appliance - Big Bell - 00.png",
        "12 Appliance - Big Bell - 01",
        "12 Appliance - Fountain - 00",
        "12 Appliance - Fountain - 01",
        "12 Appliance - Hood - 00",
        "12 Appliance - Hood - 01",
        "12 Appliance - Power - 00",
        "12 Appliance - Power - 01",
        "12 Appliance - Power - 02",
        "12 Appliance - Socket - 00",
        "12 Appliance - Socket - 01",
        "12 Appliance - Sprinkler - 00",
        "12 Appliance - Sprinkler - 01",
        "12 Appliance - Switch - 00",
        "12 Appliance - Switch - 01",
        "12 Appliance - Washing Machine - 00",
        "12 Appliance - Washing Machine - 01",
        "12 Appliance - Water Heater - 00",
        "12 Appliance - Water Heater - 01",
        "13 Curtain - Curtain - 00",
        "13 Curtain - Curtain - 01",
        "13 Curtain - Curtain - 02",
        "13 Curtain - Curtain - 03",
        "13 Curtain - Curtain - 04",
        "14 Security - Camcorder - 00",
        "14 Security - Camera - 00",
        "14 Security - Door - 00",
        "14 Security - Door - 01",
        "14 Security - Gate - 00",
        "14 Security - Gate - 01",
        "14 Security - Lock - 00",
        "14 Security - Lock - 01",
        "14 Security - Motion Sensor - 00",
        "14 Security - Motion Sensor - 01",
        "14 Security - Motion Sensor - 02",
        "14 Security - Reader - 00",
        "14 Security - Reader - 01",
        "14 Security - Reader - 02",
        "14 Security - Smoke Heat - 00",
        "14 Security - Smoke Heat - 01",
        "14 Security - Surveillance - 00",
        "14 Security - Window - 00",
        "14 Security - Window - 01",
        "15 Timer - CLock - 00",
        "15 Timer - CLock - 01",
        "16 Flag - Flag - 00",
        "16 Flag - Flag - 01",
        "17 Event - Alarm - 00",
        "17 Event - Alarm - 01",
        "17 Event - Away - 00",
        "17 Event - Away - 01",
        "17 Event - Baby - 00",
        "17 Event - Baby - 01",
        "17 Event - Baby Sleep - 00",
        "17 Event - Baby Sleep - 01",
        "17 Event - Bye - 00",
        "17 Event - Bye - 01",
        "17 Event - Chill - 00",
        "17 Event - Chill - 01",
        "17 Event - Daytime - 00",
        "17 Event - Daytime - 01",
        "17 Event - Dining - 00",
        "17 Event - Dining - 01",
        "17 Event - Earth - 00",
        "17 Event - Earth - 01",
        "17 Event - Follow Me - 00",
        "17 Event - Follow Me - 01",
        "17 Event - Guest - 00",
        "17 Event - Guest - 01",
        "17 Event - Home - 00",
        "17 Event - Home - 01",
        "17 Event - Late Night - 00",
        "17 Event - Late Night - 01",
        "17 Event - Movie - 00",
        "17 Event - Movie - 01",
        "17 Event - Night - 00",
        "17 Event - Night - 01",
        "17 Event - Ramp Down - 00",
        "17 Event - Ramp Down - 01",
        "17 Event - Ramp Up - 00",
        "17 Event - Ramp Up - 01",
        "17 Event - Relax - 00",
        "17 Event - Relax - 01",
        "17 Event - Up Down - 00",
        "17 Event - Up Down - 01",
        "17 Event - Vacation - 00",
        "17 Event - Vacation - 01",
        "18 Media - 5.1 Speakers - 00",
        "18 Media - CD - 00",
        "18 Media - Ceiling Speaker - 00",
        "18 Media - Ceiling Speaker - 01",
        "18 Media - Chat - 00",
        "18 Media - Fax - 00",
        "18 Media - Game Pad - 00",
        "18 Media - Handset - 00.png",
        "18 Media - Hi Fi - 00",
        "18 Media - LCD Screen - 00",
        "18 Media - LCD TV - 00",
        "18 Media - LCD TV - 01",
        "18 Media - Mail - 00",
        "18 Media - Microphone - 00",
        "18 Media - Mobile - 00.png",
        "18 Media - Music Note - 00",
        "18 Media - PC - 00",
        "18 Media - Photo - 00.png",
        "18 Media - Projector - 00",
        "18 Media - Projector - 01",
        "18 Media - Projector Lift - 00",
        "18 Media - Projector Lift - 01",
        "18 Media - Projector Screen - 00",
        "18 Media - Projector Screen - 01",
        "18 Media - Radio - 00",
        "18 Media - Remote - 00",
        "18 Media - SMS - 00",
        "18 Media - Setup Box - 00",
        "18 Media - Speaker - 00",
        "18 Media - Speaker - 01",
        "18 Media - Telephone - 00",
        "18 Media - iPod - 00",
        "19 Blind - Blind - 00",
        "19 Blind - Blind - 01",
        "19 Blind - Blind - 02",
        "19 Blind - Blind - 03",
        "19 Blind - Blind - 04",
        "19 Blind - Blind - 05",
        "19 Blind - Blind - 06",
        "19 Blind - Blind - Down",
        "19 Blind - Blind - Stop",
        "19 Blind - Blind - Up",
        "19 Blind - Venitian Blind - 00",
        "19 Blind - Venitian Blind - 01",
        "Others - Admin - 00",
        "Others - Arab - 00",
        "Others - Boy - 00",
        "Others - Employee - 00",
        "Others - Info - 00",
        "Others - Pi Chart - 00",
        "Others - Question - 00",
        "Others - Receptionest - 00",
        "Others - Refresh - 00",
        "Others - Setting - 00",
        "Others - Windows - 00",
        "Others - Wireless - 00.png",
        "Others - Young Arab - 00",
        "Others - e-Home - 00",
        "Others - e-Homegreen - 00",
        "Scene - All High - 00",
        "Scene - All High - 01",
        "Scene - All Low - 00",
        "Scene - All Low - 01",
        "Scene - All Medium - 00",
        "Scene - All Medium - 01",
        "Scene - All Off - 00",
        "Scene - All Off - 01",
        "Scene - All On - 00",
        "Scene - All On - 01",
        "Scene - Movie - 00",
        "Scene - Movie - 01"]
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
struct CellSize {
    static func calculateCellSize(_ size:inout CGSize, screenWidth:CGFloat) {
        var i:CGFloat = 2
        while i >= 2 {
            if (screenWidth / i) >= 120 && (screenWidth / i) <= 160 {
                break
            }
            i += 1
        }
        let const = (2/i + (i*5-5)/i)
        let cellWidth = Int(screenWidth/i - const)
        size = CGSize(width: cellWidth, height: Int(cellWidth*10/7))
    }
    
    static func calculateSurvCellSize(_ size:inout CGSize, screenWidth:CGFloat) {
        var i:CGFloat = 2
        while i >= 2 {
            if (screenWidth / i) >= 120 && (screenWidth / i) <= 220 {
                break
            }
            i += 1
        }
        let const = (2/i + (i*5-5)/i)
        let cellWidth = Int(screenWidth/i - const)
        size = CGSize(width: cellWidth, height: cellWidth)
    }
}
//MARK: Filter constants
struct FilterKey {
    static let location = "kLocation"
    static let levelId = "kLevelId"
    static let zoneId = "kZoneId"
    static let categoryId = "kCategoryId"
    static let levelName = "klevelName"
    static let zoneName = "kZoneName"
    static let categoryName = "kCategoryName"
}
enum FilterEnumeration:String {
    case Device = "Device" //prepravio
    case Scenes = "Scenes" //prepravio
    case Events = "Events" //prepravio
    case Sequences = "Sequences" //prepravio
    case Timers = "Timers" //prepravio
    case Flags = "Flags" //prepravio
    case Chat = "Chat"
    case Security = "Security" // Thise should be moved to devices but there was a problem scanning security device
    case Surveillance = "Surveillance"
    case Energy = "Energy" //prepravio
    case PCControl = "PCControl"
    case Users = "Users"
    case Database = "Database"
    static let allFilters = [Device, Scenes, Events, Sequences, Timers, Flags, Chat, Security, Surveillance, Energy, PCControl, Users, Database]

}
//MARK: Notification constants
struct NotificationKey {
    static let DidFindDevice = "kPLCDidFindDevice"
    static let DidFindDeviceName = "kPLCdidFindNameForDevice"
    static let DidFindSensorParametar = "kPLCDidFindSensorParametar"
    static let DidRefreshDeviceInfo = "btnRefreshDevicesClicked"
    static let DidReceiveDataForRepeatSendingHandler = "repeatSendingHandlerNotification"
    static let DidReceiveCategoryFromGateway = "kPLCDidFoundCategory"
    static let DidReceiveZoneFromGateway = "kPLCDidFoundCategory"
    static let DidReceiveTimerFromGateway = "kPLCDidFoundTimer"
    static let DidReceiveTimerParameterFromGateway = "kPLCDidFoundTimerParameter"
    static let DidReceiveSceneFromGateway = "kPLCDidFoundScene"
    static let DidReceiveSequenceFromGateway = "kPLCDidFoundSequence"
    static let DidReceiveEventFromGateway = "kPLCDidFoundEvent"
    static let DidReceiveFlagFromGateway = "kPLCDidFoundFlag"
    static let DidReceiveFlagParameterFromGateway = "kPLCDidFoundFlagParameter"
    static let DidReceiveCardFromGateway = "kPLCDidFoundCard"
    static let DidReceiveCardParameterFromGateway = "kPLCDidFoundCardParameter"
    
    static let RefreshDevice = "kRefreshDeviceListNotification"
    static let RefreshScanningDevice = "kRefreshScanningDeviceListNotification"
    static let RefreshTimer = "kRefreshTimerListNotification"
    static let RefreshFlag = "kRefreshFlagListNotification"
    static let RefreshInterface = "refreshInterfaceParametar"
    static let RefreshClimate = "refreshClimateController"
    static let RefreshSecurity = "refreshSecurityNotificiation"
    static let RefreshSequence = "refreshSequenceListNotification"
    static let RefreshEvent = "refreshEventListNotification"
    static let RefreshScene = "refreshSceneListNotification"
    static let RefreshSurveillance = "refreshSurveillanceListNotification"
    static let RefreshPC = "refreshPCListNotification"
    
    static let IndicatorLamp = "indicatorGreen"
    
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
    
    struct Security {
        // These two notifications are used for start and stop blinking of security control state. When command is sent to PLC (for example to arm "Day" state), blinking of (Day) state is started (notification is posted), and when new state arrives, ControlModeStopBlinking notification is posted.
        // ControlModeStartBlinking is posted in SecurityCollectionCell.swift, when command is sent
        // ControlModeStartBlinking is received in SecurityCollectionCell.swift, where timer is activated. Also it is received in ScanDevicesViewController, in order to disable scrolling of table. This is needed because when blinking (then notification is received, table is reloaded, and if user scrolls at that time, cells will get meesed up. 
        // ControlModeStartBlinking contains "controlMode" parameter in userInfo, which contains ControlMode that is being activated (String), that indicates which cell needs to be refreshed (in which cell should the timer, that toggles image, be activated
        static let ControlModeStartBlinking = "controlModeStartBlinking"
        // ControlModeStopBlinking is posted in IncommingHandler.swift, when command for Security is received.
        // ControlModeStopBlinking is received in SecurityCollectionCell.swift, where timer is deactivated. Also it is received in ScanDevicesViewController, in order to activate scrolling of table again.
        // ControlModeStopBlinking does not contain any information. When call receives this information, if state (Defaults.) is not Disarm (that means that new state is received) timer is removed.
        static let ControlModeStopBlinking = "controlModeStopBlinking"
        
    }
    
    struct FilterTimers {
        static let timerDashboard = "TimerDashboardEndedNotification"
        static let timerDevices = "TimerDevicesEndedNotification"
        static let timerEvents = "TimerEventsEndedNotification"
        static let timerScenes = "TimerScenesEndedNotification"
        static let timerSequences = "TimerSequencesEndedNotification"
        static let timerTimers = "TimerTimersEndedNotification"
        static let timerSecurity = "TimerSecurityEndedNotification"
        static let timerSurvailance = "TimerSurvailanceEndedNotification"
        static let timerFlags = "TimerFlagsEndedNotification"
        static let timerUsers = "TimerUsersEndedNotification"
        static let timerPCControl = "TimerPCControlEndedNotification"
        static let timerChat = "TimerChatEndedNotification"
        static let timerEnergy = "TimerEnergyEndedNotification"
        static let timerSettings = "TimerSettingsEndedNotification"
    }
    
    static let RefreshFilter = "kRefreshLocalParametarsNotification"
    
    static let RefreshIBeacon = "refreshIBeaconList"
}

struct AdminConstants {
    static let Username = "username"
    static let Password = "password"
    static let IsLogged = "isAdmin"
    static let OtherUserDatabase = "OtherUserDatabase"
}

struct Login {
    static let IsLoged = "isLoged"
    static let User = "user"
}

struct SegueIdentifier {
    static let some = ""
}

struct Colors {
    static let DarkGray = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).cgColor    //   #262626
    static let MediumGray = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor
    static let LightGrayColor = UIColor.lightGray.cgColor
    static let VeryLightGrayColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1).cgColor
    static let DarkGrayColor = UIColor.darkGray.cgColor
    static let DirtyBlueColor = UIColor(red: 91/255, green: 182/255, blue: 229/225, alpha: 1.0).cgColor    //   #5bb7e5
    static let DirtyRedColor = UIColor(red: 251/255, green: 87/255, blue: 87/255, alpha: 1.0).cgColor    //   #fb5757
}
// 0-255
struct DeviceValue {
    struct MotionSensor {
        static let Idle = Int(0x00)
        static let Motion = Int(0x01)
        static let IdleWarning = Int(0xFE)
        static let ResetTimer = Int(0xEF)
    }
}

extension Date {
    
    static func yesterDay() -> Date {
        
        let today: Date = Date()
        
        let daysToAdd:Int = -1
        
        // Set up date components
        var dateComponents: DateComponents = DateComponents()
        dateComponents.day = daysToAdd
        
        // Create a calendar
        let gregorianCalendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let yesterDayDate: Date = (gregorianCalendar as NSCalendar).date(byAdding: dateComponents, to: today, options:NSCalendar.Options(rawValue: 0))!
        
        return yesterDayDate
    }
}
