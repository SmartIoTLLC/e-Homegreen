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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getCategoriesByLocation(_ location:Location) -> [Category]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "orderId", ascending: true)
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "location == %@", location))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.sortDescriptors = [sortDescriptors]
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Category]
            return results
        } catch{
            
        }
        return []
    }
    
    func getCategoryById(_ id:Int, location:Location) -> Category? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "location == %@", location))
        predicateArray.append(NSPredicate(format: "id == %@", NSNumber(value: id as Int)))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [Category]
            if results.count != 0{
                return results[0]
            }
        } catch _ as NSError {
            
        }
        return nil
    }
    
    func changeAllowOption(_ option:Int, category:Category){
        category.allowOption = option as NSNumber!
        CoreDataController.sharedInstance.saveChanges()
    }
}
