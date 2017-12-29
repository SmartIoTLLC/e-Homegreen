//
//  FilterController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/19/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class FilterController: NSObject {
    
    static let shared = FilterController()
    
    let prefs = Foundation.UserDefaults.standard
    
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getLocationByObjectId(_ objectId:String) -> Location? {
        if objectId != "" && objectId != "0" && objectId != "255" {
            if let url = URL(string: objectId) {
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    do {
                        let location = try appDel.managedObjectContext?.existingObject(with: id) as? Location
                        return location
                    } catch {}
                }
            }
        }
        return nil
    }
    
    func getZoneByObjectId(_ objectId:String) -> Zone? {
        if objectId != "" && objectId != "0" && objectId != "255" {
            if let url = URL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    do {
                        let zone = try appDel.managedObjectContext?.existingObject(with: id) as? Zone
                        return zone
                    } catch {}
                }
            }
        }
        return nil
    }
    
    func getCategoryByObjectId(_ objectId:String) -> Category? {
        if objectId != "" && objectId != "0" && objectId != "255" {
            if let url = URL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    do {
                        let category = try appDel.managedObjectContext?.existingObject(with: id) as? Category
                        return category
                    } catch {}
                }
            }
        }
        return nil
    }
    
    func getLocationForFilterByUser() -> [Location] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Location.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if AdminController.shared.isAdminLogged() { if let user = DatabaseUserController.shared.getOtherUser() { fetchRequest.predicate = NSPredicate(format: "user == %@", user) }
        } else { if let user = DatabaseUserController.shared.getLoggedUser() { fetchRequest.predicate = NSPredicate(format: "user == %@", user) } }
        
        do {
            let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Location]
            return results
        } catch {}
        
        return []
    }
    
    func getLevelsByLocation(_ location:Location) -> [Zone] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "level == %@", NSNumber(value: 0 as Int)))
        predicateArray.append(NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool)))
        predicateArray.append(NSPredicate(format: "location == %@", location))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        
        do {
            let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Zone]
            return results
        } catch {}
        
        return[]
    }
    
    func getZoneByLevel(_ location:Location, parentZone:Zone) -> [Zone] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        
        let predicateArray = [
            NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool)),
            NSPredicate(format: "location == %@", location),
            NSPredicate(format: "level != %@", NSNumber(value: 0 as Int)),
            NSPredicate(format: "level == %@", parentZone.id!)
        ]
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderId", ascending: true)]
        fetchRequest.predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: predicateArray
        )
        
        do {
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [Zone] {
                    return results
                }
            }
            
        } catch {}
        
        return []
        
    }
    
    func getCategoriesByLocation(_ location:Location) -> [Category] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        
        let predicateArray:[NSPredicate] = [
            NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool)),
            NSPredicate(format: "location == %@", location)
        ]
        
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: predicateArray
        )
        
        do {
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [Category] {
                    return results
                }
            }
            
        } catch {}
        
        return []
    }
    

}
