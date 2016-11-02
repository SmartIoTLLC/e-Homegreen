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
    
    @IBInspectable var fillColor: UIColor = UIColor.orange
    
    override func draw(_ rect: CGRect) {
        
        let point1 = CGPoint(x:0, y: bounds.height/2)
        let point2 = CGPoint(x:bounds.width, y: 0)
        let point3 = CGPoint(x:bounds.width, y: bounds.height)
        
        let pathButton:UIBezierPath = UIBezierPath()
        
        pathButton.move(to: point1)
        pathButton.addLine(to: point2)
        pathButton.addLine(to: point3)
        
        pathButton.close()
        fillColor.setFill()
        pathButton.fill()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let point1 = CGPoint(x:0, y: bounds.height/2)
        let point2 = CGPoint(x:bounds.width, y: 0)
        let point3 = CGPoint(x:bounds.width, y: bounds.height)
        
        let pathButton:UIBezierPath = UIBezierPath()
        pathButton.move(to: point1)
        pathButton.addLine(to: point2)
        pathButton.addLine(to: point3)
        pathButton.close()
        
        if pathButton.contains(point){
            return self
        }else{
            return nil
        }
    }

    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                fillColor = UIColor.lightGray.withAlphaComponent(0.35)
                setNeedsDisplay()
            } else {
                fillColor = UIColor.clear
                setNeedsDisplay()
            }
        }
    }
    
    
}
