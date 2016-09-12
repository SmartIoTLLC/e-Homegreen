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
    
    func createEvent(eventId: Int, eventName: String, moduleAddress: Int, gateway: Gateway, levelId: Int?, zoneId: Int?, categoryId: Int?){
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
            
            event.eventImageOneCustom = nil
            event.eventImageTwoCustom = nil
            
            event.eventImageOneDefault = "17 Event - Up Down - 00"
            event.eventImageTwoDefault = "17 Event - Up Down - 01"
            
            event.entityLevelId = levelId
            event.eventZoneId = zoneId
            event.eventCategoryId = categoryId
            
            event.isBroadcast = true
            event.isLocalcast = true
            
            event.report = false
            
            event.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            existingEvent!.eventName = eventName
            
            existingEvent!.entityLevelId = levelId
            existingEvent!.eventZoneId = zoneId
            existingEvent!.eventCategoryId = categoryId
            
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
}
