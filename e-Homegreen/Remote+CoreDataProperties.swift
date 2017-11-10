//
//  Remote+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 10/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData

extension Remote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Remote> {
        return NSFetchRequest<Remote>(entityName: "Remote")
    }

    @NSManaged public var name: String?
    @NSManaged public var columns: NSNumber?
    @NSManaged public var rows: NSNumber?
    @NSManaged public var addressOne: NSNumber?
    @NSManaged public var addressTwo: NSNumber?
    @NSManaged public var addressThree: NSNumber?
    @NSManaged public var channel: NSNumber?
    @NSManaged public var buttonWidth: NSNumber?
    @NSManaged public var buttonHeight: NSNumber?
    @NSManaged public var marginTop: NSNumber?
    @NSManaged public var marginBottom: NSNumber?
    @NSManaged public var buttonColor: String?
    @NSManaged public var buttonShape: String?
    @NSManaged var gateway: Gateway?

}
