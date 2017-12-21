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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    func getEvents(_ filterParametar:FilterItem) -> [Event] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "eventId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "eventName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))]
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
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Event]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    
    func updateEventList(_ gateway:Gateway, filterParametar:FilterItem) -> [Event] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
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
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Event]
            return fetResults!
        } catch{
        }
        return []
    }
    
    func createEvent(_ eventId: Int, eventName: String, moduleAddress: Int, gateway: Gateway, levelId: Int?, zoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "17 Event - Up Down - 00", sceneImageTwoDefault:String? = "17 Event - Up Down - 01", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:Data? = nil, imageDataTwo:Data? = nil, report:Bool = false){
        var itExists = false
        var existingEvent:Event?
        let eventsArray = fetchEventWithIdAndAddress(eventId, gateway: gateway, moduleAddress: moduleAddress)
        if eventsArray.count > 0 {
            existingEvent = eventsArray.first
            itExists = true
        }
        if !itExists {
            let event = NSEntityDescription.insertNewObject(forEntityName: "Event", into: appDel.managedObjectContext!) as! Event
            event.eventId = NSNumber(value: eventId)
            event.eventName = eventName
            event.address = NSNumber(value: moduleAddress)
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    event.eventImageOneCustom = image.imageId
                    event.eventImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                event.eventImageOneDefault = sceneImageOneDefault
                event.eventImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    event.eventImageTwoCustom = image.imageId
                    event.eventImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                event.eventImageTwoDefault = sceneImageTwoDefault
                event.eventImageTwoCustom = sceneImageTwoCustom
            }
            
            event.entityLevelId = levelId as NSNumber?
            event.eventZoneId = zoneId as NSNumber?
            event.eventCategoryId = categoryId as NSNumber?
            
            event.isBroadcast = isBroadcast as NSNumber
            event.isLocalcast = isLocalcast as NSNumber
            
            event.report = report as NSNumber
            
            event.gateway = gateway
            CoreDataController.sharedInstance.saveChanges()
            
        } else {
            
            existingEvent!.eventName = eventName
            
            existingEvent!.entityLevelId = levelId as NSNumber?
            existingEvent!.eventZoneId = zoneId as NSNumber?
            existingEvent!.eventCategoryId = categoryId as NSNumber?
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    existingEvent!.eventImageOneCustom = image.imageId
                    existingEvent!.eventImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                existingEvent!.eventImageOneDefault = sceneImageOneDefault
                existingEvent!.eventImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    existingEvent!.eventImageTwoCustom = image.imageId
                    existingEvent!.eventImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                existingEvent!.eventImageTwoDefault = sceneImageTwoDefault
                existingEvent!.eventImageTwoCustom = sceneImageTwoCustom
            }
            
            existingEvent!.isBroadcast = isBroadcast as NSNumber
            existingEvent!.isLocalcast = isLocalcast as NSNumber
            
            existingEvent!.report = report as NSNumber
            
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func fetchEventWithIdAndAddress(_ eventId: Int, gateway: Gateway, moduleAddress:Int) -> [Event]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
        let predicateLocation = NSPredicate(format: "eventId == %@", NSNumber(value: eventId as Int))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(value: moduleAddress as Int))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Event]
            return fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return []
    }
    
    func deleteAllEvents(_ gateway:Gateway){
        let events = gateway.events.allObjects as! [Event]
        for event in events {
            self.appDel.managedObjectContext!.delete(event)
        }
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func deleteEvent(_ event:Event){
        self.appDel.managedObjectContext!.delete(event)
        CoreDataController.sharedInstance.saveChanges()
    }
}
