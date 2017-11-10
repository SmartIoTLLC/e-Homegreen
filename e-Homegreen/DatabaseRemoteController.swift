//
//  DatabaseRemoteController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 10/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

public class DatabaseRemoteController: NSObject {
    
    open static let sharedInstance = DatabaseRemoteController()
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    func getRemotes(_ filterParametar: FilterItem) -> [Remote] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Remote.fetchRequest()
            
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray: [NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))]
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location)) }
            
            if filterParametar.levelObjectId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId) { predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!)) }
            }
            
            if filterParametar.zoneObjectId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) {
                    predicateArray.append(NSPredicate(format: "sceneZoneId == %@", zone.id!))
                }
            }
            
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) {
                    predicateArray.append(NSPredicate(format: "sceneCategoryId == %@", category.id!))
                }
            }
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                let results = try managedContext?.fetch(fetchRequest) as? [Remote]
                return results ?? []
            } catch let error as NSError {
                print("Error fetching remotes: ", error, error.userInfo)
            }
            
        }
        
        return []
    }
    
    func createRemote(name: String, columns: NSNumber, rows: NSNumber, location: Location, level: NSNumber, zone: Zone, addressOne: NSNumber, addressTwo: NSNumber, addressThree: NSNumber, channel: NSNumber, buttonHeight: NSNumber, buttonWidth: NSNumber, marginTop: NSNumber, marginBottom: NSNumber, buttonColor: String, buttonShape: String) {
        
        if let remote = NSEntityDescription.insertNewObject(forEntityName: "Remote", into: managedContext!) as? Remote {
            remote.name = name
            remote.columns = columns
            remote.rows = rows
            remote.gateway?.location = location
            remote.addressOne = addressOne
            remote.addressTwo = addressTwo
            remote.addressThree = addressThree
            remote.channel = channel
            remote.buttonHeight = buttonHeight
            remote.buttonWidth = buttonWidth
            remote.marginTop = marginTop
            remote.marginBottom = marginBottom
            remote.buttonColor = buttonColor
            remote.buttonShape = buttonShape
            
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func deleteAllRemotes(_ gateway: Gateway) {
        if let remotes = gateway.remotes.allObjects as? [Remote] {
            remotes.forEach({ (remote) in managedContext?.delete(remote) })
        }
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func deleteRemote(_ remote: Remote) {
        managedContext?.delete(remote)
        CoreDataController.sharedInstance.saveChanges()
    }
}
