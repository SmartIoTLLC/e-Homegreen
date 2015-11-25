//
//  CustomGradientButtonWhite.swift
//  e-Homegreen
//
//  Created by Vladimir on 11/24/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@IBDesignable
class CustomGradientButtonWhite: UIButton {
    var defaultColorOne = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1).CGColor
    var defaultColorTwo = UIColor.lightGrayColor().CGColor
    var colorOne = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1).CGColor
    var colorTwo = UIColor.lightGrayColor().CGColor
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGrayColor().setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [colorOne , colorTwo]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
        self.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override var highlighted: Bool {
        
        willSet(newValue) {
            if newValue {
                colorOne = UIColor.darkGrayColor().CGColor
                colorTwo = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1).CGColor
            } else {
                colorOne = defaultColorOne
                colorTwo = defaultColorTwo
            }
        }
        
        didSet {
            print("highlighted = \(highlighted)")
            //            if highlighted {
            //                colorOne = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor
            //                colorTwo = UIColor.lightGrayColor().CGColor
            //            } else {
            //                colorOne = defaultColorOne
            //                colorTwo = defaultColorTwo
            //            }
            setNeedsDisplay()
        }
    }
    
    override var selected: Bool {
        willSet(newValue) {
            print("changing from \(selected) to \(newValue)")
            if newValue {
                colorOne = UIColor.darkGrayColor().CGColor
                colorTwo = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1).CGColor
            } else {
                colorOne = defaultColorOne
                colorTwo = defaultColorTwo
            }
            setNeedsDisplay()
        }
        
        didSet {
            print("selected=\(selected)")
            
        }
    }
    
}