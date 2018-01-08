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
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderId", ascending: true)]
        fetchRequest.predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [NSPredicate(format: "location == %@", location)]
        )
        
        do {
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [Category] {
                    return results
                }
            }
        } catch {}
        
        return []
    }
    
    func getCategoryById(_ id:Int, location:Location) -> Category? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        
        let predicateArray = [
            NSPredicate(format: "location == %@", location),
            NSPredicate(format: "id == %@", NSNumber(value: id as Int))
        ]
        
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        
        do {
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [Category] {
                    if results.count != 0 { return results[0] }
                }
            }
            
        } catch {}
        
        return nil
    }
    
    func changeAllowOption(_ option:Int, category:Category){
        category.allowOption = option as NSNumber!
        CoreDataController.sharedInstance.saveChanges()
    }
}
