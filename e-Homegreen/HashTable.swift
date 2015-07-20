//
//  HashTable.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/18/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation

struct DeviceType {
    let deviceId: UInt8
    let subId: UInt8
}
extension DeviceType: Hashable {
    var hashValue: Int {
        return deviceId.hashValue ^ subId.hashValue
    }
}
func == (lhs: DeviceType, rhs:DeviceType) -> Bool {
    return lhs.deviceId == rhs.deviceId && lhs.subId == rhs.subId
}
