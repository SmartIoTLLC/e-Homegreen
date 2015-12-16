//
//  DatabaseHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/1/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseHandler: NSObject {
    
    class func returnCategoryWithId(id:Int, gateway:Gateway) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicateOne = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let predicateTwo = NSPredicate(format: "gateway == %@", gateway)
        let predicateArray = [predicateOne, predicateTwo]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    class func returnZoneWithId(id:Int, gateway:Gateway) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicateOne = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let predicateTwo = NSPredicate(format: "gateway == %@", gateway)
        let predicateArray = [predicateOne, predicateTwo]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    class func returnLevelWithId(id:Int, gateway:Gateway) -> Zone? {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicateOne = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let predicateTwo = NSPredicate(format: "gateway == %@", gateway)
        let predicateArray = [predicateOne, predicateTwo]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return fetResults![0]
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return nil
    }
    
    class func returnCategoryIdWithName(name:String, gateway:Gateway) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicateOne = NSPredicate(format: "name == %@", name)
        let predicateTwo = NSPredicate(format: "gateway.objectID == %@", gateway.objectID)
        let predicateArray = [predicateOne, predicateTwo]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                return "\(fetResults![0].id)"
            } else {
                return "\(name)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    class func returnZoneIdWithName (name:String, gateway:Gateway) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicateOne = NSPredicate(format: "name == %@", name)
        let predicateTwo = NSPredicate(format: "gateway.objectID == %@", gateway.objectID)
        let predicateArray = [predicateOne, predicateTwo]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].id)"
            } else {
                return "\(name)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    class func returnZoneIdWithName (name:String) -> Int {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return Int(fetResults![0].id)
            } else {
                return -1
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return -1
    }
}
