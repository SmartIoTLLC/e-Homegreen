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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getLevelsByLocation(_ location:Location) -> [Zone]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "level == %@", NSNumber(value: 0 as Int)))
        predicateArray.append(NSPredicate(format: "location == %@", location))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Zone]
            return results
        } catch {
            
        }
        return[]
    }
    
    func getZoneByLevel(_ location:Location, parentZone:Zone) -> [Zone]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "location == %@", location))
        predicateArray.append(NSPredicate(format: "level != %@", NSNumber(value: 0 as Int)))
        predicateArray.append(NSPredicate(format: "level == %@", parentZone.id!))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        
        do {
            let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Zone]
            return results
        } catch{
            
        }
        return []
        
    }
    
    func getZoneById(_ id:Int, location:Location) -> Zone? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "location == %@", location))
        predicateArray.append(NSPredicate(format: "id == %@", NSNumber(value: id as Int)))        
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Zone]
            if results.count != 0{
                return results[0]
            }
        } catch _ as NSError {
            
        }
        return nil
    }
    
    func changeAllowOption(_ option:Int, zone:Zone){
        zone.allowOption = option as NSNumber!
        CoreDataController.shahredInstance.saveChanges()
    }

}
