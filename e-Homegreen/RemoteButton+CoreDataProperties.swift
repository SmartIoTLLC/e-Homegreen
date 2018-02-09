//
//  RemoteButton+CoreDataProperties.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/15/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData


extension RemoteButton {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RemoteButton> {
        return NSFetchRequest<RemoteButton>(entityName: "RemoteButton")
    }

    @NSManaged public var addressOne: NSNumber?
    @NSManaged public var addressThree: NSNumber?
    @NSManaged public var addressTwo: NSNumber?
    @NSManaged public var buttonColor: String?
    @NSManaged public var buttonHeight: NSNumber?
    @NSManaged public var buttonId: NSNumber?
    @NSManaged public var buttonShape: String?
    @NSManaged public var buttonState: String?
    @NSManaged public var buttonType: String?
    @NSManaged public var buttonWidth: NSNumber?
    @NSManaged public var hexString: String?
    @NSManaged public var image: NSData?
    @NSManaged public var imageScaleX: NSNumber?
    @NSManaged public var imageScaleY: NSNumber?
    @NSManaged public var imageState: String?
    @NSManaged public var marginTop: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var sceneId: NSNumber?
    @NSManaged public var irId: NSNumber?
    @NSManaged public var channel: NSNumber?
    @NSManaged public var buttonInternalType: String?
    @NSManaged public var remote: Remote?

}
