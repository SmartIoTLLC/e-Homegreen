//
//  Event.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/2/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {

    @NSManaged var eventId: NSNumber
    @NSManaged var eventName: String
    @NSManaged var eventImageOne: NSData
    @NSManaged var eventImageTwo: NSData
    @NSManaged var gateway: Gateway

}
