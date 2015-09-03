//
//  Sequence.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/3/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Sequence: NSManagedObject {

    @NSManaged var sequenceId: NSNumber
    @NSManaged var sequenceImageOne: NSData
    @NSManaged var sequenceImageTwo: NSData
    @NSManaged var sequenceName: String
    @NSManaged var address: NSNumber
    @NSManaged var gateway: Gateway

}