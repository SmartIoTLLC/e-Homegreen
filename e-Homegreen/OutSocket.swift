//
//  OutSocket.swift
//  new
//
//  Created by Teodor Stevic on 6/25/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
    let IP = "192.168.0.7"
    let PORT:UInt16 = 5001
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
        setupConnection()
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
        socket.bindToPort(PORT, error: &error)
        socket.connectToHost(IP, onPort: PORT, error: &error)
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