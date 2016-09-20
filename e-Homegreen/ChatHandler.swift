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
    

    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var devices:[Device] = []
    var scenes:[Scene] = []
    var securities:[Security] = []
    var timers:[Timer] = []
    var sequences:[Sequence] = []
    var flags:[Flag] = []
    var events:[Event] = []
    
    var typeOfControl:[ChatCommand:String] = [:]
    
    let CHAT_ANSWERS:[String:ChatCommand] = [:]
    var CHAT_COMMANDS:[String:ChatCommand] = [:]
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
    func getCommand (message:String) -> ChatCommand {
        var listOfCommands:[Int:ChatCommand] = [:]
        let message = " " + message + " "
        for command in CHAT_COMMANDS.keys {
            var numberOfMatchWords = 0
            let commandWords = command.componentsSeparatedByString(" ")
            for word in commandWords {
                if message.containsString(" " + word + " ") {
                    numberOfMatchWords += 1
                }
            }
            if numberOfMatchWords == commandWords.count {
                listOfCommands[numberOfMatchWords] = CHAT_COMMANDS[command]
            }
        }
        if listOfCommands.count != 0 {
            return listOfCommands[listOfCommands.keys.maxElement()!]!
        } else {
            return .Failed
        }
    }
    
    func getTypeOfControl(chatCommand:ChatCommand)->String {
        return typeOfControl[chatCommand]!
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
        default: break
        }
        return []
    }
    // return first zone found in scope
    func getLocation(message:String) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicate = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Gateway]
            let words = message.componentsSeparatedByString(" ")
            var maxElement:[Int:String] = [:]
            for gateway in results {
                let gatewayNameWords = gateway.name.componentsSeparatedByString(" ")
                var counter = 0
                for word in words {
                    for gatewayWord in gatewayNameWords {
                        if word.lowercaseString == gatewayWord.lowercaseString || "\(word.lowercaseString)s" == "\(gatewayWord.lowercaseString)s" {
                            counter += 1
                        }
                    }
                }
                if counter > 0 && counter <= gatewayNameWords.count && (counter/gatewayNameWords.count) == 1 {
                    maxElement[counter] = gateway.name
                }
            }
            if maxElement.keys.count > 0 {
                return maxElement[maxElement.keys.maxElement()!]!
            } else {
                return ""
            }
        } catch let catchedError as NSError {
            error = catchedError
        }
        return ""
    }
    // return first zone found in scope
    func getZone(message:String) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            let words = message.componentsSeparatedByString(" ")
            var maxElement:[Int:String] = [:]
            for zone in results {
                let zoneNameWords = zone.name!.componentsSeparatedByString(" ")
                var counter = 0
                for word in words {
                    for zoneWord in zoneNameWords {
                        if word.lowercaseString == zoneWord.lowercaseString {
                            counter += 1
                        }
                    }
                }
                if counter > 0 && counter <= zoneNameWords.count && (counter/zoneNameWords.count) == 1 {
                    maxElement[counter] = zone.name
                }
            }
            if maxElement.keys.count > 0 {
                return maxElement[maxElement.keys.maxElement()!]!
            } else {
                return ""
            }
        } catch let catchedError as NSError {
            error = catchedError
        }
        return ""
    }
    func getZone(message:String, isLevel:Bool) -> Zone? {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicate]
        if isLevel {
            let locationPredicate = NSPredicate(format: "level == %@", NSNumber(integer: 0))
            predicateArray.append(locationPredicate)
        } else {
            let locationPredicate = NSPredicate(format: "level != %@", NSNumber(integer: 0))
            predicateArray.append(locationPredicate)
        }
        fetchRequest.predicate =  NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            let words = message.componentsSeparatedByString(" ")
            var maxElement:[Int:Zone] = [:]
            for zone in results {
                print(zone.name)
                let zoneNameWords = zone.name!.componentsSeparatedByString(" ")
                var counter = 0
                for word in words {
                    for zoneWord in zoneNameWords {
                        if word.lowercaseString == zoneWord.lowercaseString {
                            counter += 1
                        }
                    }
                }
//                if counter > 0 && counter <= zoneNameWords.count && (counter/zoneNameWords.count) == 1 {
                //  There was a problem with Our Suite 2 2, because it was giving 6 instead of 4... So generaly algorithm should not count already counted word, but i think the result would be the same anyway, except if there is something like Our Suite 2 2 2 2 2 2 2 2 which would count even more... Think about this...
                if (counter/zoneNameWords.count) >= 1 {
                    maxElement[counter] = zone
                    print("\(counter):\(zone.name)")
                }
            }
            if maxElement.keys.count > 0 {
                return maxElement[maxElement.keys.maxElement()!]!
            } else {
                return nil
            }
        } catch let catchedError as NSError {
            error = catchedError
        }
        return nil
    }
    
    func returnAllDevices(filterItem:FilterItem, onlyZoneName:String) -> [Device] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let predicateNull = NSPredicate(format: "categoryId != 0")
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "isEnabled == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo]
        if filterItem.location != "" && filterItem.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterItem.location)
            predicateArray.append(locationPredicate)
        }
        if onlyZoneName == "" {
            //  DatabaseHandler.returnZoneIdWithName(zone) only return one zone so this could be a problem and also there is no LOCATION, but this was a REQUEST
            let zonePredicateOne = NSPredicate(format: "zoneId == %@", NSNumber(integer: filterItem.zoneId))
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicateOne])
            predicateArray.append(copmpoundPredicate)
        } else {
            //  DatabaseHandler.returnZoneIdWithName(zone) only return one zone so this could be a problem and also there is no LOCATION, but this was a REQUEST
            let zonePredicateOne = NSPredicate(format: "zoneId == %@", NSNumber(integer: DatabaseHandler.sharedInstance.returnZoneIdWithName(onlyZoneName)))
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicateOne])
            predicateArray.append(copmpoundPredicate)
        }
        fetchRequest.predicate =  NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return []
    }
    
    func returnAllEvents(filterItem:FilterItem, onlyZoneName:String) -> [Event] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Event")
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicate]
        if filterItem.location != "" && filterItem.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterItem.location)
            predicateArray.append(locationPredicate)
        }
        if onlyZoneName == "" {
            //  DatabaseHandler.returnZoneIdWithName(zone) only return one zone so this could be a problem and also there is no LOCATION, but this was a REQUEST
            let zonePredicateOne = NSPredicate(format: "eventZone == %@", filterItem.zoneName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicateOne])
            predicateArray.append(copmpoundPredicate)
        } else {
            //  DatabaseHandler.returnZoneIdWithName(zone) only return one zone so this could be a problem and also there is no LOCATION, but this was a REQUEST
            let zonePredicateOne = NSPredicate(format: "eventZone == %@", onlyZoneName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicateOne])
            predicateArray.append(copmpoundPredicate)
        }
        fetchRequest.predicate =  NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return []
    }
    //
    func returnAllScenes(filterItem:FilterItem, onlyZoneName:String) -> [Scene] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Scene")
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicate]
        if filterItem.location != "" && filterItem.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterItem.location)
            predicateArray.append(locationPredicate)
        }
        if onlyZoneName == "" {
            //  DatabaseHandler.returnZoneIdWithName(zone) only return one zone so this could be a problem and also there is no LOCATION, but this was a REQUEST
            let zonePredicateOne = NSPredicate(format: "sceneZone == %@", filterItem.zoneName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicateOne])
            predicateArray.append(copmpoundPredicate)
        } else {
            //  DatabaseHandler.returnZoneIdWithName(zone) only return one zone so this could be a problem and also there is no LOCATION, but this was a REQUEST
            let zonePredicateOne = NSPredicate(format: "sceneZone == %@", onlyZoneName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicateOne])
            predicateArray.append(copmpoundPredicate)
        }
        fetchRequest.predicate =  NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return []
    }
    //
    func returnAllSequences(filterItem:FilterItem, onlyZoneName:String) -> [Sequence] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Sequence")
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicate]
        if filterItem.location != "" && filterItem.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterItem.location)
            predicateArray.append(locationPredicate)
        }
        if onlyZoneName == "" {
            //  DatabaseHandler.returnZoneIdWithName(zone) only return one zone so this could be a problem and also there is no LOCATION, but this was a REQUEST
            let zonePredicateOne = NSPredicate(format: "sequenceZone == %@", filterItem.zoneName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicateOne])
            predicateArray.append(copmpoundPredicate)
        } else {
            //  DatabaseHandler.returnZoneIdWithName(zone) only return one zone so this could be a problem and also there is no LOCATION, but this was a REQUEST
            let zonePredicateOne = NSPredicate(format: "sequenceZone == %@", onlyZoneName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicateOne])
            predicateArray.append(copmpoundPredicate)
        }
        fetchRequest.predicate =  NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return []
    }
    // return first zone found in scope
    func getZone(message:String, isLevel:Bool, gateways:[Gateway]?) -> Zone? {
        let zones:[Zone]?
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        if isLevel {
            let predicate = NSPredicate(format: "level == %@", NSNumber(integer: 0))
            fetchRequest.predicate = predicate
        } else {
            let predicate = NSPredicate(format: "level != %@", NSNumber(integer: 0))
            fetchRequest.predicate = predicate
        }
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            zones = results
            for zone in zones! {
                print("\(zone.name)")
                if message.containsString("\(zone.name!.lowercaseString)") {
                    return zone
                }
            }
        } catch let catchedError as NSError {
            error = catchedError
        }
        return nil
    }
    // return first level found in scope
    func getLevel(message:String) -> Zone? {
        let zones:[Zone]?
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            zones = results
            for zone in zones! {
                print(zone.level)
                print(zone.id)
                if message.containsString(" \(zone.name) ") && zone.level != NSNumber(integer: 0) {
                    return zone
                }
            }
        } catch let catchedError as NSError {
            error = catchedError
        }
        return nil
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
        
        typeOfControl = [.TurnOnDevice: CONTROL_DEVICE, // control device
            .TurnOffDevice: CONTROL_DEVICE,
            .DimDevice: CONTROL_DEVICE,
            .CurrentTime: CHAT, // chat
            .HowAreYou: CHAT,
            .TellMeJoke: CHAT,
            .ILoveYou: CHAT,
            .AnswerMe: CHAT,
            .BestDeveloper: CHAT,
            .SetLocation: FILTER, // filter
            .SetLevel: FILTER,
            .SetZone: FILTER,
            .SetScene: CONTROL_SCENE, // control scene
            .RunEvent: CONTROL_EVENT, // control event
            .CancelEvent: CONTROL_EVENT,
            .StartSequence: CONTROL_SEQUENCE, // control sequence
            .StopSequence: CONTROL_SEQUENCE,
            .ListDeviceInZone:LIST_DEVICE, // list device
            .ListSceneInZone:LIST_SCENE, // list scene
            .ListEventsInZone:LIST_EVENTS, // list events
            .ListSequenceInZone:LIST_SEQUENCE, // list sequence
            .ListAllCommands:LIST_COMMANDS, // list commands
            .Failed: FAILED] // command not found
        
        CHAT_COMMANDS["set location"] = .SetLocation
        CHAT_COMMANDS["control location"] = .SetLocation
        CHAT_COMMANDS["select location"] = .SetLocation
        
        CHAT_COMMANDS["set level"] = .SetLevel
        CHAT_COMMANDS["control level"] = .SetLevel
        CHAT_COMMANDS["select level"] = .SetLevel
        
        CHAT_COMMANDS["set zone"] = .SetZone
        CHAT_COMMANDS["control zone"] = .SetZone
        CHAT_COMMANDS["select zone"] = .SetZone
        
        /**
        * Commands to controlling devices
        * */
        CHAT_COMMANDS["turn on"] = .TurnOnDevice
        CHAT_COMMANDS["open"] = .TurnOnDevice
        CHAT_COMMANDS["activate"] = .TurnOnDevice
        CHAT_COMMANDS["fill"] = .TurnOnDevice
        CHAT_COMMANDS["insert"] = .TurnOnDevice
        CHAT_COMMANDS["start"] = .TurnOnDevice
        CHAT_COMMANDS["lock"] = .TurnOnDevice
        CHAT_COMMANDS["occupy"] = .TurnOnDevice
        CHAT_COMMANDS["switch on"] = .TurnOnDevice
        
        CHAT_COMMANDS["turn of"] = .TurnOffDevice
        CHAT_COMMANDS["turn off"] = .TurnOffDevice
        CHAT_COMMANDS["switch off"] = .TurnOffDevice
        CHAT_COMMANDS["switch of"] = .TurnOffDevice
        CHAT_COMMANDS["close"] = .TurnOffDevice
        CHAT_COMMANDS["deactivate"] = .TurnOffDevice
        CHAT_COMMANDS["empty"] = .TurnOffDevice
        CHAT_COMMANDS["remove"] = .TurnOffDevice
        CHAT_COMMANDS["stop"] = .TurnOffDevice
        CHAT_COMMANDS["unlock"] = .TurnOffDevice
        CHAT_COMMANDS["vacate"] = .TurnOffDevice
        
        CHAT_COMMANDS["dim"] = .DimDevice
        
        CHAT_COMMANDS["set"] = .SetScene
