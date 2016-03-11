//
//  CoreDataController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController: NSObject {
    var context:NSManagedObjectContext
    override init() {
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    }
    
    func fetchDevices (gateway:Gateway) -> [Device] {
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = fetchDevicesRequest(gateway)
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Device]
            return fetResults
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return []
    }
    func fetchDevicesRequest (gateway:Gateway) -> NSFetchRequest {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let predicate = NSPredicate(format: "gateway == %@", gateway.objectID)
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    func fetchSortedPCRequest (gatewayName:String, parentZone:Int, zone:Int, category:Int) -> NSFetchRequest {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
//        let predicate = NSPredicate(format: "gateway.name == %@", gatewayName)
        let predicateOne = NSPredicate(format: "type == %@", ControlType.PC)
//        let predicateArray = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateOne])
        let predicateArray = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne])
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicateArray
        return fetchRequest
    }
    func fetchPCController (gatewayName:String, parentZone:Int, zone:Int, category:Int) -> [Device] {
        let fetchRequest = fetchSortedPCRequest(gatewayName, parentZone:parentZone, zone:zone, category:category)
        do {
            let fetResults = try context.executeFetchRequest(fetchRequest) as! [Device]
            return fetResults
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return []
    }
}