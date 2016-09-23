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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //create filter when create user
    func createFilters(_ user:User){
        for item in Menu.allMenuItem{
            if item != Menu.settings{
                if let filter = NSEntityDescription.insertNewObject(forEntityName: "FilterParametar", into: appDel.managedObjectContext!) as? FilterParametar{
                    filter.filterId = NSNumber(value: item.rawValue)
                    filter.isDefault = false
                    filter.locationId = "All"
                    filter.levelId = "All"
                    filter.zoneId = "All"
                    filter.categoryId = "All"
                    filter.user = user
                }
                if let filter = NSEntityDescription.insertNewObject(forEntityName: "FilterParametar", into: appDel.managedObjectContext!) as? FilterParametar{
                    filter.filterId = NSNumber(value: item.rawValue)
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
    
    func saveFilter(_ filterItem:FilterItem, menu:Menu){
        if let user = DatabaseUserController.shared.getLoggedUser(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(value: false as Bool)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [FilterParametar]
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
    
    func saveDeafultFilter(_ filterItem:FilterItem, menu:Menu){
        if let user = DatabaseUserController.shared.getLoggedUser(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(value: true as Bool)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [FilterParametar]
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
    
    func getFilterByMenu(_ menu:Menu) -> FilterParametar?{
        
        if let user = DatabaseUserController.shared.getLoggedUser(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(value: false as Bool)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [FilterParametar]
                if results.count != 0{
                    return results[0]
                }
            } catch {
                
            }            
        }
        if let user = DatabaseUserController.shared.getOtherUser(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(value: false as Bool)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [FilterParametar]
                if results.count != 0{
                    return results[0]
                }
            } catch {
                
            }
        }
        return nil
    }
    
    func getDefaultFilterByMenu(_ menu:Menu) -> FilterParametar?{
        if let user = DatabaseUserController.shared.getLoggedUser(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "user == %@", user))
            predicateArray.append(NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)))
            predicateArray.append(NSPredicate(format: "isDefault == %@", NSNumber(value: true as Bool)))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [FilterParametar]
                if results.count != 0{
                    return results[0]
                }
            } catch {
                
            }
        }
        return nil
    }
}
