//
//  DatabaseMacrosController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/6/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseMacrosController: NSObject {

    static let shared = DatabaseMacrosController()
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getMacrosByLocation(location: Location) -> [Macro] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Macro.fetchRequest()
        
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "location == %@", location))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Macro]
            return fetResults!
        } catch  {
        }
        return []
    }
    
    func createMacro(macroId: Int, macroName: String, location:Location){
        
        if let macro = fetchMacroWithId(location: location, id: macroId){
            macro.name = macroName
            
            CoreDataController.shahredInstance.saveChanges()
        }else{
            let macro = Macro(context: appDel.managedObjectContext!)
            
            macro.name = macroName
            macro.macroId = NSNumber(value: macroId)
            
            macro.location = location
            
            CoreDataController.shahredInstance.saveChanges()
        }
        
    }
    
    func fetchMacroWithId(location: Location, id: Int) -> Macro?{
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = Macro.fetchRequest()
        
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "macroId == %@", NSNumber(value: id)))
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate

        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Macro]
            if fetResults!.count != 0{
                return fetResults?[0]
            }
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return nil
    }
}
