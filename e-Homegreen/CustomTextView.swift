//
//  CustomTextView.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/5/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {

    override func drawRect(rect: CGRect) {
        
        let point1 = CGPoint(x:0, y: bounds.height)
        let point2 = CGPoint(x:bounds.width, y: bounds.height)
        
        let pathButton:UIBezierPath = UIBezierPath()
        
        pathButton.moveToPoint(point1)
        pathButton.addLineToPoint(point2)
        
        pathButton.lineWidth = 2
        
        
        UIColor.blueColor().setStroke()
        pathButton.stroke()
    }

}
