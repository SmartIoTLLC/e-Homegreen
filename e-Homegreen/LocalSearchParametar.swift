//
//  LocalSearchParametar.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/12/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

class LocalSearchParametar {
    class func setLocalParametar(tab:String, parametar:[String]) {
        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
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
//    class func setLocalParametar(tab:String, parametars:String...) {
//        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        let keyArray = ["\(tab)GatewaySearch","\(tab)LevelSearch","\(tab)ZoneSearch","\(tab)CategorySearch","\(tab)LevelSearchName","\(tab)ZoneSearchName","\(tab)CategorySearchName"]
//        for var i = 0; i < parametars.count ; i++ {
//            userDefault.setValue(parametars[i], forKey: keyArray[i])
//        }
//    }
    class func getLocalParametar(tab:String) ->[String] {
        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return [userDefault.stringForKey("\(tab)GatewaySearch")!,userDefault.stringForKey("\(tab)LevelSearch")!,userDefault.stringForKey("\(tab)ZoneSearch")!,userDefault.stringForKey("\(tab)CategorySearch")!,userDefault.stringForKey("\(tab)LevelSearchName")!,userDefault.stringForKey("\(tab)ZoneSearchName")!,userDefault.stringForKey("\(tab)CategorySearchName")!]
    }
    class func setLocalIds(tab:String, parametar:[String]) {
        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(parametar[0], forKey: "\(tab)LevelSearchId")
        userDefault.setValue(parametar[1], forKey: "\(tab)ZoneSearchId")
        userDefault.setValue(parametar[2], forKey: "\(tab)CategorySearchId")
        
    }
    class func getLocalIds(tab:String) ->[String] {
        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return [userDefault.stringForKey("\(tab)LevelSearchId")!,userDefault.stringForKey("\(tab)ZoneSearchId")!,userDefault.stringForKey("\(tab)CategorySearchId")!]
    }
}
//class LocalSearchParametar {
//    class func setLocalParametar(tab:String, parametar:FilterParametars) {
//        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        userDefault.setObject(parametar, forKey: "\(tab)FilterParametar")
//
//    }
//    class func getLocalParametar(tab:String) ->FilterParametars {
//        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        return [userDefault.stringForKey("\(tab)GatewaySearch")!,userDefault.stringForKey("\(tab)LevelSearch")!,userDefault.stringForKey("\(tab)ZoneSearch")!,userDefault.stringForKey("\(tab)CategorySearch")!]
//    }
//    class func setLocalIds(tab:String, parametar:FilterParametars) {
//        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        userDefault.setValue(parametar[0], forKey: "\(tab)LevelSearchId")
//        userDefault.setValue(parametar[1], forKey: "\(tab)ZoneSearchId")
//        userDefault.setValue(parametar[2], forKey: "\(tab)CategorySearchId")
//
//    }
//    class func getLocalIds(tab:String) ->FilterParametars {
//        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        return [userDefault.stringForKey("\(tab)LevelSearchId")!,userDefault.stringForKey("\(tab)ZoneSearchId")!,userDefault.stringForKey("\(tab)CategorySearchId")!]
//    }
//}
