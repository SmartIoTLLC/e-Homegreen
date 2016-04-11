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
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getLoggedUser() -> User?{
        if let stringUrl = prefs.valueForKey(Login.User) as? String{
            if let url = NSURL(string: stringUrl){
                if let id = appDel.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) {
                    if let user = appDel.managedObjectContext?.objectWithID(id) as? User {
                        return user
                    }
                }
            }
            
        }
        return nil
    }
    
    func getOtherUser() -> User?{
        if let stringUrl = AdminController.shared.getOtherUser(){
            if let url = NSURL(string: stringUrl){
                if let id = appDel.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url) {
                    if let user = appDel.managedObjectContext?.objectWithID(id) as? User {
                        return user
                    }
                }
            }
            
        }
        return nil
    }
    func setUser(url:String?) -> Bool{
        prefs.setValue(url, forKey: Login.User)
        if let _ = prefs.valueForKey(Login.User){
            return true
        }
        return false
        
    }
    
    func getUser(username:String, password:String) -> User? {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let predicateOne = NSPredicate(format: "username == %@", username)
        let predicateTwo = NSPredicate(format: "password == %@", password)
        let predicateArray:[NSPredicate] = [predicateOne, predicateTwo]
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [User]
            if fetResults?.count != 0{
                return fetResults?[0]
            }else{
                return nil
            }
            
            
        } catch  {
            
        }
        return nil
    }
    
    func isLogged() -> Bool{
        return prefs.boolForKey(Login.IsLoged)
    }
    
    func loginUser(){
        prefs.setValue(true, forKey: Login.IsLoged)
    }

    func logoutUser(){    
        prefs.setValue(false, forKey: Login.IsLoged)
    }

}
