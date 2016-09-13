//
//  Function.swift
//  new
//
//  Created by Teodor Stevic on 7/3/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

/// Class for communication with PLC. Sending commands to PLC
/// Incoming handler is responsible for reveiving commands and data.
class Function {
    // Get Socket State Command:
    static func refreshGatewayConnection (address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x02
        message[6] = 0x03
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setInternalClockRTC (address:[Byte], year:Byte, month:Byte, day:Byte, hour:Byte, minute:Byte, second:Byte, dayOfWeak:Byte) -> [Byte] {
        var messageInfo:[Byte] = [0xFF, year, month, day, hour, minute,  second, dayOfWeak]
        var message:[Byte] = []
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
    static func getChannelName (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
//MARK:- SaltoAccess
extension Function {
    static func getSaltoAccessInfoWithAddress(address:[Byte]) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0x00]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x55
        
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
}


//MARK:- CURTAIN
extension Function {
    enum Value:Byte {
        case Open = 0xFF
        case Close = 0x00
        case Stop = 0xEF
        case Toggle = 0xF1
    }
    static func setCurtainStatus (address:[Byte], value:Byte, groupId:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
         messageInfo = [0xFF, 0xFF, 0xFF, 0x06, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, groupId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
//MARK:- CLIMATE
extension Function {
    static func getACName (address:[Byte], channel:Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [channel, 0x01]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
    static func setFlag (address:[Byte], id:Byte, command:Byte) -> [Byte]{
        let messageInfo:[Byte] = [id, command]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
    static func getFlagName(address:[Byte], flagId: Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [flagId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
    static func getFlagParametar(address:[Byte], flagId: Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [flagId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
}
//MARK:- EVENT
extension Function {
    static func runEvent (address:[Byte], id:Byte) -> [Byte]{
        var messageInfo:[Byte] = [id, 0xFF]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
    static func getEventNameAndParametar(address:[Byte], eventId: Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [eventId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x08
        
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
    static func setSequence (address:[Byte], id:Int, cycle:Byte) -> [Byte]{
        let numberOne:Byte = Byte((id / 0x100) % 0x100)
        let numberTwo:Byte = Byte(id % 0x100)
        var messageInfo:[Byte] = [0xFF, 0xFF, 0xFF, 0x05, cycle, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
    static func getSequenceNameAndParametar(address:[Byte], sequenceId: Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [sequenceId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x0A
        
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
    static func setScene (address:[Byte], id:Int) -> [Byte]{
        let numberOne:Byte = Byte((id / 0x100) % 0x100)
        let numberTwo:Byte = Byte(id % 0x100)
        var messageInfo:[Byte] = [0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
    static func getSceneNameAndParametar(address:[Byte], sceneId: Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [sceneId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x08
        
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
    static func getTimerName(address:[Byte], timerId: Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [timerId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x15
        
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
    static func getTimerParametar (address:[Byte], id:Byte) -> [Byte]{
        let messageInfo:[Byte] = [id]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        let messageInfo:[Byte] = [0xFF, 0x00]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
    static func refreshTimerStatusCountApp(address:[Byte]) -> [Byte]{
        let messageInfo:[Byte] = [0xFF, 0x01]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x19
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
//MARK:- FLAG
extension Function {
    static func getCardName(address:[Byte], cardId: Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0x00, cardId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x57
        
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
    static func getCardParametar(address:[Byte], cardId: Byte) -> [Byte]{
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        messageInfo = [0x00, cardId]
        message = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x56
        
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
}
//MARK:- ANALOG/ DIGITAL INPUT
extension Function {
    static func getInterfaceParametar (address:[Byte], channel:Byte) -> [Byte]{
        let messageInfo:[Byte] = [channel]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
        message[1] = Byte(messageInfo.count % 256)
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
    //   1, 2, 3, 4, 5, 6, 7, 8, 9, 0B (star), 1A (hash)
    // Checked. OK.
    // Send command (password) for disarm
    static func sendKeySecurity (address:[Byte], key:Byte) -> [Byte]{
        let messageInfo:[Byte] = [0x01, key]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
        
        // TODO:
        //**** Change function to this code in future, it is shorter. 
        // Define variables for bytes in message such as SOI, LEN, ADDR, CID1, CID2 etc. It will be more readable.
//        let messageLength = 7 + messageInfo.count + 2
//        var messageNew = [0xAA, Byte(messageInfo.count % 256)] + address + [0x05, 0x11] + messageInfo + [self.getChkByte(byteArray:message), 0x10]
    }
    // Checked. OK.
    static func getCurrentSecurityMode (address:[Byte]) -> [Byte]{
        let messageInfo:[Byte] = [0x02, 0x00]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
    // Checked. OK.
    // Message is created as protocol specifies. Look UCM_ehomeGrreen Command List.docx file
    static func changeSecurityMode (address:[Byte], mode:Byte) -> [Byte]{
        let messageInfo:[Byte] = [0x02, mode]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
    // Checked. OK.
    // Message is created as protocol specifies. Look UCM_ehomeGrreen Command List.docx file
    static func getCurrentAlarmState (address:[Byte]) -> [Byte]{
        let messageInfo:[Byte] = [0x03, 0x00]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
    // Checked. OK.
    static func setPanic (address:[Byte], panic:Byte) -> [Byte]{
        let messageInfo:[Byte] = [0x04, panic]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
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
//MARK:- ANALOG/DIGITAL OUTPUT
extension Function {
    //    static func getInterfaceEnabled (address:[Byte], panic:Byte) -> [Byte]{
    //        let messageInfo:[Byte] = [0x04, panic]
    //        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
    //        message[0] = 0xAA
    //        message[1] = Byte(messageInfo.count % 256)
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
    //        message[1] = Byte(messageInfo.count % 256)
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
    //        message[1] = Byte(messageInfo.count % 256)
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
//MARK:- PC Control
extension Function {
    //TODO:- Nije uradjeno report PC state
    static func reportPCState (address:[Byte], text:String) -> [Byte]{
        let textByteArray = [Byte](text.utf8)
        var messageInfo:[Byte] = [0x01, 0x00, 0x00]
        messageInfo = messageInfo + textByteArray
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x0A
        message[6] = 0x01
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
//    0x01 - Shut down
//    0x02 - Restart
//    0x03 - Sleep
//    0x04 - Hibernate
//    0x05 - Log off
    static func setPCState (address:[Byte], command:Byte) -> [Byte]{
        let messageInfo:[Byte] = [0x02, command]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x0A
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
    static func setPCVolume (address:[Byte], volume:Byte, mute:Byte=0x00) -> [Byte]{
        let messageInfo:[Byte] = [volume, mute]
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x0A
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
//    0x01 - Windows Media Player
//    0x02 - Windows Media Center
    static func playVideo (address:[Byte], fileName:String, fullScreen:Byte, by:Byte) -> [Byte]{
        let fileNameByteArray = [Byte](fileName.utf8)
        var messageInfo:[Byte] = [by, fullScreen, 0xFF]
        messageInfo = messageInfo + fileNameByteArray
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x0A
        message[6] = 0x04
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func runApp (address:[Byte], cmdLine:String) -> [Byte] {
        let cmdLineByteArray = [Byte](cmdLine.utf8)
        var messageInfo:[Byte] = [0x01]
        messageInfo = messageInfo + cmdLineByteArray
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x0A
        message[6] = 0x05
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func textToSpeech (address:[Byte], text:String) -> [Byte]{
        let textByteArray = [Byte](text.utf8)
        var messageInfo:[Byte] = [0x01, 0x00, 0x00]
        messageInfo = messageInfo + textByteArray
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x0A
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

    static func sendNotification (address:[Byte], text:String, notificationType: NotificationType, notificationPosition: NotificationPosition, delayTime: Int, displayTime: Int) -> [Byte]{
        
        let textByteArray = [Byte](text.utf8)
        var message:[Byte] = [Byte](count: textByteArray.count+15, repeatedValue: 0)
        
        //Control bytes:
        message[0] = 0xAA
        message[1] = Byte((textByteArray.count+6) % 256)
        
        //Address:
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        
        //Command:
        message[5] = 0x0A
        message[6] = 0x07
        
        //Type & Position:
        message[7] = Byte(notificationType.rawValue)
        message[8] = Byte(notificationPosition.rawValue)
        
        //Delay time:
        if delayTime > 255 {
            let firstByte = UInt8(UInt16(delayTime) >> 8)
            let secondByte = UInt8(UInt16(delayTime) & 0x00ff)
            
            message[9] = firstByte
            message[10] = secondByte
        }else{
            message[9] = 0x00
            message[10] = Byte(delayTime)
        }
        
        //Display time:
        if displayTime > 255 {
            let firstByte = UInt8(UInt16(displayTime) >> 8)
            let secondByte = UInt8(UInt16(displayTime) & 0x00ff)
            
            message[11] = firstByte
            message[12] = secondByte
        }else{
            message[11] = 0x00
            message[12] = Byte(delayTime)
        }
        
        //Text:
        var i = 0
        for byte in textByteArray {
            message[13+i] = byte
            i = i + 1
        }
        
        //Control bytes:
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }

    //TODO:- Nije odradjeno budjenje iz lana
    static func wakeOnLan (address:[Byte], mac:[Byte], password:[Byte]) -> [Byte]{
        guard mac.count == 6 || password.count == 6 || address.count == 3 else {
            return [0x00]
        }
        var messageInfo:[Byte] = [0x01, 0x00, 0x00]
        messageInfo += mac
        messageInfo += password
        var message:[Byte] = [Byte](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x0A
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
}