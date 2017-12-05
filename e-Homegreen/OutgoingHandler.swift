//
//  OutgoingHandler.swift
//  new
//
//  Created by Teodor Stevic on 7/3/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

/// Class for communication with PLC. Sending commands to PLC
/// Incoming handler is responsible for reveiving commands and data.
class OutgoingHandler {
    
    // Get Socket State Command:
    static func refreshGatewayConnection (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = []
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x02, CID2: 0x03)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setInternalClockRTC (_ address:[Byte], year:Byte, month:Byte, day:Byte, hour:Byte, minute:Byte, second:Byte, dayOfWeak:Byte) -> [Byte] {
        var messageInfo:[Byte] = [0xFF, year, month, day, hour, minute,  second, dayOfWeak]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x01, CID2: 0x11)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func resetRunningTime (_ address:[Byte], channel:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x0C)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func getZone(_ address:[Byte], id:Byte) -> [Byte] {
        //        Video sam da stoji i 0xFF
        //        var messageInfo:[Byte] = [0xFF, id]
        var messageInfo:[Byte] = [0x00, id]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x02, CID2: 0x11)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func getCategory (_ address:[Byte], id:Byte) -> [Byte] {
        //        Video sam da stoji i 0xFF
        //        var messageInfo:[Byte] = [0xFF, id]
        var messageInfo:[Byte] = [0x00, id]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x02, CID2: 0x13)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    // Helpers
    static func getChkByte(byteArray:[Byte]) -> Byte {
        var chk:Int = 0
        for i in 1...(byteArray.count-3) {
            let number = "\(byteArray[i])"
            
            chk = chk + Int(number)!
        }
        chk = chk%256
        return Byte(chk)
    }
    
    static func setupMessage(messageInfo: [Byte], address: [Byte], CID1: Byte, CID2: Byte) -> [Byte] {
        var message: [Byte] = [Byte](repeating: 0, count: messageInfo.count+9)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = CID1
        message[6] = CID2
        return message
    }
}

//MARK:- RELAY
extension OutgoingHandler{
    static func getLightRelayStatus (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0xFF]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x06)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func setLightRelayStatus (_ address:[Byte], channel:Byte, value:Byte, delay:Int, runningTime:Int, skipLevel:Byte) -> [Byte] {
        let delayOne = Byte((delay / 0x100) % 0x100)
        let delayTwo = Byte(delay % 0x100)
        let runtimeOne = Byte((runningTime / 0x100) % 0x100)
        let runtimeTwo = Byte(runningTime % 0x100)
        var messageInfo = [0xFF, 0xFF, 0xFF, 0x01, value, delayOne, delayTwo, runtimeOne, runtimeTwo, 0x00, skipLevel, 0x00, channel]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x07)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}

//MARK:- CHANNEL
extension OutgoingHandler {
    static func getChannelName (_ address:[Byte], channel:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x01)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}

//MARK:- MODULE
extension OutgoingHandler {
    static func getModuleName (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x01, CID2: 0x0D)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}

//MARK:- DEVICE
extension OutgoingHandler {
    static func searchForDevices (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x01, CID2: 0x01)
//        message[5] = 0x01 // NIJE DOBRO
//        message[6] = 0x01
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}

//MARK:- SENSOR
extension OutgoingHandler {
    static func getSensorName (_ address:[Byte], channel:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2:  0x04)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getSensorParameters (_ address:[Byte], channel:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x02)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}

//MARK:- SALTO ACCESS
extension OutgoingHandler {
    static func setSaltoAccessMode(_ address:[Byte], lockId: Int, mode: Int) -> [Byte] {
        //MODE
//        GRANT ACCESS - 01
//        OPEN AND STAY IN OFFICE MODE - 02
//        FINISH OFFICE MODE - 03
        var messageInfo:[Byte] = [UInt8(lockId), UInt8(mode), 0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x51)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
    static func getSaltoAccessState(_ address:[Byte], lockId: Int) -> [Byte] {
        var messageInfo:[Byte] = [UInt8(lockId)]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x50)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
    static func getSaltoAccessInfoWithAddress(_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x55)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
}

//MARK:- CURTAIN
extension OutgoingHandler {
    static func setCurtainStatus (_ address:[Byte], value:Byte, groupId:Byte) -> [Byte] {
        var messageInfo:[Byte] = [0xFF, 0xFF, 0xFF, 0x06, value, 0x00, 0x00 /* delay time? */, 0x00, 0x00 /* running time? */, 0x00, 0x00, 0x00, groupId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x07)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func getCurtainStatus (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0xF0]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x06)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}

//MARK:- CLIMATE
extension OutgoingHandler {
    static func getACName (_ address:[Byte], channel:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel, 0x01]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x04, CID2: 0x01)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func getACStatus (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0xFF]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x04, CID2: 0x03)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func setACStatus (_ address:[Byte], channel:Byte, status:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel, status, 0x00, 0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x04, CID2: 0x05)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func setACmode (_ address:[Byte], channel:Byte, value:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel, 0x00, value, 0x00, 0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x04, CID2: 0x06)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func setACSpeed (_ address:[Byte], channel:Byte, value:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel, 0x00, value, 0x00, 0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x04, CID2: 0x07)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func setACSetPoint (_ address:[Byte], channel:Byte, coolingSetPoint:Byte, heatingSetPoint:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel, coolingSetPoint, heatingSetPoint]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x04, CID2: 0x08)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func setACEnergySaving (_ address:[Byte], channel:Byte, status:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel, status]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x04, CID2: 0x0A)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
}

