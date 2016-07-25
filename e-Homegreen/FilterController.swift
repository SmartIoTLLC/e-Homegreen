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
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getLocationByObjectId(objectId:String) -> Location?{
        if objectId != ""{
            if let url = NSURL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) {
                    if let location = appDel.managedObjectContext?.objectWithID(id) as? Location {
                        return location
                    }
                }
            }
        }
        return nil
    }
    
    func getZoneByObjectId(objectId:String) -> Zone?{
        if objectId != ""{
            if let url = NSURL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) {
                    if let zone = appDel.managedObjectContext?.objectWithID(id) as? Zone {
                        return zone
                    }
                }
            }
        }
        return nil
    }
    
    func getCategoryByObjectId(objectId:String) -> Category?{
        if objectId != ""{
            if let url = NSURL(string: objectId){
                if let id = appDel.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) {
                    if let category = appDel.managedObjectContext?.objectWithID(id) as? Category {
                        return category
                    }
                }
            }
        }
        return nil
    }
    
    func getLocationForFilterByUser() -> [Location]{
        let fetchRequest = NSFetchRequest(entityName: "Location")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if AdminController.shared.isAdminLogged(){
            if let user = DatabaseUserController.shared.getOtherUser(){
                fetchRequest.predicate = NSPredicate(format: "user == %@", user)
            }
        }else{
            if let user = DatabaseUserController.shared.getLoggedUser(){
                fetchRequest.predicate = NSPredicate(format: "user == %@", user)
            }
        }
        
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Location]
            return results
            //                let locationNames = results.map({ (let location) -> String in
            //                    if let name = location.name {
            //                        return name
            //                    }
            //                    return ""
            //                }).filter({ (let name) -> Bool in
            //                    return name != "" ? true : false
            //                }).sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
            
        } catch  {
        }
        return []
    }
    
    func getLevelsByLocation(location:Location) -> [Zone]{
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        var predicateArray:[NSPredicate] = []
        let predicateOne = NSPredicate(format: "level == %@", NSNumber(integer: 0))
        predicateArray.append(predicateOne)
        let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
        predicateArray.append(predicateTwo)
        let predicateThree = NSPredicate(format: "location == %@", location)
        predicateArray.append(predicateThree)
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            return results
        } catch {
            
        }
        return[]
    }
    
    func getZoneByLevel(location:Location, parentZone:Zone) -> [Zone]{
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        let predicateOne = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "location == %@", location)
        let predicateThree = NSPredicate(format: "level != %@", NSNumber(integer: 0))
        var predicateArray:[NSPredicate] = []
        predicateArray.append(predicateOne)
        predicateArray.append(predicateTwo)
        predicateArray.append(predicateThree)
        let predicate = NSPredicate(format: "level == %@", parentZone.id!)
        predicateArray.append(predicate)

        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
            return results
        } catch{
            
        }
        return []
        
    }
    
    func getCategoriesByLocation(location:Location) -> [Category]{
            let fetchRequest = NSFetchRequest(entityName: "Category")
            let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
            var predicateArray:[NSPredicate] = []
            let predicateTwo = NSPredicate(format: "location == %@", location)
            predicateArray.append(predicateTwo)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Category]
                return results
            } catch{
                
            }
        return []
    }
    

}
