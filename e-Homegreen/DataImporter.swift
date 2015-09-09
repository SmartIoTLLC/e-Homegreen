//
//  DataImporter.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/8/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation

class DataImporter {
    init(fileName:String) {
        var paths: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        var filePath = paths.stringByAppendingPathComponent(fileName)
        var checkValidation = NSFileManager.defaultManager()
        
        if checkValidation.fileExistsAtPath(filePath) {
            println("Postoji.")
        } else {
            println("Ne postoji.fileName")
        }
    }
    func createZonesFromFile (file:AnyObject) -> [Zone]? {
        if let file = file as? JSONDictionary {
            if let zonesDictionary = file["Zones"] as? [JSONDictionary] {
                var zones:[Zone] = []
                for zone in zonesDictionary {
                    zones.append(Zone(dictionary: zone)!)
                }
                return zones
            }
            return nil
        }
        return nil
    }
    func createCategoriesFromFile (file:AnyObject) -> [Category]? {
        if let file = file as? JSONDictionary {
            if let categoriesDictionary = file["Categories"] as? [JSONDictionary] {
                var categories:[Category] = []
                for category in categoriesDictionary {
                    categories.append(Category(dictionary: category)!)
                }
                return categories
            }
            return nil
        }
        return nil
    }
}