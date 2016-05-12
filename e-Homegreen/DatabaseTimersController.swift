//
//  DatabaseTimersController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseTimersController: NSObject {
    
    static let shared = DatabaseTimersController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getTimers(filterParametar:FilterItem) -> [Timer] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Timer")
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArrayOr:[NSPredicate] = [NSPredicate(format: "type != %@", "Stopwatch/User")]
            predicateArrayOr.append(NSPredicate(format: "timerCategory != %@", "User"))
            let compoundPredicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: predicateArrayOr)

            var predicateArrayAnd:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))]
            predicateArrayAnd.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            if filterParametar.location != "All" {
                predicateArrayAnd.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location))
            }
            if filterParametar.levelName != "All" {
                predicateArrayAnd.append(NSPredicate(format: "entityLevel == %@", filterParametar.levelName))
            }
            if filterParametar.zoneName != "All" {
                predicateArrayAnd.append(NSPredicate(format: "timeZone == %@", filterParametar.zoneName))
            }
            if filterParametar.categoryName != "All" {
                predicateArrayAnd.append(NSPredicate(format: "timerCategory == %@", filterParametar.categoryName))
            }
            let compoundPredicate2 = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArrayAnd)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [compoundPredicate1, compoundPredicate2])
            fetchRequest.predicate = compoundPredicate
            
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    func getTimerByid(id:String) -> Timer?{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Timer")
        let predicateArray:[NSPredicate] = [NSPredicate(format: "id == %@", id)]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
            if fetResults?.count != 0{
                return fetResults?.first
            }
        } catch _ as NSError {
            abort()
        }
        
        return nil
    }
    
    func getUserTimers(location:Location) -> [Timer]{
        let fetchRequest = NSFetchRequest(entityName: "Timer")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateOne]
        predicateArray.append(NSPredicate(format: "gateway.location == %@", location))
        predicateArray.append(NSPredicate(format: "type == %@", "Stopwatch/User"))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
            return fetResults!
        } catch _ as NSError {
            abort()
        }
        return []
    }
    
    func getTimerByObjectID(objectID:NSManagedObjectID) -> Timer?{
        if let timer = appDel.managedObjectContext?.objectWithID(objectID) as? Timer {
            return timer
        }
        return nil
    }
    
    func startTImerOnLocation(timer:Timer){
        var address:[UInt8] = []
        if timer.isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timer.isLocalcast.boolValue {
            address = [UInt8(Int(timer.gateway.addressOne)), UInt8(Int(timer.gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timer.gateway.addressOne)), UInt8(Int(timer.gateway.addressTwo)), UInt8(Int(timer.address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timer.timerId)), command: 0x01), gateway: timer.gateway)
    }

}
