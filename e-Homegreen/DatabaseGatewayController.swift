//
//  DatabaseGatewayController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/14/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseGatewayController: NSObject {
    
    static let shared = DatabaseGatewayController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getGatewayByLocation(location:String) -> [Gateway]{
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
            var predicateArray:[NSPredicate] = [NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))]
            predicateArray.append(NSPredicate(format: "location.user == %@", user))
            predicateArray.append(NSPredicate(format: "location.name == %@", location))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    func getGatewayByLocationForSecurity(location:Location) -> [Gateway]{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
        var predicateArray:[NSPredicate] = [NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))]
        predicateArray.append(NSPredicate(format: "location.user == %@", location.user!))
        predicateArray.append(NSPredicate(format: "location == %@", location))
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
            return fetResults!
        } catch _ as NSError {
            abort()
        }
        
        return []
    }
    
    func getGatewayByid(id:String) -> Gateway?{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicateArray:[NSPredicate] = [NSPredicate(format: "gatewayId == %@", id)]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
            if fetResults?.count != 0{
                return fetResults?.first
            }
        } catch _ as NSError {
            abort()
        }
        
        return nil
    }
    
//    func getNextAvailableId() -> Int{
//        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
//        let sortDescriptorTwo = NSSortDescriptor(key: "gatewayId", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptorTwo]
//        do {
//            let fetchResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
//            if let last = fetchResults?.last{
//                if let id = last.gatewayId as? Int {
//                    return id + 1
//                }
//            }
//            
//        } catch _ as NSError {
//            abort()
//        }
//        return 1
//    }
    
    func getGatewayByObjectID(objectID:NSManagedObjectID) -> Gateway?{
        if let gateway = appDel.managedObjectContext?.objectWithID(objectID) as? Gateway {
            return gateway
        }
        return nil
    }
    
    func getGatewayByStringObjectID(objectId:String) -> Gateway?{
        if objectId != ""{
            if let url = NSURL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) {
                    do{
                        let gateway = try appDel.managedObjectContext?.existingObjectWithID(id) as? Gateway
                        return gateway
                    }catch {
                        
                    }
                }
            }
        }
        return nil
    }
    
    func deleteGateway(gateway:Gateway){
        appDel.managedObjectContext?.deleteObject(gateway)
        CoreDataController.shahredInstance.saveChanges()
    }
    
}
