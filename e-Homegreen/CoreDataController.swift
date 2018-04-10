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
    //var context:NSManagedObjectContext
    static let sharedInstance = CoreDataController()
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override init() {
        //context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!
    }
    
    func fetchGatewaysForHost(_ host:String, port:UInt16) -> [Gateway] {
        var gateways: [Gateway] = []
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        
        let predicateOne   = NSPredicate(format: "turnedOn == %@", NSNumber(value: true as Bool))
        let predicateTwo   = NSPredicate(format: "remoteIpInUse == %@ AND remotePort == %@", host, NSNumber(value: port as UInt16))
        let predicateThree = NSPredicate(format: "localIp == %@ AND localPort == %@", host, NSNumber(value: port as UInt16))
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [predicateTwo,predicateThree])
        fetchRequest.predicate = NSCompoundPredicate(type:NSCompoundPredicate.LogicalType.and, subpredicates: [predicateOne,compoundPredicate])
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Gateway] {
                    gateways = fetResults
                }
            }
            
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return gateways
    }
    
    func fetchGatewayWithId(_ id: String) -> Gateway? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        let predicateTwo = NSPredicate(format: "gatewayId = %@", id)
        fetchRequest.predicate = predicateTwo
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Gateway] {
                    if let gateway = fetResults.first {
                        return gateway
                    }
                }
            }
            
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return nil
    }
    
    func fetchDevicesForGateway(_ gateway: Gateway) -> [Device] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let predicate = NSPredicate(format: "gateway == %@", gateway.objectID)
        let sortDescriptorOne   = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo   = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour  = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicate
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Device] {
                    return fetResults
                }
            }
            
        } catch let error as NSError { print("Unresolved error \(error), \(error.userInfo)") }
        
        return []
    }
    
    func fetchDevicesByGatewayAndAddress(_ gateway: Gateway, address:NSNumber) -> [Device] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "address", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicateArray = [
            NSPredicate(format: "gateway == %@", gateway),
            NSPredicate(format: "address == %@", address)
        ]
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Device] {
                    return fetResults
                }
            }
            
        } catch let error as NSError { print("Unresolved error \(error), \(error.userInfo)") }
        
        return []
    }
    
    func fetchDeviceByGatewayAndAddressAndChannel(_ gateway: Gateway, address:NSNumber, channel: NSNumber) -> Device? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "address", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicateArray = [
            NSPredicate(format: "gateway == %@", gateway),
            NSPredicate(format: "address == %@", address),
            NSPredicate(format: "channel == %@", channel)
        ]
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Device] {
                    return fetResults.first
                }
            }
            
        } catch let error as NSError { print("Unresolved error \(error), \(error.userInfo)") }
        
        return nil
    }
    
    func fetchSortedPCRequest (_ gatewayName:String, parentZone:Int, zone:Int, category:Int) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let predicateOne = NSPredicate(format: "type == %@", ControlType.PC)
        let predicateArray = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne])
        
        let sortDescriptorOne   = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo   = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour  = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicateArray
        return fetchRequest
    }
    
    func fetchPCController (_ gatewayName:String, parentZone:Int, zone:Int, category:Int) -> [Device] {
        let fetchRequest = fetchSortedPCRequest(gatewayName, parentZone:parentZone, zone:zone, category:category)
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Device] {
                    return fetResults
                }
            }
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)") }
        
        return []
    }
    
    func saveChanges() {
        do {
            if let moc = appDel.managedObjectContext {
                try moc.save()
            }
        } catch let error1 as NSError { let error = error1; print("Unresolved error \(error), \(error.userInfo)")
            if let moc = appDel.managedObjectContext {
                moc.rollback()
            }
        }
    }
    
}
