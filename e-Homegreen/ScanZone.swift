//
//  ScanZone.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ScanZone: ScanEntity {
    func sendCommandForScannning(_ id:Byte, address:[Byte], gateway:Gateway) {
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getZone(address, id: id), gateway: gateway)
    }
}
