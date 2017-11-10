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
            if self.broadcastTimeAndDateTimer == nil {
                let minutes = BroadcastPreference.getBroadcastMin()
                let hourMinutes = BroadcastPreference.getBroadcastHour() * 60
                let sumMinutes = minutes + hourMinutes
                let seconds: UInt64 = UInt64((sumMinutes*60)-10)
                
                self.broadcastTimeAndDateTimer = Foundation.Timer.scheduledTimer(timeInterval: Double(seconds), target: self, selector: #selector(self.sendDataToBroadcastTimeAndDate), userInfo: nil, repeats: true)
            }
        }
    }
    
    func refreshAllConnections() {
        let queue = DispatchQueue(label: "com.domain.app.refresh.connections.timer", attributes: [])

        refreshTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue) as! DispatchSource

        refreshTimer.setEventHandler {
            NSLog("Upravo se sve osvezilo")
            DispatchQueue.main.async(execute: { self.refreshAllConnectionsToEHomeGreenPLC() })
        }
        refreshTimer.resume()
        
        return
    }
    
    func stopTimer() {
        if broadcastTimeAndDateTimer != nil {
            broadcastTimeAndDateTimer?.invalidate()
            broadcastTimeAndDateTimer = nil
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
    
    func checkForBroadcastAndSetItUp() {
        if BroadcastPreference.getIsBroadcastOnStartUp() { sendDataToBroadcastTimeAndDate() }
        if BroadcastPreference.getIsBroadcastOnEvery() { startTimer() }
    }
    
    func setupBroadcastValues() {
        Foundation.UserDefaults.standard.register(defaults: ["kBroadcastHour":3])
        Foundation.UserDefaults.standard.register(defaults: ["kBroadcastMin":0])
        Foundation.UserDefaults.standard.register(defaults: ["kBroadcastPort":5000])
        Foundation.UserDefaults.standard.register(defaults: ["kBroadcastIp":"255.255.255.255"])
        
    }
}

class BroadcastPreference {
    class func getBroadcastIp() -> String {
        if let ip = Foundation.UserDefaults.standard.string(forKey: "kBroadcastIp") { return ip } else { return "" }
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
        if isUpdateRequired {(UIApplication.shared.delegate as! AppDelegate).startTimer()
        } else { (UIApplication.shared.delegate as! AppDelegate).stopTimer() }
        
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
        if let date = Foundation.UserDefaults.standard.object(forKey: "kBroadcastUpdateDate") as? Date { return date }
        return nil
    }
    
    class func setBroadcastUpdateDate() {
        Foundation.UserDefaults.standard.set(Date(), forKey: "kBroadcastUpdateDate")
    }
}
