//
//  DatabaseUserController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/31/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseUserController: NSObject {
    
    static let shared = DatabaseUserController()
    
    let prefs = Foundation.UserDefaults.standard
    
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    func getLoggedUser() -> User? {
        if let stringUrl = prefs.value(forKey: Login.User) as? String {
            if let url = URL(string: stringUrl) {
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    if let moc = managedContext {
                        if let user = moc.object(with: id) as? User {
                            return user
                        }
                    }
                }
            }
            
        }
        return nil
    }
    
    func getOtherUser() -> User? {
        if let stringUrl = AdminController.shared.getOtherUser() {
            if let url = URL(string: stringUrl) {
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    if let moc = managedContext {
                        if let user = moc.object(with: id) as? User {
                            return user
                        }
                    }
                }
            }
            
        }
        return nil
    }
    
    func setUser(_ url:String?) -> Bool{
        prefs.setValue(url, forKey: Login.User)
        if let _ = prefs.value(forKey: Login.User) { return true }
        return false
        
    }
    
    func getUserForDropDownMenu() -> [User]? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
        
        do {
            if let moc = managedContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [User] {
                    return fetResults
                }
            }
        } catch {}
        
        return []
    }
    
    func getUser(_ username:String, password:String) -> User? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
        let predicateArray:[NSPredicate] = [
            NSPredicate(format: "username == %@", username),
            NSPredicate(format: "password == %@", password)
        ]
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            if let moc = managedContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [User] {
                    if fetResults.count != 0 { return fetResults[0] } else { return nil }
                }
            }
        } catch {}
        
        return nil
    }
    
    func isLogged() -> Bool {
        return prefs.bool(forKey: Login.IsLoged)
    }
    
    func loginUser() {
        prefs.setValue(true, forKey: Login.IsLoged)
    }

    func logoutUser() {
        prefs.setValue(false, forKey: Login.IsLoged)
    }
    
    func getAllUsers() -> [User] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "username", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne]
        
        do {
            if let moc = managedContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [User] {
                    return fetResults
                }
            }
            
        } catch {}
        
        return []
    }
    
    func removeUser(user: User) {
        if let moc = appDel.managedObjectContext {
            if let locations = user.locations?.allObjects as? [Location] {
                locations.forEach({ (location) in
                    if let gateways = location.gateways?.allObjects as? [Gateway] {
                        gateways.forEach({ (gateway) in
                            if let devices = gateway.devices.allObjects as? [Device] {
                                devices.forEach({ (device) in moc.delete(device) })
                            }
                            moc.delete(gateway)
                        })
                    }
                    
                    if let securities = location.security?.allObjects as? [Security] {
                        securities.forEach({ (security) in moc.delete(security) })
                    }
                    moc.delete(location)
                })
            }
            moc.delete(user)
                        
            CoreDataController.sharedInstance.saveChanges()
        }
        
    }
    
    func loggedUserOrAdmin() -> User? {
        if AdminController.shared.isAdminLogged(){
            if let user = DatabaseUserController.shared.getOtherUser() { return user }
        } else {
            if let user = DatabaseUserController.shared.getLoggedUser() { return user }
        }
        return nil
    }

}
