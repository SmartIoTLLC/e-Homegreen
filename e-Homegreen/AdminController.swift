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
    
    let prefs = Foundation.UserDefaults.standard
    
    func setAdmin(_ username:String, password:String) -> Bool{
        prefs.setValue(username, forKey: AdminConstants.Username)
        prefs.setValue(password, forKey: AdminConstants.Password)
        
        if  let _ = prefs.string(forKey: AdminConstants.Username), let _ = prefs.string(forKey: AdminConstants.Password){
            return true
        }
        return false
    }
    
    func getAdmin() -> Admin?{
        print("admin username: \(prefs.string(forKey: AdminConstants.Username))")
        print("admin password: \(prefs.string(forKey: AdminConstants.Password))")
        if  let username = prefs.string(forKey: AdminConstants.Username), let password = prefs.string(forKey: AdminConstants.Password){
            return Admin(username: username, password: password)
        }
        return nil
    }
    
    func loginAdmin(){
        prefs.setValue(true, forKey: AdminConstants.IsLogged)
    }
    
    func logoutAdmin(){
        prefs.setValue(false, forKey: AdminConstants.IsLogged)
        prefs.setValue(nil, forKey: AdminConstants.OtherUserDatabase)
    }
    
    func isAdminLogged() -> Bool{
        if let isLogged = prefs.value(forKey: AdminConstants.IsLogged) as? Bool{
            return isLogged
        }
        return false
    }
    func getOtherUser() -> String?{
        if let str = prefs.value(forKey: AdminConstants.OtherUserDatabase) as? String{
            return str
        }
        return nil
    }
    func setOtherUser(_ url:String?) -> Bool{
        prefs.setValue(url, forKey: AdminConstants.OtherUserDatabase)
        if let _ = prefs.value(forKey: AdminConstants.OtherUserDatabase) as? String{
            return true
        }
        return false
    }
    
}
