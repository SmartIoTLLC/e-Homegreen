//
//  Model.swift
//  new
//
//  Created by Teodor Stevic on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class Model: NSObject {
    class var sharedInstance:Model{
        struct Singleton {
            static let instance = Model()
        }
        return Singleton.instance
    }
    
    var deviceArray:[DeviceOld] = []
}
