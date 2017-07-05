//
//  TimerForFilter.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/28/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

/// Timer can be started, restarted and stopped
/// When app closes, timer continues to run
/// This is done in such way:
/// When closing app (AppDelegate -> applicationWillResignActive), few parameters are saved to UserDefaults: counter value, timerIsActive, current time
/// When app starts again (AppDelegate -> applicationWillEnterForeground), parameters are loaded and timer value from which counter should continue is calculated
class TimerForFilter {
    var defaultTimerDevices: Foundation.Timer?
    var counterDevices: Int = 0                // Starting value of timer
    var defaultTimerEvents: Foundation.Timer?
    var counterEvents: Int = 0
    var defaultTimerScenes: Foundation.Timer?
    var counterScenes: Int = 0
    var defaultTimerSequences: Foundation.Timer?
    var counterSequences: Int = 0
    var defaultTimerTimers: Foundation.Timer?
    var counterTimers: Int = 0
    var defaultTimerSecurity: Foundation.Timer?
    var counterSecurity: Int = 0
    var defaultTimerSurvailance: Foundation.Timer?
    var counterSurvailance: Int = 0
    var defaultTimerFlags: Foundation.Timer?
    var counterFlags: Int = 0
    var defaultTimerUsers: Foundation.Timer?
    var counterUsers: Int = 0
    var defaultTimerPCControl: Foundation.Timer?
    var counterPCControl: Int = 0
    var defaultTimerChat: Foundation.Timer?
    var counterChat: Int = 0
    var defaultTimerEnergy: Foundation.Timer?
    var counterEnergy: Int = 0
    
    static var shared = TimerForFilter()

    func resetTimer(timerValue: Int, type: Menu){
        switch type {
        case Menu.devices:
            defaultTimerDevices?.invalidate()
            defaultTimerDevices = nil
            counterDevices = timerValue
//        case Menu.events:
//            defaultTimerEvents?.invalidate()
//            defaultTimerEvents = nil
//            counterEvents = timerValue
//        case Menu.scenes:
//            defaultTimerScenes?.invalidate()
//            defaultTimerScenes = nil
//            counterScenes = timerValue
//        case Menu.sequences:
//            defaultTimerSequences?.invalidate()
//            defaultTimerSequences = nil
//            counterSequences = timerValue
//        case Menu.timers:
//            defaultTimerTimers?.invalidate()
//            defaultTimerTimers = nil
//            counterTimers = timerValue
        case Menu.security:
            defaultTimerSecurity?.invalidate()
            defaultTimerSecurity = nil
            counterSecurity = timerValue
//        case Menu.surveillance:
//            defaultTimerSurvailance?.invalidate()
//            defaultTimerSurvailance = nil
//            counterSurvailance = timerValue
//        case Menu.flags:
//            defaultTimerFlags?.invalidate()
//            defaultTimerFlags = nil
//            counterFlags = timerValue
//        case Menu.users:
//            defaultTimerUsers?.invalidate()
//            defaultTimerUsers = nil
//            counterUsers = timerValue
//        case Menu.chat:
//            defaultTimerChat?.invalidate()
//            defaultTimerChat = nil
//            counterChat = timerValue
//        case Menu.energy:
//            defaultTimerEnergy?.invalidate()
//            defaultTimerEnergy = nil
//            counterEnergy = timerValue
//        case Menu.pcControl:
//            defaultTimerPCControl?.invalidate()
//            defaultTimerPCControl = nil
//            counterPCControl = timerValue
        default:
            defaultTimerDevices?.invalidate()
            defaultTimerDevices = nil
            counterDevices = timerValue
        }
    }
    
    func stopTimer(type: Menu){
        switch type {
        case Menu.devices:
            defaultTimerDevices?.invalidate()
            defaultTimerDevices = nil
//        case Menu.events:
//            defaultTimerEvents?.invalidate()
//            defaultTimerEvents = nil
//        case Menu.scenes:
//            defaultTimerScenes?.invalidate()
//            defaultTimerScenes = nil
//        case Menu.sequences:
//            defaultTimerSequences?.invalidate()
//            defaultTimerSequences = nil
//        case Menu.timers:
//            defaultTimerTimers?.invalidate()
//            defaultTimerTimers = nil
        case Menu.security:
            defaultTimerSecurity?.invalidate()
            defaultTimerSecurity = nil
//        case Menu.surveillance:
//            defaultTimerSurvailance?.invalidate()
//            defaultTimerSurvailance = nil
//        case Menu.flags:
//            defaultTimerFlags?.invalidate()
//            defaultTimerFlags = nil
//        case Menu.users:
//            defaultTimerUsers?.invalidate()
//            defaultTimerUsers = nil
//        case Menu.chat:
//            defaultTimerChat?.invalidate()
//            defaultTimerChat = nil
//        case Menu.energy:
//            defaultTimerEnergy?.invalidate()
//            defaultTimerEnergy = nil
//        case Menu.pcControl:
//            defaultTimerPCControl?.invalidate()
//            defaultTimerPCControl = nil
        default:
            defaultTimerDevices?.invalidate()
            defaultTimerDevices = nil
        }
    }
    
