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
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        socket.setIPv4Enabled(true)
        socket.setIPv6Enabled(false)
        
        do {
            try socket.bind(toPort: port)
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
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if filterContext != nil {
            print(filterContext)
        }
        print("INOUT SOCKET incoming message: \(address.convertToBytes())")
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.IndicatorLamp), object: self, userInfo: ["lamp":"red"])
        var host:NSString?
        var hostPort:UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &hostPort, fromAddress: address)
        if let hostHost = host as? String {
            print("\(hostHost) \(hostPort) \(data.convertToBytes())")
            _ = IncomingHandler(byteArrayToHandle: data.convertToBytes(), host: hostHost, port: hostPort)
        }
    }

    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error) {
    }
    func setupConnection1(){
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket.bind(toPort: port)
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
        }
        do {
            try socket.connect(toHost: ip, onPort: port)
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
    
    func send(_ message:String){
        if let data = message.data(using: String.Encoding.utf8){
            socket.send(data, withTimeout: -1, tag: 0)
        }
        
    }
    func sendByte(_ ip:String, arrayByte: [UInt8]) {
        let data = Data(bytes: UnsafePointer<UInt8>(arrayByte), count: arrayByte.count)
        socket.send(data, toHost: ip, port: port, withTimeout: -1, tag: 1)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.IndicatorLamp), object: self, userInfo: ["lamp":"green"])
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("didConnectToAddress")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error) {
        print("didNotConnect \(error)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error) {
        print("didNotSendDataWithTag")
    }
}
extension Data {
    public func convertToBytes() -> [UInt8] {
        let count = self.count / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        (self as NSData).getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        return bytesArray
    }
}
