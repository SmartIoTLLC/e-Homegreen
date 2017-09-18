//
//  Sura+CoreDataClass.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/18/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData


public class Sura: NSManagedObject {

    convenience init(context: NSManagedObjectContext, id: Int16, name: String) {
        self.init(context: context)
        
        self.id = id as NSNumber
        self.name = name
    }
}
