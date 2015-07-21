//
//  OutSocket.swift
//  new
//
//  Created by Teodor Stevic on 6/25/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
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
        let data = NSData(bytes: arrayByte, length: arrayByte.count)
        socket.sendData(data, withTimeout: -1, tag: 0)
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        println("didConnectToAddress")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        println("didNotConnect \(error)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
//        println("didSendDataWithTag")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        println("didNotSendDataWithTag")
    }
}