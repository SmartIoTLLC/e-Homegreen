//
//  CustomGradientBackground.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/1/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@IBDesignable
class CustomGradientBackground: UIView {
    
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGrayColor().setStroke()
        
        
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor , UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
    }

    

}
