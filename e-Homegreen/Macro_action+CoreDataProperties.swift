//
//  Macro_action+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 8/31/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData


extension Macro_action {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Macro_action> {
        return NSFetchRequest<Macro_action>(entityName: "Macro_action")
    }

    @NSManaged public var command: NSNumber?
    @NSManaged public var control_type: String?
    @NSManaged public var delay: NSNumber?
    @NSManaged public var deviceAddress: NSNumber?
    @NSManaged public var deviceChannel: NSNumber?
    @NSManaged public var gatewayAddressOne: NSNumber?
    @NSManaged public var gatewayAddressTwo: NSNumber?
    @NSManaged public var gatewayId: String?
    @NSManaged public var macro: Macro?

}
