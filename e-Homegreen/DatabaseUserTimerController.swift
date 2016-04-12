//
//  DatabaseUserTimerController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/12/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseUserTimerController: NSObject {
    
    static let shared = DatabaseUserTimerController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getTimers(filterParametar:FilterItem) -> [Timer] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Timer")
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))]
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            predicateArray.append(NSPredicate(format: "type == %@", "Stopwatch/User"))
            predicateArray.append(NSPredicate(format: "timerCategory == %@", "User"))            
            
            if filterParametar.location != "All" {
                predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location))
            }
            if filterParametar.levelName != "All" {
                predicateArray.append(NSPredicate(format: "entityLevel == %@", filterParametar.levelName))
            }
            if filterParametar.zoneName != "All" {
                predicateArray.append(NSPredicate(format: "timeZone == %@", filterParametar.zoneName))
            }
            if filterParametar.categoryName != "All" {
                predicateArray.append(NSPredicate(format: "timerCategory == %@", filterParametar.categoryName))
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
