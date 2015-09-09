//
//  Category.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/8/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation

struct Category {
    let id:Int
    let name:String
    let description:String
}

extension Category {
    init?(dictionary:JSONDictionary) {
        if let id  = dictionary["id"] as? Int, let name = dictionary["Name"] as? String, let description = dictionary["Description"] as? String {
            self.id = id
            self.name = name
            self.description = description
            return
        }
        return nil
    }
}