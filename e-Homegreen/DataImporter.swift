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
        var paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        var filePath = paths.stringByAppendingPathComponent(fileName)
        var checkValidation = NSFileManager.defaultManager()
        if checkValidation.fileExistsAtPath(filePath) {
            println("Postoji.")
            data = NSData(contentsOfFile: filePath)
            var jsonError: NSError?
            if let file = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? JSONDictionary {
                if jsonError == nil {
                    if let zonesDictionary = file["Zones"] as? [JSONDictionary] {
                        var zones:[ZoneJSON] = []
                        for zone in zonesDictionary {
                            zones.append(ZoneJSON(dictionary: zone)!)
                        }
                        return zones
                    }
                }
                return nil
            }
            return nil
            
        } else {
            println("Ne postoji.fileName")
        }
        return nil
    }
    class func createCategoriesFromFile (fileName:String) -> [CategoryJSON]? {
        var data:NSData!
        var paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        var filePath = paths.stringByAppendingPathComponent(fileName)
        var checkValidation = NSFileManager.defaultManager()
        if checkValidation.fileExistsAtPath(filePath) {
            println("Postoji.")
            data = NSData(contentsOfFile: filePath)
            var jsonError: NSError?
            if let file = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? JSONDictionary {
                if jsonError == nil {
                    if let categoriesDictionary = file["Categories"] as? [JSONDictionary] {
                        var categories:[CategoryJSON] = []
                        for category in categoriesDictionary {
                            categories.append(CategoryJSON(dictionary: category)!)
                        }
                        return categories
                    }
                }
                return nil
            }
            return nil
            
            
        } else {
            println("Ne postoji.fileName")
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
            if let idInt = id.toInt(), levelInt = level.toInt() {
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
    let id:String
    let name:String
    let description:String
}

extension CategoryJSON {
    init?(dictionary:JSONDictionary) {
        if let id  = dictionary["ID"] as? String, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String {
            if let idInt = id.toInt() {
                self.id = id
                self.name = name
                self.description = description
                return
            }
        }
        return nil
    }
}