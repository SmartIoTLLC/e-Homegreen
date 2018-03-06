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
    
    func getLevelsByLocation(_ location:Location) -> [Zone] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        
        let predicateArray = [
            NSPredicate(format: "level == %@", NSNumber(value: 0 as Int)),
            NSPredicate(format: "location == %@", location)
        ]
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderId", ascending: true)]
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        
        do {
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [Zone] {
                    return results
                }
            }
            
        } catch {}
        
        return[]
    }
    
    func getZoneByLevel(_ location:Location, parentZone:Zone) -> [Zone]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        
        let predicateArray = [
            NSPredicate(format: "location == %@", location),
            NSPredicate(format: "level != %@", NSNumber(value: 0 as Int)),
            NSPredicate(format: "level == %@", parentZone.id!)
        ]
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderId", ascending: true)]
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        
        do {
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [Zone] {
                    return results
                }
            }
            
        } catch {}
        
        return []
        
    }
    
    func getZoneById(_ id:Int, location:Location) -> Zone? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        
        let predicateArray = [
            NSPredicate(format: "location == %@", location),
            NSPredicate(format: "id == %@", NSNumber(value: id))
        ]
        
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        
        do {
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [Zone] {
                    if results.count != 0 { return results[0] }
                }
            }
        } catch {}
        
        return nil
    }
    
    func changeAllowOption(_ option:Int, zone:Zone){
        zone.allowOption = option as NSNumber!
        CoreDataController.sharedInstance.saveChanges()
    }

}
