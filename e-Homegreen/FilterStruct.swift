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
        self.location = aDecoder.decodeObject(forKey: FilterKey.location) as! String
        self.levelId = aDecoder.decodeInteger(forKey: FilterKey.levelId)
        self.zoneId = aDecoder.decodeInteger(forKey: FilterKey.zoneId)
        self.categoryId = aDecoder.decodeInteger(forKey: FilterKey.categoryId)
        self.levelName = aDecoder.decodeObject(forKey: FilterKey.levelName) as! String
        self.zoneName = aDecoder.decodeObject(forKey: FilterKey.zoneName) as! String
        self.categoryName = aDecoder.decodeObject(forKey: FilterKey.categoryName) as! String
        
        super.init()
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(location, forKey: FilterKey.location)
        aCoder.encode(levelId, forKey: FilterKey.levelId)
        aCoder.encode(zoneId, forKey: FilterKey.zoneId)
        aCoder.encode(categoryId, forKey: FilterKey.categoryId)
        aCoder.encode(levelName, forKey: FilterKey.levelName)
        aCoder.encode(zoneName, forKey: FilterKey.zoneName)
        aCoder.encode(categoryName, forKey: FilterKey.categoryName)
    }
}
class Filter:NSObject {
    static let sharedInstance = Filter()
    
    func returnFilter(forTab tab: FilterEnumeration) -> FilterItem {
        let object:FilterItem?
        let defaults = Foundation.UserDefaults.standard
        if let savedUser = defaults.object(forKey: tab.rawValue) as? Data {
            object = NSKeyedUnarchiver.unarchiveObject(with: savedUser) as? FilterItem
            return object!
        }
        return FilterItem(location: "All", levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")
    }
    
    func saveFilter(item filterItem:FilterItem, forTab tab: FilterEnumeration) {
        let defaults = Foundation.UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: filterItem)
        defaults.set(encodedData, forKey: tab.rawValue)
        defaults.synchronize()
    }
}
