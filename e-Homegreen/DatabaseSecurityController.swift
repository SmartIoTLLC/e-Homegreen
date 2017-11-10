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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func createSecurityForLocation(_ location:Location, gateway:Gateway) {
        if let securities = location.security?.allObjects as? [Security] {
            for security in securities { appDel.managedObjectContext?.delete(security) }
        }
        
        let importedData = DataImporter.createSecuritiesFromFile(Bundle.main.path(forResource: "Security", ofType: "json")!)
        for securityJSON in importedData! {
            let security = NSEntityDescription.insertNewObject(forEntityName: "Security", into: appDel.managedObjectContext!) as! Security
            security.securityName = securityJSON.name
            security.securityDescription = securityJSON.modeExplanation
            security.addressOne = gateway.addressOne
            security.addressTwo = gateway.addressTwo
            security.addressThree = 254
            security.location = location
            security.gatewayId = gateway.gatewayId
        }
    }
    
    func removeSecurityForLocation(_ location:Location) {
        if let securities = location.security?.allObjects as? [Security] {
            for security in securities{ appDel.managedObjectContext?.delete(security) }
        }
    }
    
    func getSecurity(_ filterParametar:FilterItem) -> [Security] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Security.fetchRequest()
            
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "location.user == %@", user))
            if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "location.name == %@", filterParametar.location)) }
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Security]
                return fetResults!
            } catch let error as NSError { print("Unresolved error \(error), \(error.userInfo)") }
        }
        return []
    }
    
    func getAllSecuritiesSortedBy(_ sortDescriptor: NSSortDescriptor) -> [Security] {
        if let _ = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Security.fetchRequest()
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Security]
                return fetResults!
            } catch {}
        }
        
        return []
    }
}
