//
//  DatabaseUserController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/31/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class DatabaseUserController: NSObject {
    
    static let shared = DatabaseUserController()
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let prefs = NSUserDefaults.standardUserDefaults()
    
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

}
