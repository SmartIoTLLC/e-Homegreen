//
//  ChatHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/15/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

class ChatHandler {
    
    let SYSTEM_NAME = "Valery"
    
    let CONTROL_DEVICE = "control_device"
    let CONTROL_EVENT = "control_event"
    let CONTROL_SCENE = "control_scene"
    let CONTROL_SEQUENCE = "control_sequence"
    let CHAT = "chat"
    let FILTER = "filter"
    let FAILED = "failed"
    
    
    let TURN_ON_DEVICE = 0
    let TURN_OFF_DEVICE = 1
    let DIM_DEVICE = 2
    
    let CURRENT_TIME = 3
    let HOW_ARE_YOU = 4
    
    let SET_LOCATION = 5
    let SET_LEVEL = 6
    let SET_ZONE = 7
    
    let TELL_ME_JOKE = 8
    
    let SET_SCENE = 9
    let RUN_EVENT = 10
    let START_SEQUENCE = 11
    let I_LOVE_YOU = 12
    
    let CANCEL_EVENT = 13
    let STOP_SEQUENCE = 14
    
    let BEST_DEVELOPER = 15
    
    init () {
        setValues()
        
//        var testString = "ma1 ma2 ma3 ma4 ma5    ma6".characters.split{$0 == " "}.map(String.init)
        var string = "ma1 ma2 ma3 ma4 ma5    ma6"
        
        var testString = string.componentsSeparatedByString(" ")

        for item in testString {
            print(item)
        }
        
        for item in testString {
            if string.containsString(" " + item + " ") {
                
            }
        }
    }
    func getCommand (message:String) -> Int {
        var listOfCommands:[Int:Int] = [:]
        let message = " " + message + " "
        for command in CHAT_COMMANDS.keys {
            print(command)
            var numberOfMatchWords = 0
//            let command = "turn off"
            let commandWords = command.componentsSeparatedByString(" ")
            for word in commandWords {
                if message.containsString(" " + word + " ") {
                    numberOfMatchWords++
                }
                if numberOfMatchWords == commandWords.count {
                    listOfCommands[numberOfMatchWords] = CHAT_COMMANDS[command]
                }
            }
            if listOfCommands.count != 0 {
                return listOfCommands.keys.maxElement()!
            } else {
                return -1
            }
        }
        return -1
    }
    
    func getValueForDim(message:String) -> Int {
        if message != "" {
            let stringArray = message.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            let digitString = stringArray.joinWithSeparator("")
            if let integer = Int(digitString) {
                if integer >= 0 && integer <= 100 {
                    return integer
                }
            }
        }
        return -1
    }
    
//    let typeOfControl:[Int:String] = [TURN_ON_DEVICE: CONTROL_DEVICE,
//    TURN_OFF_DEVICE: CONTROL_DEVICE,
//    DIM_DEVICE: CONTROL_DEVICE,
//    CURRENT_TIME: CHAT,
//    HOW_ARE_YOU: CHAT,
//    SET_LOCATION: FILTER,
//    SET_LEVEL: FILTER,
//    SET_ZONE: FILTER,
//    TELL_ME_JOKE: CHAT,
//    I_LOVE_YOU: CHAT,
//    BEST_DEVELOPER: CHAT,
//    SET_SCENE: CONTROL_SCENE,
//    RUN_EVENT: CONTROL_EVENT,
//    CANCEL_EVENT: CONTROL_EVENT,
//    START_SEQUENCE: CONTROL_SEQUENCE,
//    STOP_SEQUENCE: CONTROL_SEQUENCE,
//    -1: FAILED]
    
    
    let CHAT_ANSWERS:[String:Int] = [:]
    var CHAT_COMMANDS:[String:Int] = [:]
    
    func setValues () {
    
    CHAT_COMMANDS["set location"] = SET_LOCATION
    CHAT_COMMANDS["control location"] = SET_LOCATION
    CHAT_COMMANDS["select location"] = SET_LOCATION
    
    CHAT_COMMANDS["set level"] = SET_LEVEL
    CHAT_COMMANDS["control level"] = SET_LEVEL
    CHAT_COMMANDS["select level"] = SET_LEVEL
    
    CHAT_COMMANDS["set zone"] = SET_ZONE
    CHAT_COMMANDS["control zone"] = SET_ZONE
    CHAT_COMMANDS["select zone"] = SET_ZONE
    
    /**
    * Commands to controlling devices
    * */
    CHAT_COMMANDS["turn on"] = TURN_ON_DEVICE
    CHAT_COMMANDS["open"] = TURN_ON_DEVICE
    CHAT_COMMANDS["activate"] = TURN_ON_DEVICE
    CHAT_COMMANDS["fill"] = TURN_ON_DEVICE
    CHAT_COMMANDS["insert"] = TURN_ON_DEVICE
    CHAT_COMMANDS["start"] = TURN_ON_DEVICE
    CHAT_COMMANDS["lock"] = TURN_ON_DEVICE
    CHAT_COMMANDS["occupy"] = TURN_ON_DEVICE
    
    CHAT_COMMANDS["turn of"] = TURN_OFF_DEVICE
    CHAT_COMMANDS["turn off"] = TURN_OFF_DEVICE
    CHAT_COMMANDS["close"] = TURN_OFF_DEVICE
    CHAT_COMMANDS["deactivate"] = TURN_OFF_DEVICE
    CHAT_COMMANDS["empty"] = TURN_OFF_DEVICE
    CHAT_COMMANDS["remove"] = TURN_OFF_DEVICE
    CHAT_COMMANDS["stop"] = TURN_OFF_DEVICE
    CHAT_COMMANDS["unlock"] = TURN_OFF_DEVICE
    CHAT_COMMANDS["vacate"] = TURN_OFF_DEVICE
    
    CHAT_COMMANDS["dim"] = DIM_DEVICE
    
    CHAT_COMMANDS["set scene"] = SET_SCENE
    
    CHAT_COMMANDS["run event"] = RUN_EVENT
    CHAT_COMMANDS["cancel event"] = CANCEL_EVENT
    
    CHAT_COMMANDS["start sequence"] = START_SEQUENCE
    CHAT_COMMANDS["stop sequence"] = STOP_SEQUENCE
    
    /**
    * Commands to chat with Valery
    * */
    CHAT_COMMANDS["what time is it"] = CURRENT_TIME
    CHAT_COMMANDS["what is the time"] = CURRENT_TIME
    CHAT_COMMANDS["what's time"] = CURRENT_TIME
    
    CHAT_COMMANDS["how are you"] = HOW_ARE_YOU
    
    CHAT_COMMANDS["tell me joke"] = TELL_ME_JOKE
    CHAT_COMMANDS["tell joke"] = TELL_ME_JOKE
    CHAT_COMMANDS["say something funny"] = TELL_ME_JOKE
    
    CHAT_COMMANDS["love you"] = I_LOVE_YOU
    CHAT_COMMANDS["best developer android"] = BEST_DEVELOPER
    CHAT_COMMANDS["answer"] = BEST_DEVELOPER
    }
}