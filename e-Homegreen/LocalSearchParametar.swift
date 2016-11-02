//
//  LocalSearchParametar.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/12/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

class LocalSearchParametar {
    class func setLocalParametar(_ tab:String, parametar:[String]) {
        let userDefault:Foundation.UserDefaults = Foundation.UserDefaults.standard
        if parametar.count <= 4 {
            userDefault.setValue(parametar[0], forKey: "\(tab)GatewaySearch")
            userDefault.setValue(parametar[1], forKey: "\(tab)LevelSearch")
            userDefault.setValue(parametar[2], forKey: "\(tab)ZoneSearch")
            userDefault.setValue(parametar[3], forKey: "\(tab)CategorySearch")
        } else {
            userDefault.setValue(parametar[0], forKey: "\(tab)GatewaySearch")
            userDefault.setValue(parametar[1], forKey: "\(tab)LevelSearch")
            userDefault.setValue(parametar[2], forKey: "\(tab)ZoneSearch")
            userDefault.setValue(parametar[3], forKey: "\(tab)CategorySearch")
            userDefault.setValue(parametar[4], forKey: "\(tab)LevelSearchName")
            userDefault.setValue(parametar[5], forKey: "\(tab)ZoneSearchName")
            userDefault.setValue(parametar[6], forKey: "\(tab)CategorySearchName")
        }
    }
    class func getLocalParametar(_ tab:String) ->[String] {
        let userDefault:Foundation.UserDefaults = Foundation.UserDefaults.standard
        var stringForGatewaySearch = "All"
        var stringForLevelSearch = "All"
        var stringForZoneSearch = "All"
        var stringForCategorySearch = "All"
        var stringForLevelSearchNeme = "All"
        var stringForZoneSearchName = "All"
        var stringForCategorySearchName = "All"
        if let a = userDefault.string(forKey: "\(tab)GatewaySearch"){
            stringForGatewaySearch = a
        }
        if let b = userDefault.string(forKey: "\(tab)LevelSearch"){
            stringForLevelSearch = b
        }
        if let c = userDefault.string(forKey: "\(tab)ZoneSearch"){
            stringForZoneSearch = c
        }
        if let d = userDefault.string(forKey: "\(tab)CategorySearch"){
            stringForCategorySearch = d
        }
        if let e = userDefault.string(forKey: "\(tab)LevelSearchName"){
            stringForLevelSearchNeme = e
        }
        if let f = userDefault.string(forKey: "\(tab)ZoneSearchName"){
            stringForZoneSearchName = f
        }
        if let g = userDefault.string(forKey: "\(tab)CategorySearchName"){
            stringForCategorySearchName = g
        }
        
        return [stringForGatewaySearch,stringForLevelSearch, stringForZoneSearch, stringForCategorySearch, stringForLevelSearchNeme, stringForZoneSearchName, stringForCategorySearchName]
    }
    class func setLocalIds(_ tab:String, parametar:[String]) {
        let userDefault:Foundation.UserDefaults = Foundation.UserDefaults.standard
        userDefault.setValue(parametar[0], forKey: "\(tab)LevelSearchId")
        userDefault.setValue(parametar[1], forKey: "\(tab)ZoneSearchId")
        userDefault.setValue(parametar[2], forKey: "\(tab)CategorySearchId")
        
    }
    class func getLocalIds(_ tab:String) ->[String] {
        let userDefault:Foundation.UserDefaults = Foundation.UserDefaults.standard
        return [userDefault.string(forKey: "\(tab)LevelSearchId")!,userDefault.string(forKey: "\(tab)ZoneSearchId")!,userDefault.string(forKey: "\(tab)CategorySearchId")!]
    }
}
