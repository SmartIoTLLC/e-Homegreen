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
            let queue = DispatchQueue(label: "com.domain.app.broadcast.time.and.date.timer", attributes: [])
            timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource
            let minutes = BroadcastPreference.getBroadcastMin()
            let hourMinutes = BroadcastPreference.getBroadcastHour()*60
            let sumMinutes = minutes + hourMinutes
            let seconds:UInt64 = UInt64(((sumMinutes*60)-10))
            NSLog("\(seconds)")
//            timer.setTimer(start: DispatchTime.now(), interval: seconds * NSEC_PER_SEC, leeway: 1 * NSEC_PER_SEC) // every 60 seconds, with leeway of 1 second
            timer.setEventHandler {
                // do whatever you want here
                self.broadcastTimeAndDateEveryNowAndThen()
            }
            timer.resume()

            return
        }

    }
    
    func refreshAllConnections() {
        let queue = DispatchQueue(label: "com.domain.app.refresh.connections.timer", attributes: [])
        let minutes = 1
        let seconds:UInt64 = UInt64(((minutes*60)-10))
        refreshTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource
//        refreshTimer.setTimer(start: DispatchTime.now(), interval: seconds * NSEC_PER_SEC, leeway: 1 * NSEC_PER_SEC) // every 60 seconds, with leeway of 1 second
        refreshTimer.setEventHandler {
            NSLog("Upravo se sve osvezilo")
            DispatchQueue.main.async(execute: {
                self.refreshAllConnectionsToEHomeGreenPLC()
            })
        }
        refreshTimer.resume()
        
        return
    }
    
    func stopTimer() {
        if timer != nil {
            timer.cancel()
            timer = nil
        }
    }
    func stopRefreshTimer() {
        if refreshTimer != nil {
            refreshTimer.cancel()
            refreshTimer = nil
        }
    }
    
    func broadcastTimeAndDate() {
        if BroadcastPreference.getIsBroadcastOnStartUp() {
            broadcastTimeAndDateOnStartUp()
            return
        }
//        startTimer()
    }
    
    func broadcastTimeAndDateOnStartUp() {
        sendDataToBroadcastTimeAndDate()
    }
    
    func broadcastTimeAndDateEveryNowAndThen() {
        if let date = BroadcastPreference.getBroadcastUpdateDate() as Date! {
            let minutes = BroadcastPreference.getBroadcastMin()
            let hourMinutes = BroadcastPreference.getBroadcastHour()*60
            let sumMinutes = minutes + hourMinutes
            if Date().timeIntervalSince(date.addingTimeInterval(TimeInterval(NSNumber(value: sumMinutes as Int)))) >= Double(sumMinutes)  {
                sendDataToBroadcastTimeAndDate()
            }
        }
    }
    
    func sendDataToBroadcastTimeAndDate() {
        
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year , .month , .day, .hour, .minute, .second, .weekday] , from: date)
        
        let year =  components.year!-2000
        let month = components.month
        let day = components.day
        let hour =  components.hour
        let minute = components.minute
        let second = components.second
        let weekday = components.weekday!-1
        
        SendingHandler.sendCommand(byteArray: OutgoingHandler.setInternalClockRTC([0xFF,0xFF,0xFF], year: Byte(year), month: Byte(month!), day: Byte(day!), hour: Byte(hour!), minute: Byte(minute!), second: Byte(second!), dayOfWeak: Byte(weekday)), ip: BroadcastPreference.getBroadcastIp(), port: UInt16 (BroadcastPreference.getBroadcastPort()))
        BroadcastPreference.setBroadcastUpdateDate()
        
    }
}

class BroadcastPreference {
    class func getBroadcastIp() -> String {
        if let ip = Foundation.UserDefaults.standard.string(forKey: "kBroadcastIp") {
            return ip
        } else {
            return ""
        }
    }
    class func setBroadcastIp(_ ip:String) {
        Foundation.UserDefaults.standard.setValue(ip, forKey: "kBroadcastIp")
    }
    
    class func getBroadcastPort() -> Int {
        let port = Foundation.UserDefaults.standard.integer(forKey: "kBroadcastPort")
        return port
    }
    class func setBroadcastPort(_ port:Int) {
        Foundation.UserDefaults.standard.setValue(port, forKey: "kBroadcastPort")
    }
    
    class func getIsBroadcastOnStartUp() -> Bool {
        let port = Foundation.UserDefaults.standard.bool(forKey: "kIsBroadcastOnStartUp")
        return port
    }
    class func setIsBroadcastOnStartUp(_ port:Bool) {
        Foundation.UserDefaults.standard.set(port, forKey: "kIsBroadcastOnStartUp")
    }
    
    class func getIsBroadcastOnEvery() -> Bool {
        let port = Foundation.UserDefaults.standard.bool(forKey: "kIsBroadcastOnEvery")
        return port
    }
    class func setIsBroadcastOnEvery(_ isUpdateRequired:Bool) {
        if isUpdateRequired {
//            (UIApplication.shared.delegate as! AppDelegate).startTimer()
        } else {
//            (UIApplication.shared.delegate as! AppDelegate).stopTimer()
        }
        Foundation.UserDefaults.standard.set(isUpdateRequired, forKey: "kIsBroadcastOnEvery")
    }
    
    class func getBroadcastHour() -> Int {
        let port = Foundation.UserDefaults.standard.integer(forKey: "kBroadcastHour")
        return port
    }
    class func setBroadcastHour(_ port:Int) {
        Foundation.UserDefaults.standard.setValue(port, forKey: "kBroadcastHour")
    }
    
    class func getBroadcastMin() -> Int {
        let port = Foundation.UserDefaults.standard.integer(forKey: "kBroadcastMin")
        return port
    }
    class func setBroadcastMin(_ port:Int) {
        Foundation.UserDefaults.standard.setValue(port, forKey: "kBroadcastMin")
    }
    
    class func getBroadcastUpdateDate() -> Date? {
        if let date = Foundation.UserDefaults.standard.object(forKey: "kBroadcastUpdateDate") as? Date {
            return date
        }
        return nil
    }
    class func setBroadcastUpdateDate() {
        Foundation.UserDefaults.standard.set(Date(), forKey: "kBroadcastUpdateDate")
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
