//
//  DatabaseMenuController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/27/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseMenuController: NSObject {
    
    static let shared = DatabaseMenuController()
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //create menu when create user
    func createMenu(_ user:User){
        if let menu = user.menu?.allObjects as? [MenuItem]{
            for menuitem in menu{
                appDel.managedObjectContext?.delete(menuitem)
            }
        }
        if user.isSuperUser == true{
            for item in Menu.allMenuItem{
                if let menu = NSEntityDescription.insertNewObject(forEntityName: "MenuItem", into: appDel.managedObjectContext!) as? MenuItem{
                    menu.id = NSNumber(value: item.rawValue)
                    menu.orderId = NSNumber(value: item.rawValue)
                    menu.isVisible = true
                    menu.user = user
                    CoreDataController.shahredInstance.saveChanges()
                }
            }
        }else{
            for item in Menu.allMenuItemNotSuperUser{
                if let menu = NSEntityDescription.insertNewObject(forEntityName: "MenuItem", into: appDel.managedObjectContext!) as? MenuItem{
                    menu.id = NSNumber(value: item.rawValue)
                    menu.orderId = NSNumber(value: item.rawValue)
                    menu.isVisible = true
                    menu.user = user
                    CoreDataController.shahredInstance.saveChanges()
                }
            }
        }
    }
    
    //menu for admin
    func createMenuForAdmin() -> [MenuItem]{
        var menuList:[MenuItem] = []
        if let entity = NSEntityDescription.entity(forEntityName: "MenuItem", in: appDel.managedObjectContext!){
            for item in Menu.allMenuItem{
                if let menu = NSManagedObject.init(entity: entity, insertInto: nil) as? MenuItem{
                    menu.id = NSNumber(value: item.rawValue)
                    menu.orderId = NSNumber(value: item.rawValue)
                menu.isVisible = true
                    menuList.append(menu)
                }
            }
        }
        return menuList
        
    }
    
    func getVisibleMenuItemByUser(_ user:User) -> [MenuItem]{
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MenuItem.fetchRequest()
            let sortDescriptorOne = NSSortDescriptor(key: "orderId", ascending: true)
            var predicateArray:[NSPredicate] = [NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool))]
            predicateArray.append(NSPredicate(format: "user == %@", user))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.sortDescriptors = [sortDescriptorOne]
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [MenuItem]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
            return []
    }
    
    func getDefaultMenuItemByUser(_ user:User) -> [MenuItem]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MenuItem.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "id", ascending: true)
        let predicateArray:[NSPredicate] = [NSPredicate(format: "user == %@", user)]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptorOne]
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [MenuItem]
            return fetResults!
        } catch _ as NSError {
            abort()
        }
        return []
    }
    
    func getMenuItemByUser(_ user:User) -> [MenuItem]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MenuItem.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "orderId", ascending: true)
        let predicateArray:[NSPredicate] = [NSPredicate(format: "user == %@", user)]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptorOne]
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [MenuItem]
            return fetResults!
        } catch _ as NSError {
            abort()
        }
        return []
    }
    
    func changeOrder(_ menu:[MenuItem], user:User){
        let tempMenu = getMenuItemByUser(user)
        for (tempIndex,tempItem) in tempMenu.enumerated(){
            var exist = false
            for (index,item) in menu.enumerated(){
                if tempItem.id == item.id && tempItem.id != 13{
                    tempItem.orderId = NSNumber(value: index)
                    exist = true
                }
            }
            if !exist && tempItem.id != 13{
                tempItem.orderId = NSNumber(value: tempIndex)
            }
        }
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func changeState(_ menuItem:MenuItem){
        if menuItem.isVisible == true{
            menuItem.isVisible = false
        }else{
            menuItem.isVisible = true
        }        
        CoreDataController.shahredInstance.saveChanges()
    }

}
