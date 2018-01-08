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
        if let user = DatabaseUserController.shared.loggedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Timer.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "gateway.name", ascending: true),
                NSSortDescriptor(key: "timerId", ascending: true),
                NSSortDescriptor(key: "timerName", ascending: true)
            ]
            
            var predicateArray = [
                NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool)),
                NSPredicate(format: "gateway.location.user == %@", user),
                NSPredicate(format: "type == %@", NSNumber(value: TimerType.stopwatch.rawValue as Int)),
                NSPredicate(format: "timerCategoryId == %@", NSNumber(value: 20 as Int))
            ]
            
            if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location)) }
            if filterParametar.levelName != "All" { predicateArray.append(NSPredicate(format: "entityLevel == %@", filterParametar.levelName)) }
            if filterParametar.zoneName != "All" { predicateArray.append(NSPredicate(format: "timeZone == %@", filterParametar.zoneName)) }
            if filterParametar.categoryName != "All" { predicateArray.append(NSPredicate(format: "timerCategory == %@", filterParametar.categoryName)) }
            
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let fetResults = try moc.fetch(fetchRequest) as? [Timer] {
                        return fetResults
                    }
                }
            } catch {}
        }
        return []
    }
    
}
