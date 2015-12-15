//
//  ChatHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/15/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData
//enum
//struct ChatInfo {
//    let command:Int
//    let device:[Device]
//    let dimValue:Int?
//}
class ChatHandler {
    
    let SYSTEM_NAME = "Valery"
    
    let CONTROL_DEVICE = "control_device"
    let CONTROL_EVENT = "control_event"
    let CONTROL_SCENE = "control_scene"
    let CONTROL_SEQUENCE = "control_sequence"
    let CHAT = "chat"
    let FILTER = "filter"
    let FAILED = "failed"
    
    let LIST_DEVICE = "list_device"
    let LIST_SCENE = "list_scene"
    let LIST_EVENTS = "list_event"
    let LIST_SEQUENCE = "list_sequence"
    
    let LIST_COMMANDS = "list_commands"
    
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
    
    let LIST_DEVICE_IN_ZONE = 16
    let LIST_SCENE_IN_ZONE = 17
    let LIST_EVENTS_IN_ZONE = 18
    let LIST_SEQUENCE_IN_ZONE = 19
    
    let LIST_ALL_COMMANDS = 20
    
    let ANSWER_ME = 21
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var devices:[Device] = []
    var scenes:[Scene] = []
    var securities:[Security] = []
    var timers:[Timer] = []
    var sequences:[Sequence] = []
    var flags:[Flag] = []
    var events:[Event] = []
    
    var typeOfControl:[Int:String] = [:]
    
    let CHAT_ANSWERS:[String:Int] = [:]
    var CHAT_COMMANDS:[String:Int] = [:]

    init () {
        setValues()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
    }
    func getAllZoneNames() ->[Zone] {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicateOne
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            return results
        } catch let catchedError as NSError {
            error = catchedError
            return []
        }
    }
//    func getCommandScope(message:String) -> ChatScope {
//        let message = " " + message + " "
//        if message.containsString(" in ") {
//            // ima kljucnu rec in
//            let zones = getAllZoneNames()
//            for zone in zones {
//                if message.containsString(zone.name) {
//                    // Nadjeno je ime
//                    // zone.name VRATI IME ZA ZONU
//                    fetchEntitiesWithoutFilter(<#T##whatToFetch: String##String#>, inZoneId: <#T##Int#>, inZoneName: <#T##String#>)
//                }
//            }
//            // Nije nadjen ni jedan zone
//            // VRATI ODGOVOR DA JE KOMANDA NEJASNA
//        } else {
//            // trazi filter
//        }
////        abc
//    }
    func getCommand (message:String) -> Int {
        var listOfCommands:[Int:Int] = [:]
        let message = " " + message + " "
        for command in CHAT_COMMANDS.keys {
            var numberOfMatchWords = 0
            let commandWords = command.componentsSeparatedByString(" ")
            for word in commandWords {
                if message.containsString(" " + word + " ") {
                    numberOfMatchWords++
                }
            }
            if numberOfMatchWords == commandWords.count {
                listOfCommands[numberOfMatchWords] = CHAT_COMMANDS[command]
            }
        }
        if listOfCommands.count != 0 {
            return listOfCommands[listOfCommands.keys.maxElement()!]!
            //            return listOfCommands.keys.maxElement()!
        } else {
            return -1
        }
        return -1
    }
    
    func getTypeOfControl(index:Int)->String {
        //        return typeOfControl[getCommand(message)]!
        return typeOfControl[index]!
    }
    
    func getValueForDim(message:String, withDeviceName:String) -> Int {
        if message != "" {
            let messageWithoutName = message.stringByReplacingOccurrencesOfString(withDeviceName.lowercaseString, withString: "")
            let stringArray = messageWithoutName.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            let digitString = stringArray.joinWithSeparator("")
            if let integer = Int(digitString) {
                if integer >= 0 && integer <= 100 {
                    return integer
                }
            }
        }
        return -1
    }
    
