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
    
    class func returnCategoryWithId(id:Int, location:Location) -> String {
        // 255: default
        // 0: when there is no category defined
        if id == 255 || id == 0{
            return "All"
        }else{
            let fetchRequest = NSFetchRequest(entityName: "Category")
            let predicateOne = NSPredicate(format: "id == %@", NSNumber(integer: id))
            let predicateTwo = NSPredicate(format: "location == %@", location)
            let predicateArray = [predicateOne, predicateTwo]
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
                if fetResults!.count != 0 {
                    if let name = fetResults![0].name{
                        return name
                    }else{
                        return ""
                    }
                    
                } else {
                    return ""
                }
            } catch _ as NSError {
                print("Unresolved error")
                abort()
            }
            return ""
        }
    }
    class func returnCategoryWithIdForScanDevicesCell(id:Int, location:Location) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicateOne = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let predicateTwo = NSPredicate(format: "location == %@", location)
        let predicateArray = [predicateOne, predicateTwo]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                if let name = fetResults![0].name{
                    return name
                }else{
                    return ""
                }
            } else {
                return ""
            }
        } catch _ as NSError {
            print("Unresolved error")
        }
        return ""
    }
    
    class func returnZoneWithId(id:Int, location:Location) -> Zone? {
        // 255: default
        // 0: when there is no zone defined
        if id == 255 || id == 0{
            return nil
        }else{
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let predicateOne = NSPredicate(format: "id == %@", NSNumber(integer: id))
            let predicateTwo = NSPredicate(format: "location == %@", location)
            let predicateArray = [predicateOne, predicateTwo]
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
                if fetResults!.count != 0 {
                    return fetResults?.first
//                    if fetResults![0].name! != "All"{
//                        return "\(fetResults![0].name!)"
//                    }
                } else {
                    return nil
                }
            } catch _ as NSError {
                print("Unresolved error")
                abort()
            }
            return nil
        }
    }
    class func returnZoneWithIdForScanDevicesCell(id:Int, location:Location) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicateOne = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let predicateTwo = NSPredicate(format: "location == %@", location)
        let predicateArray = [predicateOne, predicateTwo]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name!)"
            } else {
                return ""
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    class func returnLevelWithId(id:Int, location:Location) -> Zone? {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicateOne = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let predicateTwo = NSPredicate(format: "location == %@", location)
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
    
    class func returnCategoryIdWithName(name:String, location:Location) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicateOne = NSPredicate(format: "name == %@", name)
        let predicateTwo = NSPredicate(format: "location == %@", location)
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
    
    class func returnZoneIdWithName (name:String, location:Location) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicateOne = NSPredicate(format: "name == %@", name)
        let predicateTwo = NSPredicate(format: "location == %@", location)
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
                return Int(fetResults![0].id!)
            } else {
                return 255
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return -1
    }
    
    
}
