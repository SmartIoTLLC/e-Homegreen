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
    override func draw(_ rect: CGRect) {
        vRect = rect
        var path = UIBezierPath()
        if isHeader == false{
            path = UIBezierPath(roundedRect: rect,
                byRoundingCorners: UIRectCorner.allCorners,
                cornerRadii: CGSize(width: 5.0, height: 5.0))
            path.addClip()
            path.lineWidth = 2
            
            UIColor.darkGray.setStroke()
        }
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
        if isHeader == false{
            path.stroke()
        }
    }
    func updateBackgroundColor(){
        gl.colors = [ colorOne, colorTwo]
    }
    func changeGradientColors(_ rect: CGRect){
        vRect = rect
        var path = UIBezierPath()
        if isHeader == false{
            path = UIBezierPath(roundedRect: rect,
                byRoundingCorners: UIRectCorner.allCorners,
                cornerRadii: CGSize(width: 5.0, height: 5.0))
            path.addClip()
            path.lineWidth = 2
            
            UIColor.lightGray.setStroke()
        }
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
        if isHeader == false{
            path.stroke()
        }
    }

    

}
