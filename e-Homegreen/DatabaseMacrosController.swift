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
    
    func createMacro(macroId: Int, macroName: String, location:Location, macroImageOneDefault:String? = "12 Appliance - Bell - 00", macroImageTwoDefault:String? = "12 Appliance - Bell - 01", macroImageOneCustom:String? = nil, macroImageTwoCustom:String? = nil, imageDataOne:Data? = nil, imageDataTwo:Data? = nil){
        
        if let macro = fetchMacroWithId(location: location, id: macroId){
            macro.name = macroName
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    macro.macroImageOneCustom = image.imageId
                    macro.macroImageOneDefault = nil
                    location.user!.addImagesObject(image)
                }
            }else{
                macro.macroImageOneDefault = macroImageOneDefault
                macro.macroImageOneCustom = macroImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    macro.macroImageTwoCustom = image.imageId
                    macro.macroImageTwoDefault = nil
                    location.user!.addImagesObject(image)
                    
                }
            }else{
                macro.macroImageTwoDefault = macroImageTwoDefault
                macro.macroImageTwoCustom = macroImageTwoCustom
            }
            
            CoreDataController.shahredInstance.saveChanges()
        }else{
            let macro = Macro(context: appDel.managedObjectContext!)
            
            if let imageDataOne = imageDataOne{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataOne
                    image.imageId = UUID().uuidString
                    macro.macroImageOneCustom = image.imageId
                    macro.macroImageOneDefault = nil
                    location.user!.addImagesObject(image)
                }
            }else{
                macro.macroImageOneDefault = macroImageOneDefault
                macro.macroImageOneCustom = macroImageOneCustom
            }
            
            if let imageDataTwo = imageDataTwo{
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                    image.imageData = imageDataTwo
                    image.imageId = UUID().uuidString
                    macro.macroImageTwoCustom = image.imageId
                    macro.macroImageTwoDefault = nil
                    location.user!.addImagesObject(image)
                    
                }
            }else{
                macro.macroImageTwoDefault = macroImageTwoDefault
                macro.macroImageTwoCustom = macroImageTwoCustom
            }
            
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
        predicateArray.append(NSPredicate(format: "location == %@", location))
        
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
    
    func deleteAllMacros(_ gateway:Gateway){
        let macros = gateway.location.macros?.allObjects as! [Macro]
        for macro in macros {
            self.appDel.managedObjectContext!.delete(macro)
        }
        
        CoreDataController.shahredInstance.saveChanges()
    }
    
    func deleteMacro(_ macro:Macro){
        self.appDel.managedObjectContext!.delete(macro)
        CoreDataController.shahredInstance.saveChanges()
    }
}
