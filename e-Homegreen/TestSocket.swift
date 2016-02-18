//
//  TestSocket.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/22/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class TestSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
    var ip = ""
    var port:UInt16 = 0
    var socket:GCDAsyncUdpSocket!
    
    init (ip:String, port:UInt16) {
        super.init()
        self.ip = ip
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
        }
        //        if !socket.connectToHost(ip, onPort: port, error: &error) {
        //            println("1 \(error)")
        //        }
        //        if !socket.enableBroadcast(true, error: &error) {
        //            println("2 \(error)")
        //        }
        //        if !socket.joinMulticastGroup(ip, error: &error) {
        //            println("3 \(error)")
        //        }
        do {
            try socket.beginReceiving()
        } catch let error1 as NSError {
            error = error1
            print("4 \(error)")
        }
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        print("incoming message: \(address.convertToBytes())")
        var host:NSString?
        var hostPort:UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &hostPort, fromAddress: address)
        if let hostHost = host as? String {
            print("\(hostHost) \(hostPort) \(data.convertToBytes())")
            IncomingHandler(byteArrayToHandle: data.convertToBytes(), host: hostHost, port: hostPort)
        }
    }
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        print("Nemoj mi samo reci da je ovo problem!")
    }
    func setupConnection1(){
//        var error : NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket.bindToPort(port)
        } catch let error1 as NSError {
            print("4 \(error1)")
        }
        do {
            try socket.connectToHost(ip, onPort: port)
        } catch let error1 as NSError {
            print("4 \(error1)")
        }
        do {
            try socket.enableBroadcast(true)
        } catch let error1 as NSError {
            print("4 \(error1)")
        }
        send("ping")
    }
    
    func send(message:String){
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        socket.sendData(data, withTimeout: -1, tag: 0)
    }
    func sendByte(arrayByte: [UInt8]) {
//        let data = NSData(bytes: arrayByte, length: arrayByte.count)
//        socket.sendData(data, withTimeout: -1, tag: 0)
        let data = NSData(bytes: arrayByte, length: arrayByte.count)
        socket.sendData(data, toHost: ip, port: port, withTimeout: -1, tag: 0)
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
