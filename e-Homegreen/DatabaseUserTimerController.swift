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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getTimers(_ filterParametar:FilterItem) -> [Timer] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))]
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            predicateArray.append(NSPredicate(format: "type == %@", NSNumber(value: TimerType.stopwatch.rawValue as Int)))
            predicateArray.append(NSPredicate(format: "timerCategoryId == %@", NSNumber(value: 20 as Int)))
            
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
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Timer]
                return fetResults!
            } catch _ as NSError {
                //abort()
            }
        }
        return []
    }
    
}
