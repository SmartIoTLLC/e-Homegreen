//
//  Event.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/3/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {

    @NSManaged var eventId: NSNumber
    @NSManaged var eventImageOne: NSData
    @NSManaged var eventImageTwo: NSData
    @NSManaged var eventName: String
    @NSManaged var address: NSNumber
    @NSManaged var gateway: Gateway

}
