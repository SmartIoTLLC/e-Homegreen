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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getGatewayByLocation(_ location:String) -> [Gateway]{
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
            var predicateArray:[NSPredicate] = [NSPredicate(format: "turnedOn == %@", NSNumber(value: true as Bool))]
            predicateArray.append(NSPredicate(format: "location.user == %@", user))
            predicateArray.append(NSPredicate(format: "location.name == %@", location))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Gateway]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    func getGatewayByLocationForSecurity(_ location:Location) -> [Gateway]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        var predicateArray:[NSPredicate] = [NSPredicate(format: "turnedOn == %@", NSNumber(value: true as Bool))]
        predicateArray.append(NSPredicate(format: "location.user == %@", location.user!))
        predicateArray.append(NSPredicate(format: "location == %@", location))
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Gateway]
            return fetResults!
        } catch _ as NSError {
            abort()
        }
        
        return []
    }
    
    func getGatewayByid(_ id:String) -> Gateway?{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        let predicateArray:[NSPredicate] = [NSPredicate(format: "gatewayId == %@", id)]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Gateway]
            if fetResults?.count != 0{
                return fetResults?.first
            }
        } catch _ as NSError {
            abort()
        }
        
        return nil
    }
    
    func getGatewayByObjectID(_ objectID:NSManagedObjectID) -> Gateway?{
        if let gateway = appDel.managedObjectContext?.object(with: objectID) as? Gateway {
            return gateway
        }
        return nil
    }
    
    func getGatewayByStringObjectID(_ objectId:String) -> Gateway?{
        if objectId != ""{
            if let url = URL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    do{
                        let gateway = try appDel.managedObjectContext?.existingObject(with: id) as? Gateway
                        return gateway
                    }catch {
                        
                    }
                }
            }
        }
        return nil
    }
    
    func deleteGateway(_ gateway:Gateway){
        appDel.managedObjectContext?.delete(gateway)
        CoreDataController.shahredInstance.saveChanges()
    }
    
}
