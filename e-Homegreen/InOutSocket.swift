//
//  InOutSocket.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/23/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class InOutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
    var ip = "255.255.255.255"
    var port:UInt16 = 0
    var socket:GCDAsyncUdpSocket!
    
    init (port:UInt16) {
        super.init()
        self.port = port
        self.setupConnection()
    }
    func setupConnection(){
        var error : NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket.setIPv4Enabled(true)
        socket.setIPv6Enabled(false)
        
        do {
            try socket.bindToPort(port)
        } catch let error1 as NSError {
            error = error1
            print("1 \(error)")
            print("U pitanju je \(ip) \(port)")
        }
        
        do {
            try socket.beginReceiving()
        } catch let error1 as NSError {
            error = error1
            print("4 \(error)")
            print("U pitanju je \(ip) \(port)")
        }
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        if filterContext != nil {
            print(filterContext)
        }
        print("INOUT SOCKET incoming message: \(address.convertToBytes())")
        var host:NSString?
        var hostPort:UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &hostPort, fromAddress: address)
        if let hostHost = host as? String {
            print("\(hostHost) \(hostPort) \(data.convertToBytes())")
            _ = IncomingHandler(byteArrayToHandle: data.convertToBytes(), host: hostHost, port: hostPort)
        }
    }
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
    }
    func setupConnection1(){
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket.bindToPort(port)
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
        }
        do {
            try socket.connectToHost(ip, onPort: port)
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
        }
        do {
            try socket.enableBroadcast(true)
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
        }
        send("ping")
    }
    
    func send(message:String){
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        socket.sendData(data, withTimeout: -1, tag: 0)
    }
    func sendByte(ip:String, arrayByte: [UInt8]) {
        let data = NSData(bytes: arrayByte, length: arrayByte.count)
        socket.sendData(data, toHost: ip, port: port, withTimeout: -1, tag: 1)
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        print("didConnectToAddress")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        print("didNotConnect \(error)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        print("didNotSendDataWithTag")
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
