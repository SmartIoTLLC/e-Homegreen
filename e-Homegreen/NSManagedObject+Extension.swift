//
//  NSManagedObject+Extension.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
//    class func entityName() -> String {
//        let fullClassName = NSStringFromClass(object_getClass(self))
//        let nameComponents = fullClassName.characters.split{$0 == "."}.map(String.init)
////        return last(nameComponents)!
//        return nameComponents.last!
//    }
//    
//    convenience init(context: NSManagedObjectContext) {
//        let name = type(of: self).entityName()
//        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
//        self.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
}

//Swift 2:Xcode 7 beta 1
//let fullNameArr = split(fullName.characters){$0 == " "}.map{String($0)}

//Swift 2: Xcode 7 beta 2
//let fullNameArr = split(fullName.characters){$0 == " "}.map(String.init)

//Swift 2: Xcode 7 beta 5
//let fullNameArr = fullName.split {$0 == " "}

//Swift 2: Xcode 7
//let fullNameArr = fullName.characters.split{$0 == " "}.map(String.init)
