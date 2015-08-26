//
//  Scene.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 8/26/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class Scene: NSManagedObject {

    @NSManaged var sceneId: NSNumber
    @NSManaged var sceneName: String
    @NSManaged var sceneImage: NSData
    @NSManaged var gateway: Gateway

}
