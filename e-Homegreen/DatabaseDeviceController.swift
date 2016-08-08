//
//  DatabaseDeviceController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/14/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseDeviceController: NSObject {

    static let shared = DatabaseDeviceController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getPCs(filterParametar: FilterItem) -> [Device] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
            
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
            let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
            
            var predicateArray:[NSPredicate] = []
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            predicateArray.append(NSPredicate(format: "type == %@", ControlType.PC))
            
            if filterParametar.location != "All" {
                predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location))
            }
            if filterParametar.levelId != 0 && filterParametar.levelId != 255{
                predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(integer: filterParametar.levelId)))
            }
            if filterParametar.zoneId != 0 && filterParametar.zoneId != 255{
                predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(integer: filterParametar.zoneId)))
            }
            if filterParametar.categoryId != 0 && filterParametar.categoryId != 255{
                predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(integer: filterParametar.categoryId)))
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate

            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
                return fetResults!
            } catch let error as NSError {
                print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
        return []
    }

    
    
}
