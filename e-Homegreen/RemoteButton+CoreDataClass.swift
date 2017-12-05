//
//  RemoteButton+CoreDataClass.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/14/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData


public class RemoteButton: NSManagedObject {
    
}

struct ButtonState {
    static let visible = "Visible"
    static let invisible = "Invisible"
    static let disable = "Disable"
}

struct ButtonColor {
    static let red = "Red"
    static let gray = "Gray"
    static let green = "Green"
    static let blue = "Blue"
}

struct ButtonType {
    static let sceneButton = "SCENE"
    static let hexButton = "HEX"
    static let irButton = "IR"
}

struct ButtonInternalType {
    static let regular = "REGULAR"
    static let imageButton = "IMAGE BUTTON"
    static let image = "IMAGE"
}
