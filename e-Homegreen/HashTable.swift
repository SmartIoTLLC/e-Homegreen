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
        var newSubId = subId
        switch deviceId {
        case 0x01:if subId > 0x01 {newSubId = 0x01}
        case 0x03:if subId > 0x05 {newSubId = 0x05}
        case 0x04:if subId > 0x04 {newSubId = 0x04}
        case 0x13:if subId > 0x03 {newSubId = 0x03}
        case 0x16:if subId > 0x02 {newSubId = 0x02}
        case 0x11:if subId > 0x01 {newSubId = 0x01}
        case 0x14:if subId > 0x01 {newSubId = 0x01}
        case 0x12:if subId > 0x02 {newSubId = 0x02}
        case 0x15:if subId > 0x03 {newSubId = 0x03}
        case 0x21:if subId > 0x00 {newSubId = 0x00}
        case 0x22:if subId > 0x00 {newSubId = 0x00}
        case 0x23:if subId > 0x00 {newSubId = 0x00}
        case 0x24:if subId > 0x00 {newSubId = 0x00}
        case 0x25:if subId > 0x00 {newSubId = 0x00}
        case 0x26:if subId > 0x00 {newSubId = 0x00}
        case 0x27:if subId > 0x00 {newSubId = 0x00}
        case 0x31:if subId > 0x00 {newSubId = 0x00}
        case 0x32:if subId > 0x00 {newSubId = 0x00}
        case 0x33:if subId > 0x00 {newSubId = 0x00}
        case 0x34:if subId > 0x00 {newSubId = 0x00}
        case 0x35:if subId > 0x00 {newSubId = 0x00}
        case 0x54:if subId > 0x01 {newSubId = 0x01}
        case 0x72:if subId > 0x00 {
            newSubId = 0x00
            }
        case 0x41:if subId > 0x00 {newSubId = 0x00}
        case 0x42:if subId > 0x00 {newSubId = 0x00}
        case 0x43:if subId > 0x01 {newSubId = 0x01}
        case 0x44:if subId > 0x00 {newSubId = 0x00}
        case 0x45:if subId > 0x01 {newSubId = 0x01}
        case 0x47:if subId > 0x00 {newSubId = 0x00}
        case 0x0C:if subId > 0x00 {newSubId = 0x00}
        case 0x43:if subId > 0x00 {newSubId = 0x00}
        default:break
        }
        return deviceId.hashValue ^ newSubId.hashValue
    }
}
func == (lhs: DeviceType, rhs:DeviceType) -> Bool {
    var lhsSubId = lhs.subId
    switch lhs.deviceId {
    case 0x01:if lhs.subId > 0x01 {lhsSubId = 0x01}
    case 0x03:if lhs.subId > 0x05 {lhsSubId = 0x05}
    case 0x04:if lhs.subId > 0x04 {lhsSubId = 0x04}
    case 0x13:if lhs.subId > 0x03 {lhsSubId = 0x03}
    case 0x16:if lhs.subId > 0x02 {lhsSubId = 0x02}
    case 0x11:if lhs.subId > 0x01 {lhsSubId = 0x01}
    case 0x14:if lhs.subId > 0x01 {lhsSubId = 0x01}
    case 0x12:if lhs.subId > 0x02 {lhsSubId = 0x02}
    case 0x15:if lhs.subId > 0x03 {lhsSubId = 0x03}
    case 0x21:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x22:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x23:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x24:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x25:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x26:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x27:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x31:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x32:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x33:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x34:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x35:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x54:if lhs.subId > 0x01 {lhsSubId = 0x01}
    case 0x72:if lhs.subId > 0x00 {
        lhsSubId = 0x00
        }
    case 0x41:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x42:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x43:if lhs.subId > 0x01 {lhsSubId = 0x01}
    case 0x44:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x45:if lhs.subId > 0x01 {lhsSubId = 0x01}
    case 0x47:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x0C:if lhs.subId > 0x00 {lhsSubId = 0x00}
    case 0x43:if lhs.subId > 0x00 {lhsSubId = 0x00}
    default:break
    }
    var rhsSubId = rhs.subId
    switch rhs.deviceId {
    case 0x01:if rhs.subId > 0x01 {rhsSubId = 0x01}
    case 0x03:if rhs.subId > 0x05 {rhsSubId = 0x05}
    case 0x04:if rhs.subId > 0x04 {rhsSubId = 0x04}
    case 0x13:if rhs.subId > 0x03 {rhsSubId = 0x03}
    case 0x16:if rhs.subId > 0x02 {rhsSubId = 0x02}
    case 0x11:if rhs.subId > 0x01 {rhsSubId = 0x01}
    case 0x14:if rhs.subId > 0x01 {rhsSubId = 0x01}
    case 0x12:if rhs.subId > 0x02 {rhsSubId = 0x02}
    case 0x15:if rhs.subId > 0x03 {rhsSubId = 0x03}
    case 0x21:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x22:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x23:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x24:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x25:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x26:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x27:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x31:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x32:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x33:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x34:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x35:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x54:if rhs.subId > 0x01 {rhsSubId = 0x01}
    case 0x72:if rhs.subId > 0x00 {
        rhsSubId = 0x00
        }
    case 0x41:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x42:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x43:if rhs.subId > 0x01 {rhsSubId = 0x01}
    case 0x44:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x45:if rhs.subId > 0x01 {rhsSubId = 0x01}
    case 0x47:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x0C:if rhs.subId > 0x00 {rhsSubId = 0x00}
    case 0x43:if rhs.subId > 0x00 {rhsSubId = 0x00}
    default:break
    }
    return lhs.deviceId == rhs.deviceId && lhsSubId == rhsSubId
    //    return true
}
