//
//  AdminController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

struct Admin{
    var username:String
    var password:String
}

class AdminController: NSObject {
    
    static let shared = AdminController()
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    func setAdmin(username:String, password:String) -> Bool{
        prefs.setValue(username, forKey: AdminConstants.Username)
        prefs.setValue(password, forKey: AdminConstants.Password)
        
        if  let _ = prefs.stringForKey(AdminConstants.Username), let _ = prefs.stringForKey(AdminConstants.Password){
            return true
        }
        return false
    }
    
    func getAdmin() -> Admin?{
        if  let username = prefs.stringForKey(AdminConstants.Username), let password = prefs.stringForKey(AdminConstants.Password){
            return Admin(username: username, password: password)
        }
        return nil
    }
    
    func loginAdmin(){
        prefs.setValue(true, forKey: AdminConstants.IsLogged)
    }
    
    func logoutAdmin(){
        prefs.setValue(false, forKey: AdminConstants.IsLogged)
    }
    
    func isAdminLogged() -> Bool{
        return (prefs.valueForKey(AdminConstants.IsLogged) as? Bool)!
    }
    func getOtherUser() -> String?{
        if let str = prefs.valueForKey(AdminConstants.OtherUserDatabase) as? String{
            return str
        }
        return nil
    }
    func setOtherUser(url:String) -> Bool{
        prefs.setValue(url, forKey: AdminConstants.OtherUserDatabase)
        if let _ = prefs.valueForKey(AdminConstants.OtherUserDatabase) as? String{
            return true
        }
        return false
    }
    
}
