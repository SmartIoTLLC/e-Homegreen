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
    
    @IBInspectable var isHeader: Bool = true
    var colorOne = Colors.DarkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    var colorTwo = Colors.MediumGray {
        didSet {
            setNeedsDisplay()
        }
    }
    var vRect = CGRect()
     var gl: CAGradientLayer = CAGradientLayer()
    override func drawRect(rect: CGRect) {
        vRect = rect
        var path = UIBezierPath()
        if isHeader == false{
            path = UIBezierPath(roundedRect: rect,
                byRoundingCorners: UIRectCorner.AllCorners,
                cornerRadii: CGSize(width: 5.0, height: 5.0))
            path.addClip()
            path.lineWidth = 2
            
            UIColor.darkGrayColor().setStroke()
        }
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
        if isHeader == false{
            path.stroke()
        }
//        gl = CAGradientLayer()
//        gl.colors = [ colorOne, colorTwo]
//        gl.locations = [ 0.0, 1.0]
//        gl.frame = frame
//        self.layer.insertSublayer(gl, atIndex: 0)
    }
    func updateBackgroundColor(){
        gl.colors = [ colorOne, colorTwo]
    }
    func changeGradientColors(rect: CGRect){
        vRect = rect
        var path = UIBezierPath()
        if isHeader == false{
            path = UIBezierPath(roundedRect: rect,
                byRoundingCorners: UIRectCorner.AllCorners,
                cornerRadii: CGSize(width: 5.0, height: 5.0))
            path.addClip()
            path.lineWidth = 2
            
            UIColor.lightGrayColor().setStroke()
        }
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
        if isHeader == false{
            path.stroke()
        }
    }

    

}
