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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getSequences(_ filterParametar:FilterItem) -> [Sequence] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Sequence.fetchRequest()
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))]
            predicateArray.append(NSPredicate(format: "gateway.location.user == %@", user))
            if filterParametar.location != "All" {
                let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterParametar.location)
                predicateArray.append(locationPredicate)
            }
            if filterParametar.levelObjectId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId) { predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!)) }
            }
            if filterParametar.zoneObjectId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) { predicateArray.append(NSPredicate(format: "sequenceZoneId == %@", zone.id!)) }
            }
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) { predicateArray.append(NSPredicate(format: "sequenceCategoryId == %@", category.id!)) }
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Sequence]
                return fetResults!
            } catch {}
        }
        return []
    }
    
    func updateSequenceList(_ gateway:Gateway, filterParametar:FilterItem) -> [Sequence] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Sequence.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway))
        
        if filterParametar.levelObjectId != "All" {
            if let level = FilterController.shared.getZoneByObjectId(filterParametar.levelObjectId) { predicateArray.append(NSPredicate(format: "entityLevelId == %@", level.id!)) }
        }
        if filterParametar.zoneObjectId != "All" {
            if let zone = FilterController.shared.getZoneByObjectId(filterParametar.zoneObjectId) { predicateArray.append(NSPredicate(format: "sequenceZoneId == %@", zone.id!)) }
        }
        if filterParametar.categoryObjectId != "All" {
            if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId) { predicateArray.append(NSPredicate(format: "sequenceCategoryId == %@", category.id!)) }
        }
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Sequence]
            return fetResults!
        } catch {}
        
        return []
    }
    
    func createSequence(_ sequenceId: Int, sequenceName: String, moduleAddress: Int, gateway: Gateway, levelId: Int?, zoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "lightBulb", sceneImageTwoDefault:String? = "lightBulb", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:Data? = nil, imageDataTwo:Data? = nil, sequenceCycles:Int = 2){
        var itExists = false
        var existingSequence:Sequence?
        let sequencaArray = fetchSequenceWithIdAndAddress(sequenceId, gateway: gateway, moduleAddress: moduleAddress)
        if sequencaArray.count > 0 {
            existingSequence = sequencaArray.first
            itExists = true
        }
        if !itExists {
            let sequence = NSEntityDescription.insertNewObject(forEntityName: "Sequence", into: appDel.managedObjectContext!) as! Sequence
            sequence.sequenceId = NSNumber(value: sequenceId)
            sequence.sequenceName = sequenceName
            sequence.address = NSNumber(value: moduleAddress)
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    sequence.sequenceImageOneCustom = image.imageId
                    sequence.sequenceImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            } else {
                sequence.sequenceImageOneDefault = sceneImageOneDefault
                sequence.sequenceImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    sequence.sequenceImageTwoCustom = image.imageId
                    sequence.sequenceImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            } else {
                sequence.sequenceImageTwoDefault = sceneImageTwoDefault
                sequence.sequenceImageTwoCustom = sceneImageTwoCustom
            }
            
            sequence.entityLevelId = levelId as NSNumber?
            sequence.sequenceZoneId = zoneId as NSNumber?
            sequence.sequenceCategoryId = categoryId as NSNumber?
            
            sequence.isBroadcast = isBroadcast as NSNumber
            sequence.isLocalcast = isLocalcast as NSNumber
            
            sequence.sequenceCycles = NSNumber(value: sequenceCycles)
            
            sequence.gateway = gateway
            CoreDataController.sharedInstance.saveChanges()
            
        } else {
            
            existingSequence!.sequenceName = sequenceName
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    existingSequence!.sequenceImageOneCustom = image.imageId
                    existingSequence!.sequenceImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            } else {
                existingSequence!.sequenceImageOneDefault = sceneImageOneDefault
                existingSequence!.sequenceImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    existingSequence!.sequenceImageTwoCustom = image.imageId
                    existingSequence!.sequenceImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            } else {
                existingSequence!.sequenceImageTwoDefault = sceneImageTwoDefault
                existingSequence!.sequenceImageTwoCustom = sceneImageTwoCustom
            }
            
            existingSequence!.entityLevelId = levelId as NSNumber?
            existingSequence!.sequenceZoneId = zoneId as NSNumber?
            existingSequence!.sequenceCategoryId = categoryId as NSNumber?
            
            existingSequence!.isBroadcast = isBroadcast as NSNumber
            existingSequence!.isLocalcast = isLocalcast as NSNumber
            
            existingSequence!.sequenceCycles = NSNumber(value: sequenceCycles)
            
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func fetchSequenceWithIdAndAddress(_ sceneId: Int, gateway: Gateway, moduleAddress:Int) -> [Sequence]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Sequence.fetchRequest()
        let predicateLocation = NSPredicate(format: "sequenceId == %@", NSNumber(value: sceneId as Int))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(value: moduleAddress as Int))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        fetchRequest.predicate = combinedPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Sequence]
            return fetResults!
        } catch let error1 as NSError { print("Unresolved error \(error1), \(error1.userInfo)") }
        
        return []
    }
    
    func deleteAllSequences(_ gateway:Gateway){
        let sequences = gateway.sequences.allObjects as! [Sequence]
        for sequence in sequences {
            self.appDel.managedObjectContext!.delete(sequence)
        }
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func deleteSequence(_ sequence:Sequence){
        self.appDel.managedObjectContext!.delete(sequence)
        CoreDataController.sharedInstance.saveChanges()
    }
}
