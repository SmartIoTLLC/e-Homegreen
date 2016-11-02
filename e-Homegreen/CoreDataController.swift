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
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    override init() {
        context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext!
    }
    
    func fetchGatewaysForHost(_ host:String, port:UInt16) -> [Gateway]{
        var gateways: [Gateway] = []
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(value: true as Bool))
        let predicateTwo = NSPredicate(format: "remoteIpInUse == %@ AND remotePort == %@", host, NSNumber(value: port as UInt16))
        let predicateThree = NSPredicate(format: "localIp == %@ AND localPort == %@", host, NSNumber(value: port as UInt16))
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [predicateTwo,predicateThree])
        fetchRequest.predicate = NSCompoundPredicate(type:NSCompoundPredicate.LogicalType.and, subpredicates: [predicateOne,compoundPredicate])
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            if let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Gateway]{
                gateways = fetResults
            }
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return gateways
    }
    func fetchGatewayWithId(_ id: String) -> Gateway?{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        let predicateTwo = NSPredicate(format: "gatewayId = %@", id)
        fetchRequest.predicate = predicateTwo
        do {
            if let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Gateway]{
                if fetResults.count > 0{
                    return fetResults.first!
                }
            }
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return nil
    }
    func fetchDevicesForGateway(_ gateway: Gateway) -> [Device] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let predicate = NSPredicate(format: "gateway == %@", gateway.objectID)
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Device]
            return fetResults
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return []
    }
    func fetchDevicesByGatewayAndAddress(_ gateway: Gateway, address:NSNumber) -> [Device] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "address", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway == %@", gateway)]
        predicateArray.append(NSPredicate(format: "address == %@", address))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Device]
            return fetResults
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return []
    }
    func fetchSortedPCRequest (_ gatewayName:String, parentZone:Int, zone:Int, category:Int) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let predicateOne = NSPredicate(format: "type == %@", ControlType.PC)
        let predicateArray = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne])
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicateArray
        return fetchRequest
    }
    func fetchPCController (_ gatewayName:String, parentZone:Int, zone:Int, category:Int) -> [Device] {
        let fetchRequest = fetchSortedPCRequest(gatewayName, parentZone:parentZone, zone:zone, category:category)
        do {
            let fetResults = try context.fetch(fetchRequest) as! [Device]
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
            abort()
        }
    }
}
