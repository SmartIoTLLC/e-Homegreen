//
//  DatabaseLocationController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseLocationController: NSObject {

    static let shared = DatabaseLocationController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getNextAvailableId(user:User) -> Int{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Location")
        let sortDescriptorTwo = NSSortDescriptor(key: "orderId", ascending: true)
        let predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Location]
            if let last = fetchResults?.last{
                if let id = last.orderId as? Int {
                    return id + 1
                }
            }
            
        } catch _ as NSError {
            abort()
        }
        return 1
    }
}
