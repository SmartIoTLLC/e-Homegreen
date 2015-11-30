//
//  DataImporter.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/8/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
class DataImporter {
    class func createZonesFromFile (fileName:String) -> [ZoneJSON]? {
        var data:NSData!
        let paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let filePath = paths.stringByAppendingPathComponent(fileName)
        let checkValidation = NSFileManager.defaultManager()
        if checkValidation.fileExistsAtPath(filePath) {
            print("Postoji.")
            data = NSData(contentsOfFile: filePath)
            let jsonError: NSError?
//            ”
            
            do {
                var string = NSString(data: data, encoding: NSUTF8StringEncoding)
                string = string!.stringByReplacingOccurrencesOfString("\u{201D}", withString: "\"")
                let dataFormatted = string?.dataUsingEncoding(NSUTF8StringEncoding)
                let file = try NSJSONSerialization.JSONObjectWithData(dataFormatted!, options: []) as! JSONDictionary
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
//                abort()
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
                    var string = NSString(data: data, encoding: NSUTF8StringEncoding)
                    string = string!.stringByReplacingOccurrencesOfString("\u{201D}", withString: "\"")
                    let dataFormatted = string?.dataUsingEncoding(NSUTF8StringEncoding)
                    let file = try NSJSONSerialization.JSONObjectWithData(dataFormatted!, options: []) as! JSONDictionary
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
//                    abort()
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
                var string = NSString(data: data, encoding: NSUTF8StringEncoding)
                string = string!.stringByReplacingOccurrencesOfString("\u{201D}", withString: "\"")
                let dataFormatted = string?.dataUsingEncoding(NSUTF8StringEncoding)
                let file = try NSJSONSerialization.JSONObjectWithData(dataFormatted!, options: []) as! JSONDictionary
                print(file["Categories"])
                if let categoriesDictionary = file["Categories"] as? [JSONDictionary] {
                    var categories:[CategoryJSON] = []
                    for category in categoriesDictionary {
                        do {
                            let categoryJson = try CategoryJSON.createCategory(category)
                            categories.append(categoryJson)
                        } catch InputError.InputMissing {
                            return nil
                        } catch InputError.IdIncorrect {
                            return nil
                        }
                    }
                    return categories
                }
            } catch let error1 as NSError {
                jsonError = error1
                print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
//                abort()
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
                    var string = NSString(data: data, encoding: NSUTF8StringEncoding)
                    string = string!.stringByReplacingOccurrencesOfString("\u{201D}", withString: "\"")
                    let dataFormatted = string?.dataUsingEncoding(NSUTF8StringEncoding)
                    let file = try NSJSONSerialization.JSONObjectWithData(dataFormatted!, options: []) as! JSONDictionary
                    print(file["Categories"])
                    if let categoriesDictionary = file["Categories"] as? [JSONDictionary] {
                        var categories:[CategoryJSON] = []
                        for category in categoriesDictionary {
                            do {
                                let categoryJson = try CategoryJSON.createCategory(category)
                                categories.append(categoryJson)
                            } catch InputError.InputMissing {
                                return nil
                            } catch InputError.IdIncorrect {
                                return nil
                            }
                        }
                        return categories
                    }
                } catch let error1 as NSError {
                    jsonError = error1
                    print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
//                    abort()
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
                var string = NSString(data: data, encoding: NSUTF8StringEncoding)
                string = string!.stringByReplacingOccurrencesOfString("\u{201D}", withString: "\"")
                let dataFormatted = string?.dataUsingEncoding(NSUTF8StringEncoding)
                let file = try NSJSONSerialization.JSONObjectWithData(dataFormatted!, options: []) as! JSONDictionary
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
//                abort()
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
        if var id = dictionary["ID"] as? String, var level = dictionary["Level"] as? String, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String {
            if id == "" {id = "0"}
            if level == "" {level = "0"}
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

//class func createCategoriesFromFileFromNSBundle () throws -> [CategoryJSON]? {
//    
//}
extension CategoryJSON {
    static func createCategory(dictionary:JSONDictionary) throws -> CategoryJSON {
        guard var id  = dictionary["ID"] as? String, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String else {
            throw InputError.InputMissing
        }
        if id == "" {id = "0"}
        guard let idInt = Int(id) else {
            throw InputError.IdIncorrect
        }
//        if var id  = dictionary["ID"] as? String, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String {
//            if id == "" {id = "0"}
//            if let idInt = Int(id) {
//                self.id = idInt
//                self.name = name
//                self.description = description
//                return
//            }
//        }
        return CategoryJSON(id: idInt, name: name, description: description)
    }
}
//extension CategoryJSON {
//    init?(dictionary:JSONDictionary) throws {
//        if var id  = dictionary["ID"] as? String, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String {
//            if id == "" {id = "0"}
//            if let idInt = Int(id) {
//                self.id = idInt
//                self.name = name
//                self.description = description
//                return
//            }
//        }
//        return nil
//    }
//}

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