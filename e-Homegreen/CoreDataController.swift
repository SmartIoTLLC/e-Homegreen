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
    static let shahredInstance = CoreDataController()
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override init() {
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    }
    
    func fetchGatewaysForHost(host:String, port:UInt16) -> [Gateway]{
        var gateways: [Gateway] = []
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "remoteIpInUse == %@ AND remotePort == %@", host, NSNumber(unsignedShort: port))
        let predicateThree = NSPredicate(format: "localIp == %@ AND localPort == %@", host, NSNumber(unsignedShort: port))
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicateTwo,predicateThree])
        fetchRequest.predicate = NSCompoundPredicate(type:NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne,compoundPredicate])
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            if let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]{
                gateways = fetResults
            }
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return gateways
    }
    func fetchDevicesForGateway(gateway: Gateway) -> [Device] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        let predicate = NSPredicate(format: "gateway == %@", gateway.objectID)
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Device]
            return fetResults
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return []
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
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            let error = error1
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}