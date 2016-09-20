//
//  ScanCategory.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ScanCategory: ScanEntity {
    func sendCommandForScannning(id:Byte, address:[Byte], gateway:Gateway) {
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCategory(address, id: id), gateway: gateway)
    }
}
