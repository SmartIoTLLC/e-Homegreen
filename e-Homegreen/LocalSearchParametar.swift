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
        userDefault.setValue(parametar[0], forKey: "\(tab)GatewaySearch")
        userDefault.setValue(parametar[1], forKey: "\(tab)LevelSearch")
        userDefault.setValue(parametar[2], forKey: "\(tab)ZoneSearch")
        userDefault.setValue(parametar[3], forKey: "\(tab)CategorySearch")
        
    }
    class func getLocalParametar(tab:String) ->[String] {
        let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return [userDefault.stringForKey("\(tab)GatewaySearch")!,userDefault.stringForKey("\(tab)LevelSearch")!,userDefault.stringForKey("\(tab)ZoneSearch")!,userDefault.stringForKey("\(tab)CategorySearch")!]
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
