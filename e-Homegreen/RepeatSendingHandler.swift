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
        
        sendCommand()
        
//        didGetResponseTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "sendCommand", userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetResponseNotification:", name: "repeatSendingHandlerNotification", object: nil)
    }
    
    //   Did get response from gateway
    func didGetResponseNotification (notification:NSNotification) {
        if let info = notification.userInfo! as? [String:Device] {
            if let deviceInfo = info["deviceDidReceiveSignalFromGateway"] {
                if device.objectID == deviceInfo.objectID {
                    didGetResponse = true
                    didGetResponseTimer!.invalidate()
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: "repeatSendingHandlerNotification", object: nil)
                }
            }
        }
    }
    var firstTime:Bool = false
    func sendCommand () {
        if !didGetResponse {
            if repeatCounter <= 4 {
                SendingHandler.sendCommand(byteArray: byteArray, gateway: gateway)
                repeatCounter += 1
                if !firstTime {
                    didGetResponseTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "sendCommand", userInfo: nil, repeats: true)
                    firstTime = true
                }
            } else {
                didGetResponseTimer!.invalidate()
                device.currentValue = deviceOldValue
                saveChanges()
                NSNotificationCenter.defaultCenter().removeObserver(self, name: "repeatSendingHandlerNotification", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self)
            }
        }
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}