    func startTimer(type: Menu){
        switch type {
        case Menu.devices:
            defaultTimerDevices?.invalidate()
            defaultTimerDevices = nil
            if counterDevices > 0 {
                defaultTimerDevices = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerDevices), userInfo: nil, repeats: true)
            }
//        case Menu.events:
//            defaultTimerEvents?.invalidate()
//            defaultTimerEvents = nil
//            if counterEvents > 0 {
//                defaultTimerEvents = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerEvents), userInfo: nil, repeats: true)
//            }
//        case Menu.scenes:
//            defaultTimerScenes?.invalidate()
//            defaultTimerScenes = nil
//            if counterScenes > 0 {
//                defaultTimerScenes = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerScenes), userInfo: nil, repeats: true)
//            }
////        case Menu.sequences:
//            defaultTimerSequences?.invalidate()
//            defaultTimerSequences = nil
//            if counterSequences > 0 {
//                defaultTimerSequences = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerSequences), userInfo: nil, repeats: true)
//            }
//        case Menu.timers:
//            defaultTimerTimers?.invalidate()
//            defaultTimerTimers = nil
//            if counterTimers > 0 {
//                defaultTimerTimers = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerTimers), userInfo: nil, repeats: true)
//            }
        case Menu.security:
            defaultTimerSecurity?.invalidate()
            defaultTimerSecurity = nil
            if counterSecurity > 0 {
                defaultTimerSecurity = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerSecurity), userInfo: nil, repeats: true)
            }
//        case Menu.surveillance:
//            defaultTimerSurvailance?.invalidate()
//            defaultTimerSurvailance = nil
//            if counterSurvailance > 0 {
//                defaultTimerSurvailance = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerSurvailance), userInfo: nil, repeats: true)
//            }
//        case Menu.flags:
//            defaultTimerFlags?.invalidate()
//            defaultTimerFlags = nil
//            if counterFlags > 0 {
//                defaultTimerFlags = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerFlags), userInfo: nil, repeats: true)
//            }
//        case Menu.users:
//            defaultTimerUsers?.invalidate()
//            defaultTimerUsers = nil
//            if counterUsers > 0 {
//                defaultTimerUsers = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerUsers), userInfo: nil, repeats: true)
//            }
//        case Menu.chat:
//            defaultTimerChat?.invalidate()
//            defaultTimerChat = nil
//            if counterChat > 0 {
//                defaultTimerChat = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerChat), userInfo: nil, repeats: true)
//            }
//        case Menu.energy:
//            defaultTimerEnergy?.invalidate()
//            defaultTimerEnergy = nil
//            if counterEnergy > 0 {
//                defaultTimerEnergy = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerEnergy), userInfo: nil, repeats: true)
//            }
//        case Menu.pcControl:
//            defaultTimerPCControl?.invalidate()
//            defaultTimerPCControl = nil
//            if counterPCControl > 0 {
//                defaultTimerPCControl = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerPCControl), userInfo: nil, repeats: true)
//            }
        default:
            defaultTimerDevices?.invalidate()
            defaultTimerDevices = nil
            if counterDevices > 0 {
                defaultTimerDevices = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimerDevices), userInfo: nil, repeats: true)
            }
            
        }
        
    }
    
    @objc func updateTimerDevices(){
        if self.counterDevices > 0 {
            self.counterDevices -= 1
        }else{
            self.resetTimer(timerValue: 0, type: Menu.devices)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerDevices), object: nil)
        }
    }
    @objc func updateTimerEvents(){
        if self.counterEvents > 0 {
            self.counterEvents -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.events)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEvents), object: nil)
        }
    }
    @objc func updateTimerScenes(){
        if self.counterScenes > 0 {
            self.counterScenes -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.scenes)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerScenes), object: nil)
        }
    }
    @objc func updateTimerSequences(){
        if self.counterSequences > 0 {
            self.counterSequences -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.sequences)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSequences), object: nil)
        }
    }
    @objc func updateTimerTimers(){
        if self.counterTimers > 0 {
            self.counterTimers -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.timers)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerTimers), object: nil)
        }
    }
    @objc func updateTimerSecurity(){
        if self.counterSecurity > 0 {
            self.counterSecurity -= 1
        }else{
            self.resetTimer(timerValue: 0, type: Menu.security)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSecurity), object: nil)
        }
    }
    @objc func updateTimerSurvailance(){
        if self.counterSurvailance > 0 {
            self.counterSurvailance -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.surveillance)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSurvailance), object: nil)
        }
    }
    @objc func updateTimerFlags(){
        if self.counterFlags > 0 {
            self.counterFlags -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.flags)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerFlags), object: nil)
        }
    }
    @objc func updateTimerUsers(){
        if self.counterUsers > 0 {
            self.counterUsers -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.users)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerUsers), object: nil)
        }
    }
    @objc func updateTimerPCControl(){
        if self.counterPCControl > 0 {
            self.counterPCControl -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.pcControl)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerPCControl), object: nil)
        }
    }
    @objc func updateTimerChat(){
        if self.counterChat > 0 {
            self.counterChat -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.chat)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerChat), object: nil)
        }
    }
    @objc func updateTimerEnergy(){
        if self.counterEnergy > 0 {
            self.counterEnergy -= 1
        }else{
//            self.resetTimer(timerValue: 0, type: Menu.energy)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEnergy), object: nil)
        }
    }
}
