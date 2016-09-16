//
//  DatabaseSequencesController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseSequencesController: NSObject {
    
    static let shared = DatabaseSequencesController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getSequences(filterParametar:FilterItem) -> [Sequence] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Sequence")
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))]
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            if filterParametar.location != "All" {
                let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterParametar.location)
                predicateArray.append(locationPredicate)
            }
            if filterParametar.levelObjectId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId){
                    predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!))
                }
            }
            if filterParametar.zoneObjectId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId){
                    predicateArray.append(NSPredicate(format: "sequenceZoneId == %@", zone.id!))
                }
            }
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                    predicateArray.append(NSPredicate(format: "sequenceCategoryId == %@", category.id!))
                }
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
                return fetResults!
            } catch _ as NSError {
                abort()
            }
        }
        return []
    }
    
    func updateSequenceList(gateway:Gateway, filterParametar:FilterItem) -> [Sequence] {
        let fetchRequest = NSFetchRequest(entityName: "Sequence")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
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
                predicateArray.append(NSPredicate(format: "sequenceZoneId == %@", zone.id!))
            }
        }
        if filterParametar.categoryObjectId != "All" {
            if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                predicateArray.append(NSPredicate(format: "sequenceCategoryId == %@", category.id!))
            }
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
            return fetResults!
        } catch{
        }
        return []
    }
    
    func createSequence(sequenceId: Int, sequenceName: String, moduleAddress: Int, gateway: Gateway, levelId: Int?, zoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "lightBulb", sceneImageTwoDefault:String? = "lightBulb", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:NSData? = nil, imageDataTwo:NSData? = nil, sequenceCycles:Int = 2){
        var itExists = false
        var existingSequence:Sequence?
        let sequencaArray = fetchSequenceWithIdAndAddress(sequenceId, gateway: gateway, moduleAddress: moduleAddress)
        if sequencaArray.count > 0 {
            existingSequence = sequencaArray.first
            itExists = true
        }
        if !itExists {
            let sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: appDel.managedObjectContext!) as! Sequence
            sequence.sequenceId = sequenceId
            sequence.sequenceName = sequenceName
            sequence.address = moduleAddress
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = NSUUID().UUIDString
                    sequence.sequenceImageOneCustom = image.imageId
                    sequence.sequenceImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                sequence.sequenceImageOneDefault = sceneImageOneDefault
                sequence.sequenceImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = NSUUID().UUIDString
                    sequence.sequenceImageTwoCustom = image.imageId
                    sequence.sequenceImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                sequence.sequenceImageTwoDefault = sceneImageTwoDefault
                sequence.sequenceImageTwoCustom = sceneImageTwoCustom
            }
            
            sequence.entityLevelId = levelId
            sequence.sequenceZoneId = zoneId
            sequence.sequenceCategoryId = categoryId
            
            sequence.isBroadcast = isBroadcast
            sequence.isLocalcast = isLocalcast
            
            sequence.sequenceCycles = sequenceCycles
            
            sequence.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            existingSequence!.sequenceName = sequenceName
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = NSUUID().UUIDString
                    existingSequence!.sequenceImageOneCustom = image.imageId
                    existingSequence!.sequenceImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                existingSequence!.sequenceImageOneDefault = sceneImageOneDefault
                existingSequence!.sequenceImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = NSUUID().UUIDString
                    existingSequence!.sequenceImageTwoCustom = image.imageId
                    existingSequence!.sequenceImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                existingSequence!.sequenceImageTwoDefault = sceneImageTwoDefault
                existingSequence!.sequenceImageTwoCustom = sceneImageTwoCustom
            }
            
            existingSequence!.entityLevelId = levelId
            existingSequence!.sequenceZoneId = zoneId
            existingSequence!.sequenceCategoryId = categoryId
            
            existingSequence!.isBroadcast = isBroadcast
            existingSequence!.isLocalcast = isLocalcast
            
            existingSequence!.sequenceCycles = sequenceCycles
            
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func fetchSequenceWithIdAndAddress(sceneId: Int, gateway: Gateway, moduleAddress:Int) -> [Sequence]{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Sequence")
        let predicateLocation = NSPredicate(format: "sequenceId == %@", NSNumber(integer: sceneId))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(integer: moduleAddress))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
            return fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return []
    }
    
    func deleteAllSequences(gateway:Gateway){
        let sequences = gateway.sequences.allObjects as! [Sequence]
        for sequence in sequences {
            self.appDel.managedObjectContext!.deleteObject(sequence)
        }
        
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func deleteSequence(sequence:Sequence){
        self.appDel.managedObjectContext!.deleteObject(sequence)
        CoreDataController.shahredInstance.saveChanges()
    }
}
