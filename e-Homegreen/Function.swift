//
//  Function.swift
//  new
//
//  Created by Teodor Stevic on 7/3/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class Function {
    static func getLightRelayStatus (address:[UInt8]) -> [UInt8] {
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [0xFF]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setLightRelayStatus (address:[UInt8], channel:UInt8, value:UInt8, delay:Int, runningTime:Int, skipLevel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        let delayOne = UInt8((delay / 0x100) % 0x100)
        let delayTwo = UInt8(delay % 0x100)
        let runtimeOne = UInt8((runningTime / 0x100) % 0x100)
        let runtimeTwo = UInt8(runningTime % 0x100)
        messageInfo = [0xFF, 0xFF, 0xFF, 0x01, value, delayOne, delayTwo, runtimeOne, runtimeTwo, 0x00, skipLevel, 0x00, channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func searchForDevices (address:[UInt8]) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func zoneControl (zone:UInt8, value:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [0x01, 0x00, 0x00, 0x02, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, zone]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getWarnings (address:[UInt8]) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = []
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getRunningTime (address:[UInt8]) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = []
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setCurtainStatus (address:[UInt8], channel:UInt8, value:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [0xFF, 0xFF, 0xFF, 0x06, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    // AC
    static func getACStatus (address:[UInt8]) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [0xFF]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setACStatus (address:[UInt8], channel:UInt8, status:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, status, 0x00, 0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setACmode (address:[UInt8], channel:UInt8, value:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, 0x00, value, 0x00, 0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setACSpeed (address:[UInt8], channel:UInt8, value:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, 0x00, value, 0x00, 0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setACSetPoint (address:[UInt8], channel:UInt8, coolingSetPoint:UInt8, heatingSetPoint:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, coolingSetPoint, heatingSetPoint]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setACEnergySaving (address:[UInt8], channel:UInt8, status:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, status]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func runEvent (address:[UInt8], id:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = [id, 0xFF]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func cancelEvent (address:[UInt8], id:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = [id, 0xEF]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setScene (address:[UInt8], id:Int) -> [UInt8]{
        let numberOne:UInt8 = UInt8((id / 0x100) % 0x100)
        let numberTwo:UInt8 = UInt8(id % 0x100)
        var messageInfo:[UInt8] = [0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[0]
        message[4] = address[0]
        message[5] = 0x03
        message[6] = 0x07
        for i in 0...messageInfo.count - 1 {
            message[7+i] = messageInfo[i]
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setSequence (address:[UInt8], id:Int, cycle:UInt8) -> [UInt8]{
        let numberOne:UInt8 = UInt8((id / 0x100) % 0x100)
        let numberTwo:UInt8 = UInt8(id % 0x100)
        var messageInfo:[UInt8] = [0xFF, 0xFF, 0xFF, 0x05, cycle, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setSensorState (address:[UInt8], channel:UInt8, status:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        var s:UInt8 = 0x00
        if status == 0xFF {
            s = 0x80
        }
        if status == 0x00 {
            s = 0x7F
        }
        messageInfo = [channel, s]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getSensorState (address:[UInt8]) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [0xFF]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getSensorEna (address:[UInt8], channel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func sensorEnabled (address:[UInt8], channel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, 0x80]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func sensorDisabled (address:[UInt8], channel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, 0x7F]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getChannelName (address:[UInt8], channel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getModuleName (address:[UInt8]) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = []
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getACName (address:[UInt8], channel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, 0x01]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getSensorName (address:[UInt8], channel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getSensorZone (address:[UInt8], channel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func sendIRLibrary (address:[UInt8], channel:UInt8, ir_id:UInt8, times:UInt8, interval:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        //messageInfo = [channel * 64 + times, interval, UInt8(ir_id / 0x100), UInt8((ir_id / 0x100) % 0x100)]
        messageInfo = [] //  resi ovo
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    
    static func sendSerialLibrary (address:[UInt8], channel:UInt8, serialId:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        //messageInfo = [UInt8((serialId / 0x100) % 0x100), UInt8(serialId % 0x100), channel]
        messageInfo = [] //  resi ovo
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    
    static func resetRunningTime (address:[UInt8], channel:UInt8) -> [UInt8]{
        var messageInfo:[UInt8] = []
        var message:[UInt8] = []
        messageInfo = [channel, 0x00, 0x00, 0x00, 0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
//    static func refreshSecurityMode () -> [UInt8]{
//        var messageInfo:[UInt8] = []
//        var message:[UInt8] = []
//        messageInfo = [0x02, 0x00]
//        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = UInt8(messageInfo.count)
//        message[2] = UInt8(id1Address)
//        message[3] = UInt8(id2Address)
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
//    static func sendKeySecurity (key:UInt8) -> [UInt8]{
//        var messageInfo:[UInt8] = []
//        var message:[UInt8] = []
//        messageInfo = [0x01, key]
//        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = UInt8(messageInfo.count)
//        message[2] = UInt8(id1Address)
//        message[3] = UInt8(id2Address)
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
    
    //   **************************************************************************************
    //   ************************************   SECURITY   ************************************
    //   **************************************************************************************
    
    static func refreshSecurityMode (address:[UInt8]) -> [UInt8]{
        let messageInfo:[UInt8] = [0x02, 0x00]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func sendKeySecurity (address:[UInt8], key:UInt8) -> [UInt8]{
        let messageInfo:[UInt8] = [0x01, key]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getCurrentSecurityMode (address:[UInt8]) -> [UInt8]{
        let messageInfo:[UInt8] = [0x02, 0x00]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func changeSecurityMode (address:[UInt8], mode:UInt8) -> [UInt8]{
        let messageInfo:[UInt8] = [0x02, mode]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getCurrentAlarmState (address:[UInt8]) -> [UInt8]{
        let messageInfo:[UInt8] = [0x03, 0x00]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func setPanic (address:[UInt8], panic:UInt8) -> [UInt8]{
        let messageInfo:[UInt8] = [0x04, panic]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
//    ===========================   Timer   ===========================
    static func getTimerParametar (address:[UInt8], id:UInt8) -> [UInt8]{
        let messageInfo:[UInt8] = [id]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    static func getCancelTimerStatus (address:[UInt8], id:UInt8, command:UInt8) -> [UInt8]{
        let messageInfo:[UInt8] = [id, command]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
//    ===========================   Timer   ===========================
    
    static func setFlag (address:[UInt8], id:UInt8, command:UInt8) -> [UInt8]{
        let messageInfo:[UInt8] = [id, command]
        var message:[UInt8] = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    
    static func getChkByte (byteArray byteArray:[UInt8]) -> UInt8 {
        var chk:Int = 0
        for var i = 1; i <= byteArray.count-3; i++ {
            let number = "\(byteArray[i])"
            
            chk = chk + Int(number)!
        }
        chk = chk%256
        return UInt8(chk)
    }
}
