//
//  DatabaseFlagsController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseFlagsController: NSObject {
    static let shared = DatabaseFlagsController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getFlags(filterParametar:FilterItem) -> [Flag] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Flag")
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "flagId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "flagName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            var predicateArray:[NSPredicate] = [predicateOne]
            
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            
            if filterParametar.location != "All" {
                let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterParametar.location)
                predicateArray.append(locationPredicate)
            }
            if filterParametar.levelName != "All" {
                let levelPredicate = NSPredicate(format: "entityLevel == %@", filterParametar.levelName)
                predicateArray.append(levelPredicate)
            }
            if filterParametar.zoneName != "All" {
                let zonePredicate = NSPredicate(format: "flagZone == %@", filterParametar.zoneName)
                predicateArray.append(zonePredicate)
            }
            if filterParametar.categoryName != "All" {
                let categoryPredicate = NSPredicate(format: "flagCategory == %@", filterParametar.categoryName)
                predicateArray.append(categoryPredicate)
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Flag]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }

}
