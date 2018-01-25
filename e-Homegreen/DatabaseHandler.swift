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
    var appDel:AppDelegate! = UIApplication.shared.delegate as! AppDelegate
    
    static let sharedInstance = DatabaseHandler()
    
    func returnCategoryWithId(_ id:Int, location:Location) -> String {
        // 255: default
        // 0: when there is no category defined
        if id == 255 || id == 0 {
            return "All"
        } else {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "id == %@", NSNumber(value: id as Int)) ,
                NSPredicate(format: "location == %@", location)
            ]
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let fetResults = try moc.fetch(fetchRequest) as? [Category] {
                        if fetResults.count != 0 {
                            if let name = fetResults[0].name { return name } else { return "" }
                            
                        } else {  return "" }
                    }
                }
                
            } catch _ as NSError { print("Unresolved error") }
            
            return ""
        }
    }
    func returnCategoryWithIdForScanDevicesCell(_ id:Int, location:Location) -> String {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        
        let predicateArray = [
            NSPredicate(format: "id == %@", NSNumber(value: id as Int)),
            NSPredicate(format: "location == %@", location)
        ]
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Category] {
                    if fetResults.count != 0 {
                        if let name = fetResults[0].name { return name } else { return "" }
                    } else { return "" }
                }
            }
            
        } catch { print("Unresolved error") }
        
        return ""
    }
    
    func returnZoneWithId(_ id:Int, location:Location) -> Zone? {
        // 255: default
        // 0: when there is no zone defined
        if id == 255 || id == 0{
            return nil
        } else {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()

            let predicateArray = [
                NSPredicate(format: "id == %@", NSNumber(value: id as Int)),
                NSPredicate(format: "location == %@", location)
            ]
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let fetResults = try moc.fetch(fetchRequest) as? [Zone] {
                        if fetResults.count != 0 { return fetResults.first } else { return nil }
                    }
                }
                
            } catch { print("Unresolved error") }
            
            return nil
        }
    }
    
    func returnZoneWithIdForScanDevicesCell(_ id:Int, location:Location) -> String {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()

        let predicateArray = [
            NSPredicate(format: "id == %@", NSNumber(value: id as Int)),
            NSPredicate(format: "location == %@", location)
        ]
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Zone] {
                    if fetResults.count != 0 { return "\(fetResults[0].name!)" } else { return "" }
                }
            }
        } catch { print("Unresolved error") }
        
        return ""
    }
    
    func returnLevelWithId(_ id:Int, location:Location) -> Zone? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()

        let predicateArray = [
            NSPredicate(format: "id == %@", NSNumber(value: id as Int)),
            NSPredicate(format: "location == %@", location)
        ]
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Zone] {
                    if fetResults.count != 0 { return fetResults[0] }
                }
            }
            
        } catch { print("Unresolved error") }
        
        return nil
    }
    
    func returnCategoryIdWithName(_ name:String, location:Location) -> String {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        
        let predicateArray = [
            NSPredicate(format: "name == %@", name),
            NSPredicate(format: "location == %@", location)
        ]
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Category] {
                    if fetResults.count != 0 { return "\(fetResults[0].id!)" } else { return "\(name)" }
                }
            }
            
        } catch { print("Unresolved error") }
        
        return ""
    }
    
    func returnZoneIdWithName (_ name:String, location:Location) -> String {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()

        let predicateArray = [
            NSPredicate(format: "name == %@", name),
            NSPredicate(format: "location == %@", location)
        ]
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Zone] {
                    if fetResults.count != 0 { return "\(fetResults[0].id!)" } else { return "\(name)" }
                }
            }
            
        } catch { print("Unresolved error") }
        
        return ""
    }
    
    func returnZoneIdWithName (_ name:String) -> Int {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Zone] {
                    if fetResults.count != 0 { return Int(fetResults[0].id!) } else { return 255 }
                }
            }
        } catch { print("Unresolved error") }
        
        return -1
    }
    
    func returnGatewayWithAddress(_ address1: Int, address2: Int, address3: Int) -> [Gateway]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Gateway.fetchRequest()
        let predicate1 = NSPredicate(format: "addressOne = %@", argumentArray: [address2])
        
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1])//, predicate2, predicate3])
        fetchRequest.predicate = combinedPredicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Gateway] {
                    return fetResults
                } 
            }
            
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return []
    }
    
    func fetchZonesWithLocationId(_ locationId: Location) -> [Zone] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", locationId)
        fetchRequest.predicate = predicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Zone] {
                    return fetResults
                }
            }
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return []
    }
    func fetchCategoriesWithLocationId(_ locationId: Location) -> [Category] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", locationId)
        fetchRequest.predicate = predicate
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Category] {
                    return fetResults
                }
            }
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return []
    }
    
    func fetchTimers() -> [Timer]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Timer] {
                    return fetResults
                }
            }
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return []
    }
}
