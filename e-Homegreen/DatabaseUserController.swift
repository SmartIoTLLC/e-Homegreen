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
    
    func getLoggedUser() -> User?{
        if let stringUrl = prefs.value(forKey: Login.User) as? String{
            if let url = URL(string: stringUrl){
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    if let user = appDel.managedObjectContext?.object(with: id) as? User {
                        return user
                    }
                }
            }
            
        }
        return nil
    }
    
    func getOtherUser() -> User?{
        if let stringUrl = AdminController.shared.getOtherUser(){
            if let url = URL(string: stringUrl){
                if let id = appDel.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    if let user = appDel.managedObjectContext?.object(with: id) as? User {
                        return user
                    }
                }
            }
            
        }
        return nil
    }
    func setUser(_ url:String?) -> Bool{
        prefs.setValue(url, forKey: Login.User)
        if let _ = prefs.value(forKey: Login.User){
            return true
        }
        return false
        
    }
    
    func getUserForDropDownMenu() -> [User] {
        let userEntity = String(describing: User.self)
        let request = NSFetchRequest<User>(entityName: userEntity)
        //let fetchRequest: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
        /* Uz zakomentarisani FetchRequest je pucalo iz nekog razloga nakon ubijanja aplikacije*/
        
        do {
            let fetResults = try appDel.managedObjectContext?.fetch(request)
            return fetResults ?? []
            
        } catch  {
            
        }
        return []
    }
    
    func getUser(_ username:String, password:String) -> User? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
        let predicateOne = NSPredicate(format: "username == %@", username)
        let predicateTwo = NSPredicate(format: "password == %@", password)
        let predicateArray:[NSPredicate] = [predicateOne, predicateTwo]
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [User] {
                    if let user = results.first {
                        return user
                    }
                }
            }
        } catch  {}
        return nil
    }
    
    func isLogged() -> Bool{
        return prefs.bool(forKey: Login.IsLoged)
    }
    
    func loginUser(){
        prefs.setValue(true, forKey: Login.IsLoged)
    }

    func logoutUser(){    
        prefs.setValue(false, forKey: Login.IsLoged)
    }
    
    func getAllUsers() -> [User] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "username", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne]
        do {
            let fetResults = try appDel.managedObjectContext?.fetch(fetchRequest) as? [User]
            return fetResults ?? []
        } catch  {
            
        }
        return []
    }
    
    func removeUser(user: User){
        appDel.managedObjectContext?.delete(user)
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func logedUserOrAdmin() -> User?{
        if AdminController.shared.isAdminLogged(){
            if let user = DatabaseUserController.shared.getOtherUser(){
                return user
            }
        }else{
            if let user = DatabaseUserController.shared.getLoggedUser(){
                return user
            }
        }
        return nil
    }

}
