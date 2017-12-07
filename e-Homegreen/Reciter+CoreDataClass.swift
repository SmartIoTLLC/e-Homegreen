//
//  Reciter+CoreDataClass.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/15/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData


public class Reciter: NSManagedObject {

    convenience init(context: NSManagedObjectContext, id: String, name: String, server: String, rewaya: String, count: String, letter: String, suras: String) {
        self.init(context: context)
        
        self.id     = id
        self.name   = name
        self.server = server
        self.rewaya = rewaya
        self.count  = count
        self.letter = letter
        self.suras  = suras
    }
    
    func getRecitersSurasAsInt() -> [Int16]? {
        if let string = self.suras {
            let stringArray = string.components(separatedBy: ",")
            return stringArray.map { Int16($0) ?? 0 }
        }
        return []
    }
}
