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
    
    init (byteArray:[UInt8], gateway:Gateway) {
        if let ssid = UIDevice.currentDevice().SSID {
            if gateway.ssid == ssid {
                //  Send via local ip
                outSocket = OutSocket(ip: gateway.localIp, port: UInt16(Int(gateway.localPort)))
            } else {
                //  Send via remote ip
                outSocket = OutSocket(ip: gateway.remoteIp, port: UInt16(Int(gateway.remotePort)))
            }
            outSocket.sendByte(byteArray)
            outSocket.socket.closeAfterSending()
        } else {
            //  Send vie remote ip
            outSocket = OutSocket(ip: gateway.remoteIp, port: UInt16(Int(gateway.remotePort)))
            outSocket.sendByte(byteArray)
            outSocket.socket.closeAfterSending()
        }
    }
    
}
