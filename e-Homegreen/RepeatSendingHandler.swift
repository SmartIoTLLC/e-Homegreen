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
    
    var didGetResponse:Bool = false
    var didGetResponseTimer:NSTimer!
    
    //
    // ================== Sending command for changing value of device ====================
    //
    init(byteArray:[UInt8], gateway: Gateway, device:Device, oldValue:Int) {
        super.init()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.byteArray = byteArray
        self.gateway = gateway
        self.device = device
        self.deviceOldValue = oldValue
        self.delay = Double(device.delay) + 1
        
        sendCommand()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RepeatSendingHandler.didGetResponseNotification(_:)), name: NotificationKey.DidReceiveDataForRepeatSendingHandler, object: nil)
    }
    
    init(byteArray:[UInt8], gateway: Gateway) {
        super.init()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.byteArray = byteArray
        self.gateway = gateway
        
        sendCommandForTimer()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RepeatSendingHandler.didGetResponseNotification(_:)), name: NotificationKey.DidReceiveDataForRepeatSendingHandler, object: nil)
    }
    
    //   Did get response from gateway
    func didGetResponseNotification (notification:NSNotification) {
        if let info = notification.userInfo! as? [String:Device] {
            if let deviceInfo = info["deviceDidReceiveSignalFromGateway"] {
                if device.objectID == deviceInfo.objectID {
                    didGetResponse = true
                    didGetResponseTimer!.invalidate()
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveDataForRepeatSendingHandler, object: nil)
                }
            }
        }
    }
    var isFirstTime:Bool = true
    func sendCommand () {
        if !didGetResponse {
            if repeatCounter <= 4 {
                if repeatCounter > 1 {
                    self.delay = 1
                }
                SendingHandler.sendCommand(byteArray: byteArray, gateway: gateway)
                if let timer = didGetResponseTimer{
                    didGetResponseTimer.invalidate()
                    didGetResponseTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "sendCommand", userInfo: nil, repeats: false)
                }else{
                    didGetResponseTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "sendCommand", userInfo: nil, repeats: false)
                }
                repeatCounter += 1
            } else {
                didGetResponseTimer!.invalidate()
                device.currentValue = deviceOldValue
                CoreDataController.shahredInstance.saveChanges()
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveDataForRepeatSendingHandler, object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self)
            }
        }else{
            didGetResponseTimer!.invalidate()
            device.currentValue = deviceOldValue
            CoreDataController.shahredInstance.saveChanges()
            NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveDataForRepeatSendingHandler, object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self)
        }
    }
    
    func sendCommandForTimer () {
        if !didGetResponse {
            if repeatCounter <= 4 {
                if repeatCounter > 1 {
                    self.delay = 1
                }
                SendingHandler.sendCommand(byteArray: byteArray, gateway: gateway)
                if let timer = didGetResponseTimer{
                    didGetResponseTimer.invalidate()
                    didGetResponseTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "sendCommand", userInfo: nil, repeats: false)
                }else{
                    didGetResponseTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "sendCommand", userInfo: nil, repeats: false)
                }
                repeatCounter += 1
            } else {
                didGetResponseTimer!.invalidate()
                CoreDataController.shahredInstance.saveChanges()
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveDataForRepeatSendingHandler, object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self)
            }
        }else{
            didGetResponseTimer!.invalidate()
            CoreDataController.shahredInstance.saveChanges()
            NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveDataForRepeatSendingHandler, object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self)
        }
    }

}