//    func returnCommand (message:String) -> ChatInfo {
//        let command = getCommand(message)
//        let devices = getItemByName(getTypeOfControl(command), message: message)
//        let dimValue = getValueForDim(message)
//        return ChatInfo(command: command, device: devices, dimValue: +)
//    }
    
    func getItemByName(typeOfControl:String, message:String) -> [AnyObject] {
        switch typeOfControl {
        case "control_device":
            fetchEntities("Device")
            var returnItems:[Device] = []
            for item in devices {
                if message.containsString(item.name.lowercaseString) || message.containsString("\(item.name.lowercaseString)s") {
                    returnItems.append(item)
                }
            }
            return returnItems
        case "control_scene":
            fetchEntities("Scene")
            var returnItems:[Scene] = []
            for item in scenes {
                if message.containsString(item.sceneName.lowercaseString) || message.containsString("\(item.sceneName.lowercaseString)s") {
                    returnItems.append(item)
                }
            }
            return returnItems
        case "control_event":
            fetchEntities("Event")
            var returnItems:[Event] = []
            for item in events {
                if message.containsString(item.eventName.lowercaseString) || message.containsString("\(item.eventName.lowercaseString)s") {
                    returnItems.append(item)
                }
            }
            return returnItems
        case "control_sequence":
            fetchEntities("Sequence")
            var returnItems:[Sequence] = []
            for item in sequences {
                if message.containsString(item.sequenceName.lowercaseString) || message.containsString("\(item.sequenceName .lowercaseString)s") {
                    returnItems.append(item)
                }
            }
            return returnItems
        default:
            return []
            break
        }
    }
    
    func fetchEntities (whatToFetch:String) {
        let locationSearchText = LocalSearchParametar.getLocalParametar("Chat")
        if whatToFetch == "Scene" {
            let fetchRequest = NSFetchRequest(entityName: "Scene")
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            var predicateArray:[NSPredicate] = [predicateOne]
            if locationSearchText[0] != "All" {
                let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearchText[0])
                predicateArray.append(locationPredicate)
            }
            if locationSearchText[4] != "All" {
                let levelPredicate = NSPredicate(format: "entityLevel == %@", locationSearchText[4])
                predicateArray.append(levelPredicate)
            }
            if locationSearchText[5] != "All" {
                let zonePredicate = NSPredicate(format: "sceneZone == %@", locationSearchText[5])
                predicateArray.append(zonePredicate)
            }
            if locationSearchText[6] != "All" {
                let categoryPredicate = NSPredicate(format: "sceneCategory == %@", locationSearchText[6])
                predicateArray.append(categoryPredicate)
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Scene]
                print(results.count)
                scenes = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Event" {
            let fetchRequest = NSFetchRequest(entityName: "Event")
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            var predicateArray:[NSPredicate] = [predicateOne]
            if locationSearchText[0] != "All" {
                let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearchText[0])
                predicateArray.append(locationPredicate)
            }
            if locationSearchText[4] != "All" {
                let levelPredicate = NSPredicate(format: "entityLevel == %@", locationSearchText[4])
                predicateArray.append(levelPredicate)
            }
            if locationSearchText[5] != "All" {
                let zonePredicate = NSPredicate(format: "eventZone == %@", locationSearchText[5])
                predicateArray.append(zonePredicate)
            }
            if locationSearchText[6] != "All" {
                let categoryPredicate = NSPredicate(format: "eventCategory == %@", locationSearchText[6])
                predicateArray.append(categoryPredicate)
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Event]
                events = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Sequence" {
            let fetchRequest = NSFetchRequest(entityName: "Sequence")
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            var predicateArray:[NSPredicate] = [predicateOne]
            if locationSearchText[0] != "All" {
                let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearchText[0])
                predicateArray.append(locationPredicate)
            }
            if locationSearchText[4] != "All" {
                let levelPredicate = NSPredicate(format: "entityLevel == %@", locationSearchText[4])
                predicateArray.append(levelPredicate)
            }
            if locationSearchText[5] != "All" {
                let zonePredicate = NSPredicate(format: "sequenceZone == %@", locationSearchText[5])
                predicateArray.append(zonePredicate)
            }
            if locationSearchText[6] != "All" {
                let categoryPredicate = NSPredicate(format: "sequenceCategory == %@", locationSearchText[6])
                predicateArray.append(categoryPredicate)
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Sequence]
                sequences = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Device" {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
            let predicateNull = NSPredicate(format: "categoryId != 0")
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            let predicateTwo = NSPredicate(format: "isEnabled == %@", NSNumber(bool: true))
            var predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo]
            if locationSearchText[0] != "All" {
                let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearchText[0])
                predicateArray.append(locationPredicate)
            }
            if locationSearchText[1] != "All" {
                let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: Int(locationSearchText[1])!))
                let levelPredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", locationSearchText[4])
                let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [levelPredicate, levelPredicateTwo])
                predicateArray.append(copmpoundPredicate)
            }
            if locationSearchText[2] != "All" {
                let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: Int(locationSearchText[2])!))
                let zonePredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", locationSearchText[5])
                let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicate, zonePredicateTwo])
                predicateArray.append(copmpoundPredicate)
            }
            if locationSearchText[3] != "All" {
                let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: Int(locationSearchText[3])!))
                let categoryPredicateTwo = NSPredicate(format: "ANY gateway.categories.name == %@", locationSearchText[6])
                let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, categoryPredicateTwo])
                predicateArray.append(copmpoundPredicate)
            }
            fetchRequest.predicate =  NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
                devices = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    func fetchEntitiesWithoutFilter (whatToFetch:String, inZoneId:Int, inZoneName:String) {
        if whatToFetch == "Scene" {
            let fetchRequest = NSFetchRequest(entityName: "Scene")
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            let predicateTwo = NSPredicate(format: "entityLevel == %@", inZoneName)
            let predicateThree = NSPredicate(format: "sceneZone == %@", inZoneName)
            let orCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicateTwo, predicateThree])
            let predicateArray:[NSPredicate] = [predicateOne, orCompoundPredicate]
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Scene]
                print(results.count)
                scenes = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Event" {
            let fetchRequest = NSFetchRequest(entityName: "Event")
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            let predicateTwo = NSPredicate(format: "entityLevel == %@", inZoneName)
            let predicateThree = NSPredicate(format: "eventZone == %@", inZoneName)
            let orCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicateTwo, predicateThree])
            let predicateArray:[NSPredicate] = [predicateOne, orCompoundPredicate]
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Event]
                events = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Sequence" {
            let fetchRequest = NSFetchRequest(entityName: "Sequence")
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            let predicateTwo = NSPredicate(format: "entityLevel == %@", inZoneName)
            let predicateThree = NSPredicate(format: "sequenceZone == %@", inZoneName)
            let orCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicateTwo, predicateThree])
            let predicateArray:[NSPredicate] = [predicateOne, orCompoundPredicate]
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Sequence]
                sequences = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Device" {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
            let predicateNull = NSPredicate(format: "categoryId != 0")
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            let predicateTwo = NSPredicate(format: "isEnabled == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: inZoneId))
            let predicateFour = NSPredicate(format: "zoneId == %@", NSNumber(integer: inZoneId))
            let orCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicateThree, predicateFour])
            let predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo, orCompoundPredicate]
            fetchRequest.predicate =  NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
                devices = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func setValues () {
        
//        public static Map<Integer, String> nameOfControl = new HashMap<>();
//        
//        static {
//            nameOfControl.put(TURN_ON_DEVICE, "turn on");
//            nameOfControl.put(TURN_OFF_DEVICE, "turn off");
//            nameOfControl.put(DIM_DEVICE, "diming");
//            nameOfControl.put(CURRENT_TIME, "get current time");
//            nameOfControl.put(HOW_ARE_YOU, "ask how are you");
//            nameOfControl.put(SET_LOCATION, "set location");
//            nameOfControl.put(SET_LEVEL, "set level");
//            nameOfControl.put(SET_ZONE, "set zone");
//            nameOfControl.put(TELL_ME_JOKE, "tell some joke");
//            nameOfControl.put(RUN_EVENT, "run event");
//            nameOfControl.put(START_SEQUENCE, "start sequence");
//            nameOfControl.put(I_LOVE_YOU, "say i love you");
//            nameOfControl.put(CANCEL_EVENT, "cancel event");
//            nameOfControl.put(STOP_SEQUENCE, "stop sequence");
//            nameOfControl.put(BEST_DEVELOPER, "ask who is best developer");
//            nameOfControl.put(LIST_DEVICE_IN_ZONE, "list devices");
//            nameOfControl.put(LIST_SCENE_IN_ZONE, "list scenes");
//            nameOfControl.put(LIST_EVENTS_IN_ZONE, "list events");
//            nameOfControl.put(LIST_SEQUENCE_IN_ZONE, "list sequences");
//            nameOfControl.put(LIST_ALL_COMMANDS, "list all commands");
//            nameOfControl.put(SET_SCENE, "set scene");
//        }
        
        typeOfControl = [TURN_ON_DEVICE: CONTROL_DEVICE,
            TURN_OFF_DEVICE: CONTROL_DEVICE,
            DIM_DEVICE: CONTROL_DEVICE,
            CURRENT_TIME: CHAT,
            HOW_ARE_YOU: CHAT,
            SET_LOCATION: FILTER,
            SET_LEVEL: FILTER,
            SET_ZONE: FILTER,
            TELL_ME_JOKE: CHAT,
            I_LOVE_YOU: CHAT,
            ANSWER_ME: CHAT,
            BEST_DEVELOPER: CHAT,
            SET_SCENE: CONTROL_SCENE,
            RUN_EVENT: CONTROL_EVENT,
            CANCEL_EVENT: CONTROL_EVENT,
            START_SEQUENCE: CONTROL_SEQUENCE,
            STOP_SEQUENCE: CONTROL_SEQUENCE,
            LIST_DEVICE_IN_ZONE:LIST_DEVICE,
            LIST_SCENE_IN_ZONE:LIST_SCENE,
            LIST_EVENTS_IN_ZONE:LIST_EVENTS,
            LIST_SEQUENCE_IN_ZONE:LIST_SEQUENCE,
            LIST_ALL_COMMANDS:LIST_COMMANDS,
            -1: FAILED]
        
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
        CHAT_COMMANDS["switch on"] = TURN_ON_DEVICE
        
        CHAT_COMMANDS["turn of"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["turn off"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["switch off"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["switch of"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["close"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["deactivate"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["empty"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["remove"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["stop"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["unlock"] = TURN_OFF_DEVICE
        CHAT_COMMANDS["vacate"] = TURN_OFF_DEVICE
        
        CHAT_COMMANDS["dim"] = DIM_DEVICE
        
        CHAT_COMMANDS["set"] = SET_SCENE
//        CHAT_COMMANDS["set scene"] = SET_SCENE
        
        CHAT_COMMANDS["run"] = RUN_EVENT
//        CHAT_COMMANDS["run event"] = RUN_EVENT
        CHAT_COMMANDS["cancel event"] = CANCEL_EVENT
        
        CHAT_COMMANDS["start sequence"] = START_SEQUENCE
        CHAT_COMMANDS["stop sequence"] = STOP_SEQUENCE
        
        /**
        * Commands for listing
        * */
        CHAT_COMMANDS["list device"] = LIST_DEVICE_IN_ZONE
        CHAT_COMMANDS["list devices"] = LIST_DEVICE_IN_ZONE
        CHAT_COMMANDS["list scene"] = LIST_SCENE_IN_ZONE
        CHAT_COMMANDS["list scenes"] = LIST_SCENE_IN_ZONE
        CHAT_COMMANDS["list event"] = LIST_EVENTS_IN_ZONE
        CHAT_COMMANDS["list events"] = LIST_EVENTS_IN_ZONE
        CHAT_COMMANDS["list sequence"] = LIST_SEQUENCE_IN_ZONE
        CHAT_COMMANDS["list sequences"] = LIST_SEQUENCE_IN_ZONE

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
        
        CHAT_COMMANDS["what is"] = ANSWER_ME
        CHAT_COMMANDS["tell me about"] = ANSWER_ME
        CHAT_COMMANDS["do i need to"] = ANSWER_ME
        CHAT_COMMANDS["do i want"] = ANSWER_ME
        CHAT_COMMANDS["who is"] = ANSWER_ME
        CHAT_COMMANDS["where is"] = ANSWER_ME
        CHAT_COMMANDS["what do"] = ANSWER_ME
        
        CHAT_COMMANDS["love you"] = I_LOVE_YOU
        CHAT_COMMANDS["best developer ios"] = BEST_DEVELOPER
        CHAT_COMMANDS["answer"] = BEST_DEVELOPER
        
        /**
        * List commands
        * */
        CHAT_COMMANDS["list commands"] = LIST_ALL_COMMANDS
        CHAT_COMMANDS["list command"] = LIST_ALL_COMMANDS
        CHAT_COMMANDS["what can i say"] = LIST_ALL_COMMANDS
        CHAT_COMMANDS["what is my options"] = LIST_ALL_COMMANDS
    }
    func getAnswerCommand(command:String) -> String  {
        var answer = ""
        switch command {
        case "turn on":
            answer = "turned on"
        case "open":
            answer = "opened"
        case "activate":
            answer = "activated"
        case "fill":
            answer = "filled"
        case "insert":
            answer = "inserted"
        case "start":
            answer = "started"
        case "lock":
            answer = "locked"
        case "occupy":
            answer = "occupied"
        case "switch on":
            answer = "switched on"
        case "turn off":
            answer = "turned off"
        case "turn of":
            answer = "turned off"
        case "switch off":
            answer = "switched off"
        case "switch of":
            answer = "switched off"
        case "close":
            answer = "closed"
        case "deactivate":
            answer = "deactivated"
        case "empty":
            answer = "emptied"
        case "remove":
            answer = "removed"
        case "stop":
            answer = "stoped"
        case "unlock":
            answer = "unlocked"
        case "vacate":
            answer = "vacated"
        default: break
        }
        return answer
    }
}