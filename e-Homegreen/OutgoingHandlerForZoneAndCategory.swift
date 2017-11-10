//
//  OutgoingHandlerForZoneAndCategory.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/13/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

struct CommandParametar{
    static let SOI:Byte = 0xAA  //Start of Information
    static let EOI:Byte = 0x10  //End of Information
}

class OutgoingHandlerForZoneAndCategory: NSObject {
    static let shared =  OutgoingHandlerForZoneAndCategory()
    
    func getCommandTurnOnByZone(_ zoneId:Int) -> [Byte] {
        var messageInfo:[Byte] = [0xff, 0xff, 0xff,0x02, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, Byte(zoneId)]
        var message:[Byte] = setupMessage(messageInfo: messageInfo)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = CommandParametar.EOI
        return message
    }
    
    func getCommandTurnOffByZone(_ zoneId:Int) -> [Byte] {
        var messageInfo:[Byte] = [0xff, 0xff, 0xff,0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, Byte(zoneId)]
        var message:[Byte] = setupMessage(messageInfo: messageInfo)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = CommandParametar.EOI
        return message
    }
    
    func getCommandTurnOnByCategory(_ categoryId:Int) -> [Byte] {
        var messageInfo:[Byte] = [0xff, 0xff, 0xff, 0x03, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, Byte(categoryId)]
        var message:[Byte] = setupMessage(messageInfo: messageInfo)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = CommandParametar.EOI
        return message
    }
    
    func getCommandTurnOffByCategory(_ categoryId:Int) -> [Byte] {
        var messageInfo:[Byte] = [0xff, 0xff, 0xff, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, Byte(categoryId)]
        var message:[Byte] = setupMessage(messageInfo: messageInfo)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = CommandParametar.EOI
        return message
    }
    
    func getCommandChangeValueByZone(_ zoneId:Int, value:Int) -> [Byte] {
        var messageInfo:[Byte] = [0xff, 0xff, 0xff,0x02, Byte(value), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, Byte(zoneId)]
        var message:[Byte] = setupMessage(messageInfo: messageInfo)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = CommandParametar.EOI
        return message
    }
    
    func getCommandChangeValueByCategory(_ categoryId:Int, value:Int) -> [Byte] {
        var messageInfo:[Byte] = [0xff, 0xff, 0xff, 0x03, Byte(value), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, Byte(categoryId)]
        var message:[Byte] = setupMessage(messageInfo: messageInfo)
        
        for i in 0...messageInfo.count - 1 { message[7+i] = messageInfo[i] }
        message[message.count-2] = self.getChkByte(byteArray:message)
        message[message.count-1] = CommandParametar.EOI
        return message
    }
    
    
    // Helper methods
    func getChkByte (byteArray:[Byte]) -> Byte {
        var chk:Int = 0
        for i in 1...byteArray.count-3{
            let number = "\(byteArray[i])"
            
            chk = chk + Int(number)!
        }
        chk = chk%256
        return Byte(chk)
    }
    
    func setupMessage(messageInfo: [Byte]) -> [Byte] {
        var message: [Byte] = [Byte](repeating: 0, count: messageInfo.count+9)
        message[0] = CommandParametar.SOI
        message[1] = Byte(messageInfo.count % 256)
        message[2] = 0xff
        message[3] = 0xff
        message[4] = 0xff
        message[5] = 0x03
        message[6] = 0x07
        return message
    }
}
