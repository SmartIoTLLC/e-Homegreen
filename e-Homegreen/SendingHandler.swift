//
//  SendingHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/19/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SendingHandler: NSObject {
   
    var outSocket:OutSocket
    
    init (byteArray:[UInt8], ip:String, port: Int) {
        outSocket = OutSocket(ip: ip, port: UInt16(port))
        outSocket.sendByte(byteArray)
//        outSocket.socket.close()
        outSocket.socket.closeAfterSending()
    }
    
}
