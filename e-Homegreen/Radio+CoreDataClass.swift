//
//  Radio+CoreDataClass.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/14/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

@objc(Radio)
public class Radio: NSManagedObject {

    convenience init(context: NSManagedObjectContext, stationName: String, area: String, city: String, genre: String, url: String, isWorking: Bool, radioDescription: String) {
        self.init(context: context)
        self.stationName = stationName
        self.area = area
        self.city = city
        self.genre = genre
        self.url = url
        self.isWorking = isWorking as NSNumber
        self.radioDescription = radioDescription
    }
    
}
