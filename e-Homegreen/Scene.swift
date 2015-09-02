//
//  Scene.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/2/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Scene: NSManagedObject {

    @NSManaged var sceneId: NSNumber
    @NSManaged var sceneImageOne: NSData
    @NSManaged var sceneName: String
    @NSManaged var sceneImageTwo: NSData
    @NSManaged var gateway: Gateway

}
