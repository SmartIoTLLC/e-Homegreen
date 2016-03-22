//
//  FilterStruct.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

struct Filter {
    let location:String
    let levelId:Int
    let zoneId:Int
    let categoryId:Int
    let levelName:String
    let zoneName:String
    let categoryName:String
    
    static func encode(filter: Filter) {
        let personClassObject = HelperClass(filter: filter)
        
        NSKeyedArchiver.archiveRootObject(personClassObject, toFile: HelperClass.path())
    }
    
    static func decode() -> Filter? {
        let filterClassObject = NSKeyedUnarchiver.unarchiveObjectWithFile(HelperClass.path()) as? HelperClass
        
        return filterClassObject?.filter
    }
}
extension Filter {
    class HelperClass:NSObject, NSCoding {
        
        var filter: Filter?
        
        init(filter: Filter) {
            self.filter = filter
            super.init()
        }
        
        class func path() -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
            let path = documentsPath?.stringByAppendingString("/Filter")
            return path!
        }
        
        required init?(coder aDecoder: NSCoder) {
            guard let location = aDecoder.decodeObjectForKey(FilterKey.location) as? String else { filter = nil; super.init(); return nil }
            let levelId = aDecoder.decodeIntegerForKey(FilterKey.levelId)
            let zoneId = aDecoder.decodeIntegerForKey(FilterKey.zoneId)
            let categoryId = aDecoder.decodeIntegerForKey(FilterKey.categoryId)
            guard let levelName = aDecoder.decodeObjectForKey(FilterKey.levelName) as? String else { filter = nil; super.init(); return nil }
            guard let zoneName = aDecoder.decodeObjectForKey(FilterKey.zoneName) as? String else { filter = nil; super.init(); return nil }
            guard let categoryName = aDecoder.decodeObjectForKey(FilterKey.categoryName) as? String else { filter = nil; super.init(); return nil }
            
            filter = Filter(location:location, levelId:levelId, zoneId:zoneId, categoryId:categoryId, levelName:levelName, zoneName:zoneName, categoryName:categoryName)
            
            super.init()
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(filter!.location, forKey: FilterKey.location)
            aCoder.encodeObject(filter!.levelId, forKey: FilterKey.levelId)
            aCoder.encodeObject(filter!.zoneId, forKey: FilterKey.zoneId)
            aCoder.encodeObject(filter!.categoryId, forKey: FilterKey.categoryId)
            aCoder.encodeObject(filter!.levelName, forKey: FilterKey.levelName)
            aCoder.encodeObject(filter!.zoneName, forKey: FilterKey.zoneName)
            aCoder.encodeObject(filter!.categoryName, forKey: FilterKey.categoryName)
        }
    }
}