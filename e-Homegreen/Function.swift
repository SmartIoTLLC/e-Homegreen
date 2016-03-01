//
//  Function.swift
//  new
//
//  Created by Teodor Stevic on 7/3/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class Function {
    static func setInternalClockRTC (address:[Byte], year:Byte, month:Byte, day:Byte, hour:Byte, minute:Byte, second:Byte, dayOfWeak:Byte) -> [Byte] {
        var messageInfo:[Byte] = [0xFF, year, month, day, hour, minute,  second, dayOfWeak]
        var message:[Byte] = []
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x01
        message[6] = 0x11
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getLightRelayStatus (address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0xFF]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x06
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getCurtainStatus (address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0xF0]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x06
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setLightRelayStatus (address:[Byte], channel:Byte, value:Byte, delay:Int, runningTime:Int, skipLevel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        let delayOne = Byte((delay / 0x100) % 0x100)
        let delayTwo = Byte(delay % 0x100)
        let runtimeOne = Byte((runningTime / 0x100) % 0x100)
        let runtimeTwo = Byte(runningTime % 0x100)
        messageInfo = [0xFF, 0xFF, 0xFF, 0x01, value, delayOne, delayTwo, runtimeOne, runtimeTwo, 0x00, skipLevel, 0x00, channel]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x07
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func searchForDevices (address:[Byte]) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0x00]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x01 // NIJE DOBRO
        message[6] = 0x01
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func zoneControl (zone:Byte, value:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0x01, 0x00, 0x00, 0x02, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, zone]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = 0xFF
        message[3] = 0xFF
        message[4] = 0xFF
        message[5] = 0x03
        message[6] = 0x07
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // da li treba da bude prazan ili bar jedan 0x00 u messageInfo?
    static func getWarnings (address:[Byte]) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0x00]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x10
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // da li treba da bude prazan ili bar jedan 0x00 u messageInfo?
    static func getRunningTime (address:[Byte]) -> [Byte]{
        var messageInfo:[Byte] = [0x00]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x10
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setCurtainStatus (address:[Byte], channel:Byte, value:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0xFF, 0xFF, 0xFF, 0x06, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, channel]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x07
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getChannelName (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x01
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getModuleName (address:[Byte]) -> [Byte]{
        var messageInfo:[Byte] = [0x00]
        var message:[Byte] = []
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x01
        message[6] = 0x0D
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getSensorName (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x04
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getSensorZone (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x02
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func sendIRLibrary (address:[Byte], channel:Byte, ir_id:Byte, times:Byte, interval:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        //messageInfo = [channel * 64 + times, interval, Byte(ir_id / 0x100), Byte((ir_id / 0x100) % 0x100)]
        messageInfo = [0x00] //  resi ovo
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x09
        message[6] = 0x05
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func sendSerialLibrary (address:[Byte], channel:Byte, serialId:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        //messageInfo = [Byte((serialId / 0x100) % 0x100), Byte(serialId % 0x100), channel]
        messageInfo = [0x00] //  resi ovo
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x09
        message[6] = 0x0E
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func resetRunningTime (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
//        messageInfo = [channel, 0x00, 0x00, 0x00, 0x00]
        messageInfo = [channel]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x0C
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
//    static func refreshSecurityMode () -> [Byte]{
//        var messageInfo:[Byte] = []
//        var message:[Byte] = []
//        messageInfo = [0x02, 0x00]
//        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = Byte(messageInfo.count)
//        message[2] = Byte(id1Address)
//        message[3] = Byte(id2Address)
//        message[4] = 0xFE
//        message[5] = 0x05
//        message[6] = 0x0C
//        var i = 0
//        for byte in messageInfo {
//            message[7+i] = byte
//            i = i + 1
//        }
//        message[message.count-2] = self.getChkByte(byteArray:message)
//        message[message.count-1] = 0x10
//        return message
//    }
//    static func sendKeySecurity (key:Byte) -> [Byte]{
//        var messageInfo:[Byte] = []
//        var message:[Byte] = []
//        messageInfo = [0x01, key]
//        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = Byte(messageInfo.count)
//        message[2] = Byte(id1Address)
//        message[3] = Byte(id2Address)
//        message[4] = 0xFE
//        message[5] = 0x05
//        message[6] = 0x11
//        var i = 0
//        for byte in messageInfo {
//            message[7+i] = byte
//            i = i + 1
//        }
//        message[message.count-2] = self.getChkByte(byteArray:message)
//        message[message.count-1] = 0x10
//        return message
//    }
    // MARK: - Get check byte
    static func getChkByte (byteArray byteArray:[Byte]) -> Byte {
        var chk:Int = 0
        for var i = 1; i <= byteArray.count-3; i++ {
            let number = "\(byteArray[i])"
            
            chk = chk + Int(number)!
        }
        chk = chk%256
        return Byte(chk)
    }
    // MARK: - Get command for getting zone and categories
    class func getZone (address:[Byte], id:Byte) -> [Byte] {
        var message:[Byte] = []
        //        Video sam da stoji i 0xFF
        //        var messageInfo:[Byte] = [0xFF, id]
        var messageInfo:[Byte] = [0x00, id]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x02
        message[6] = 0x11
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    class func getCategory (address:[Byte], id:Byte) -> [Byte] {
        var message:[Byte] = []
        //        Video sam da stoji i 0xFF
        //        var messageInfo:[Byte] = [0xFF, id]
        var messageInfo:[Byte] = [0x00, id]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x02
        message[6] = 0x13
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}
//MARK:- CLIMATE
extension Function {
    static func getACName (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, 0x01]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x01
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getACStatus (address:[Byte]) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0xFF]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x03
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setACStatus (address:[Byte], channel:Byte, status:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, status, 0x00, 0x00]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x05
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setACmode (address:[Byte], channel:Byte, value:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, 0x00, value, 0x00, 0x00]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x06
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setACSpeed (address:[Byte], channel:Byte, value:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, 0x00, value, 0x00, 0x00]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x07
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setACSetPoint (address:[Byte], channel:Byte, coolingSetPoint:Byte, heatingSetPoint:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, coolingSetPoint, heatingSetPoint]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x08
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setACEnergySaving (address:[Byte], channel:Byte, status:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, status]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x0A
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}
//MARK:- FLAG
extension Function {
    //   **************************************************************************************
    //   **************************************   FLAG   **************************************
    //   **************************************************************************************
    static func setFlag (address:[Byte], id:Byte, command:Byte) -> [Byte]{
        let messageInfo:[Byte] = [id, command]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x07
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func refreshFlagStatus (address:[Byte]) -> [Byte]{
        let messageInfo:[Byte] = [0xFF]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x06
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}
//MARK:- EVENT
extension Function {
    //   **************************************************************************************
    //   **************************************   EVENT   *************************************
    //   **************************************************************************************
    static func runEvent (address:[Byte], id:Byte) -> [Byte]{
        var messageInfo:[Byte] = [id, 0xFF]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x10
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func cancelEvent (address:[Byte], id:Byte) -> [Byte]{
        var messageInfo:[Byte] = [id, 0xEF]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x10
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}
//MARK:- SEQUENCE
extension Function {
    //   **************************************************************************************
    //   *************************************   SEQUENCE   ***********************************
    //   **************************************************************************************
    static func setSequence (address:[Byte], id:Int, cycle:Byte) -> [Byte]{
        let numberOne:Byte = Byte((id / 0x100) % 0x100)
        let numberTwo:Byte = Byte(id % 0x100)
        var messageInfo:[Byte] = [0xFF, 0xFF, 0xFF, 0x05, cycle, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x07
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}
//MARK:- SCENE
extension Function {
    //   **************************************************************************************
    //   **************************************   SCENE   *************************************
    //   **************************************************************************************
    static func setScene (address:[Byte], id:Int) -> [Byte]{
        let numberOne:Byte = Byte((id / 0x100) % 0x100)
        let numberTwo:Byte = Byte(id % 0x100)
        var messageInfo:[Byte] = [0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x07
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}
//MARK:- TIMER
extension Function {
    //   **************************************************************************************
    //   **************************************   TIMER   *************************************
    //   **************************************************************************************
    static func getTimerParametar (address:[Byte], id:Byte) -> [Byte]{
        let messageInfo:[Byte] = [id]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x13
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // 01 is Start, EF is Cancel, EE is Pause, ED is Resume
    static func getCancelTimerStatus(address:[Byte], id:Byte, command:Byte) -> [Byte]{
        let messageInfo:[Byte] = [id, command]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x17
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func refreshTimerStatus(address:[Byte]) -> [Byte]{
        let messageInfo:[Byte] = [0xFF]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x17
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}
//MARK:- ANALOG/ DIGITAL INPUT
extension Function {
    //   **************************************************************************************
    //   ****************************   ANALOG/ DIGITAL INPUT   *******************************
    //   **************************************************************************************
    
    static func getInterfaceParametar (address:[Byte], channel:Byte) -> [Byte]{
        let messageInfo:[Byte] = [channel]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x02
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    // Set interface parametar
    static func setInterfaceParametar (address:[Byte], channel:Byte, isEnabled:Byte) -> [Byte]{
        let messageInfo:[Byte] = [channel, isEnabled]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x03
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    // Set interface parametar
    static func getInterfaceStatus (address:[Byte], channel:Byte, isEnabled:Byte) -> [Byte]{
        let messageInfo:[Byte] = [channel, isEnabled]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x03
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // Set interface parametar
    static func setSensorState (address:[Byte], channel:Byte, status:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        var s:Byte = 0x00
        if status == 0xFF {
            s = 0x80
        }
        if status == 0x00 {
            s = 0x7F
        }
        messageInfo = [channel, s]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x03
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // Get interface status
    static func getSensorState (address:[Byte]) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0xFF]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x01
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // Get interface parametar
    static func getSensorEna (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x02
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // Set interface parametar
    static func sensorEnabled (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, 0x80]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x03
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func sensorDisabled (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, 0x7F]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x03
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
}
//MARK:- SECURITY
extension Function {
    //   **************************************************************************************
    //   ************************************   SECURITY   ************************************
    //   **************************************************************************************
    
    static func refreshSecurityMode (address:[Byte]) -> [Byte]{
        let messageInfo:[Byte] = [0x02, 0x00]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x0C
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    //   1, 2, 3, 4, 5, 6, 7, 8, 9, 0B (star), 1A (hash)
    static func sendKeySecurity (address:[Byte], key:Byte) -> [Byte]{
        let messageInfo:[Byte] = [0x01, key]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x11
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getCurrentSecurityMode (address:[Byte]) -> [Byte]{
        let messageInfo:[Byte] = [0x02, 0x00]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x11
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func changeSecurityMode (address:[Byte], mode:Byte) -> [Byte]{
        let messageInfo:[Byte] = [0x02, mode]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x11
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getCurrentAlarmState (address:[Byte]) -> [Byte]{
        let messageInfo:[Byte] = [0x03, 0x00]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x11
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setPanic (address:[Byte], panic:Byte) -> [Byte]{
        let messageInfo:[Byte] = [0x04, panic]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x11
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }

}

extension Function {
//   **************************************************************************************
//   ****************************   ANALOG/ DIGITAL OUPUT   *******************************
//   **************************************************************************************
    
//    static func getInterfaceEnabled (address:[Byte], panic:Byte) -> [Byte]{
//        let messageInfo:[Byte] = [0x04, panic]
//        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = Byte(messageInfo.count)
//        message[2] = address[0]
//        message[3] = address[1]
//        message[4] = address[2]
//        message[5] = 0x05
//        message[6] = 0x11
//        var i = 0
//        for byte in messageInfo {
//            message[7+i] = byte
//            i = i + 1
//        }
//        message[message.count-2] = self.getChkByte(byteArray:message)
//        message[message.count-1] = 0x10
//        return message
//    }
//    static func setInterfaceParametar (address:[Byte], panic:Byte) -> [Byte]{
//        let messageInfo:[Byte] = [0x04, panic]
//        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = Byte(messageInfo.count)
//        message[2] = address[0]
//        message[3] = address[1]
//        message[4] = address[2]
//        message[5] = 0x05
//        message[6] = 0x11
//        var i = 0
//        for byte in messageInfo {
//            message[7+i] = byte
//            i = i + 1
//        }
//        message[message.count-2] = self.getChkByte(byteArray:message)
//        message[message.count-1] = 0x10
//        return message
//    }
//    static func setInterfaceEnabled (address:[Byte], panic:Byte) -> [Byte]{
//        let messageInfo:[Byte] = [0x04, panic]
//        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = Byte(messageInfo.count)
//        message[2] = address[0]
//        message[3] = address[1]
//        message[4] = address[2]
//        message[5] = 0x05
//        message[6] = 0x11
//        var i = 0
//        for byte in messageInfo {
//            message[7+i] = byte
//            i = i + 1
//        }
//        message[message.count-2] = self.getChkByte(byteArray:message)
//        message[message.count-1] = 0x10
//        return message
//    }
    
}