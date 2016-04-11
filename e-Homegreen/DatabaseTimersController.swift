//
//  DatabaseTimersController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseTimersController: NSObject {
    
    static let shared = DatabaseTimersController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getTimers(filterParametar:FilterItem) -> [Timer] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Timer")
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
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
                let zonePredicate = NSPredicate(format: "timeZone == %@", filterParametar.zoneName)
                predicateArray.append(zonePredicate)
            }
            if filterParametar.categoryName != "All" {
                let categoryPredicate = NSPredicate(format: "timerCategory == %@", filterParametar.categoryName)
                predicateArray.append(categoryPredicate)
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
}
