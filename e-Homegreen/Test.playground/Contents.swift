////: Playground - noun: a place where people can play
//
//import UIKit
//
//var str = "Hello, playground"
//var mac:[UInt8] = [0x01, 0x00, 0x00]
//var password:[UInt8] = [0x01, 0x00, 0x00]
//var messageInfo:[UInt8] = [0x01, 0x00, 0x00]
//messageInfo += mac
//messageInfo += password
//class Hey: NSObject {
//    func wakeOnLan (address:[UInt8], mac:[UInt8], password:[UInt8]) -> [UInt8]{
//        guard mac.count == 6 && password.count == 6 && address.count == 3 else {
//            return [0x00]
//        }
//        return [0x02]
//    }
//}
//Hey().wakeOnLan([1,2,3], mac: [1,2,3,4,5,6], password: [1,2,3,4,5,6])
//let locations:[NSObject:[AnyObject]] = [
//    1:["String1",12,43.5, "String Vladimir"],
//    "String":["String",1,3.5, "String"],]
//
//let array = locations[1]?[0]
//locations["String"]
//
//struct Users {
//    let name:String
//    let stores:[Int]
//}
//var users : [String: AnyObject] = [:]
//users["name"] = "SomeName"
//users["stores"] = [1,1,1,1,1]
//NSUserDefaults.standardUserDefaults().setObject(users, forKey: "Users")
//users = [:]
//if let myDictionaryFromUD = NSUserDefaults.standardUserDefaults().objectForKey("Users") as? [String:AnyObject]{
//    myDictionaryFromUD["name"]
//    let user = Users(name: myDictionaryFromUD["name"] as! String, stores: myDictionaryFromUD["stores"] as! [Int])
//    
//}
////
////  User.swift
////  BlueToothTest
////
////  Created by Damir Djozic on 12/8/15.
////  Copyright © 2015 NotYetNamed. All rights reserved.
////
//
////import Foundation
//
///// Class that represents User entity
//
//
//
//
////let userToSave = User(id: 1, email: "123")
////let defaults = NSUserDefaults.standardUserDefaults()
////let encodedData = NSKeyedArchiver.archivedDataWithRootObject(userToSave)
////defaults.setObject(encodedData, forKey: "Paprika")
////defaults.synchronize()
////let user:User?
////if let savedUser = defaults.objectForKey("Paprika") as? NSData {
////    user = NSKeyedUnarchiver.unarchiveObjectWithData(savedUser) as? User
////}
////user
import UIKit
struct Location {
    let id:Int
    let name:String?
}
let results = [Location(id: 1, name: "Teodor"),Location(id: 1, name: "Teodor"),Location(id: 1, name: "Teodor"),Location(id: 1, name: "Teodor"),Location(id: 1, name: "Teodor"),Location(id: 1, name: "Damir"),Location(id: 1, name: "Teodor"),Location(id: 1, name: "Sladjan"),Location(id: 1, name: "Teodor")]
let locationNames = results.map({ (let location) -> String in
    if let name = location.name {
        return name
    }
    return ""
}).filter({ (let name) -> Bool in
    return name != "" ? true : false
}).
sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
