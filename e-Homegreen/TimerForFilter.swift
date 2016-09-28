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
    var defaultTimer1: Foundation.Timer?
    var counter1: Double = 5           // Starting value of timer
    var timerIsActive1 = false          // indicator that timer should continue runing in backgroung
    
    static var shared = TimerForFilter()
    
    @objc func updateTimer(){
        if self.counter1 > 0 {
            self.counter1 -= 1
        }else{
            self.resetTimer()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TimerEndedNotification"), object: nil)
        }
        
    }
    
    func resetTimer(){
        defaultTimer1?.invalidate()
        defaultTimer1 = nil
        counter1 = 5
        timerIsActive1 = false
    }
    
    func stopTimer(){
        defaultTimer1?.invalidate()
        defaultTimer1 = nil
        timerIsActive1 = false
    }
    
    func startTimer(){
        defaultTimer1?.invalidate()
        timerIsActive1 = true
        
        defaultTimer1 = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerForFilter.shared.updateTimer), userInfo: nil, repeats: true)
    }
}
