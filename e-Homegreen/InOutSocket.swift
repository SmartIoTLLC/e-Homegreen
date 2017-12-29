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
    
    func setupConnection() {
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        socket.setIPv4Enabled(true)
        socket.setIPv6Enabled(false)
//        let utf8 = "255.255.255.255".toBase64()
//        let data = Data(base64Encoded: utf8)
//
//        do { try socket.bind(toAddress: data!) } catch {}
        
        do { try socket.bind(toPort: port) } catch let error as NSError { print("1 \(String(describing: error))"); print("UDP U pitanju je \(ip) \(port)") }
        do { try socket.beginReceiving() } catch let error as NSError { print("4 \(String(describing: error))"); print("UDP U pitanju je \(ip) \(port)") }
        do { try socket.enableBroadcast(true) } catch let error as NSError { print("Error enabling broadcast :", error, error.userInfo); print("UDP U pitanju je \(ip) \(port)") }
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if filterContext != nil { print(filterContext!) }
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.IndicatorLamp), object: self, userInfo: ["lamp":"red"])
        var host:NSString?
        var hostPort:UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &hostPort, fromAddress: address)
        if let hostHost = host as String? {
            print("INOUT SOCKET INCOMING MESSAGE: \nAddress:", address.convertToBytes(),"\n Host:", hostHost, hostPort,"\n Byte Array:", data.convertToBytes(),"\n")
            print("UDP incoming :\(data.convertToBytes())")
            _ = IncomingHandler(byteArrayToHandle: data.convertToBytes(), host: hostHost, port: hostPort)
        }
    }

    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error) {
        print("UDP DID CLOSE")
    }
    
    func send(_ message:String){
        if let data = message.data(using: String.Encoding.utf8) { socket.send(data, withTimeout: -1, tag: 0) }
    }
    
    func sendByte(_ ip:String, arrayByte: [UInt8]) {
        let data = Data(bytes: UnsafePointer<UInt8>(arrayByte), count: arrayByte.count)
        socket.send(data, toHost: ip, port: port, withTimeout: -1, tag: 1) // if ip != 127.0.0.1
        if ip != "127.0.0.1" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.IndicatorLamp), object: self, userInfo: ["lamp":"green"])
        }        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {}
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error) {
        print("UDP didNotConnect \(error)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {}
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error) {
        print("UDP did not send")
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

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
