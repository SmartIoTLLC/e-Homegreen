//
//  NSNumberExtensions.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/4/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation

extension NSNumber {
    
    var byteValue: UInt8 {
        return UInt8(Int(self))
    }
}
