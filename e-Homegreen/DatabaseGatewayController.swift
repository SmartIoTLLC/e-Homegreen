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
    
    func getGatewayByLocation(_ location:String) -> [Gateway] {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "turnedOn == %@", NSNumber(value: true as Bool)),
                NSPredicate(format: "location.user == %@", user),
                NSPredicate(format: "location.name == %@", location)
            ]
            
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let fetResults = try moc.fetch(fetchRequest) as? [Gateway] {
                        return fetResults
                    }
                }
                
            } catch {}
        }
        return []
    }
    
    func getGatewayByLocationForSecurity(_ location:Location) -> [Gateway] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        let predicateArray = [
            NSPredicate(format: "turnedOn == %@", NSNumber(value: true as Bool)),
            NSPredicate(format: "location.user == %@", location.user!),
            NSPredicate(format: "location == %@", location)
        ]
        
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Gateway] {
                    return fetResults
                }
            }
        } catch {}
        
        return []
    }
    
    func getGatewayByid(_ id:String) -> Gateway? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "gatewayId == %@", id)])
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Gateway] {
                    if fetResults.count != 0 { return fetResults.first }
                }
            }

        } catch {}
        
        return nil
    }
    
    func getGatewayByObjectID(_ objectID:NSManagedObjectID) -> Gateway? {
        if let moc = appDel.managedObjectContext {
            if let gateway = moc.object(with: objectID) as? Gateway {
                return gateway
            }
        }
        return nil
    }
    
    func getGatewayByStringObjectID(_ objectId:String) -> Gateway? {
        if objectId != "" {
            if let url = URL(string: objectId) {
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    
                    do { return try appDel.managedObjectContext?.existingObject(with: id) as? Gateway
                    } catch {}
                }
            }
        }
        return nil
    }
    
    func deleteGateway(_ gateway:Gateway) {
        if let moc = appDel.managedObjectContext {
            moc.delete(gateway)
            CoreDataController.sharedInstance.saveChanges()
        }        
    }
    
}
