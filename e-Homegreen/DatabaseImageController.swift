//
//  DatabaseImageController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 8/17/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseImageController: NSObject {
    
    static let shared = DatabaseImageController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    func getImageById(id:String) -> Image?{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Image")
        let predicateArray:[NSPredicate] = [NSPredicate(format: "imageId == %@", id)]
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Image]
            if fetResults?.count != 0{
                return fetResults?.first
            }
        } catch _ as NSError {
            abort()
        }
        
        return nil
    }

}
