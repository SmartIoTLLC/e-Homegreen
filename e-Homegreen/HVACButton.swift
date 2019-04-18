//
//  HVACButton.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 8/30/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

@IBDesignable
class HVACButton: UIButton {
    var defaultColorOne = Colors.MediumGray
    var defaultColorTwo = Colors.DarkGray
    var colorOne = Colors.MediumGray
    var colorTwo = Colors.DarkGray
    
    var selectedButton:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setParametar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setParametar()
    }
    
    func setParametar(){
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 1)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
    }
    
    override func draw(_ rect: CGRect) {
        
        if selectedButton {
            let path = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: UIRectCorner.allCorners,
                                    cornerRadii: CGSize(width: 5.0, height: 5.0))
            path.addClip()
            
            UIColor.lightText.setFill()
            
            path.fill()
            
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.backgroundColor = UIColor.clear
        } else {
            
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
            self.setTitleColor(UIColor.white, for: UIControl.State())
            self.backgroundColor = UIColor.clear
        }
    }
    
    func setSelectedColor(){
        selectedButton = true
        setNeedsDisplay()
    }
    
    func setGradientColor(){
        selectedButton = false
        setNeedsDisplay()
    }


}
