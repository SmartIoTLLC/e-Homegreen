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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getScene(_ filterParametar:FilterItem) -> [Scene] {
        if let user = DatabaseUserController.shared.logedUserOrAdmin(){
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Scene.fetchRequest()
            
            let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
            let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
            
            var predicateArray:[NSPredicate] = [NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))]
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
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            
            fetchRequest.predicate = compoundPredicate
            do {
                let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Scene]
                return fetResults!
            } catch  {
                
            }
        }
        return []
        
    }
    func fetchSceneWithIdAndAddress(_ sceneId: Int, gateway: Gateway, moduleAddress:Int) -> [Scene]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Scene.fetchRequest()
        let predicateLocation = NSPredicate(format: "sceneId == %@", NSNumber(value: sceneId as Int))
        let predicateGateway = NSPredicate(format: "gateway == %@", gateway)
        let predicateAddress = NSPredicate(format: "address == %@", NSNumber(value: moduleAddress as Int))
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLocation, predicateGateway, predicateAddress])
        
        fetchRequest.predicate = combinedPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Scene]
            return fetResults!
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return []
    }
    func updateSceneList(_ gateway:Gateway, filterParametar:FilterItem) -> [Scene]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Scene.fetchRequest()
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
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Scene]
            return fetResults!
        } catch {
        }
        return []
    }
    
    
    func createScene(_ sceneId: Int, sceneName: String, moduleAddress: Int, gateway: Gateway, levelId: Int?, zoneId: Int?, categoryId: Int?, isBroadcast:Bool = true, isLocalcast:Bool = true, sceneImageOneDefault:String? = "Scene - All On - 00", sceneImageTwoDefault:String? = "Scene - All On - 01", sceneImageOneCustom:String? = nil, sceneImageTwoCustom:String? = nil, imageDataOne:Data? = nil, imageDataTwo:Data? = nil){
        var itExists = false
        var existingScene:Scene?
        let sceneArray = fetchSceneWithIdAndAddress(sceneId, gateway: gateway, moduleAddress: moduleAddress)
        if sceneArray.count > 0 {
            existingScene = sceneArray.first
            itExists = true
        }
        if !itExists {
            let scene = NSEntityDescription.insertNewObject(forEntityName: "Scene", into: appDel.managedObjectContext!) as! Scene
            scene.sceneId = NSNumber(value: sceneId)
            scene.sceneName = sceneName
            scene.address = NSNumber(value: moduleAddress)
            
            scene.sceneImageOneCustom = nil
            scene.sceneImageTwoCustom = nil
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    scene.sceneImageOneCustom = image.imageId
                    scene.sceneImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                scene.sceneImageOneDefault = sceneImageOneDefault
                scene.sceneImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    scene.sceneImageTwoCustom = image.imageId
                    scene.sceneImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                scene.sceneImageTwoDefault = sceneImageTwoDefault
                scene.sceneImageTwoCustom = sceneImageTwoCustom
            }
            
            scene.entityLevelId = levelId as NSNumber?
            scene.sceneZoneId = zoneId as NSNumber?
            scene.sceneCategoryId = categoryId as NSNumber?
            
            scene.isBroadcast = isBroadcast as NSNumber
            scene.isLocalcast = isLocalcast as NSNumber
            
            scene.gateway = gateway
            CoreDataController.shahredInstance.saveChanges()
            
        } else {
            
            existingScene!.sceneName = sceneName
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    existingScene!.sceneImageOneCustom = image.imageId
                    existingScene!.sceneImageOneDefault = nil
                    gateway.location.user!.addImagesObject(image)
                }
            }else{
                existingScene!.sceneImageOneDefault = sceneImageOneDefault
                existingScene!.sceneImageOneCustom = sceneImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    existingScene!.sceneImageTwoCustom = image.imageId
                    existingScene!.sceneImageTwoDefault = nil
                    gateway.location.user!.addImagesObject(image)
                    
                }
            }else{
                existingScene!.sceneImageTwoDefault = sceneImageTwoDefault
                existingScene!.sceneImageTwoCustom = sceneImageTwoCustom
            }
            
            existingScene!.entityLevelId = levelId as NSNumber?
            existingScene!.sceneZoneId = zoneId as NSNumber?
            existingScene!.sceneCategoryId = categoryId as NSNumber?
            
            existingScene!.isBroadcast = isBroadcast as NSNumber
            existingScene!.isLocalcast = isLocalcast as NSNumber
            
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    
    func deleteAllScenes(_ gateway:Gateway){
        let scenes = gateway.scenes.allObjects as! [Scene]
        for scene in scenes {
            self.appDel.managedObjectContext!.delete(scene)
        }
        
        CoreDataController.shahredInstance.saveChanges()
    }
    func deleteScene(_ scene:Scene){
        self.appDel.managedObjectContext!.delete(scene)
        CoreDataController.shahredInstance.saveChanges()
    }
}
