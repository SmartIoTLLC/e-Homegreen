//
//  SurveillanceCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/19/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class SurveillenceCell:UICollectionViewCell{
    
    @IBOutlet weak var lblName: MarqueeLabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    func setItem(surv:Surveillance, filterParametar:FilterItem){
        lblName.text = getName(surv, filterParametar: filterParametar)
    }
    
    func getName(surv:Surveillance, filterParametar:FilterItem) -> String{
        var name:String = ""
        if surv.location!.name != filterParametar.location{
            name += surv.location!.name! + " "
        }
        if surv.surveillanceLevel != filterParametar.levelName{
            name += surv.surveillanceLevel! + " "
        }
        if surv.surveillanceZone != filterParametar.zoneName{
            name += surv.surveillanceZone! + " "
        }
        name += surv.name!
        return name
    }
    
    func setImageForSurveillance (image:UIImage?) {
        self.image.image = image
        setNeedsDisplay()
    }
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.AllCorners,
                                cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGrayColor().setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        
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
