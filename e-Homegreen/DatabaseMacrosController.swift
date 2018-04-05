//
//  DatabaseMacrosController.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/27/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import Foundation
import CoreData

class DatabaseMacrosController {
    
    open static let sharedInstance = DatabaseMacrosController()
    
     let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    func saveMacroToCD(name: String, type: String, leftImage: String, rightImage: String) -> Bool {
        if let macroEntity = NSEntityDescription.entity(forEntityName: "Macro", in: managedContext!) {
            let macroInstance = NSManagedObject(entity: macroEntity, insertInto: managedContext!)
            
            macroInstance.setValue(name, forKey: "name")
            macroInstance.setValue(type, forKey: "type")
            macroInstance.setValue(leftImage, forKey: "negative_image")
            macroInstance.setValue(rightImage, forKey: "positive_image")
            
            macroInstance.setValue("", forKey: "macro_zone")
            macroInstance.setValue(1, forKey: "macro_location")
            macroInstance.setValue("", forKey: "macro_level")
            macroInstance.setValue("", forKey: "macro_category")
            
            if saveChanges() == true {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func addActionToMacros(command: NSNumber, control_type: String, delay: NSNumber, deviceAddress: NSNumber, gatewayAddressOne: NSNumber, gatewayAddressTwo: NSNumber, deviceChannel: NSNumber, macro: Macro) -> Bool { //TODO: macro: [Macro] must be array
      
        if let macroActionInstance = NSEntityDescription.insertNewObject(forEntityName: "Macro_action", into: managedContext!) as? Macro_action {
            
            macroActionInstance.command = command
            macroActionInstance.control_type = control_type
            macroActionInstance.delay = delay
            macroActionInstance.deviceAddress = deviceAddress
            macroActionInstance.gatewayAddressOne = gatewayAddressOne
            macroActionInstance.gatewayAddressTwo = gatewayAddressTwo
            macroActionInstance.deviceChannel = deviceChannel
        
            do {
                macro.addToMacro_actions(macroActionInstance)
                try managedContext?.save()
            } catch let error as NSError {
                print("Unable to save to core data from DatabaseMacrosController, because of \(error), \(error.userInfo)")
                managedContext?.rollback()
                return false
            }
        } else {
            print("nisam uspeo")
            return false
        }
       
            return true
        }
    
    func fetchMacroActionsFor(macro: Macro) {
        var macroAction = [Macro_action]()
        print("MACRO: \(macro.name)")
        for action in macro.macro_actions! {
            macroAction.append(action as! Macro_action)
        }
        
        for action in macroAction {
            print("NEW")
            print(action.command)
            print(action.control_type)
            print(action.deviceAddress)
            print(action.gatewayAddressOne)
            print(action.gatewayAddressTwo)
            print(action.deviceChannel)
        }
      


    }
    
    
    func fetchAllMacrosFromCD() -> [Macro]? {
        let fetchRequest = NSFetchRequest<Macro>(entityName: "Macro")
        do {
          let fetchResult = try managedContext?.fetch(fetchRequest)
            return fetchResult
        } catch let error as NSError {
            print("Error during fetching Macros, \(error), \(error.userInfo)")
        }
        return nil
    }
    
    private func saveChanges() -> Bool {
        do {
            try managedContext?.save()
        } catch let error as NSError {
            print("Unable to save to core data from DatabaseMacrosController, because of \(error), \(error.userInfo)")
            managedContext?.rollback()
            return false
        }
        return true
    }
    
    
    
    
    
}
