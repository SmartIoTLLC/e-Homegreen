//
//  CustomGradientButton.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@IBDesignable
class CustomGradientButton: UIButton {
    var defaultColorOne = Colors.MediumGray
    var defaultColorTwo = Colors.DarkGray
    var colorOne = Colors.MediumGray
    var colorTwo = Colors.DarkGray
    
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.darkGrayColor().setStroke()
    
        let context = UIGraphicsGetCurrentContext()
        let colors = [colorTwo, colorOne]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override var highlighted: Bool {
        
        willSet(newValue) {
//            print("changing from \(selected) to \(newValue)")
//            print("highlighted = \(highlighted)")
            if newValue {
                colorOne = Colors.DarkGray
                colorTwo = Colors.LightGrayColor
            } else {
                colorOne = defaultColorOne
                colorTwo = defaultColorTwo
            }
        }
        
        didSet {
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
                colorOne = Colors.DarkGray
                colorTwo = Colors.DarkGray
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
