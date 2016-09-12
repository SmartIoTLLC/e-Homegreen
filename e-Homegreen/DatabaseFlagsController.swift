//
//  DatabaseFlagsController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseFlagsController: NSObject {
    static let shared = DatabaseFlagsController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getFlags(filterParametar:FilterItem) -> [Flag] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Flag")
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "flagId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "flagName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))]
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            if filterParametar.location != "All" {
                predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location))
            }
            
            if filterParametar.levelObjectId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId){
                    predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!))
                }
            }
            if filterParametar.zoneObjectId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                    predicateArray.append(NSPredicate(format: "flagZoneId == %@", zone.id!))
                }
            }
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                    predicateArray.append(NSPredicate(format: "flagCategoryId == %@", category.id!))
                }
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Flag]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    func createFlag(flagId: Int, flagName: String?, moduleAddress: Int, gateway: Gateway, levelId: Int?, selectedZoneId: Int?, categoryId: Int?){
        var itExists = false
        var existingFlag:Flag?
        var flagArray = fetchFlagWithIdAndAddress(flagId, gateway: gateway, moduleAddress: moduleAddress)
        if flagArray.count > 0 {
            existingFlag = flagArray.first
            itExists = true
        }
        if !itExists {
            let flag = NSEntityDescription.insertNewObjectForEntityForName("Flag", inManagedObjectContext: appDel.managedObjectContext!) as! Flag
            flag.flagId = flagId
            if let flagName = flagName {
                flag.flagName = flagName
            }else{
                flag.flagName = ""
            }
            flag.address = moduleAddress
            
            flag.flagImageOneCustom = nil
            flag.flagImageTwoCustom = nil
            
            flag.flagImageOneDefault = "16 Flag - Flag - 00"
            flag.flagImageTwoDefault = "16 Flag - Flag - 01"
            
            flag.entityLevelId = levelId
            flag.flagZoneId = selectedZoneId
            flag.flagCategoryId = categoryId
            
            flag.isBroadcast = true
            flag.isLocalcast = true
            
            flag.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            if let flagName = flagName {
                existingFlag!.flagName = flagName
            }
            
            existingFlag!.entityLevelId = levelId
            existingFlag!.flagZoneId = selectedZoneId
            existingFlag!.flagCategoryId = categoryId
            
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func fetchFlagWithIdAndAddress(flagId: Int, gateway: Gateway, moduleAddress:Int) -> [Flag]{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: String(Flag))
        let predicateLocation = NSPredicate(format: "flagId == %@", NSNumber(integer: flagId))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(integer: moduleAddress))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Flag]
            return fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return []
    }

}
