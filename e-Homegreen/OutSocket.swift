//
//  OutSocket.swift
//  new
//
//  Created by Teodor Stevic on 6/25/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
    var ip = "192.168.0.7"
    var port:UInt16 = 5001
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
        setupConnection()
    }
    
    init (ip:String, port:UInt16) {
        super.init()
        self.setupConnection()
        self.ip = ip
        self.port = port
    }
//    func setupConnection(){
//        var error : NSError?
//        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
//        socket.connectToHost(IP, onPort: PORT, error: &error)
//    }
    
//    func send(message:String){
//        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
//        socket.sendData(data, withTimeout: 2, tag: 0)
//    }
    func setupConnection(){
        var error : NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket.bindToPort(port, error: &error)
        socket.connectToHost(ip, onPort: port, error: &error)
        //        socket.beginReceiving(&error)
        socket.enableBroadcast(true, error: &error)
    }
    
    func send(message:String){
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        socket.sendData(data, withTimeout: 2, tag: 0)
    }
    func sendByte(arrayByte: [UInt8]) {
        let data = NSData(bytes: arrayByte, length: arrayByte.count)
        socket.sendData(data, withTimeout: 2, tag: 0)
//        println("Ajde \(data)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        println("didConnectToAddress")
//        println(address)
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