//
//  RepeatSendingHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class RepeatSendingHandler: NSObject {
    
    var byteArray: [UInt8]!
    var gateway: Gateway!
    var repeatCounter:Int = 1
    var delay:Double = 0
    
    var device:Device!
    var deviceOldValue:Int!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var sameDeviceKey: [NSManagedObjectID: NSNumber] = [:]
    var currentDeviceKey: [NSManagedObjectID: NSNumber] = [:]
    
    var didGetResponse:Bool = false
    var didGetResponseTimer:Foundation.Timer!
    
    var timerForSaltoAccessRefresh: Foundation.Timer!
    
    //
    // ================== Sending command for changing value of device ====================
    //
    init(byteArray:[UInt8], gateway: Gateway, device:Device, oldValue:Int, command: NSNumber? = nil) {
        super.init()
        appDel = UIApplication.shared.delegate as! AppDelegate
        currentDeviceKey = [device.objectID: command!]
        
        self.byteArray = byteArray
        self.gateway = gateway
        self.device = device
        self.deviceOldValue = oldValue
        self.delay = Double(device.delay) + 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(RepeatSendingHandler.didGetResponseNotification(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sameDevice(_:)), name: Notification.Name(rawValue: NotificationKey.SameDeviceDifferentCommand), object: nil)
        
        if byteArray[5] == 5 && byteArray[6] == 80{
            sendCommandForSaltoAccess()
            getDeviceStatus(controlType: device.controlType, gateway: gateway)
        }else{
            sendCommand()
            getDeviceStatus(controlType: device.controlType, gateway: gateway)
        }
        
        
    }
    
    fileprivate func getDeviceStatus(controlType: String, gateway: Gateway) {
        let address = [UInt8(Int(gateway.addressOne)), UInt8(Int(gateway.addressTwo)), UInt8(Int(device.address))]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            if controlType == ControlType.Dimmer ||
                controlType == ControlType.Relay ||
                controlType == ControlType.Curtain {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            }            
            
        }

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
        if let info = notification.userInfo! as? [String:Device] {
            if let deviceInfo = info["deviceDidReceiveSignalFromGateway"] {
                if device.objectID == deviceInfo.objectID {
                    didGetResponse = true
                    if didGetResponseTimer != nil { didGetResponseTimer.invalidate() }
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                }
            }
        }
    }
    
    func sameDevice(_ notification: Notification) {
        if let info = notification.userInfo as? [NSManagedObjectID: NSNumber] {
            sameDeviceKey = info
        }
    }
    
    func updateRunnableList(deviceID: NSManagedObjectID) {
        RunnableList.sharedInstance.removeDeviceFromRunnableList(device: deviceID)
    }
    
    func sendCommand () {
        if sameDeviceKey != currentDeviceKey {
            if !didGetResponse {
                if repeatCounter < 4 {
                    if repeatCounter > 1 { self.delay = 1 }
                    
                    SendingHandler.sendCommand(byteArray: byteArray, gateway: gateway)
                    
                    repeatCounter += 1
                    if didGetResponseTimer != nil { didGetResponseTimer.invalidate() }                    
                    didGetResponseTimer = nil
                    didGetResponseTimer = Foundation.Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(sendCommand), userInfo: nil, repeats: false)
                } else {
                    didGetResponseTimer.invalidate()
                    didGetResponseTimer = nil
                    device.currentValue = RunnableList.sharedInstance.deviceOldValue[device.objectID] ?? (deviceOldValue as NSNumber)
                    updateRunnableList(deviceID: device.objectID)
                    CoreDataController.sharedInstance.saveChanges()
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
                }
            }else{
                if didGetResponseTimer != nil { didGetResponseTimer.invalidate() }
                didGetResponseTimer = nil
                updateRunnableList(deviceID: device.objectID)
                CoreDataController.sharedInstance.saveChanges()
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
            }
        } else {
            if didGetResponseTimer != nil { didGetResponseTimer.invalidate() }
            didGetResponseTimer = nil
            return
        }
        

    }
    func sendCommandForSaltoAccess() {
        
        if sameDeviceKey != currentDeviceKey {
            if !didGetResponse {
                if repeatCounter < 4 {
                    if repeatCounter > 1 { self.delay = 1 }
                    
                    SendingHandler.sendCommand(byteArray: byteArray, gateway: gateway)
                    repeatCounter += 1
                    if didGetResponseTimer != nil { didGetResponseTimer.invalidate() }
                    didGetResponseTimer = nil
                    didGetResponseTimer = Foundation.Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(sendCommandForSaltoAccess), userInfo: nil, repeats: false)
                    
                } else {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
                    
                    // at the end we must set timer for 8 sec and then 1s and then 1 sec. That is the protocol
                    timerForSaltoAccessRefresh = Foundation.Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(RepeatSendingHandler.refreshSaltoAccessAfter8Sec), userInfo: nil, repeats: false)
                    
                }
            }else{
                if didGetResponseTimer != nil { didGetResponseTimer.invalidate() }
                didGetResponseTimer = nil
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
                // at the end we must set timer for 8 sec and then 1s and then 1 sec. That is the protocol
                timerForSaltoAccessRefresh = Foundation.Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(RepeatSendingHandler.refreshSaltoAccessAfter8Sec), userInfo: nil, repeats: false)
            }
        } else {
            return
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
                CoreDataController.sharedInstance.saveChanges()
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self)
            }
        }else{
            if didGetResponseTimer != nil { didGetResponseTimer.invalidate() }
            CoreDataController.sharedInstance.saveChanges()
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
