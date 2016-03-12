//
//  String+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/12/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

extension NSObject {
    func convertByteArrayToMacAddress(byteArray:[UInt8]) -> String {
        guard byteArray.count == 6 else {
            return ""
        }
        var returnString = ""
        for (index, byte) in byteArray.enumerate() {
            if index == byteArray.count-1 {
                returnString += String.localizedStringWithFormat("%02x", byte)
                break
            }
            returnString += String.localizedStringWithFormat("%02x", byte) + ":"
        }
        return returnString.uppercaseString
    }
}