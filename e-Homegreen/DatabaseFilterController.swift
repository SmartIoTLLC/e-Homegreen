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
    
    func saveDefaultFilterForAllTabs(_ filterItem:FilterItem, time: Int) {
        if let moc = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            if let user = DatabaseUserController.shared.getLoggedUser() {
                
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
                
                let predicateArray = [
                    NSPredicate(format: "user == %@", user),
                    NSPredicate(format: "isDefaultForAllTabs == true")
                ]
                
                let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
                fetchRequest.predicate = compoundPredicate
                
                do {
                    if let results = try moc.fetch(fetchRequest) as? [FilterParametar] {
                        if let existingFilter = results.first {
                            if results.count != 0 {
                                existingFilter.locationId    = filterItem.locationObjectId
                                existingFilter.levelId       = filterItem.levelObjectId
                                existingFilter.zoneId        = filterItem.zoneObjectId
                                existingFilter.categoryId    = filterItem.categoryObjectId
                                existingFilter.timerDuration = NSNumber(value: time)
                            }
                        } else {
                            let newDefaultFilter = FilterParametar(context: moc)
                            newDefaultFilter.locationId          = filterItem.locationObjectId
                            newDefaultFilter.levelId             = filterItem.levelObjectId
                            newDefaultFilter.zoneId              = filterItem.zoneObjectId
                            newDefaultFilter.categoryId          = filterItem.categoryObjectId
                            newDefaultFilter.timerDuration       = NSNumber(value: time)
                            newDefaultFilter.isDefaultForAllTabs = true
                            newDefaultFilter.isDefault           = NSNumber(value: true as Bool)
                        }
                        CoreDataController.sharedInstance.saveChanges()
                    }
                } catch {}
                
            }
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
                        if results.count != 0 { return results[0].timerDuration.intValue }
                    }
                }
            } catch {}
        }
        return 0
    }
    
    func getDefaultFilterParameterForAllTabs() -> FilterParametar? {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FilterParametar.fetchRequest()
            
            let predicateArray = [
                NSPredicate(format: "user == %@", user),
                NSPredicate(format: "isDefaultForAllTabs == true")
            ]
            
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let results = try moc.fetch(fetchRequest) as? [FilterParametar] {
                        if let filter = results.first { return filter }
                    }
                }
                
            } catch {}
        }
        return nil
    }
    
    func getDefaultFilterItemForAllTabs() -> FilterItem? {
        if let filterParameter = getDefaultFilterParameterForAllTabs() {
            
            let filterItem = FilterItem(location: "All", levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")
            if filterParameter.locationId != "All" {
                if let location = FilterController.shared.getLocationByObjectId(filterParameter.locationId)?.name { filterItem.location = location }
            }
            
            if filterParameter.levelId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParameter.levelId) {
                    filterItem.levelName = level.name ?? "All"
                    filterItem.levelId = level.id?.intValue ?? 0
                }
                
            }
            
            if filterParameter.zoneId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParameter.zoneId) {
                    filterItem.zoneName = zone.name ?? "All"
                    filterItem.zoneId = zone.id?.intValue ?? 0
                }
            }
            
            if filterParameter.categoryId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParameter.categoryId) {
                    filterItem.categoryName = category.name ?? "All"
                    filterItem.categoryId = category.id?.intValue ?? 0
                }
            }
            
            return filterItem
        }
        return nil
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
