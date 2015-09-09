//
//  RepeatSendingHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import Foundation

class RepeatSendingHandler {
    
    let byteArray: [UInt8]
    let gateway: Gateway
    var repeatCounter:Int = 1
    
    var didGetResponse:Bool = false
    var didGetResponseTimer:NSTimer!
    
    init(byteArray:[UInt8], gateway: Gateway, notificationName:String) {
        self.byteArray = byteArray
        self.gateway = gateway
        didGetResponseTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "sendCommand", userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetResponseNotification", name: notificationName, object: nil)
    }
    func didGetResponseNotification () {
        didGetResponse = true
        didGetResponseTimer!.invalidate()
    }
    
    func sendComand () {
        if repeatCounter <= 4 {
            SendingHandler(byteArray: byteArray, gateway: gateway)
            repeatCounter += 1
        }
    }
}