//
//  CoreDataWrapper.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/4/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import Foundation
import CoreData

extension Array {
//    func lastObject() -> Element {
//        let endIndex = self.endIndex
//        let lastItemIndex = endIndex - 1
//        
//        return self[lastItemIndex]
//    }
}

class CoreDataStack : NSObject {
    var persistentStoreCoordinator : NSPersistentStoreCoordinator?
    var managedObjectModel : NSManagedObjectModel?
    var managedObjectContext : NSManagedObjectContext?
    
    override init() {
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)

        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)

        let domains = NSSearchPathDomainMask.UserDomainMask
        let directory = NSSearchPathDirectory.DocumentDirectory
        
//        let error = NSError()
//        let applicationDocumentsDirectory : AnyObject = NSFileManager.defaultManager().URLsForDirectory(directory, inDomains: domains).lastObject()
//        let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
//        
//        let storeURL = applicationDocumentsDirectory.URLByAppendingPathComponent("VIPER-SWIFT.sqlite")
//        
//        persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: "", URL: storeURL, options: options, error: nil)
//        
//        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
//        managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
//        managedObjectContext!.undoManager = nil
//        
        super.init()
    }
    
//    func fetchEntriesWithPredicate(predicate: NSPredicate, sortDescriptors: [AnyObject], completionBlock: (([ManagedTodoItem]) -> Void)!) {
//        let fetchRequest = NSFetchRequest(entityName: "TodoItem")
//        fetchRequest.predicate = predicate
//        fetchRequest.sortDescriptors = []
//        
//        managedObjectContext?.performBlock {
//            do {
//                let queryResults = try self.managedObjectContext?.executeFetchRequest(fetchRequest)
//                let managedResults = queryResults! as [ManagedTodoItem]
//                completionBlock(managedResults)
//            } catch {
//                
//            }
//        }
//    }
    
//    func newTodoItem() -> ManagedTodoItem {
//        let entityDescription = NSEntityDescription.entityForName("TodoItem", inManagedObjectContext: managedObjectContext)
//        let newEntry = NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext) as ManagedTodoItem
//        
//        return newEntry
//    }
    
//    func save() {
//        managedObjectContext?.save()
//    }
}