//
//  DataImporter.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/8/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
class DataImporter {
    class func createZonesFromFile (_ fileName:String) -> [ZoneJSON]? {
        var data:Data!
        let filePath = "" //paths.appendingPathComponent(fileName)
        let checkValidation = FileManager.default
        if checkValidation.fileExists(atPath: filePath) {
            print("Postoji.")
            data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            let jsonError: NSError?
//            ”
            
            do {
                var string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                string = string!.replacingOccurrences(of: "\u{201D}", with: "\"") as NSString?
                let dataFormatted = string?.data(using: String.Encoding.utf8.rawValue)
                let file = try JSONSerialization.jsonObject(with: dataFormatted!, options: []) as! JSONDictionary
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
        var data:Data!
        if let filePath = Bundle.main.path(forResource: "Zones List", ofType: "json") {
            let checkValidation = FileManager.default
            if checkValidation.fileExists(atPath: filePath) {
                print("Postoji.")
                data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
                let jsonError: NSError?
                
                do {
                    var string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    string = string!.replacingOccurrences(of: "\u{201D}", with: "\"") as NSString?
                    let dataFormatted = string?.data(using: String.Encoding.utf8.rawValue)
                    let file = try JSONSerialization.jsonObject(with: dataFormatted!, options: []) as! JSONDictionary
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
    class func createCategoriesFromFile (_ fileName:String) -> [CategoryJSON]? {
        var data:Data!
        let filePath = "" // paths.appendingPathComponent(fileName)
        let checkValidation = FileManager.default
        if checkValidation.fileExists(atPath: filePath) {
            print("Postoji.")
            data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            let jsonError: NSError?
            
            do {
                var string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                string = string!.replacingOccurrences(of: "\u{201D}", with: "\"") as NSString?
                let dataFormatted = string?.data(using: String.Encoding.utf8.rawValue)
                let file = try JSONSerialization.jsonObject(with: dataFormatted!, options: []) as! JSONDictionary
                print(file["Categories"])
                if let categoriesDictionary = file["Categories"] as? [JSONDictionary] {
                    var categories:[CategoryJSON] = []
                    for category in categoriesDictionary {
                        do {
                            let categoryJson = try CategoryJSON.createCategory(category)
                            categories.append(categoryJson)
                        } catch InputError.inputMissing {
                            return nil
                        } catch InputError.idIncorrect {
                            return nil
                        }
                    }
                    return categories
                }
            } catch let error1 as NSError {
                jsonError = error1
                print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
            }
            return nil
            
            
        } else {
            print("Ne postoji.fileName")
        }
        return nil
    }
    class func createCategoriesFromFileFromNSBundle () -> [CategoryJSON]? {
        var data:Data!
        if let filePath = Bundle.main.path(forResource: "Categories List", ofType: "json") {
            let checkValidation = FileManager.default
            if checkValidation.fileExists(atPath: filePath) {
                print("Postoji.")
                data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
                let jsonError: NSError?
                
                do {
                    var string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    string = string!.replacingOccurrences(of: "\u{201D}", with: "\"") as NSString?
                    let dataFormatted = string?.data(using: String.Encoding.utf8.rawValue)
                    let file = try JSONSerialization.jsonObject(with: dataFormatted!, options: []) as! JSONDictionary
                    print(file["Categories"])
                    if let categoriesDictionary = file["Categories"] as? [JSONDictionary] {
                        var categories:[CategoryJSON] = []
                        for category in categoriesDictionary {
                            do {
                                let categoryJson = try CategoryJSON.createCategory(category)
                                categories.append(categoryJson)
                            } catch InputError.inputMissing {
                                return nil
                            } catch InputError.idIncorrect {
                                return nil
                            }
                        }
                        return categories
                    }
                } catch let error1 as NSError {
                    jsonError = error1
                    print("Unresolved error \(jsonError), \(jsonError!.userInfo)")
                }
                return nil
                
                
            } else {
                print("Ne postoji.fileName")
            }
        }
        return nil
    }
    class func createSecuritiesFromFile (_ filePath:String) -> [SecurityJSON]? {
        var data:Data!
        let checkValidation = FileManager.default
        if checkValidation.fileExists(atPath: filePath) {
            print("Postoji.")
            data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            let jsonError: NSError?
            
            do {
                var string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                string = string!.replacingOccurrences(of: "\u{201D}", with: "\"") as NSString?
                let dataFormatted = string?.data(using: String.Encoding.utf8.rawValue)
                let file = try JSONSerialization.jsonObject(with: dataFormatted!, options: []) as! JSONDictionary
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
            if let idInt = Int(id), let levelInt = Int(level) {
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
    static func createCategory(_ dictionary:JSONDictionary) throws -> CategoryJSON {
        guard var id  = dictionary["ID"] as? String, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String else {
            throw InputError.inputMissing
        }
        if id == "" {id = "0"}
        guard let idInt = Int(id) else {
            throw InputError.idIncorrect
        }
        return CategoryJSON(id: idInt, name: name, description: description)
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
