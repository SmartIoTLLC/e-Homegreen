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
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //create menu when create user
    func createMenu(user:User){
        if let menu = user.menu?.allObjects as? [MenuItem]{
            for menuitem in menu{
                appDel.managedObjectContext?.deleteObject(menuitem)
            }
        }
        if user.isSuperUser == true{
            for item in Menu.allMenuItem{
                if let menu = NSEntityDescription.insertNewObjectForEntityForName("MenuItem", inManagedObjectContext: appDel.managedObjectContext!) as? MenuItem{
                    menu.id = item.rawValue
                    menu.orderId = item.rawValue
                    menu.isVisible = true
                    menu.user = user
                    CoreDataController.shahredInstance.saveChanges()
                }
            }
        }else{
            for item in Menu.allMenuItemNotSuperUser{
                if let menu = NSEntityDescription.insertNewObjectForEntityForName("MenuItem", inManagedObjectContext: appDel.managedObjectContext!) as? MenuItem{
                    menu.id = item.rawValue
                    menu.orderId = item.rawValue
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
        if let entity = NSEntityDescription.entityForName("MenuItem", inManagedObjectContext: appDel.managedObjectContext!){
            for item in Menu.allMenuItem{
                if let menu = NSManagedObject.init(entity: entity, insertIntoManagedObjectContext: nil) as? MenuItem{
                menu.id = item.rawValue
                menu.orderId = item.rawValue
                menu.isVisible = true
                    menuList.append(menu)
                }
            }
        }
        return menuList
        
    }
    
    func getVisibleMenuItemByUser(user:User) -> [MenuItem]{
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MenuItem")
            let sortDescriptorOne = NSSortDescriptor(key: "orderId", ascending: true)
            var predicateArray:[NSPredicate] = [NSPredicate(format: "isVisible == %@", NSNumber(bool: true))]
            predicateArray.append(NSPredicate(format: "user == %@", user))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.sortDescriptors = [sortDescriptorOne]
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [MenuItem]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
            return []
    }
    
    func getMenuItemByUser(user:User) -> [MenuItem]{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MenuItem")
        let sortDescriptorOne = NSSortDescriptor(key: "orderId", ascending: true)
        let predicateArray:[NSPredicate] = [NSPredicate(format: "user == %@", user)]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptorOne]
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [MenuItem]
            return fetResults!
        } catch _ as NSError {
            abort()
        }
        return []
    }
    
    func changeOrder(menu:[MenuItem], user:User){
        let tempMenu = getMenuItemByUser(user)
        for (tempIndex,tempItem) in tempMenu.enumerate(){
            var exist = false
            for (index,item) in menu.enumerate(){
                if tempItem.id == item.id && tempItem.id != 13{
                    tempItem.orderId = index
                    exist = true
                }
            }
            if !exist && tempItem.id != 13{
                tempItem.orderId = tempIndex
            }
        }
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func changeItems(fromMenuItem:MenuItem, toMenuItem:MenuItem){
        
        let pom = fromMenuItem.orderId
        fromMenuItem.orderId = toMenuItem.orderId
        toMenuItem.orderId = pom
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func changeState(menuItem:MenuItem){
        if menuItem.isVisible == true{
            menuItem.isVisible = false
        }else{
            menuItem.isVisible = true
        }        
        CoreDataController.shahredInstance.saveChanges()
    }

}