//MARK:- FLAG
extension OutgoingHandler {
    static func setFlag (_ address:[Byte], id:Byte, command:Byte) -> [Byte] {
        let messageInfo:[Byte] = [id, command]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x07)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func refreshFlagStatus (_ address:[Byte]) -> [Byte] {
        let messageInfo:[Byte] = [0xFF]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x06)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func getFlagName(_ address:[Byte], flagId: Byte) -> [Byte] {
        var messageInfo:[Byte] = [flagId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x04)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
    
    static func getFlagParametar(_ address:[Byte], flagId: Byte) -> [Byte] {
        var messageInfo:[Byte] = [flagId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x02)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
}

//MARK:- EVENT
extension OutgoingHandler {
    static func runEvent (_ address:[Byte], id:Byte) -> [Byte] {
        var messageInfo:[Byte] = [id, 0xFF]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x10)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func cancelEvent (_ address:[Byte], id:Byte) -> [Byte] {
        var messageInfo:[Byte] = [id, 0xEF]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x10)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func getEventNameAndParametar(_ address:[Byte], eventId: Byte) -> [Byte] {
        var messageInfo:[Byte] = [eventId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x08)
        message[5] = 0x05
        message[6] = 0x08
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
}

//MARK:- SEQUENCE
extension OutgoingHandler {
    static func setSequence (_ address:[Byte], id:Int, cycle:Byte) -> [Byte] {
        let numberOne:Byte = Byte((id / 0x100) % 0x100)
        let numberTwo:Byte = Byte(id % 0x100)
        var messageInfo:[Byte] = [0xFF, 0xFF, 0xFF, 0x05, cycle, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x07)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func getSequenceNameAndParametar(_ address:[Byte], sequenceId: Byte) -> [Byte] {
        var messageInfo:[Byte] = [sequenceId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x0A)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
}

//MARK:- SCENE
extension OutgoingHandler {
    static func setScene (_ address:[Byte], id:Int) -> [Byte] {
        let numberOne:Byte = Byte((id / 0x100) % 0x100)
        let numberTwo:Byte = Byte(id % 0x100)
        var messageInfo:[Byte] = [0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, numberOne, numberTwo]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x07)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func getSceneNameAndParametar(_ address:[Byte], sceneId: Byte) -> [Byte] {
        var messageInfo:[Byte] = [sceneId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x08)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
}

//MARK:- TIMER
extension OutgoingHandler {
    static func getTimerName(_ address:[Byte], timerId: Byte) -> [Byte] {
        var messageInfo:[Byte] = [timerId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x15)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
    
    static func getTimerParametar (_ address:[Byte], id:Byte) -> [Byte] {
        let messageInfo:[Byte] = [id]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x13)
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
    static func getCancelTimerStatus(_ address:[Byte], id:Byte, command:Byte) -> [Byte] {
        let messageInfo:[Byte] = [id, command]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x17)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func refreshTimerStatus(_ address:[Byte]) -> [Byte] {
        let messageInfo:[Byte] = [0xFF, 0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x17)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func refreshTimerStatusCountApp(_ address:[Byte]) -> [Byte] {
        let messageInfo:[Byte] = [0xFF, 0x01]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x19)
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

//MARK:- CARD
extension OutgoingHandler {
    static func getCardName(_ address:[Byte], cardId: Byte) -> [Byte] {
        var messageInfo:[Byte] = [0x00, cardId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x57)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
    
    static func getCardParametar(_ address:[Byte], cardId: Byte) -> [Byte] {
        var messageInfo:[Byte] = [0x00, cardId]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x56)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        
        return message
    }
}

//MARK:- ANALOG/ DIGITAL INPUT
extension OutgoingHandler {
    static func getInterfaceParametar (_ address:[Byte], channel:Byte) -> [Byte] {
        let messageInfo:[Byte] = [channel]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x02)
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
    static func setInterfaceParametar (_ address:[Byte], channel:Byte, isEnabled:Byte) -> [Byte] {
        let messageInfo:[Byte] = [channel, isEnabled]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x03)
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
    static func getInterfaceStatus (_ address:[Byte], channel:Byte, isEnabled:Byte) -> [Byte] {
        let messageInfo:[Byte] = [channel, isEnabled]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x03)
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
    static func setSensorState (_ address:[Byte], channel:Byte, status:Byte) -> [Byte] {
        var s:Byte = 0x00
        if status == 0xFF { s = 0x80 }
        if status == 0x00 { s = 0x7F }
        
        var messageInfo = [channel, s]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x03)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    // Get interface status
    static func getSensorState (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0xFF]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x01)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    // Get interface parametar
    static func getSensorEna (_ address:[Byte], channel:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x02)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    // Set interface parametar
    static func sensorEnabled (_ address:[Byte], channel:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel, 0x80]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x03)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func sensorDisabled (_ address:[Byte], channel:Byte) -> [Byte] {
        var messageInfo:[Byte] = [channel, 0x7F]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x03)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
}

//MARK:- SECURITY
extension OutgoingHandler {
    // Send command (password) for disarm
    static func sendKeySecurity (_ address:[Byte], key:Byte) -> [Byte] {
        let messageInfo:[Byte] = [0x01, key]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x11)
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
    
    static func getCurrentSecurityMode (_ address:[Byte]) -> [Byte] {
        let messageInfo:[Byte] = [0x02, 0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x11)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    // Message is created as protocol specifies. Look UCM_ehomeGrreen Command List.docx file
    static func changeSecurityMode (_ address:[Byte], mode:Byte) -> [Byte] {
        let messageInfo:[Byte] = [0x02, mode]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x11)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    // Message is created as protocol specifies. Look UCM_ehomeGrreen Command List.docx file
    static func getCurrentAlarmState (_ address:[Byte]) -> [Byte] {
        let messageInfo:[Byte] = [0x03, 0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x11)
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
    
    static func setPanic (_ address:[Byte], panic:Byte) -> [Byte] {
        let messageInfo:[Byte] = [0x04, panic]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x11)
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
extension OutgoingHandler {
    static func getInterfaceEnabled (_ address:[Byte], panic:Byte) -> [Byte] {
        let messageInfo:[Byte] = [0x04, panic]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x11)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func setInterfaceParametar (_ address:[Byte], panic:Byte) -> [Byte] {
        let messageInfo:[Byte] = [0x04, panic]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x11)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func setInterfaceEnabled (_ address:[Byte], panic:Byte) -> [Byte] {
        let messageInfo:[Byte] = [0x04, panic]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x05, CID2: 0x11)
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

//MARK:- PC Control
extension OutgoingHandler {
    
    static func getPCState(_ address: [Byte]) -> [Byte] {
        
        let messageInfo: [Byte] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var message: [Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x0A, CID2: 0x08)
        
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray: message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func setPCVolume(_ address:[Byte], volume:Byte, mute:Byte=0x00) -> [Byte] {
        let messageInfo:[Byte] = [volume, mute]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x0A, CID2: 0x03)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func playVideo(_ address:[Byte], fileName:String, fullScreen:Byte, by:Byte) -> [Byte] {
        let fileNameByteArray = [Byte](fileName.utf8)
        var messageInfo:[Byte] = [by, fullScreen, 0xFF]
        messageInfo = messageInfo + fileNameByteArray
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x0A, CID2: 0x04)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func runApp (_ address:[Byte], cmdLine:String) -> [Byte] {
        let cmdLineByteArray = [Byte](cmdLine.utf8)
        var messageInfo:[Byte] = [0x01]
        messageInfo = messageInfo + cmdLineByteArray
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x0A, CID2: 0x05)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func sendNotificationToPC(_ address:[Byte], text:String, notificationType: NotificationType, notificationPosition: NotificationPosition, delayTime: Int, displayTime: Int) -> [Byte] {
        
        let textByteArray = [Byte](text.utf8)
        var message:[Byte] = [Byte](repeating: 0, count: textByteArray.count+15)
        
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
}

// NOT IMPLEMENTED FUNCTIONS
extension OutgoingHandler {
    static func setPCState (_ address:[Byte], command:Byte) -> [Byte] {
        let messageInfo:[Byte] = [0x02, command]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x0A, CID2: 0x02)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    //TODO:- Nije uradjeno report PC state
    static func reportPCState(_ address:[Byte], text:String) -> [Byte] {
        let textByteArray = [Byte](text.utf8)
        var messageInfo:[Byte] = [0x01, 0x00, 0x00]
        messageInfo = messageInfo + textByteArray
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x0A, CID2: 0x01)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    
    static func textToSpeech (_ address:[Byte], text:String) -> [Byte] {
        let textByteArray = [Byte](text.utf8)
        var messageInfo:[Byte] = [0x01, 0x00, 0x00]
        messageInfo = messageInfo + textByteArray
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x0A, CID2: 0x06)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    //TODO:- Nije odradjeno budjenje iz lana
    static func wakeOnLan (_ address:[Byte], mac:[Byte], password:[Byte]) -> [Byte] {
        guard mac.count == 6 || password.count == 6 || address.count == 3 else { return [0x00] }
        
        var messageInfo:[Byte] = [0x01, 0x00, 0x00]
        messageInfo += mac
        messageInfo += password
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x0A, CID2: 0x07)
        var i = 0
        for byte in messageInfo {
            message[7+i] = byte
            i = i + 1
        }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    // Not used
    static func zoneControl (_ zone:Byte, value:Byte) -> [Byte] {
            var messageInfo:[Byte] = [0x01, 0x00, 0x00, 0x02, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, zone]
            var message:[Byte] = [Byte](repeating: 0, count: messageInfo.count+9)
            message[0] = 0xAA
            message[1] = Byte(messageInfo.count % 256)
            message[2] = 0xFF
            message[3] = 0xFF
            message[4] = 0xFF
            message[5] = 0x03
            message[6] = 0x07
            for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
            message[message.count-2] = self.getChkByte(byteArray:message)
            message[message.count-1] = 0x10
            return message
        }
    
    static func getWarnings (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x10)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func sendIRLibrary (_ address:[Byte], channel:Byte, ir_id:Byte, times:Byte, interval:Byte) -> [Byte] {
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        //messageInfo = [channel * 64 + times, interval, Byte(ir_id / 0x100), Byte((ir_id / 0x100) % 0x100)]
        messageInfo = [0x00] //  resi ovo
        message = [Byte](repeating: 0, count: messageInfo.count+9)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x09
        message[6] = 0x05
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func sendSerialLibrary (_ address:[Byte], channel:Byte, serialId:Byte) -> [Byte] {
        var messageInfo:[Byte] = []
        var message:[Byte] = []
        //messageInfo = [Byte((serialId / 0x100) % 0x100), Byte(serialId % 0x100), channel]
        messageInfo = [0x00] //  resi ovo
        message = [Byte](repeating: 0, count: messageInfo.count+9)
        message[0] = 0xAA
        message[1] = Byte(messageInfo.count % 256)
        message[2] = address[0]
        message[3] = address[1]
        message[4] = address[2]
        message[5] = 0x09
        message[6] = 0x0E
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }
    static func getRunningTime (_ address:[Byte]) -> [Byte] {
        var messageInfo:[Byte] = [0x00]
        var message:[Byte] = setupMessage(messageInfo: messageInfo, address: address, CID1: 0x03, CID2: 0x10)
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = 0x10
        return message
    }

}

// MESSAGE EXAMPLE
//
//static func sendNotificationToPC(_ address:[Byte], text:String, notificationType: NotificationType, notificationPosition: NotificationPosition, delayTime: Int, displayTime: Int) -> [Byte] {
//
//    let textByteArray = [Byte](text.utf8)
//    var message:[Byte] = [Byte](repeating: 0, count: textByteArray.count+15)
//
//    //Control bytes:
//    message[0] = 0xAA
//    message[1] = Byte((textByteArray.count+6) % 256)
//
//    //Address:
//    message[2] = address[0]
//    message[3] = address[1]
//    message[4] = address[2]
//
//    //Command:
//    message[5] = 0x0A
//    message[6] = 0x07
//
//    //Type & Position:
//    message[7] = Byte(notificationType.rawValue)
//    message[8] = Byte(notificationPosition.rawValue)
//
//    //Delay time:
//    if delayTime > 255 {
//        let firstByte = UInt8(UInt16(delayTime) >> 8)
//        let secondByte = UInt8(UInt16(delayTime) & 0x00ff)
//
//        message[9] = firstByte
//        message[10] = secondByte
//    }else{
//        message[9] = 0x00
//        message[10] = Byte(delayTime)
//    }
//
//    //Display time:
//    if displayTime > 255 {
//        let firstByte = UInt8(UInt16(displayTime) >> 8)
//        let secondByte = UInt8(UInt16(displayTime) & 0x00ff)
//
//        message[11] = firstByte
//        message[12] = secondByte
//    }else{
//        message[11] = 0x00
//        message[12] = Byte(delayTime)
//    }
//
//    //Text:
//    var i = 0
//    for byte in textByteArray {
//        message[13+i] = byte
//        i = i + 1
//    }
//
//    //Control bytes:
//    message[message.count-2] = self.getChkByte(byteArray:message)
//    message[message.count-1] = 0x10
//
//    return message
//}

