//
//  RepeatSendingHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

class RepeatSendingHandler {
    
    let byteArray: [UInt8]
    let gateway: Gateway
    var repeatCounter:Int = 1
    
    var device:Device
    let deviceOldValue:Int
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var didGetResponse:Bool = false
    var didGetResponseTimer:NSTimer!
    
    //
    // ================== Sending command for changing value of device ====================
    //
    init(byteArray:[UInt8], gateway: Gateway, notificationName:String, device:Device, oldValue:Int) {
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.byteArray = byteArray
        self.gateway = gateway
        self.device = device
        self.deviceOldValue = oldValue
        
        didGetResponseTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "sendCommand", userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetResponseNotification", name: notificationName, object: nil)
    }
    
    func didGetResponseNotification () {
        didGetResponse = true
        didGetResponseTimer!.invalidate()
    }
    
    func sendComand () {
        if !didGetResponse {
            if repeatCounter <= 4 {
                SendingHandler(byteArray: byteArray, gateway: gateway)
                repeatCounter += 1
            } else {
                device.currentValue = deviceOldValue
                saveChanges()
                NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self)
            }
        }
    }
    
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}