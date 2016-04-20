//
//  DatabaseSurveillanceController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/19/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseSurveillanceController: NSObject {
    
    static let shared = DatabaseSurveillanceController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getSurveillace(filterParametar:FilterItem) -> [Surveillance]{
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            
        let fetchRequest = NSFetchRequest(entityName: "Surveillance")
            
        let sortDescriptor = NSSortDescriptor(key: "ip", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "port", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptorTwo]
            
        var predicateArray:[NSPredicate] = [NSPredicate(format: "location.user == %@", user)]
        if filterParametar.location != "All" {
            predicateArray.append(NSPredicate(format: "location.name == %@", filterParametar.location))
        }
        if filterParametar.levelName != "All" {
            let levelPredicate = NSPredicate(format: "surveillanceLevel == %@", filterParametar.levelName)
            predicateArray.append(levelPredicate)
        }
        if filterParametar.zoneName != "All" {
            let zonePredicate = NSPredicate(format: "surveillanceZone == %@", filterParametar.zoneName)
            predicateArray.append(zonePredicate)
        }
        if filterParametar.categoryName != "All" {
            let categoryPredicate = NSPredicate(format: "surveillanceCategory == %@", filterParametar.categoryName)
            predicateArray.append(categoryPredicate)
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Surveillance]
            return fetResults!
        } catch _ as NSError {
            abort()
        }
        }
        return []
    }

}