//        CHAT_COMMANDS["set scene"] = .SetScene
        
        CHAT_COMMANDS["run"] = .RunEvent
//        CHAT_COMMANDS["run event"] = .RunEvent
        CHAT_COMMANDS["cancel event"] = .CancelEvent
        
        CHAT_COMMANDS["start sequence"] = .StartSequence
        CHAT_COMMANDS["stop sequence"] = .StopSequence
        
        /**
        * Commands for listing
        * */
        CHAT_COMMANDS["list device"] = .ListDeviceInZone
        CHAT_COMMANDS["list devices"] = .ListDeviceInZone
        CHAT_COMMANDS["list scene"] = .ListSceneInZone
        CHAT_COMMANDS["list scenes"] = .ListSceneInZone
        CHAT_COMMANDS["list event"] = .ListEventsInZone
        CHAT_COMMANDS["list events"] = .ListEventsInZone
        CHAT_COMMANDS["list sequence"] = .ListSequenceInZone
        CHAT_COMMANDS["list sequences"] = .ListSequenceInZone

        /**
        * Commands to chat with Valery
        * */
        CHAT_COMMANDS["what time is it"] = .CurrentTime
        CHAT_COMMANDS["what is the time"] = .CurrentTime
        CHAT_COMMANDS["what's time"] = .CurrentTime
        CHAT_COMMANDS["what time is it?"] = .CurrentTime
        CHAT_COMMANDS["what is the time?"] = .CurrentTime
        CHAT_COMMANDS["what's time?"] = .CurrentTime
        CHAT_COMMANDS["time"] = .CurrentTime
        
        CHAT_COMMANDS["how are you"] = .HowAreYou
        CHAT_COMMANDS["how are you?"] = .HowAreYou
        
        CHAT_COMMANDS["tell me joke"] = .TellMeJoke
        CHAT_COMMANDS["tell joke"] = .TellMeJoke
        CHAT_COMMANDS["say something funny"] = .TellMeJoke
        
        CHAT_COMMANDS["what is"] = .AnswerMe
        CHAT_COMMANDS["tell me about"] = .AnswerMe
        CHAT_COMMANDS["do i need to"] = .AnswerMe
        CHAT_COMMANDS["do i want"] = .AnswerMe
        CHAT_COMMANDS["who is"] = .AnswerMe
        CHAT_COMMANDS["where is"] = .AnswerMe
        CHAT_COMMANDS["what do"] = .AnswerMe
        
        CHAT_COMMANDS["love you"] = .ILoveYou
        CHAT_COMMANDS["like you"] = .ILoveYou
        CHAT_COMMANDS["who is best developer"] = .BestDeveloper
        CHAT_COMMANDS["who is best"] = .BestDeveloper
//        CHAT_COMMANDS["answer"] = .BestDeveloper
        
        /**
        * List commands
        * */
        CHAT_COMMANDS["list commands"] = .ListAllCommands
        CHAT_COMMANDS["list command"] = .ListAllCommands
        CHAT_COMMANDS["what can i say"] = .ListAllCommands
        CHAT_COMMANDS["what is my options"] = .ListAllCommands
        CHAT_COMMANDS["what is my option"] = .ListAllCommands
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