//
//  ChatInfo.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/14/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

struct ChatScopeAnswer {
    let zoneName:String
    let chatScope:ChatScope
}

enum ChatScope {
    case ZoneFound
    case DidNotFindZone
    case UseFilter
}
//let TURN_ON_DEVICE = 0
//let TURN_OFF_DEVICE = 1
//let DIM_DEVICE = 2
//
//let CURRENT_TIME = 3
//let HOW_ARE_YOU = 4
//
//let SET_LOCATION = 5
//let SET_LEVEL = 6
//let SET_ZONE = 7
//
//let TELL_ME_JOKE = 8
//
//let SET_SCENE = 9
//let RUN_EVENT = 10
//let START_SEQUENCE = 11
//let I_LOVE_YOU = 12
//
//let CANCEL_EVENT = 13
//let STOP_SEQUENCE = 14
//
//let BEST_DEVELOPER = 15
//
//let LIST_DEVICE_IN_ZONE = 16
//let LIST_SCENE_IN_ZONE = 17
//let LIST_EVENTS_IN_ZONE = 18
//let LIST_SEQUENCE_IN_ZONE = 19
//
//let LIST_ALL_COMMANDS = 20
//
//let ANSWER_ME = 21
//enum ChatCommand:Int {
//    case Failed = -1
//    case TurnOnDevice = 0 // done
//    case TurnOffDevice = 1 // done
//    case DimDevice = 2 // done
//
//    case CurrentTime = 3 // done
//    case HowAreYou = 4 // done
//
//    case SetLocation = 5
//    case SetLevel = 6
//    case SetZone = 7
//
//    case TellMeJoke = 8 // done
//
//    case SetScene = 9 // done
//    case RunEvent = 10 // done
//    case StartSequence = 11 // done
//    
//    case ILoveYou = 12 // done
//
//    case CancelEvent = 13 // done
//    case StopSequence = 14 // done
//
//    case BestDeveloper = 15 // done
//
//    case ListDeviceInZone = 16
//    case ListSceneInZone = 17
//    case ListEventsInZone = 18
//    case ListSequenceInZone = 19
//
//    case ListAllCommands = 20
//
//    case AnswerMe = 21 // done
//}
enum ChatCommand:String {
    case Failed = "Failed"
    case TurnOnDevice = "Turning on the device" // done
    case TurnOffDevice = "Turning off the device" // done
    case DimDevice = "Dimming the device" // done
    
    case CurrentTime = "Current time" // done
    case HowAreYou = "Asking how is app" // done
    
    case SetLocation = "Setting location" // done
    case SetLevel = "Setting level"
    case SetZone = "Setting zone"
    
    case TellMeJoke = "Telling a joke" // done
    
    case SetScene = "Setting a scene" // done
    case RunEvent = "Running an event" // done
    case StartSequence = "Starting a sequence" // done
    
    case ILoveYou = "Telling app you love it" // done
    
    case CancelEvent = "Canceling an event" // done
    case StopSequence = "Stopping a sequence" // done
    
    case BestDeveloper = "Whose best developer" // done
    
    case ListDeviceInZone = "Listing all devices in zone"
    case ListSceneInZone = "Listing all scenes in zone"
    case ListEventsInZone = "Listing all events in zone"
    case ListSequenceInZone = "Listing all sequences in zone"
    
    case ListAllCommands = "Listing all commands" // done
    
    case AnswerMe = "Asking some general question" // done
}
//struct ChatCommand {
//    let TurnOnDevice = 0
//    let TurnOffDevice = 1
//    let DimDevice = 2
//    
//    let CurrentTime = 3
//    let HowAreYou = 4
//    
//    let SetLocation = 5
//    let SetLevel = 6
//    let SetZone = 7
//    
//    let TellMeJoke = 8
//    
//    let SetScene = 9
//    let RunEvent = 10
//    let StartSequence = 11
//    let ILoveYou = 12
//    
//    let CancelEvent = 13
//    let StopSequence = 14
//    
//    let BestDeveloper = 15
//    
//    let ListDeviceInZone = 16
//    let ListSceneInZone = 17
//    let ListEventsInZone = 18
//    let ListSequenceInZone = 19
//    
//    let ListAllCommands = 20
//    
//    let AnsweMe = 21
//}