//
//  Functions.swift
//  new
//
//  Created by Teodor Stevic on 7/3/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class Functions: NSObject {
    var messageInfo:[UInt8] = []
    var message:[UInt8] = []
//    var id1Address = 1, id2Address = 0, id3Address = 0
    
    func getLightRelayStatus (address:[UInt8]) -> [UInt8] {
        messageInfo = [0xFF]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
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
//    func setLightRelayStatus (address:[UInt8], channel:UInt8, value:UInt8, runningTime:UInt8) -> [UInt8]{
//        messageInfo = [0xFF, 0xFF, 0xFF, 0x01, value, 0x00, 0x00, 0x00, runningTime, 0x00, 0x00, 0x00, channel]
//        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = UInt8(messageInfo.count)
//        message[2] = address[0]
//        message[3] = address[1]
//        message[4] = address[2]
//        message[5] = 0x03
//        message[6] = 0x07
//        var i = 0
//        for byte in messageInfo {
//            message[7+i] = byte
//            i = i + 1
//        }
//        message[message.count-2] = self.getChkByte(byteArray:message)
//        message[message.count-1] = 0x10
//        return message
//    }
    func setLightRelayStatus (address:[UInt8], channel:UInt8, value:UInt8, delay:Int, runningTime:Int, skipLevel:UInt8) -> [UInt8]{
        var delayOne = UInt8((delay / 0x100) % 0x100)
        var delayTwo = UInt8(delay % 0x100)
        var runtimeOne = UInt8((runningTime / 0x100) % 0x100)
        var runtimeTwo = UInt8(runningTime % 0x100)
        messageInfo = [0xFF, 0xFF, 0xFF, 0x01, value, delayOne, delayTwo, runtimeOne, runtimeTwo, 0x00, skipLevel, 0x00, channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
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
//    func setDelayRunningTimeSkip (address:[UInt8], channel:UInt8, value:UInt8, delay:Int, runningTime:Int, skipLevel:Int) -> [UInt8]{
//        var delayOne = UInt8((delay / 0x100) % 0x100)
//        var delayTwo = UInt8(delay % 0x100)
//        var runtimeOne = UInt8((runningTime / 0x100) % 0x100)
//        var runtimeTwo = UInt8(runningTime % 0x100)
//        messageInfo = [0xFF, 0xFF, 0xFF, 0x01, value, delayOne, delayTwo, runtimeOne, runtimeTwo, 0x00, skipLevel, 0x00, channel]
//        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = UInt8(messageInfo.count)
//        message[2] = address[0]
//        message[3] = address[1]
//        message[4] = address[2]
//        message[5] = 0x03
//        message[6] = 0x07
//        var i = 0
//        for byte in messageInfo {
//            message[7+i] = byte
//            i = i + 1
//        }
//        message[message.count-2] = self.getChkByte(byteArray:message)
//        message[message.count-1] = 0x10
//        return message
//    }
    // da li treba da bude prazan ili bar jedan 0x00 u messageInfo?
    func searchForDevices (address:[UInt8]) -> [UInt8]{
        messageInfo = [0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x01 // NIJE DOBRO
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
    func zoneControl (zone:UInt8, value:UInt8) -> [UInt8]{
        messageInfo = [0x01, 0x00, 0x00, 0x02, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, zone]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = 0xFF
        message[3] = 0xFF
        message[4] = 0xFF
        message[5] = 0x03
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
    // da li treba da bude prazan ili bar jedan 0x00 u messageInfo?
    func getWarnings (address:[UInt8]) -> [UInt8]{
        messageInfo = []
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x10
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // da li treba da bude prazan ili bar jedan 0x00 u messageInfo?
    func getRunningTime (address:[UInt8]) -> [UInt8]{
        messageInfo = []
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
        message[6] = 0x10
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    func setCurtainStatus (address:[UInt8], channel:UInt8, value:UInt8) -> [UInt8]{
        messageInfo = [0xFF, 0xFF, 0xFF, 0x06, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
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
    // AC
    func getACStatus (address:[UInt8]) -> [UInt8]{
        messageInfo = [0xFF]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
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
    func setACStatus (address:[UInt8], channel:UInt8, status:UInt8) -> [UInt8]{
        messageInfo = [channel, status, 0x00, 0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
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
    func setACmode (address:[UInt8], channel:UInt8, value:UInt8) -> [UInt8]{
        messageInfo = [channel, 0x00, value, 0x00, 0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
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
    func setACSpeed (address:[UInt8], channel:UInt8, value:UInt8) -> [UInt8]{
        messageInfo = [channel, 0x00, value, 0x00, 0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
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
    func setACSetPoint (address:[UInt8], channel:UInt8, coolingSetPoint:UInt8, heatingSetPoint:UInt8) -> [UInt8]{
        messageInfo = [channel, coolingSetPoint, heatingSetPoint]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x08
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    func setACEnergySaving (address:[UInt8], channel:UInt8, status:UInt8) -> [UInt8]{
        messageInfo = [channel, status]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
        message[6] = 0x0A
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    func runEvent (address:[UInt8], id:UInt8) -> [UInt8]{
        messageInfo = [id, 0xFF]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
        message[6] = 0x10
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    func setSensorState (address:[UInt8], channel:UInt8, status:UInt8) -> [UInt8]{
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
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    func getSensorState (address:[UInt8]) -> [UInt8]{
        messageInfo = [0xFF]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
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
    func getSensorEna (address:[UInt8], channel:UInt8) -> [UInt8]{
        messageInfo = [channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    func sensorEnabled (address:[UInt8], channel:UInt8) -> [UInt8]{
        messageInfo = [channel, 0x80]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    func sensorDisabled (address:[UInt8], channel:UInt8) -> [UInt8]{
        messageInfo = [channel, 0x7F]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    func setScene (address:[UInt8], id:Int) -> [UInt8]{
        var numberOne:UInt8 = UInt8((id / 0x100) % 0x100)
        var numberTwo:UInt8 = UInt8(id % 0x100)
        messageInfo = [0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[0]
        message[4] = address[0]
        message[5] = 0x03
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
//    func setDelayRuntimeSkipState (address:[UInt8], id:Int) -> [UInt8]{
//        var numberOne:UInt8 = UInt8((id / 0x100) % 0x100)
//        var numberTwo:UInt8 = UInt8(id % 0x100)
//        messageInfo = [0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
//        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
//        message[0] = 0xAA
//        message[1] = UInt8(messageInfo.count)
//        message[2] = address[0]
//        message[3] = address[0]
//        message[4] = address[0]
//        message[5] = 0x03
//        message[6] = 0x07
//        var i = 0
//        for byte in messageInfo {
//            message[7+i] = byte
//            i = i + 1
//        }
//        message[message.count-2] = self.getChkByte(byteArray:message)
//        message[message.count-1] = 0x10
//        return message
//    }
    func getChannelName (address:[UInt8], channel:UInt8) -> [UInt8]{
        messageInfo = [channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
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
    func getModuleName (address:[UInt8]) -> [UInt8]{
        messageInfo = []
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x01
        message[6] = 0x0D
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    func getACName (address:[UInt8], channel:UInt8) -> [UInt8]{
        messageInfo = [channel, 0x01]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x04
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
    func getSensorName (address:[UInt8], channel:UInt8) -> [UInt8]{
        messageInfo = [channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x05
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
    func getSensorZone (address:[UInt8], channel:UInt8) -> [UInt8]{
        messageInfo = [channel]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
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
    func sendIRLibrary (address:[UInt8], channel:UInt8, ir_id:UInt8, times:UInt8, interval:UInt8) -> [UInt8]{
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
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    func sendSerialLibrary (address:[UInt8], channel:UInt8, serialId:UInt8) -> [UInt8]{
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
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    func resetRunningTime (address:[UInt8], channel:UInt8) -> [UInt8]{
        messageInfo = [channel, 0x00, 0x00, 0x00, 0x00]
        message = [UInt8](count: messageInfo.count+9, repeatedValue: 0)
        message[0] = 0xAA
        message[1] = UInt8(messageInfo.count)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x03
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
//    func refreshSecurityMode () -> [UInt8]{
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
//    func sendKeySecurity (key:UInt8) -> [UInt8]{
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
    func getChkByte (#byteArray:[UInt8]) -> UInt8 {
        var chk:Int = 0
        for var i = 1; i <= byteArray.count-3; i++ {
            var number = "\(byteArray[i])"
            
            chk = chk + number.toInt()!
        }
        chk = chk%256
        return UInt8(chk)
    }
}
