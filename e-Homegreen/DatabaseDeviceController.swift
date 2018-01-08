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
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
            
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "gateway.name", ascending: true),
                NSSortDescriptor(key: "address", ascending: true),
                NSSortDescriptor(key: "type", ascending: true),
                NSSortDescriptor(key: "channel", ascending: true)
            ]
            
            var predicateArray = [
                NSPredicate(format: "gateway.location.user == %@", user),
                NSPredicate(format: "type == %@", ControlType.PC)
            ]
            
            if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location)) }
            if filterParametar.levelId != 0 && filterParametar.levelId != 255 { predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int))) }
            if filterParametar.zoneId != 0 && filterParametar.zoneId != 255 { predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int))) }
            if filterParametar.categoryId != 0 && filterParametar.categoryId != 255 { predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int))) }
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate

            do {
                if let moc = appDel.managedObjectContext {
                    if let fetResults = try moc.fetch(fetchRequest) as? [Device] {
                        return fetResults
                    }
                }
                
            } catch let error as NSError { print("Unresolved error \(error), \(error.userInfo)") }
            
        }
        return []
    }
    
    func getIRDevice(withChannelID id: Int) -> Device? {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
            
            let sortDescriptors = [
                NSSortDescriptor(key: "gateway.name", ascending: true),
                NSSortDescriptor(key: "address", ascending: true),
                NSSortDescriptor(key: "type", ascending: true),
                NSSortDescriptor(key: "channel", ascending: true)
            ]
            fetchRequest.sortDescriptors = sortDescriptors
            
            let predicateArray = [
                NSPredicate(format: "gateway.location.user == %@", user),
                NSPredicate(format: "type == %@", ControlType.Sensor),
                NSPredicate(format: "channel == %ld", id)
            ]
            
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let fetchResults = try moc.fetch(fetchRequest) as? [Device] {
                        return fetchResults.first
                    }                    
                }
                
            } catch {}
        }
        
        return nil
    }
    
}
