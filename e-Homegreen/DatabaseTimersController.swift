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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getAllTimersSortedBy(_ sortDescripror: NSSortDescriptor) -> [Timer] {
        if let _ = DatabaseUserController.shared.loggedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
            
            fetchRequest.sortDescriptors = [sortDescripror]
            
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Timer]
                return fetResults!
            } catch {}
        }
        return []
    }
    
    func getTimers(_ filterParametar:FilterItem) -> [Timer] {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArrayOr:[NSPredicate] = [NSPredicate(format: "type != %@", NSNumber(value: TimerType.stopwatch.rawValue as Int))]
            predicateArrayOr.append(NSPredicate(format: "timerCategoryId != %@", NSNumber(value: 20 as Int)))
            let compoundPredicate1 = NSCompoundPredicate(orPredicateWithSubpredicates: predicateArrayOr)

            var predicateArrayAnd:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))]
            predicateArrayAnd.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            if filterParametar.location != "All" { predicateArrayAnd.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location)) }
            
            if filterParametar.levelObjectId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId) { predicateArrayAnd.append(NSPredicate(format: "entityLevelId == %@", level.id!)) }
            }
            if filterParametar.zoneObjectId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) { predicateArrayAnd.append(NSPredicate(format: "timeZoneId == %@", zone.id!)) }
            }
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) { predicateArrayAnd.append(NSPredicate(format: "timerCategoryId == %@", category.id!)) }
            }
            
            let compoundPredicate2 = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArrayAnd)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [compoundPredicate1, compoundPredicate2])
            fetchRequest.predicate = compoundPredicate
            
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Timer]
                return fetResults!
            } catch {}
        }
        return []
    }
    
    func updateTimerList(_ gateway:Gateway, filterParametar:FilterItem) -> [Timer] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway))
        
        if filterParametar.levelObjectId != "All" {
            if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId) { predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!)) }
        }
        if filterParametar.zoneObjectId != "All" {
            if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) { predicateArray.append(NSPredicate(format: "timeZoneId == %@", zone.id!)) }
        }
        if filterParametar.categoryObjectId != "All" {
            if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) { predicateArray.append(NSPredicate(format: "timerCategoryId == %@", category.id!)) }
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Timer]
            return fetResults!
        } catch {}
        
        return []
    }
    
    func getTimerByid(_ id:String) -> Timer?{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
        let predicateArray:[NSPredicate] = [NSPredicate(format: "id == %@", id)]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Timer]
            if fetResults?.count != 0 { return fetResults?.first }
            
        } catch {}
        
        return nil
    }
    
    func getUserTimers(_ location:Location) -> [Timer]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        
        var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))]
        predicateArray.append(NSPredicate(format: "gateway.location == %@", location))
        predicateArray.append(NSPredicate(format: "type == %@", NSNumber(value: TimerType.stopwatch.rawValue as Int)))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Timer]
            return fetResults!
        } catch {}
        
        return []
    }
    
    func getTimerByObjectID(_ objectID:NSManagedObjectID) -> Timer?{
        if let timer = appDel.managedObjectContext?.object(with: objectID) as? Timer { return timer }
        return nil
    }
    
    func getTimerByStringObjectID(_ objectId:String) -> Timer?{
        if objectId != ""{
            if let url = URL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    do {
                        let timer = try appDel.managedObjectContext?.existingObject(with: id) as? Timer
                        return timer
                    } catch {}
                }
            }
        }
        return nil
    }
    
    func startTImerOnLocation(_ timer:Timer){
        var address:[UInt8] = []
        if timer.isBroadcast.boolValue { address = [0xFF, 0xFF, 0xFF]
        } else if timer.isLocalcast.boolValue { address = [UInt8(Int(timer.gateway.addressOne)), UInt8(Int(timer.gateway.addressTwo)), 0xFF]
        } else { address = [UInt8(Int(timer.gateway.addressOne)), UInt8(Int(timer.gateway.addressTwo)), UInt8(Int(timer.address))] }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: UInt8(Int(timer.timerId)), command: 0x01), gateway: timer.gateway)
    }

    func addTimer(_ timerId: Int, timerName: String?, moduleAddress: Int, gateway: Gateway, type: Int?, levelId: Int?, selectedZoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "15 Timer - CLock - 00", sceneImageTwoDefault:String? = "15 Timer - CLock - 01", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:Data? = nil, imageDataTwo:Data? = nil){
        var itExists = false
        var existingTimer:Timer?
        let timerArray = fetchTimerWithId(timerId, gateway: gateway, moduleAddress: moduleAddress)
        if timerArray.count > 0 {
            existingTimer = timerArray.first
            itExists = true
        }
        
        if !itExists {
            let timer = NSEntityDescription.insertNewObject(forEntityName: "Timer", into: appDel.managedObjectContext!) as! Timer
            timer.timerId = NSNumber(value: timerId)
            if let timerName = timerName { timer.timerName = timerName } else { timer.timerName = "" }
            timer.address = NSNumber(value: moduleAddress)
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image {
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    timer.timerImageOneCustom = image.imageId
                    timer.timerImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            } else {
                timer.timerImageOneDefault = sceneImageOneDefault
                timer.timerImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    timer.timerImageTwoCustom = image.imageId
                    timer.timerImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            } else {
                timer.timerImageTwoDefault = sceneImageTwoDefault
                timer.timerImageTwoCustom = sceneImageTwoCustom
            }
            
            timer.entityLevelId = levelId as NSNumber?
            timer.timeZoneId = selectedZoneId as NSNumber?
            timer.timerCategoryId = categoryId as NSNumber?
            
            timer.isBroadcast = isBroadcast as NSNumber
            timer.isLocalcast = isLocalcast as NSNumber
            if let type = type{
                timer.type = NSNumber(value: type)
            } else {
                timer.type = 0
            }
            
            timer.id = UUID().uuidString
            timer.gateway = gateway
            CoreDataController.sharedInstance.saveChanges()
            
        } else {
            
            if let timerName = timerName { existingTimer!.timerName = timerName }
            
            existingTimer!.entityLevelId = levelId as NSNumber?
            existingTimer!.timeZoneId = selectedZoneId as NSNumber?
            existingTimer!.timerCategoryId = categoryId as NSNumber?
            
            if let type = type { existingTimer!.type = NSNumber(value: type) } else { existingTimer!.type = 0 }
            
            if let imageDataOne = imageDataOne {
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image {
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    existingTimer!.timerImageOneCustom = image.imageId
                    existingTimer!.timerImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            } else {
                existingTimer!.timerImageOneDefault = sceneImageOneDefault
                existingTimer!.timerImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo {
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image {
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    existingTimer!.timerImageTwoCustom = image.imageId
                    existingTimer!.timerImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            } else {
                existingTimer!.timerImageTwoDefault = sceneImageTwoDefault
                existingTimer!.timerImageTwoCustom = sceneImageTwoCustom
            }
            
            existingTimer!.isBroadcast = isBroadcast as NSNumber
            existingTimer!.isLocalcast = isLocalcast as NSNumber
            
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func fetchTimerWithId(_ timerId: Int, gateway: Gateway, moduleAddress:Int) -> [Timer] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
        let predicateLocation = NSPredicate(format: "timerId == %@", NSNumber(value: timerId as Int))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(value: moduleAddress as Int))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Timer]
            return fetResults!
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return []
    }
    
    func deleteAllTimers(_ gateway:Gateway){
        let timers = gateway.timers.allObjects as! [Timer]
        for timer in timers { self.appDel.managedObjectContext!.delete(timer) }
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func deleteTimer(_ timer:Timer){
        self.appDel.managedObjectContext!.delete(timer)
        CoreDataController.sharedInstance.saveChanges()
    }
    
}
