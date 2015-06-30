//
//  DashboardViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class DashboardViewController: CommonViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonConstruct()
        

        
        var clock:SPClockView = SPClockView(frame: CGRectMake(20, 20, 140, 140))
        clock.timeZone = NSTimeZone.localTimeZone()
        self.view.addSubview(clock)
        
        var panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
        clock.addGestureRecognizer(panRecognizer)
        
        var panRecognizer1 = UIPanGestureRecognizer(target:self, action:"detectPan1:")
        calendar.addGestureRecognizer(panRecognizer1)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func detectPan(recognizer:UIPanGestureRecognizer) {
        var translation  = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPointMake(recognizer.view!.center.x + translation.x,
            recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointMake(0, 0), inView: self.view!)
    }
    
    func detectPan1(recognizer:UIPanGestureRecognizer) {
        var translation  = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPointMake(recognizer.view!.center.x + translation.x,
            recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointMake(0, 0), inView: self.view!)
    }
    


    
}
