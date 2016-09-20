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
        print("Command sent: \(byteArray) na: \(gateway)")
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDel.inOutSockets.count > 0 {
            
            if let ssid = UIDevice.currentDevice().SSID {
                // Checks if ssid exists
                var doesSSIDExist = false
                if let ssids = gateway.location.ssids?.allObjects as? [SSID]  {
                    doesSSIDExist = ssids.contains({ (let item) -> Bool in
                        return item.name == ssid ? true : false
                    })
                }
                // According to result in finding if ssid exists move on
                if doesSSIDExist {
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
    static func sendCommand(byteArray byteArray:[UInt8], ip:String, port:UInt16) {
        print("Command sent: \(byteArray)")
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
       
        for inOutSocket in appDel.inOutSockets {
            if inOutSocket.port == UInt16(Int(port)) {
                inOutSocket.sendByte(appDel.returnIpAddress(ip), arrayByte:byteArray)
                return
            }
        }
        //  Send via local ip
        let io = InOutSocket(port: port)
        io.sendByte(appDel.returnIpAddress(ip), arrayByte:byteArray)
//        io.socket.close()
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