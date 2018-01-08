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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getSurveillace(_ filterParametar:FilterItem) -> [Surveillance] {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Surveillance.fetchRequest()
            
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "ip", ascending: true),
                NSSortDescriptor(key: "port", ascending: true)
            ]
            
            var predicateArray = [NSPredicate(format: "location.user == %@", user)]
            if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "location.name == %@", filterParametar.location)) }
            if filterParametar.levelName != "All" { predicateArray.append(NSPredicate(format: "surveillanceLevel == %@", filterParametar.levelName)) }
            if filterParametar.zoneName != "All" { predicateArray.append(NSPredicate(format: "surveillanceZone == %@", filterParametar.zoneName)) }
            if filterParametar.categoryName != "All" { predicateArray.append(NSPredicate(format: "surveillanceCategory == %@", filterParametar.categoryName)) }
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let fetResults = try moc.fetch(fetchRequest) as? [Surveillance] {
                        return fetResults
                    }
                }
            } catch {}
            
        }
        return []
    }
    
    func deleteSurveillance(_ surv:Surveillance) {
        if let moc = appDel.managedObjectContext {
            moc.delete(surv)
        }        
    }
    
}
