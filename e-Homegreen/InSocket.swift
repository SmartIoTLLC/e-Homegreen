//
//  InSocket.swift
//  new
//
//  Created by Teodor Stevic on 6/25/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class InSocket: NSObject, GCDAsyncUdpSocketDelegate {

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
        
<<<<<<< HEAD
        if !socket.bindToPort(port, error: &error) {
            println("1 \(error)")
        }
//        if !socket.enableBroadcast(true, error: &error) {
//            println("2 \(error)")
//        }
        if !socket.joinMulticastGroup(ip, error: &error) {
            println("3 \(error)")
        }
        if !socket.beginReceiving(&error) {
            println("4 \(error)")
        }
=======
        socket.bindToPort(port, error: &error)
//                socket.enableBroadcast(true, error: &error)
        socket.joinMulticastGroup(ip, error: &error)
        if error != nil{
            println("ERROR GROUP")
        }
        socket.beginReceiving(&error)
        //        socket.enableBroadcast(true, error: &error)
        
        
        
//        socket.bindToPort(port, error: &error)
//        socket.enableBroadcast(true, error: &error)
//        socket.joinMulticastGroup(ip, error: &error)
//        socket.beginReceiving(&error)
>>>>>>> origin/master
        
    }
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
//        println("incoming message: \(data)")
<<<<<<< HEAD
        println("incoming message: \(address.convertToBytes())")
=======
//        println("incoming message: \(address.convertToBytes())")
>>>>>>> origin/master
//        println("GCDAsyncUdpSocket, za poruke od servera, delegat je pozvan.")
        var host:NSString?
        var hostPort:UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &hostPort, fromAddress: address)
        if let hostHost = host as? String {
<<<<<<< HEAD
            println("\(hostHost) \(hostPort) \(data.convertToBytes())")
            IncomingHandler(byteArrayToHandle: data.convertToBytes(), host: hostHost, port: hostPort)
=======
            println("incoming message: \(hostHost) \(hostPort) \(data.convertToBytes())")
//            IncomingHandler(byteArrayToHandle: data.convertToBytes(), host: hostHost, port: hostPort)
>>>>>>> origin/master
        }
    }
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        println("Nemoj mi samo reci da je ovo problem!")
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
