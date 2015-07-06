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
    let PORT:UInt16 = 5000
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        var error : NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket.bindToPort(PORT, error: &error)
        socket.enableBroadcast(true, error: &error)
        socket.joinMulticastGroup(IP, error: &error)
        socket.beginReceiving(&error)
    }
    
    var deviceArray:[Device] = []
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!,      withFilterContext filterContext: AnyObject!) {
        var count = data.length / sizeof(UInt8)
        var array = [UInt8](count: count, repeatedValue: 6)
        data.getBytes(&array, length: count * sizeof(UInt8))
        println("1 incoming message: \(data)")
        println("2 incoming message: \(array.map{String($0, radix: 16, uppercase: false)})")
        
        var myArray:[UInt8] =  data.convertToBytes()
        println("pre chk \(chkByte(myArray))")
        if myArray[0] == 0xAA && myArray[myArray.count-1] == 0x10 && myArray[5] == 0xF1 && myArray[6] == 0x01 {
            println("Opaaa na kvadrat")
            var deviceExists:Bool = false
            if deviceArray != [] {
                for device in deviceArray {
                    if (device.deviceId == myArray[7] && device.subId == myArray[8]) || (myArray[7] == 0x01 && myArray[8] == 0x01) {
                        deviceExists = true
                        break
                    }
                }
            } else {
                if  myArray[7] != 0x01 && myArray[8] != 0x01 {
                    deviceExists = true
                } else {
                    deviceExists = false
                    
                }
            }
            if !deviceExists {deviceArray.append(Device(deviceId: myArray[7], subId: myArray[8], macOfDevice: [myArray[9],myArray[10],myArray[11],myArray[12],myArray[13],myArray[14]]))}
            
        } else {
            //  problem
        }
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
