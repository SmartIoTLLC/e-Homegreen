//
//  DatabaseGatewayController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/14/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseGatewayController: NSObject {
    
    static let shared = DatabaseGatewayController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getGatewayByLocation(location:String) -> [Gateway]{
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
            var predicateArray:[NSPredicate] = [NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))]
            predicateArray.append(NSPredicate(format: "location.user == %@", user))
            predicateArray.append(NSPredicate(format: "location.name == %@", location))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    func getGatewayByObjectID(objectID:NSManagedObjectID) -> Gateway?{
        if let gateway = appDel.managedObjectContext?.objectWithID(objectID) as? Gateway {
            return gateway
        }
        return nil
    }
}
