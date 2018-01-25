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
    func createFilters(_ user:User) {
        if let moc = appDel.managedObjectContext {
            for item in Menu.allMenuItem {
                if item != Menu.settings {
                    if let filter = NSEntityDescription.insertNewObject(forEntityName: "FilterParametar", into: moc) as? FilterParametar {
                        filter.filterId      = NSNumber(value: item.rawValue)
                        filter.isDefault     = false
                        filter.locationId    = "All"
                        filter.levelId       = "All"
                        filter.zoneId        = "All"
                        filter.categoryId    = "All"
                        filter.timerDuration = 0
                        filter.user          = user
                    }
                    if let filter = NSEntityDescription.insertNewObject(forEntityName: "FilterParametar", into: moc) as? FilterParametar {
                        filter.filterId      = NSNumber(value: item.rawValue)
                        filter.isDefault     = true
                        filter.locationId    = "All"
                        filter.levelId       = "All"
                        filter.zoneId        = "All"
                        filter.categoryId    = "All"
                        filter.timerDuration = 0
                        filter.user          = user
                    }
                }
            }
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func saveFilter(_ filterItem:FilterItem, menu:Menu) {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)),
                NSPredicate(format: "isDefault == %@", NSNumber(value: false as Bool))
            ]
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let results = try moc.fetch(fetchRequest) as? [FilterParametar] {
                        if results.count != 0 {
                            results[0].locationId = filterItem.locationObjectId
                            results[0].levelId    = filterItem.levelObjectId
                            results[0].zoneId     = filterItem.zoneObjectId
                            results[0].categoryId = filterItem.categoryObjectId
                            CoreDataController.sharedInstance.saveChanges()
                        }
                    }

                }

            } catch {}
            
        }
    }
    
    func saveDeafultFilter(_ filterItem:FilterItem, menu:Menu, time: Int) {
        if let user = DatabaseUserController.shared.getLoggedUser() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)),
                NSPredicate(format: "isDefault == %@", NSNumber(value: true as Bool))
                                  ]
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let results = try moc.fetch(fetchRequest) as? [FilterParametar] {
                        if results.count != 0 {
                            results[0].locationId    = filterItem.locationObjectId
                            results[0].levelId       = filterItem.levelObjectId
                            results[0].zoneId        = filterItem.zoneObjectId
                            results[0].categoryId    = filterItem.categoryObjectId
                            results[0].timerDuration = NSNumber(value: time)
                            CoreDataController.sharedInstance.saveChanges()
                        }
                    }
                }
            } catch {}
            
        }
    }
    
    func getDeafultFilterTimeDuration(menu:Menu) -> Int {
        if let user = DatabaseUserController.shared.getLoggedUser() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)),
                NSPredicate(format: "isDefault == %@", NSNumber(value: true as Bool))
            ]
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let results = try moc.fetch(fetchRequest) as? [FilterParametar] {
                        if results.count != 0 { return Int(results[0].timerDuration) }
                    }
                }
            } catch {}
        }
        return 0
    }
    
    func getFilterByMenu(_ menu:Menu) -> FilterParametar? {
        
        if let user = DatabaseUserController.shared.getLoggedUser() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)),
                NSPredicate(format: "isDefault == %@", NSNumber(value: false as Bool))
            ]
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let results = try moc.fetch(fetchRequest) as? [FilterParametar] {
                        if results.count != 0 { return results[0] }
                    }
                }
                
            } catch {}
            
        }
        
        if let user = DatabaseUserController.shared.getOtherUser() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)),
                NSPredicate(format: "isDefault == %@", NSNumber(value: false as Bool))
            ]
            
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let results = try moc.fetch(fetchRequest) as? [FilterParametar] {
                        if results.count != 0 { return results[0] }
                    }
                }
            } catch {}
            
        }
        return nil
    }
    
    func getDefaultFilterByMenu(_ menu:Menu) -> FilterParametar? {
        if let user = DatabaseUserController.shared.getLoggedUser() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "filterId == %@", NSNumber(value: menu.rawValue as Int)),
                NSPredicate(format: "isDefault == %@", NSNumber(value: true as Bool))
                ]
            
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let results = try moc.fetch(fetchRequest) as? [FilterParametar] {
                        if results.count != 0 { return results[0] }
                    }
                }
            } catch {}
            
        }
        return nil
    }
}
