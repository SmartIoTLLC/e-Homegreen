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
    func getAllFlags() -> [Flag] {
        if let _ = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Flag")
            let sortDescriptors = NSSortDescriptor(key: "flagName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Flag]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    func updateFlagList(gateway:Gateway, filterParametar:FilterItem) -> [Flag] {
        let fetchRequest = NSFetchRequest(entityName: "Flag")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "flagId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "flagName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway))
        
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
        } catch{
        }
        return []
    }
    
    func createFlag(flagId: Int, flagName: String?, moduleAddress: Int, gateway: Gateway, levelId: Int?, selectedZoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "16 Flag - Flag - 00", sceneImageTwoDefault:String? = "16 Flag - Flag - 01", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:NSData? = nil, imageDataTwo:NSData? = nil){
        var itExists = false
        var existingFlag:Flag?
        let flagArray = fetchFlagWithIdAndAddress(flagId, gateway: gateway, moduleAddress: moduleAddress)
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
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = NSUUID().UUIDString
                    flag.flagImageOneCustom = image.imageId
                    flag.flagImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                flag.flagImageOneDefault = sceneImageOneDefault
                flag.flagImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = NSUUID().UUIDString
                    flag.flagImageTwoCustom = image.imageId
                    flag.flagImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                flag.flagImageTwoDefault = sceneImageTwoDefault
                flag.flagImageTwoCustom = sceneImageTwoCustom
            }
            
            flag.entityLevelId = levelId
            flag.flagZoneId = selectedZoneId
            flag.flagCategoryId = categoryId
            
            flag.isBroadcast = isBroadcast
            flag.isLocalcast = isLocalcast
            
            flag.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            if let flagName = flagName {
                existingFlag!.flagName = flagName
            }
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = NSUUID().UUIDString
                    existingFlag!.flagImageOneCustom = image.imageId
                    existingFlag!.flagImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                existingFlag!.flagImageOneDefault = sceneImageOneDefault
                existingFlag!.flagImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = NSUUID().UUIDString
                    existingFlag!.flagImageTwoCustom = image.imageId
                    existingFlag!.flagImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                existingFlag!.flagImageTwoDefault = sceneImageTwoDefault
                existingFlag!.flagImageTwoCustom = sceneImageTwoCustom
            }
            
            existingFlag!.entityLevelId = levelId
            existingFlag!.flagZoneId = selectedZoneId
            existingFlag!.flagCategoryId = categoryId
            
            existingFlag!.isBroadcast = isBroadcast
            existingFlag!.isLocalcast = isLocalcast
            
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
    
    func deleteAllFlags(gateway:Gateway){
        let flags = gateway.flags.allObjects as! [Flag]
        for flag in flags {
            self.appDel.managedObjectContext!.deleteObject(flag)
        }
        
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func deleteFlag(flag:Flag){
        self.appDel.managedObjectContext!.deleteObject(flag)
        CoreDataController.shahredInstance.saveChanges()
    }

}
