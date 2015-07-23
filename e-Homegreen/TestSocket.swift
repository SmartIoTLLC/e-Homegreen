//
//  TestSocket.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/22/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

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
        
        
        
        if !socket.bindToPort(port, error: &error) {
            println("1 \(error)")
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
        if !socket.beginReceiving(&error) {
            println("4 \(error)")
        }
        
        
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        println("incoming message: \(address.convertToBytes())")
        var host:NSString?
        var hostPort:UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &hostPort, fromAddress: address)
        if let hostHost = host as? String {
            println("\(hostHost) \(hostPort) \(data.convertToBytes())")
            IncomingHandler(byteArrayToHandle: data.convertToBytes(), host: hostHost, port: hostPort)
        }
    }
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        println("Nemoj mi samo reci da je ovo problem!")
    }
    func setupConnection1(){
        var error : NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket.bindToPort(port, error: &error)
        socket.connectToHost(ip, onPort: port, error: &error)
        socket.enableBroadcast(true, error: &error)
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
        println("didConnectToAddress")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        println("didNotConnect \(error)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        println("didSendDataWithTag")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        println("didNotSendDataWithTag")
    }
}
