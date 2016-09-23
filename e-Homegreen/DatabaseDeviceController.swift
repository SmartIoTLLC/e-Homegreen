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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getPCs(_ filterParametar: FilterItem) -> [Device] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
            
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
                predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int)))
            }
            if filterParametar.zoneId != 0 && filterParametar.zoneId != 255{
                predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int)))
            }
            if filterParametar.categoryId != 0 && filterParametar.categoryId != 255{
                predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int)))
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate

            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Device]
                return fetResults!
            } catch let error as NSError {
                print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
        return []
    }
    
}
