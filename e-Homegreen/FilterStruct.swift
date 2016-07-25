//
//  FilterStruct.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class FilterItem: NSObject {
    var location:String = "All"
    var levelId:Int = 0
    var zoneId:Int = 0
    var categoryId:Int = 0
    var levelName:String = "All"
    var zoneName:String = "All"
    var categoryName:String = "All"
    var locationObjectId:String = "All"
    var levelObjectId:String = "All"
    var zoneObjectId:String = "All"
    var categoryObjectId:String = "All"
    
    init(location:String, levelId:Int, zoneId:Int, categoryId:Int, levelName:String, zoneName:String, categoryName:String) {
        self.location = location
        self.levelId = levelId
        self.zoneId = zoneId
        self.categoryId = categoryId
        self.levelName = levelName
        self.zoneName = zoneName
        self.categoryName = categoryName
    }
    
    required init(coder aDecoder: NSCoder) {
        self.location = aDecoder.decodeObjectForKey(FilterKey.location) as! String
        self.levelId = aDecoder.decodeIntegerForKey(FilterKey.levelId)
        self.zoneId = aDecoder.decodeIntegerForKey(FilterKey.zoneId)
        self.categoryId = aDecoder.decodeIntegerForKey(FilterKey.categoryId)
        self.levelName = aDecoder.decodeObjectForKey(FilterKey.levelName) as! String
        self.zoneName = aDecoder.decodeObjectForKey(FilterKey.zoneName) as! String
        self.categoryName = aDecoder.decodeObjectForKey(FilterKey.categoryName) as! String
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(location, forKey: FilterKey.location)
        aCoder.encodeInteger(levelId, forKey: FilterKey.levelId)
        aCoder.encodeInteger(zoneId, forKey: FilterKey.zoneId)
        aCoder.encodeInteger(categoryId, forKey: FilterKey.categoryId)
        aCoder.encodeObject(levelName, forKey: FilterKey.levelName)
        aCoder.encodeObject(zoneName, forKey: FilterKey.zoneName)
        aCoder.encodeObject(categoryName, forKey: FilterKey.categoryName)
    }
}
class Filter:NSObject {
    static let sharedInstance = Filter()
    
    func returnFilter(forTab tab: FilterEnumeration) -> FilterItem {
        let object:FilterItem?
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedUser = defaults.objectForKey(tab.rawValue) as? NSData {
            object = NSKeyedUnarchiver.unarchiveObjectWithData(savedUser) as? FilterItem
            return object!
        }
        return FilterItem(location: "All", levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")
    }
    
    func saveFilter(item filterItem:FilterItem, forTab tab: FilterEnumeration) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(filterItem)
        defaults.setObject(encodedData, forKey: tab.rawValue)
        defaults.synchronize()
    }
}