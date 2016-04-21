//
//  AppDelegate+BroadcastTimeAndDate.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/2/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension AppDelegate {
    
    func startTimer() {
        if BroadcastPreference.getIsBroadcastOnEvery() {
            let queue = dispatch_queue_create("com.domain.app.broadcast.time.and.date.timer", nil)
            timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
            let minutes = BroadcastPreference.getBroadcastMin()
            let hourMinutes = BroadcastPreference.getBroadcastHour()*60
            let sumMinutes = minutes + hourMinutes
            let seconds:UInt64 = UInt64(((sumMinutes*60)-10))
            NSLog("\(seconds)")
            dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 60 seconds, with leeway of 1 second
            dispatch_source_set_event_handler(timer) {
                // do whatever you want here
                self.broadcastTimeAndDateEveryNowAndThen()
            }
            dispatch_resume(timer)

            return
        }

    }
    
    func refreshAllConnections() {
        let queue = dispatch_queue_create("com.domain.app.refresh.connections.timer", nil)
        var minutes = 1
        let seconds:UInt64 = UInt64(((minutes*60)-10))
        refreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(refreshTimer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 60 seconds, with leeway of 1 second
        dispatch_source_set_event_handler(refreshTimer) {
            NSLog("Upravo se sve osvezilo")
            dispatch_async(dispatch_get_main_queue(),{
                self.refreshAllConnectionsToEHomeGreenPLC()
            })
        }
        dispatch_resume(refreshTimer)
        
        return
    }
    
    func stopTimer() {
        if timer != nil {
            dispatch_source_cancel(timer)
            timer = nil
        }
    }
    func stopRefreshTimer() {
        if refreshTimer != nil {
            dispatch_source_cancel(refreshTimer)
            refreshTimer = nil
        }
    }
    
    func broadcastTimeAndDate() {
        if BroadcastPreference.getIsBroadcastOnStartUp() {
            broadcastTimeAndDateOnStartUp()
            return
        }
        startTimer()
    }
    
    func broadcastTimeAndDateOnStartUp() {
        sendDataToBroadcastTimeAndDate()
    }
    
    func broadcastTimeAndDateEveryNowAndThen() {
        if let date = BroadcastPreference.getBroadcastUpdateDate() as NSDate! {
            let minutes = BroadcastPreference.getBroadcastMin()
            let hourMinutes = BroadcastPreference.getBroadcastHour()*60
            let sumMinutes = minutes + hourMinutes
            if NSDate().timeIntervalSinceDate(date.dateByAddingTimeInterval(NSTimeInterval(NSNumber(integer: sumMinutes)))) >= Double(sumMinutes)  {
                sendDataToBroadcastTimeAndDate()
            }
        }
    }
    
    func sendDataToBroadcastTimeAndDate() {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year , .Month , .Day, .Hour, .Minute, .Second, .Weekday] , fromDate: date)
        
        let year =  components.year-2000
        let month = components.month
        let day = components.day
        let hour =  components.hour
        let minute = components.minute
        let second = components.second
        let weekday = components.weekday-1
        
        SendingHandler.sendCommand(byteArray: Function.setInternalClockRTC([0xFF,0xFF,0xFF], year: Byte(year), month: Byte(month), day: Byte(day), hour: Byte(hour), minute: Byte(minute), second: Byte(second), dayOfWeak: Byte(weekday)), ip: BroadcastPreference.getBroadcastIp(), port: UInt16 (BroadcastPreference.getBroadcastPort()))
        BroadcastPreference.setBroadcastUpdateDate()
        
    }
}

class BroadcastPreference {
    class func getBroadcastIp() -> String {
        if let ip = NSUserDefaults.standardUserDefaults().stringForKey("kBroadcastIp") {
            return ip
        } else {
            return ""
        }
    }
    class func setBroadcastIp(ip:String) {
        NSUserDefaults.standardUserDefaults().setValue(ip, forKey: "kBroadcastIp")
    }
    
    class func getBroadcastPort() -> Int {
        let port = NSUserDefaults.standardUserDefaults().integerForKey("kBroadcastPort")
        return port
    }
    class func setBroadcastPort(port:Int) {
        NSUserDefaults.standardUserDefaults().setValue(port, forKey: "kBroadcastPort")
    }
    
    class func getIsBroadcastOnStartUp() -> Bool {
        let port = NSUserDefaults.standardUserDefaults().boolForKey("kIsBroadcastOnStartUp")
        return port
    }
    class func setIsBroadcastOnStartUp(port:Bool) {
        NSUserDefaults.standardUserDefaults().setBool(port, forKey: "kIsBroadcastOnStartUp")
    }
    
    class func getIsBroadcastOnEvery() -> Bool {
        let port = NSUserDefaults.standardUserDefaults().boolForKey("kIsBroadcastOnEvery")
        return port
    }
    class func setIsBroadcastOnEvery(isUpdateRequired:Bool) {
        if isUpdateRequired {
            (UIApplication.sharedApplication().delegate as! AppDelegate).startTimer()
        } else {
            (UIApplication.sharedApplication().delegate as! AppDelegate).stopTimer()
        }
        NSUserDefaults.standardUserDefaults().setBool(isUpdateRequired, forKey: "kIsBroadcastOnEvery")
    }
    
    class func getBroadcastHour() -> Int {
        let port = NSUserDefaults.standardUserDefaults().integerForKey("kBroadcastHour")
        return port
    }
    class func setBroadcastHour(port:Int) {
        NSUserDefaults.standardUserDefaults().setValue(port, forKey: "kBroadcastHour")
    }
    
    class func getBroadcastMin() -> Int {
        let port = NSUserDefaults.standardUserDefaults().integerForKey("kBroadcastMin")
        return port
    }
    class func setBroadcastMin(port:Int) {
        NSUserDefaults.standardUserDefaults().setValue(port, forKey: "kBroadcastMin")
    }
    
    class func getBroadcastUpdateDate() -> NSDate? {
        if let date = NSUserDefaults.standardUserDefaults().objectForKey("kBroadcastUpdateDate") as? NSDate {
            return date
        }
        return nil
    }
    class func setBroadcastUpdateDate() {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "kBroadcastUpdateDate")
    }
}
// Ovo se vise ne koristi, ali svakako proveri
//class RefreshConnectionsPreference {
//    class func getMinutes() -> Int {
//        let number = NSUserDefaults.standardUserDefaults().integerForKey("kRefreshConnections")
//        return number
//    }
//    class func setMinutes(number:Int) {
//        NSUserDefaults.standardUserDefaults().setInteger(number, forKey: "kRefreshConnections")
//    }
//}