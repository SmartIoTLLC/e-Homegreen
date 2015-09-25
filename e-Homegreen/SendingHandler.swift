//
//  SendingHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/19/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class SendingHandler {
    static func sendCommand(byteArray byteArray:[UInt8], gateway:Gateway) {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDel.inOutSockets.count > 0 {
            if let ssid = UIDevice.currentDevice().SSID {
                if gateway.ssid == ssid {
                    //  Send via local ip
                    for inOutSocket in appDel.inOutSockets {
                        if inOutSocket.port == UInt16(Int(gateway.localPort)) {
                            inOutSocket.sendByte(gateway.localIp, arrayByte:byteArray)
                            return
                        }
                    }
                } else {
                    //  Send via remote ip
                    for inOutSocket in appDel.inOutSockets {
                        if inOutSocket.port == UInt16(Int(gateway.remotePort)) {
                            inOutSocket.sendByte(gateway.remoteIpInUse, arrayByte:byteArray)
                            return
                        }
                    }
                }
            } else {
                //  Send vie remote ip
                for inOutSocket in appDel.inOutSockets {
                    if inOutSocket.port == UInt16(Int(gateway.remotePort)) {
                        inOutSocket.sendByte(gateway.remoteIpInUse, arrayByte:byteArray)
                        return
                    }
                }
            }
        }
        
    }
}

extension UIDevice {
    public var SSID: String? {
        get {
            if let interfaces = CNCopySupportedInterfaces(){
                for i in 0..<CFArrayGetCount(interfaces){
                    let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, i)
                    let rec = unsafeBitCast(interfaceName, AnyObject.self)
                    let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)")
                    if unsafeInterfaceData != nil {
                        let interfaceData = unsafeInterfaceData! as NSDictionary!
                        return (interfaceData["SSID"] as! String)
                    }
                }
            }
            return nil
            
        }
    }
}
//class SendingHandler: NSObject {
//    var appDel:AppDelegate!
//
//    init (byteArray:[UInt8], gateway:Gateway) {
//        super.init()
//        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
//        if let ssid = UIDevice.currentDevice().SSID {
//            if gateway.ssid == ssid {
//                //  Send via local ip
//                if appDel.inOutSockets != [] {
////                    var i:Int
//                    for i in 0...appDel.inOutSockets.count-1 {
//                        if appDel.inOutSockets[i].port == UInt16(Int(gateway.localPort)) {
//                            appDel.inOutSockets[i].sendByte(gateway.localIp, arrayByte:byteArray)
//                        }
//                    }
//                }
//            } else {
//                //  Send via remote ip
//                if appDel.inOutSockets != [] {
////                    var i:Int
//                    for i in 0...appDel.inOutSockets.count-1 {
//                        if appDel.inOutSockets[i].port == UInt16(Int(gateway.remotePort)) {
//                            print(gateway.remoteIpInUse)
//                            appDel.inOutSockets[i].sendByte(gateway.remoteIpInUse, arrayByte:byteArray)
//                        }
//                    }
//                }
//            }
//        } else {
//            //  Send vie remote ip
//            if appDel.inOutSockets != [] {
////                var i:Int
//                for i in 0...appDel.inOutSockets.count-1 {
//                    if appDel.inOutSockets[i].port == UInt16(Int(gateway.remotePort)) {
//                        print(gateway.remoteIpInUse)
//                        appDel.inOutSockets[i].sendByte(gateway.remoteIpInUse, arrayByte:byteArray)
//                    }
//                }
//            }
//        }
//    }
//}
