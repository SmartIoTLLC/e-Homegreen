//
//  SendingHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/19/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SendingHandler: NSObject {
    
    var appDel:AppDelegate!
    
    init (byteArray:[UInt8], gateway:Gateway) {
        super.init()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        if let ssid = UIDevice.currentDevice().SSID {
            if gateway.ssid == ssid {
                //  Send via local ip
                if appDel.inOutSockets != [] {
                    var i:Int
                    for i in 0...appDel.inOutSockets.count-1 {
                        if appDel.inOutSockets[i].port == UInt16(Int(gateway.localPort)) {
                            appDel.inOutSockets[i].sendByte(gateway.localIp, arrayByte:byteArray)
                        }
                    }
                }
            } else {
                //  Send via remote ip
                if appDel.inOutSockets != [] {
                    var i:Int
                    for i in 0...appDel.inOutSockets.count-1 {
                        if appDel.inOutSockets[i].port == UInt16(Int(gateway.remotePort)) {
//                            appDel.inOutSockets[i].sendByte(gateway.remoteIp, arrayByte:byteArray)
                            println(gateway.remoteIpInUse)
                            appDel.inOutSockets[i].sendByte(gateway.remoteIpInUse, arrayByte:byteArray)
                        }
                    }
                }
            }
        } else {
            //  Send vie remote ip
            if appDel.inOutSockets != [] {
                var i:Int
                for i in 0...appDel.inOutSockets.count-1 {
                    if appDel.inOutSockets[i].port == UInt16(Int(gateway.remotePort)) {
//                        appDel.inOutSockets[i].sendByte(gateway.remoteIp, arrayByte:byteArray)
                        println(gateway.remoteIpInUse)
                        appDel.inOutSockets[i].sendByte(gateway.remoteIpInUse, arrayByte:byteArray)
                    }
                }
            }
        }
    }
}
