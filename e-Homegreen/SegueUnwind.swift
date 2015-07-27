//
//  SegueUnwind.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SegueUnwind: UIStoryboardSegue {
    
    override func perform() {
        
        var secondVCView = self.sourceViewController.view as UIView!
        var firstVCView = self.destinationViewController.view as UIView!
        
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(firstVCView, aboveSubview: secondVCView)
        
        // Animate the transition.
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            firstVCView.frame = CGRectOffset(firstVCView.frame, screenWidth, 0)
            secondVCView.frame = CGRectOffset(secondVCView.frame, screenWidth, 0)
            
            }) { (Finished) -> Void in
                
                self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
   
}
