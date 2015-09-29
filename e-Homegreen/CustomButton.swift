//
//  CustomButton.swift
//  ButtonCustom
//
//  Created by Vladimir on 9/28/15.
//  Copyright © 2015 nswebdevolopment. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    
    
    @IBInspectable var fillColor: UIColor = UIColor.orangeColor()
    
    override func drawRect(rect: CGRect) {
        
        let point1 = CGPoint(x:0, y: bounds.height/2)
        let point2 = CGPoint(x:bounds.width, y: 0)
        let point3 = CGPoint(x:bounds.width, y: bounds.height)
        
        let pathButton:UIBezierPath = UIBezierPath()
        
        pathButton.moveToPoint(point1)
        pathButton.addLineToPoint(point2)
        pathButton.addLineToPoint(point3)
        
        pathButton.closePath()
        fillColor.setFill()
        pathButton.fill()
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let point1 = CGPoint(x:0, y: bounds.height/2)
        let point2 = CGPoint(x:bounds.width, y: 0)
        let point3 = CGPoint(x:bounds.width, y: bounds.height)
        
        let pathButton:UIBezierPath = UIBezierPath()
        pathButton.moveToPoint(point1)
        pathButton.addLineToPoint(point2)
        pathButton.addLineToPoint(point3)
        pathButton.closePath()
        
        if pathButton.containsPoint(point){
            return self
        }else{
            return nil
        }
    }

    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                fillColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.35)
                setNeedsDisplay()
            } else {
                fillColor = UIColor.clearColor()
                setNeedsDisplay()
            }
        }
    }
    
    
}
