//
//  Macro+CoreDataClass.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/6/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

@objc(Macro)
// Macro is currently not used because it is not well specified.
public class Macro: NSManagedObject {
    var isSelected:Bool = false
}
