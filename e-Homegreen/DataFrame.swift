//
//  DataFrame.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

enum MainCID:Byte {
    case commonComand = 0xF1
    case gatewayControllerCommand = 0xF2
    case lightingControlCommandDimmerRelayModule = 0xF3
    case climateControlCommand = 0xF4
    case analogDigitalInputCommand = 0xF5
    case analogDigitalOutputCommand = 0xF6
    case switchPanelCommand = 0xF8
    case lcdPanelCommands = 0xF7
    case irCommand = 0xF9
    case pcControllerCommand = 0xFA
}

struct DataFrame {
    let SOI:Byte
    let LEN:Byte
    let ADR1:Byte
    let ADR2:Byte
    let ADR3:Byte
    let CID1:MainCID
    let CID2:Byte
    let INFO:[Byte]
    let CHK:Byte
    let EOI:Byte
}

extension DataFrame {
    init?(byteArray:[Byte]) {
        // 0xFC is an exception, it is not normal. Khalifa said to implement it like this
        // Check if byte array has minimum count size requirements
        guard byteArray.count >= 9 else { print("Byte array shorter than 9"); return nil }
        
        // Check if first byte is ok
        guard byteArray[0] == 0xAA || byteArray[0] == 0xFC  else { print("First byte is wrong"); return nil }
        
        // Check if second byte is ok
        let len = Int(byteArray[1])
        guard len == (byteArray.count-9 % 256) else { print("Second byte is wrong"); return nil }
        
        // Check if penultimate byte is ok
        let chk = Int(byteArray[byteArray.count-2])
        var sum = 0
        for i in 1 ..< byteArray.count - 2 { sum += Int(byteArray[i]) }
        guard chk == sum % 256  else { print("Check sum is wrong"); return nil }
        
        // Check if last byte is ok
        guard byteArray[byteArray.count-1] == 0x10 else { print("Last byte is wrong"); return nil }
        
        // Check if there is main CID in enum
        guard let mainCid = MainCID(rawValue: byteArray[5]) else { print("There is no Main cmd"); return nil }
        
        // Create data frame object
        self.SOI = byteArray[0]
        self.LEN = byteArray[1]
        self.ADR1 = byteArray[2]
        self.ADR2 = byteArray[3]
        self.ADR3 = byteArray[4]
        self.CID1 = mainCid
        self.CID2 = byteArray[6]
        if (byteArray.count-3) >= 7 {
            self.INFO = Array(byteArray[7...(byteArray.count-3)])
        } else {
            self.INFO = []
        }
        self.CHK = byteArray[byteArray.count-2]
        self.EOI = byteArray[byteArray.count-1]
        return
    }
}
