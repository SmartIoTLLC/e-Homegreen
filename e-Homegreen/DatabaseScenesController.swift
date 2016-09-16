//
//  DatabaseScenesController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/8/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseScenesController: NSObject {
    
    static let shared = DatabaseScenesController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getScene(filterParametar:FilterItem) -> [Scene] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest = NSFetchRequest(entityName: "Scene")
            
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
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
                    predicateArray.append(NSPredicate(format: "sceneZoneId == %@", zone.id!))
                }
            }
            if filterParametar.categoryObjectId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                    predicateArray.append(NSPredicate(format: "sceneCategoryId == %@", category.id!))
                }
            }
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
                return fetResults!
            } catch  {
                
            }
        }
        return []
        
    }
    
    func updateSceneList(gateway:Gateway, filterParametar:FilterItem) -> [Scene]{
        let fetchRequest = NSFetchRequest(entityName: "Scene")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
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
                predicateArray.append(NSPredicate(format: "sceneZoneId == %@", zone.id!))
            }
        }
        if filterParametar.categoryObjectId != "All" {
            if let category = FilterController.shared.getCategoryByObjectId(filterParametar.categoryObjectId){
                predicateArray.append(NSPredicate(format: "sceneCategoryId == %@", category.id!))
            }
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
            return fetResults!
        } catch {
        }
        return []
    }
    
    func createScene(sceneId: Int, sceneName: String, moduleAddress: Int, gateway: Gateway, levelId: Int?, zoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "Scene - All On - 00", sceneImageTwoDefault:String? = "Scene - All On - 01", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil){
        var itExists = false
        var existingScene:Scene?
        let sceneArray = fetchSceneWithIdAndAddress(sceneId, gateway: gateway, moduleAddress: moduleAddress)
        if sceneArray.count > 0 {
            existingScene = sceneArray.first
            itExists = true
        }
        if !itExists {
            let scene = NSEntityDescription.insertNewObjectForEntityForName("Scene", inManagedObjectContext: appDel.managedObjectContext!) as! Scene
            scene.sceneId = sceneId
            scene.sceneName = sceneName
            scene.address = moduleAddress
            
            scene.sceneImageOneCustom = nil
            scene.sceneImageTwoCustom = nil
            
            scene.sceneImageOneDefault = sceneImageOneDefault
            scene.sceneImageOneCustom = sceneImageOneCustom
            scene.sceneImageTwoDefault = sceneImageTwoDefault
            scene.sceneImageTwoCustom = sceneImageTwoCustom
            
            scene.entityLevelId = levelId
            scene.sceneZoneId = zoneId
            scene.sceneCategoryId = categoryId
            
            scene.isBroadcast = isBroadcast
            scene.isLocalcast = isLocalcast
            
            scene.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            existingScene!.sceneName = sceneName
            
            existingScene!.sceneImageOneDefault = sceneImageOneDefault
            existingScene!.sceneImageOneCustom = sceneImageOneCustom
            existingScene!.sceneImageTwoDefault = sceneImageTwoDefault
            existingScene!.sceneImageTwoCustom = sceneImageTwoCustom

            
            existingScene!.entityLevelId = levelId
            existingScene!.sceneZoneId = zoneId
            existingScene!.sceneCategoryId = categoryId
            
            existingScene!.isBroadcast = isBroadcast
            existingScene!.isLocalcast = isLocalcast
            
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func fetchSceneWithIdAndAddress(sceneId: Int, gateway: Gateway, moduleAddress:Int) -> [Scene]{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Scene")
        let predicateLocation = NSPredicate(format: "sceneId == %@", NSNumber(integer: sceneId))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(integer: moduleAddress))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
            return fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return []
    }
    
    func deleteAllScenes(gateway:Gateway){
        let scenes = gateway.scenes.allObjects as! [Scene]
        for scene in scenes {
            self.appDel.managedObjectContext!.deleteObject(scene)
        }
        
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func deleteScene(scene:Scene){
        self.appDel.managedObjectContext!.deleteObject(scene)
        CoreDataController.shahredInstance.saveChanges()
    }

    
}
