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
            
            if filterParametar.levelObjectId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId){
                    predicateArrayAnd.append(NSPredicate(format: "entityLevelId == %@", level.id!))
                }
            }
            if filterParametar.zoneObjectId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                    predicateArrayAnd.append(NSPredicate(format: "timeZoneId == %@", zone.id!))
                }
            }
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                    predicateArrayAnd.append(NSPredicate(format: "timerCategoryId == %@", category.id!))
                }
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
    
    func updateTimerList(gateway:Gateway, filterParametar:FilterItem) -> [Timer] {
        let fetchRequest = NSFetchRequest(entityName: "Timer")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway))
        
        if filterParametar.levelObjectId != "All" {
            if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId){
                predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!))
            }
        }
        if filterParametar.zoneObjectId != "All" {
            if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                predicateArray.append(NSPredicate(format: "timeZoneId == %@", zone.id!))
            }
        }
        if filterParametar.categoryObjectId != "All" {
            if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                predicateArray.append(NSPredicate(format: "timerCategoryId == %@", category.id!))
            }
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
            return fetResults!
        } catch{
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
    
    func getTimerByStringObjectID(objectId:String) -> Timer?{
        if objectId != ""{
            if let url = NSURL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) {
                    do{
                        let timer = try appDel.managedObjectContext?.existingObjectWithID(id) as? Timer
                        return timer
                    }catch {
                        
                    }
                }
            }
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

    func addTimer(timerId: Int, timerName: String?, moduleAddress: Int, gateway: Gateway, type: Int?, levelId: Int?, selectedZoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "Scene - All On - 00", sceneImageTwoDefault:String? = "Scene - All On - 01", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:NSData? = nil, imageDataTwo:NSData? = nil){
        var itExists = false
        var existingTimer:Timer?
        var timerArray = fetchTimerWithId(timerId, gateway: gateway, moduleAddress: moduleAddress)
        if timerArray.count > 0 {
            existingTimer = timerArray.first
            itExists = true
        }
        if !itExists {
            let timer = NSEntityDescription.insertNewObjectForEntityForName("Timer", inManagedObjectContext: appDel.managedObjectContext!) as! Timer
            timer.timerId = timerId
            if let timerName = timerName {
                timer.timerName = timerName
            }else{
                timer.timerName = ""
            }
            timer.address = moduleAddress
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = NSUUID().UUIDString
                    timer.timerImageOneCustom = image.imageId
                    timer.timerImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                timer.timerImageOneDefault = sceneImageOneDefault
                timer.timerImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = NSUUID().UUIDString
                    timer.timerImageTwoCustom = image.imageId
                    timer.timerImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                timer.timerImageTwoDefault = sceneImageTwoDefault
                timer.timerImageTwoCustom = sceneImageTwoCustom
            }
            
            timer.entityLevelId = levelId
            timer.timeZoneId = selectedZoneId
            timer.timerCategoryId = categoryId
            
            timer.isBroadcast = isBroadcast
            timer.isLocalcast = isLocalcast
            if let type = type{
                timer.type = type
            }else{
                timer.type = 0
            }
            
            timer.id = NSUUID().UUIDString
            timer.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            if let timerName = timerName {
                existingTimer!.timerName = timerName
            }
            
            existingTimer!.entityLevelId = levelId
            existingTimer!.timeZoneId = selectedZoneId
            existingTimer!.timerCategoryId = categoryId
            
            if let type = type{
                existingTimer!.type = type
            }else{
                existingTimer!.type = 0
            }
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = NSUUID().UUIDString
                    existingTimer!.timerImageOneCustom = image.imageId
                    existingTimer!.timerImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                existingTimer!.timerImageOneDefault = sceneImageOneDefault
                existingTimer!.timerImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = NSUUID().UUIDString
                    existingTimer!.timerImageTwoCustom = image.imageId
                    existingTimer!.timerImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                existingTimer!.timerImageTwoDefault = sceneImageTwoDefault
                existingTimer!.timerImageTwoCustom = sceneImageTwoCustom
            }
            
            existingTimer!.isBroadcast = isBroadcast
            existingTimer!.isLocalcast = isLocalcast
            
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func fetchTimerWithId(timerId: Int, gateway: Gateway, moduleAddress:Int) -> [Timer]{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Timer")
        let predicateLocation = NSPredicate(format: "timerId == %@", NSNumber(integer: timerId))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(integer: moduleAddress))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
            return fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return []
    }
    
    func deleteAllTimers(gateway:Gateway){
        let timers = gateway.timers.allObjects as! [Timer]
        for timer in timers {
            self.appDel.managedObjectContext!.deleteObject(timer)
        }
        
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func deleteTimer(timer:Timer){
        self.appDel.managedObjectContext!.deleteObject(timer)
        CoreDataController.shahredInstance.saveChanges()
    }
    
}
