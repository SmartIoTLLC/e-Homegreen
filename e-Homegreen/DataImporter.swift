//
//  DataImporter.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/8/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
//IPGCW02001_000_000_Categories List
//IPGCW02001_000_000_Zones List
//
//var dataCategory = DataImporter(fileName: "IPGCW02001_000_000_Categories List.json")
//if let dateCategories = dataCategory.createCategoriesFromFile()! {
//    categories = dataCategories
//}
class DataImporter {
    //    init(fileName:String) {
    //        var paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    //        var filePath = paths.stringByAppendingPathComponent(fileName)
    //        var checkValidation = NSFileManager.defaultManager()
    //        if checkValidation.fileExistsAtPath(filePath) {
    //            println("Postoji.")
    ////            data = NSData(contentsOfFile: filePath)
    //
    //        } else {
    //            println("Ne postoji.fileName")
    //        }
    //    }
    class func createZonesFromFile (fileName:String) -> [ZoneJSON]? {
        var data:NSData!
        let paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let filePath = paths.stringByAppendingPathComponent(fileName)
        let checkValidation = NSFileManager.defaultManager()
        if checkValidation.fileExistsAtPath(filePath) {
            print("Postoji.")
            data = NSData(contentsOfFile: filePath)
            let jsonError: NSError?
            
            do {
                let file = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDictionary
                print(file["Zones"])
                if let zonesDictionary = file["Zones"] as? [JSONDictionary] {
                    var zones:[ZoneJSON] = []
                    for zone in zonesDictionary {
                        zones.append(ZoneJSON(dictionary: zone)!)
                    }
                    return zones
                }
            } catch let error1 as NSError {
                jsonError = error1
                print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
                abort()
            }
            return nil
            
        } else {
            print("Ne postoji.fileName")
        }
        return nil
    }
    class func createZonesFromFileFromNSBundle () -> [ZoneJSON]? {
        var data:NSData!
        if let filePath = NSBundle.mainBundle().pathForResource("Zones List", ofType: "json") {
            //        let filePath = paths.stringByAppendingPathComponent(fileName)
            let checkValidation = NSFileManager.defaultManager()
            if checkValidation.fileExistsAtPath(filePath) {
                print("Postoji.")
                data = NSData(contentsOfFile: filePath)
                let jsonError: NSError?
                
                do {
                    let file = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDictionary
                    print(file["Zones"])
                    if let zonesDictionary = file["Zones"] as? [JSONDictionary] {
                        var zones:[ZoneJSON] = []
                        for zone in zonesDictionary {
                            zones.append(ZoneJSON(dictionary: zone)!)
                        }
                        return zones
                    }
                } catch let error1 as NSError {
                    jsonError = error1
                    print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
                    abort()
                }
                return nil
                
            } else {
                print("Ne postoji.fileName")
            }
        }
        return nil
    }
    class func createCategoriesFromFile (fileName:String) -> [CategoryJSON]? {
        var data:NSData!
        let paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let filePath = paths.stringByAppendingPathComponent(fileName)
        let checkValidation = NSFileManager.defaultManager()
        if checkValidation.fileExistsAtPath(filePath) {
            print("Postoji.")
            data = NSData(contentsOfFile: filePath)
            let jsonError: NSError?
            
            do {
                let file = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDictionary
                print(file["Categories"])
                if let categoriesDictionary = file["Categories"] as? [JSONDictionary] {
                    var categories:[CategoryJSON] = []
                    for category in categoriesDictionary {
                        categories.append(CategoryJSON(dictionary: category)!)
                    }
                    return categories
                }
            } catch let error1 as NSError {
                jsonError = error1
                print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
                abort()
            }
            return nil
            
            
        } else {
            print("Ne postoji.fileName")
        }
        return nil
    }
    class func createCategoriesFromFileFromNSBundle () -> [CategoryJSON]? {
        var data:NSData!
        if let filePath = NSBundle.mainBundle().pathForResource("Categories List", ofType: "json") {
            //        let filePath = paths.stringByAppendingPathComponent(fileName)
            let checkValidation = NSFileManager.defaultManager()
            if checkValidation.fileExistsAtPath(filePath) {
                print("Postoji.")
                data = NSData(contentsOfFile: filePath)
                let jsonError: NSError?
                
                do {
                    let file = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDictionary
                    print(file["Categories"])
                    if let categoriesDictionary = file["Categories"] as? [JSONDictionary] {
                        var categories:[CategoryJSON] = []
                        for category in categoriesDictionary {
                            categories.append(CategoryJSON(dictionary: category)!)
                        }
                        return categories
                    }
                } catch let error1 as NSError {
                    jsonError = error1
                    print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
                    abort()
                }
                return nil
                
                
            } else {
                print("Ne postoji.fileName")
            }
        }
        return nil
    }
    class func createSecuritiesFromFile (filePath:String) -> [SecurityJSON]? {
        var data:NSData!
        //        let paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        //        let filePath = paths.stringByAppendingPathComponent(fileName)
        let checkValidation = NSFileManager.defaultManager()
        if checkValidation.fileExistsAtPath(filePath) {
            print("Postoji.")
            data = NSData(contentsOfFile: filePath)
            let jsonError: NSError?
            
            do {
                let file = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDictionary
                print(file["Securities"])
                if let securitiesDictionary = file["Securities"] as? [JSONDictionary] {
                    var securities:[SecurityJSON] = []
                    for security in securitiesDictionary {
                        securities.append(SecurityJSON(dictionary: security)!)
                    }
                    return securities
                }
            } catch let error1 as NSError {
                jsonError = error1
                print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
                abort()
            }
            return nil
            
            
        } else {
            print("Ne postoji.fileName")
        }
        return nil
    }
}

typealias JSONDictionary = [String:AnyObject]

struct ZoneJSON {
    let id:Int
    let level:Int
    let name:String
    let description:String
}

extension ZoneJSON {
    init?(dictionary:JSONDictionary) {
        if let id = dictionary["ID"] as? String, let level = dictionary["Level"] as? String, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String {
            if let idInt = Int(id), levelInt = Int(level) {
                self.id = idInt
                self.level = levelInt
                self.name = name
                self.description = description
                return
            }
        }
        return nil
    }
}

struct CategoryJSON {
    let id:Int
    let name:String
    let description:String
}

extension CategoryJSON {
    init?(dictionary:JSONDictionary) {
        if let id  = dictionary["ID"] as? String, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String {
            if let idInt = Int(id) {
                self.id = idInt
                self.name = name
                self.description = description
                return
            }
        }
        return nil
    }
}

struct SecurityJSON {
    let name:String
    let modeExplanation:String
}
extension SecurityJSON {
    init?(dictionary:JSONDictionary) {
        if let name = dictionary["name"] as? String, let modeExplanation = dictionary["modeExplanation"] as? String {
            self.name = name
            self.modeExplanation = modeExplanation
            return
        }
        return nil
    }
}