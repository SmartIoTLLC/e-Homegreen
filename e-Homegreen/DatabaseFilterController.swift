//
//  DatabaseFilterController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/25/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseFilterController: NSObject {

    static let shared = DatabaseFilterController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //create filter when create user
    func createFilters(user:User){
        for item in Menu.allMenuItem{
            if item != Menu.Settings{
                if let filter = NSEntityDescription.insertNewObjectForEntityForName("FilterParametar", inManagedObjectContext: appDel.managedObjectContext!) as? FilterParametar{
                    filter.filterId = item.rawValue
                    filter.isDefault = false
                    filter.locationId = "All"
                    filter.levelId = "All"
                    filter.zoneId = "All"
                    filter.categoryId = "All"
                    filter.user = user
                }
                if let filter = NSEntityDescription.insertNewObjectForEntityForName("FilterParametar", inManagedObjectContext: appDel.managedObjectContext!) as? FilterParametar{
                    filter.filterId = item.rawValue
                    filter.isDefault = true
                    filter.locationId = "All"
                    filter.levelId = "All"
                    filter.zoneId = "All"
                    filter.categoryId = "All"
                    filter.user = user
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func saveFilter(filterItem:FilterItem, menu:Menu){
        if let user = DatabaseUserController.shared.getLoggedUser(){
            let fetchRequest = NSFetchRequest(entityName: "FilterParametar")
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(integer: menu.rawValue)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(bool: false)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [FilterParametar]
                if results.count != 0{
                    results[0].locationId = filterItem.locationObjectId
                    results[0].levelId = filterItem.levelObjectId
                    results[0].zoneId = filterItem.zoneObjectId
                    results[0].categoryId = filterItem.categoryObjectId
                    CoreDataController.shahredInstance.saveChanges()
                }
            } catch {
                
            }
            
        }
    }
    
    func saveDeafultFilter(filterItem:FilterItem, menu:Menu){
        if let user = DatabaseUserController.shared.getLoggedUser(){
            let fetchRequest = NSFetchRequest(entityName: "FilterParametar")
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(integer: menu.rawValue)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(bool: true)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [FilterParametar]
                if results.count != 0{
                    results[0].locationId = filterItem.locationObjectId
                    results[0].levelId = filterItem.levelObjectId
                    results[0].zoneId = filterItem.zoneObjectId
                    results[0].categoryId = filterItem.categoryObjectId
                    CoreDataController.shahredInstance.saveChanges()
                }
            } catch {
                
            }
            
        }
    }
    
    func getFilterByMenu(menu:Menu) -> FilterParametar?{
        if let user = DatabaseUserController.shared.getLoggedUser(){
            let fetchRequest = NSFetchRequest(entityName: "FilterParametar")
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(integer: menu.rawValue)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(bool: false)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [FilterParametar]
                if results.count != 0{
                    return results[0]
                }
            } catch {
                
            }            
        }
        return nil
    }
    
    func getDefaultFilterByMenu(menu:Menu) -> FilterParametar?{
        if let user = DatabaseUserController.shared.getLoggedUser(){
            let fetchRequest = NSFetchRequest(entityName: "FilterParametar")
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(integer: menu.rawValue)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(bool: true)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [FilterParametar]
                if results.count != 0{
                    return results[0]
                }
            } catch {
                
            }
        }
        return nil
    }
}
