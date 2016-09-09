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
            let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
            var predicateArray:[NSPredicate] = [predicateOne]
            
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            
            if filterParametar.location != "All" {
                let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterParametar.location)
                predicateArray.append(locationPredicate)
            }
            if filterParametar.levelName != "All" {
                let levelPredicate = NSPredicate(format: "entityLevel == %@", filterParametar.levelName)
                predicateArray.append(levelPredicate)
            }
            if filterParametar.zoneName != "All" {
                let zonePredicate = NSPredicate(format: "flagZone == %@", filterParametar.zoneName)
                predicateArray.append(zonePredicate)
            }
            if filterParametar.categoryName != "All" {
                let categoryPredicate = NSPredicate(format: "flagCategory == %@", filterParametar.categoryName)
                predicateArray.append(categoryPredicate)
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
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Scene")
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
