//
//  DatabaseCategoryController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/19/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseCategoryController: NSObject {
    
    static let shared = DatabaseCategoryController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getCategoriesByLocation(location:Location) -> [Category]{
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "location == %@", location))
        
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
    
    func getCategoryById(id:Int, location:Location) -> Category? {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "location == %@", location))
        predicateArray.append(NSPredicate(format: "id == %@", NSNumber(integer: id)))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Category]
            if results.count != 0{
                return results[0]
            }
        } catch _ as NSError {
            
        }
        return nil
    }
    
    func changeAllowOption(option:Int, category:Category){
        category.allowOption = option
        CoreDataController.shahredInstance.saveChanges()
    }
}
