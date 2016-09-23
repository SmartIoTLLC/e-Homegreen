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
    var defaultColorOne = Colors.VeryLightGrayColor
    var defaultColorTwo = Colors.LightGrayColor
    var colorOne = Colors.VeryLightGrayColor
    var colorTwo = Colors.LightGrayColor
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.allCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGray.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [colorOne , colorTwo]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
            colors: colors as CFArray,
            locations: colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
        self.setTitleColor(UIColor.black, for: UIControlState())
        self.backgroundColor = UIColor.clear
    }
    
    override var isHighlighted: Bool {
        
        willSet(newValue) {
            if newValue {
                colorOne = Colors.DarkGrayColor
                colorTwo = Colors.VeryLightGrayColor
            } else {
                colorOne = defaultColorOne
                colorTwo = defaultColorTwo
            }
        }
        
        didSet {
            print("highlighted = \(isHighlighted)")
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
    
    override var isSelected: Bool {
        willSet(newValue) {
            print("changing from \(isSelected) to \(newValue)")
            if newValue {
                colorOne = Colors.DarkGrayColor
                colorTwo = Colors.VeryLightGrayColor
            } else {
                colorOne = defaultColorOne
                colorTwo = defaultColorTwo
            }
            setNeedsDisplay()
        }
        
        didSet {
            print("selected=\(isSelected)")
            
        }
    }
    
}
