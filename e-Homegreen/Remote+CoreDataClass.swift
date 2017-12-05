//
//  Remote+CoreDataClass.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 10/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
//

import Foundation
import CoreData


public class Remote: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, remoteInformation info: RemoteInformation) {
        self.init(context: context)
        addressOne = NSNumber(value: info.addressOne)
        addressTwo = NSNumber(value: info.addressTwo)
        addressThree = NSNumber(value: info.addressThree)
        buttonColor = info.buttonColor
        buttonShape = info.buttonShape
        buttonWidth = NSNumber(value: info.buttonWidth)
        buttonHeight = NSNumber(value: info.buttonHeight)
        channel = NSNumber(value: info.channel)
        columns = NSNumber(value: info.columns)
        marginBottom = NSNumber(value: info.marginBottom)
        marginTop = NSNumber(value: info.marginTop)
        name = info.name
        rows = NSNumber(value: info.rows)
        location = info.location
    }
}

struct RemoteInformation {
    let addressOne: Int
    let addressTwo: Int
    let addressThree: Int
    let buttonColor: String
    let buttonShape: String
    let buttonWidth: Int
    let buttonHeight: Int
    let channel: Int
    let columns: Int
    let marginBottom: Int
    let marginTop: Int
    let name: String
    let rows: Int
    let location: Location
}



struct ButtonShape {
    static let circle = "Circle"
    static let rectangle = "Rectangle"
}
