//
//  ScanFunction.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/27/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
protocol ScanEntity {
    func sendCommandForScannning(_ id:Byte, address:[Byte], gateway:Gateway)
}

enum WhatToScan {
    case zone, category
}
class ScanFunction {
    var from:Int
    var to:Int
    var sum:Int
    var counter:Int
    var gateway:Gateway
    let scanWhat:ScanEntity
    let gatewayAddress:[Byte]
    
    init(from:Int, to:Int, gateway:Gateway, scanForWhat:WhatToScan) {
        self.from      = from
        self.to        = to
        self.sum       = to - from + 1
        self.counter   = 0
        self.gateway   = gateway
        gatewayAddress = [Byte(gateway.addressOne.intValue), Byte(gateway.addressTwo.intValue), Byte(gateway.addressThree.intValue)]
        
        switch scanForWhat {
            case .zone     : scanWhat = ScanZone()
            case .category : scanWhat = ScanCategory()
        }
    }
    
    func sendCommandForFinding(id:Byte) {
        scanWhat.sendCommandForScannning(id, address: gatewayAddress, gateway: gateway)
    }
}
