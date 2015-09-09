//
//  Zone.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/8/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String:AnyObject]

struct Zone {
    let id:Int
    let level:Int
    let name:String
    let description:String
}

extension Zone {
    init?(dictionary:JSONDictionary) {
        if let id = dictionary["Id"] as? Int, let level = dictionary["Level"] as? Int, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String {
            self.id = id
            self.level = level
            self.name = name
            self.description = description
            return
        }
        return nil
    }
}