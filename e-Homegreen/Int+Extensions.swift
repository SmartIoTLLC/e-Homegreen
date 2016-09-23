//
//  Int+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
extension UInt {
    static func convertFourBytesToUInt(_ byteArray: [Byte]) -> UInt {
        // тврдити || claim, assert, contend, aver, vouch, purport || истицати || assert, run out, outflow || изјавити
        assert(byteArray.count <= 4)
        var result: UInt = 0
        for idx in 0..<(byteArray.count) {
            let shiftAmount = UInt((byteArray.count) - idx - 1) * 8
            result += UInt(byteArray[idx]) << shiftAmount
        }
        return result
    }
}
extension Byte {
    func covertToInt() -> Int {
        return Int(self)
    }
}
