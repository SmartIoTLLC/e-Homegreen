//
//  DatabaseEventsController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseEventsController: NSObject {
    
    static let shared = DatabaseEventsController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    func getEvents(filterParametar:FilterItem) -> [Event] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Event")
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "eventId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "eventName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))]
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            if filterParametar.location != "All" {
                predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location))
            }
            
            if filterParametar.levelObjectId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId){
                    predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!))
                }
            }
            if filterParametar.zoneObjectId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                    predicateArray.append(NSPredicate(format: "eventZoneId == %@", zone.id!))
                }
            }
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                    predicateArray.append(NSPredicate(format: "eventCategoryId == %@", category.id!))
                }
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    
    func updateEventList(gateway:Gateway, filterParametar:FilterItem) -> [Event] {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "eventId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "eventName", ascending: true)
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
                predicateArray.append(NSPredicate(format: "eventZoneId == %@", zone.id!))
            }
        }
        if filterParametar.categoryObjectId != "All" {
            if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                predicateArray.append(NSPredicate(format: "eventCategoryId == %@", category.id!))
            }
        }
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
            return fetResults!
        } catch{
        }
        return []
    }
    
    func createEvent(eventId: Int, eventName: String, moduleAddress: Int, gateway: Gateway, levelId: Int?, zoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "17 Event - Up Down - 00", sceneImageTwoDefault:String? = "17 Event - Up Down - 01", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:NSData? = nil, imageDataTwo:NSData? = nil, report:Bool = false){
        var itExists = false
        var existingEvent:Event?
        let eventsArray = fetchEventWithIdAndAddress(eventId, gateway: gateway, moduleAddress: moduleAddress)
        if eventsArray.count > 0 {
            existingEvent = eventsArray.first
            itExists = true
        }
        if !itExists {
            let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: appDel.managedObjectContext!) as! Event
            event.eventId = eventId
            event.eventName = eventName
            event.address = moduleAddress
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = NSUUID().UUIDString
                    event.eventImageOneCustom = image.imageId
                    event.eventImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                event.eventImageOneDefault = sceneImageOneDefault
                event.eventImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = NSUUID().UUIDString
                    event.eventImageTwoCustom = image.imageId
                    event.eventImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                event.eventImageTwoDefault = sceneImageTwoDefault
                event.eventImageTwoCustom = sceneImageTwoCustom
            }
            
            event.entityLevelId = levelId
            event.eventZoneId = zoneId
            event.eventCategoryId = categoryId
            
            event.isBroadcast = isBroadcast
            event.isLocalcast = isLocalcast
            
            event.report = report
            
            event.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            existingEvent!.eventName = eventName
            
            existingEvent!.entityLevelId = levelId
            existingEvent!.eventZoneId = zoneId
            existingEvent!.eventCategoryId = categoryId
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = NSUUID().UUIDString
                    existingEvent!.eventImageOneCustom = image.imageId
                    existingEvent!.eventImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                existingEvent!.eventImageOneDefault = sceneImageOneDefault
                existingEvent!.eventImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = NSUUID().UUIDString
                    existingEvent!.eventImageTwoCustom = image.imageId
                    existingEvent!.eventImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                existingEvent!.eventImageTwoDefault = sceneImageTwoDefault
                existingEvent!.eventImageTwoCustom = sceneImageTwoCustom
            }
            
            existingEvent!.isBroadcast = isBroadcast
            existingEvent!.isLocalcast = isLocalcast
            
            existingEvent!.report = report
            
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func fetchEventWithIdAndAddress(eventId: Int, gateway: Gateway, moduleAddress:Int) -> [Event]{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Event")
        let predicateLocation = NSPredicate(format: "eventId == %@", NSNumber(integer: eventId))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(integer: moduleAddress))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
            return fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return []
    }
    
    func deleteAllEvents(gateway:Gateway){
        let events = gateway.events.allObjects as! [Event]
        for event in events {
            self.appDel.managedObjectContext!.deleteObject(event)
        }
        
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func deleteEvent(event:Event){
        self.appDel.managedObjectContext!.deleteObject(event)
        CoreDataController.shahredInstance.saveChanges()
    }
}
