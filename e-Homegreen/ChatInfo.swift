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
    case zoneFound
    case didNotFindZone
    case useFilter
}
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
