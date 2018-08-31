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
    var screenWidth: CGFloat?
    var screenHeight: CGFloat?
    
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
    
    func addActionToMacros(command: NSNumber, control_type: String, delay: NSNumber, deviceAddress: NSNumber, gatewayAddressOne: NSNumber, gatewayAddressTwo: NSNumber, gatewayId: String?, deviceChannel: NSNumber, macro: Macro) -> Bool { //TODO: macro: [Macro] must be array
        
        if let macroActionInstance = NSEntityDescription.insertNewObject(forEntityName: "Macro_action", into: managedContext!) as? Macro_action {
            
            macroActionInstance.command = command
            macroActionInstance.control_type = control_type
            macroActionInstance.delay = delay
            macroActionInstance.deviceAddress = deviceAddress
            macroActionInstance.gatewayAddressOne = gatewayAddressOne
            macroActionInstance.gatewayAddressTwo = gatewayAddressTwo
            macroActionInstance.deviceChannel = deviceChannel
            macroActionInstance.gatewayId = gatewayId
            
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
    
    func fetchMacroActionsFor(macro: Macro) -> [Macro_action] {
        var macroAction = [Macro_action]()
        
        for action in macro.macro_actions! {
            macroAction.append(action as! Macro_action)
        }
        
        return macroAction
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
    
    func removeFromCD(macroAction: Macro_action) -> Bool {
        managedContext?.delete(macroAction)
        return saveChanges()
    }
    
    func removeFromCD(macro: Macro) -> Bool {
        managedContext?.delete(macro)
        return saveChanges()
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
