//
//  DatabaseZoneController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/19/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseZoneController: NSObject {
    
    static let shared = DatabaseZoneController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getLevels(location:Location) -> [Zone]{
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        
        var predicateArray:[NSPredicate] = [NSPredicate(format: "level == %@", NSNumber(integer: 0))]
        predicateArray.append(NSPredicate(format: "isVisible == %@", NSNumber(bool: true)))
        predicateArray.append(NSPredicate(format: "location.name == %@", location.name!))
        predicateArray.append(NSPredicate(format: "location.user == %@", location.user!))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            return results
        } catch _ as NSError {
            
        }
        return []
    }
    
    func getZonesOnLevel(location:Location, levelId:Int) -> [Zone]{
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        var predicateArray:[NSPredicate] = [NSPredicate(format: "isVisible == %@", NSNumber(bool: true))]
        predicateArray.append(NSPredicate(format: "location == %@", location))
        predicateArray.append(NSPredicate(format: "level != %@", NSNumber(integer: 0)))
        predicateArray.append(NSPredicate(format: "location.user == %@", location.user!))

        predicateArray.append(NSPredicate(format: "level == %@", NSNumber(integer: levelId)))

        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            return results
        } catch _ as NSError {
            
        }
        return []
    }
    
    func getZoneById(id:Int, location:Location) -> Zone? {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        
        var predicateArray:[NSPredicate] = [NSPredicate(format: "isVisible == %@", NSNumber(bool: true))]
        predicateArray.append(NSPredicate(format: "location == %@", location))
        predicateArray.append(NSPredicate(format: "id == %@", NSNumber(integer: id)))        
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            if results.count != 0{
                return results[0]
            }
        } catch _ as NSError {
            
        }
        return nil
    }
    
    func getZone(objectId:NSManagedObjectID) -> Zone?{
        if let zone = appDel.managedObjectContext?.objectWithID(objectId) as? Zone {
            return zone
        }
        return nil
    }
    
    func changeAllowOption(option:Int, zone:Zone){
        zone.allowOption = option
        CoreDataController.shahredInstance.saveChanges()
    }

}
