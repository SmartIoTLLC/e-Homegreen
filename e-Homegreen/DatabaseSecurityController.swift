//
//  DatabaseSecurityController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/15/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseSecurityController: NSObject {
    
    static let shared = DatabaseSecurityController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func createSecurityForLocation(location:Location, gateway:Gateway){
        if let securities = location.security?.allObjects as? [Security]{
            for security in securities{
                appDel.managedObjectContext?.deleteObject(security)
            }
        }
        let importedData = DataImporter.createSecuritiesFromFile(NSBundle.mainBundle().pathForResource("Security", ofType: "json")!)
        for securityJSON in importedData! {
            let security = NSEntityDescription.insertNewObjectForEntityForName("Security", inManagedObjectContext: appDel.managedObjectContext!) as! Security
            security.name = securityJSON.name
            security.modeExplanation = securityJSON.modeExplanation
            security.addressOne = gateway.addressOne
            security.addressTwo = gateway.addressTwo
            security.addressThree = 254
            security.location = location
            security.gateway = gateway
//            saveChanges()
        }
    }
    
    func getSecurity(filterParametar:FilterItem) -> [Security]{
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Security")
            
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "location.user == %@", user))
            if filterParametar.location != "All" {
                predicateArray.append(NSPredicate(format: "location.name == %@", filterParametar.location))
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Security]
                return fetResults!
            } catch let error as NSError {
                print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
        return []
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch _ as NSError {
            abort()
        }
    }

}
