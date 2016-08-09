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
    
    func getCategories(location:Location) -> [Category]{
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        var predicateArray:[NSPredicate] = [NSPredicate(format: "location == %@", location)]
        predicateArray.append(NSPredicate(format: "isVisible == %@", NSNumber(bool: true)))

        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Category]
            return results
        } catch _ as NSError {
            
        }
        return []
    }
    
    func getCategory(objectId:NSManagedObjectID) -> Category?{
        if let category = appDel.managedObjectContext?.objectWithID(objectId) as? Category {
            return category
        }
        return nil
    }
    
    func changeAllowOption(option:Int, category:Category){
        category.allowOption = option
        CoreDataController.shahredInstance.saveChanges()
    }
}
