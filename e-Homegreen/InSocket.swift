//
//  InSocket.swift
//  new
//
//  Created by Teodor Stevic on 6/25/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class InSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
//    let IP = "255.255.255.255"
//    let PORT:UInt16 = 5556
    let IP = "255.255.255.255"
    let PORT:UInt16 = 5001
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        var error : NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        socket.setIPv4Enabled(true)
        socket.setIPv6Enabled(false)
        
        socket.bindToPort(PORT, error: &error)
        //        socket.enableBroadcast(true, error: &error)
        socket.joinMulticastGroup(IP, error: &error)
        socket.beginReceiving(&error)
        //        socket.enableBroadcast(true, error: &error)
    }
    
    var deviceArray:[Device] = []
    var number = 0
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,      withFilterContext filterContext: AnyObject!) {
        ReceiveHandler(byteArrayToHandle: data.convertToBytes())
        println("\(number) incoming message: \(data)")
        number += 1
    }
    func chkByte (array:[UInt8]) -> UInt8 {
        var chk:Int = 0
        for var i = 1; i <= array.count-3; i++ {
            var number = "\(array[i])"
            chk = chk + number.toInt()!
        }
        chk = chk%256
        return UInt8(chk)
    }
}
extension NSData {
    public func convertToBytes() -> [UInt8] {
        let count = self.length / sizeof(UInt8)
        var bytesArray = [UInt8](count: count, repeatedValue: 0)
        self.getBytes(&bytesArray, length:count * sizeof(UInt8))
        return bytesArray
    }
}
