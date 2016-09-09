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
                let zonePredicate = NSPredicate(format: "sequenceZone == %@", filterParametar.zoneName)
                predicateArray.append(zonePredicate)
            }
            if filterParametar.categoryName != "All" {
                let categoryPredicate = NSPredicate(format: "sequenceCategory == %@", filterParametar.categoryName)
                predicateArray.append(categoryPredicate)
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
    
    func createSequence(sequenceId: Int, sequenceName: String, moduleAddress: Int, gateway: Gateway, levelId: Int?, zoneId: Int?, categoryId: Int?){
        var itExists = false
        var existingSequence:Sequence?
        let sequencaArray = fetchSequenceWithIdAndAddress(sequenceId, gateway: gateway, moduleAddress: moduleAddress)
        if sequencaArray.count > 0 {
            existingSequence = sequencaArray.first
            itExists = true
        }
        if !itExists {
            let sequence = NSEntityDescription.insertNewObjectForEntityForName("Secuence", inManagedObjectContext: appDel.managedObjectContext!) as! Sequence
            sequence.sequenceId = sequenceId
            sequence.sequenceName = sequenceName
            sequence.address = moduleAddress
            
            sequence.sequenceImageOneCustom = nil
            sequence.sequenceImageTwoCustom = nil
            
            sequence.sequenceImageOneDefault = "lightBulb"
            sequence.sequenceImageTwoDefault = "lightBulb"
            
            sequence.entityLevelId = levelId
            sequence.sequenceZoneId = zoneId
            sequence.sequenceCategoryId = categoryId
            
            sequence.isBroadcast = true
            sequence.isLocalcast = true
            
            sequence.isBroadcast = true
            sequence.isLocalcast = true
            sequence.sequenceCycles = 2
            
            sequence.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            existingSequence!.sequenceName = sequenceName
            
            existingSequence!.entityLevelId = levelId
            existingSequence!.sequenceZoneId = zoneId
            existingSequence!.sequenceCategoryId = categoryId
            
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
}
