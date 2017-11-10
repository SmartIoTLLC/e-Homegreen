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
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.allCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.darkGray.setStroke()
    
        let context = UIGraphicsGetCurrentContext()
        let colors = [colorTwo, colorOne]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
            colors: colors as CFArray,
            locations: colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.backgroundColor = UIColor.clear
    }
    
    override var isHighlighted: Bool {
        
        willSet(newValue) {
            if newValue {
                colorOne = Colors.DarkGray
                colorTwo = Colors.LightGrayColor
            } else {
                colorOne = defaultColorOne
                colorTwo = defaultColorTwo
            }
        }
        
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool {
        willSet(newValue) {
            print("changing from \(isSelected) to \(newValue)")
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
            print("selected=\(isSelected)")
        }
    }
    
}
