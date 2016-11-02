//
//  RepeatSendingHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

/// Class communicates with PLC, sending messages. As specified by stakeholder, every sending message should be repeated maximally three times if there is no answer. Methods in this code enable that.
class RepeatSendingHandler: NSObject {
    
    var byteArray: [UInt8]!
    var gateway: Gateway!
    var repeatCounter:Int = 1
    var delay:Double = 0
    var device:Device!
    var deviceOldValue:Int!
    var appDel:AppDelegate!
    var error:NSError? = nil
    var didGetResponse:Bool = false
    var didGetResponseTimer:Foundation.Timer!
    var timerForSaltoAccessRefresh: Foundation.Timer!
    var isFirstTime:Bool = true
    
    //
    // ================== Sending command for changing value of device ====================
    //
    init(byteArray:[UInt8], gateway: Gateway, device:Device, oldValue:Int) {
        super.init()
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.byteArray = byteArray
        self.gateway = gateway
        self.device = device
        self.deviceOldValue = oldValue
        self.delay = Double(device.delay) + 1
        
        if byteArray[5] == 5 && byteArray[6] == 80{
            sendCommandForSaltoAccess()
        }else{
            sendCommand()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(RepeatSendingHandler.didGetResponseNotification(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
    }
    init(byteArray:[UInt8], gateway: Gateway) {
        super.init()
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.byteArray = byteArray
        self.gateway = gateway
        
        sendCommandForTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RepeatSendingHandler.didGetResponseNotification(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
    }
    
    //   Did get response from gateway
    func didGetResponseNotification (_ notification:Notification) {
        if let info = (notification as NSNotification).userInfo! as? [String:Device] {
            if let deviceInfo = info["deviceDidReceiveSignalFromGateway"] {
                if device.objectID == deviceInfo.objectID {
                    didGetResponse = true
                    didGetResponseTimer!.invalidate()
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                }
            }
        }
    }
    
    func sendCommand () {
        if !didGetResponse {
            if repeatCounter <= 4 {
                if repeatCounter > 1 {
                    self.delay = 1
                }
                SendingHandler.sendCommand(byteArray: byteArray, gateway: gateway)
                if didGetResponseTimer != nil{
                    didGetResponseTimer.invalidate()
                    didGetResponseTimer = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(RepeatSendingHandler.sendCommand), userInfo: nil, repeats: false)
                }else{
                    didGetResponseTimer = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(RepeatSendingHandler.sendCommand), userInfo: nil, repeats: false)
                }
                repeatCounter += 1
            } else {
                didGetResponseTimer!.invalidate()
                device.currentValue = deviceOldValue as NSNumber
                CoreDataController.shahredInstance.saveChanges()
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
            }
        }else{
            didGetResponseTimer!.invalidate()
            device.currentValue = deviceOldValue as NSNumber
            CoreDataController.shahredInstance.saveChanges()
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
        }
    }
    func sendCommandForSaltoAccess() {
        if !didGetResponse {
            if repeatCounter <= 4 {
                if repeatCounter > 1 {
                    self.delay = 1
                }
                SendingHandler.sendCommand(byteArray: byteArray, gateway: gateway)
                if didGetResponseTimer != nil{
                    didGetResponseTimer.invalidate()
                    didGetResponseTimer = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(RepeatSendingHandler.sendCommandForSaltoAccess), userInfo: nil, repeats: false)
                }else{
                    didGetResponseTimer = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(RepeatSendingHandler.sendCommandForSaltoAccess), userInfo: nil, repeats: false)
                }
                repeatCounter += 1
            } else {
                didGetResponseTimer!.invalidate()
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
                
                // at the end we must set timer for 8 sec and then 1s and then 1 sec. That is the protocol
                timerForSaltoAccessRefresh = Foundation.Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(RepeatSendingHandler.refreshSaltoAccessAfter8Sec), userInfo: nil, repeats: false)
                
            }
        }else{
            didGetResponseTimer!.invalidate()
            didGetResponseTimer = nil
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
            // at the end we must set timer for 8 sec and then 1s and then 1 sec. That is the protocol
            timerForSaltoAccessRefresh = Foundation.Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(RepeatSendingHandler.refreshSaltoAccessAfter8Sec), userInfo: nil, repeats: false)
        }
    }
    func sendCommandForTimer () {
        if !didGetResponse {
            if repeatCounter <= 4 {
                if repeatCounter > 1 {
                    self.delay = 1
                }
                SendingHandler.sendCommand(byteArray: byteArray, gateway: gateway)
                if didGetResponseTimer != nil{
                    didGetResponseTimer.invalidate()
                    didGetResponseTimer = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(RepeatSendingHandler.sendCommand), userInfo: nil, repeats: false)
                }else{
                    didGetResponseTimer = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(RepeatSendingHandler.sendCommand), userInfo: nil, repeats: false)
                }
                repeatCounter += 1
            } else {
                didGetResponseTimer!.invalidate()
                CoreDataController.shahredInstance.saveChanges()
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
            }
        }else{
            didGetResponseTimer!.invalidate()
            CoreDataController.shahredInstance.saveChanges()
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
        }
    }

    func refreshSaltoAccessAfter8Sec(){
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState([byteArray[2], byteArray[3], byteArray[4]], lockId: device.channel.intValue), gateway: device.gateway)
        timerForSaltoAccessRefresh.invalidate()
        timerForSaltoAccessRefresh = nil
        timerForSaltoAccessRefresh = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RepeatSendingHandler.refreshSaltoAccessAfter1Sec), userInfo: nil, repeats: false)
    }
    func refreshSaltoAccessAfter1Sec(){
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState([byteArray[2], byteArray[3], byteArray[4]], lockId: device.channel.intValue), gateway: device.gateway)
        timerForSaltoAccessRefresh.invalidate()
        timerForSaltoAccessRefresh = nil
        timerForSaltoAccessRefresh = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RepeatSendingHandler.refreshSaltoAccessOneMoreTimeAfter1Sec), userInfo: nil, repeats: false)
    }
    func refreshSaltoAccessOneMoreTimeAfter1Sec(){
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState([byteArray[2], byteArray[3], byteArray[4]], lockId: device.channel.intValue), gateway: device.gateway)
        timerForSaltoAccessRefresh.invalidate()
        timerForSaltoAccessRefresh = nil
    }
}
