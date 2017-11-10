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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getFlags(_ filterParametar:FilterItem) -> [Flag] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Flag.fetchRequest()
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "flagId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "flagName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))]
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            
            if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location)) }
            
            if filterParametar.levelObjectId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId) { predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!)) }
            }
            if filterParametar.zoneObjectId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) { predicateArray.append(NSPredicate(format: "flagZoneId == %@", zone.id!)) }
            }
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) { predicateArray.append(NSPredicate(format: "flagCategoryId == %@", category.id!)) }
            }
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Flag]
                return fetResults!
            } catch {}
        }
        return []
    }
    
    func getAllFlags() -> [Flag] {
        if let _ = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Flag.fetchRequest()
            let sortDescriptors = NSSortDescriptor(key: "flagName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Flag]
                return fetResults!
            } catch {}
        }
        return []
    }
    
    func updateFlagList(_ gateway:Gateway, filterParametar:FilterItem) -> [Flag] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Flag.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "flagId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "flagName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway))
        
        if filterParametar.levelObjectId != "All" {
            if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId) { predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!)) }
        }
        if filterParametar.zoneObjectId != "All" {
            if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) { predicateArray.append(NSPredicate(format: "flagZoneId == %@", zone.id!)) }
        }
        if filterParametar.categoryObjectId != "All" {
            if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) { predicateArray.append(NSPredicate(format: "flagCategoryId == %@", category.id!)) }
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Flag]
            return fetResults!
        } catch {}
        
        return []
    }
    
    func createFlag(_ flagId: Int, flagName: String?, moduleAddress: Int, gateway: Gateway, levelId: Int?, selectedZoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "16 Flag - Flag - 00", sceneImageTwoDefault:String? = "16 Flag - Flag - 01", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:Data? = nil, imageDataTwo:Data? = nil){
        var itExists = false
        var existingFlag:Flag?
        let flagArray = fetchFlagWithIdAndAddress(flagId, gateway: gateway, moduleAddress: moduleAddress)
        if flagArray.count > 0 {
            existingFlag = flagArray.first
            itExists = true
        }
        if !itExists {
            let flag = NSEntityDescription.insertNewObject(forEntityName: "Flag", into: appDel.managedObjectContext!) as! Flag
            flag.flagId = NSNumber(value: flagId)
            if let flagName = flagName {
                flag.flagName = flagName
            } else {
                flag.flagName = ""
            }
            flag.address = NSNumber(value: moduleAddress)
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    flag.flagImageOneCustom = image.imageId
                    flag.flagImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            } else {
                flag.flagImageOneDefault = sceneImageOneDefault
                flag.flagImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    flag.flagImageTwoCustom = image.imageId
                    flag.flagImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            } else {
                flag.flagImageTwoDefault = sceneImageTwoDefault
                flag.flagImageTwoCustom = sceneImageTwoCustom
            }
            
            flag.entityLevelId = levelId as NSNumber?
            flag.flagZoneId = selectedZoneId as NSNumber?
            flag.flagCategoryId = categoryId as NSNumber?
            
            flag.isBroadcast = isBroadcast as NSNumber
            flag.isLocalcast = isLocalcast as NSNumber
            
            flag.gateway = gateway
            CoreDataController.sharedInstance.saveChanges()
            
        } else {
            
            if let flagName = flagName {
                existingFlag!.flagName = flagName
            }
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    existingFlag!.flagImageOneCustom = image.imageId
                    existingFlag!.flagImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            } else {
                existingFlag!.flagImageOneDefault = sceneImageOneDefault
                existingFlag!.flagImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    existingFlag!.flagImageTwoCustom = image.imageId
                    existingFlag!.flagImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            } else {
                existingFlag!.flagImageTwoDefault = sceneImageTwoDefault
                existingFlag!.flagImageTwoCustom = sceneImageTwoCustom
            }
            
            existingFlag!.entityLevelId = levelId as NSNumber?
            existingFlag!.flagZoneId = selectedZoneId as NSNumber?
            existingFlag!.flagCategoryId = categoryId as NSNumber?
            
            existingFlag!.isBroadcast = isBroadcast as NSNumber
            existingFlag!.isLocalcast = isLocalcast as NSNumber
            
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func fetchFlagWithIdAndAddress(_ flagId: Int, gateway: Gateway, moduleAddress:Int) -> [Flag]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Flag.fetchRequest()
        let predicateLocation = NSPredicate(format: "flagId == %@", NSNumber(value: flagId as Int))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(value: moduleAddress as Int))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Flag]
            return fetResults!
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return []
    }
    
    func deleteAllFlags(_ gateway:Gateway) {
        let flags = gateway.flags.allObjects as! [Flag]
        for flag in flags { self.appDel.managedObjectContext!.delete(flag) }
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func deleteFlag(_ flag:Flag){
        self.appDel.managedObjectContext!.delete(flag)
        CoreDataController.sharedInstance.saveChanges()
    }

}
