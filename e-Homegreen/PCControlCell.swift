//
//  PCControlCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class PCControlCell: UICollectionViewCell {
    
    @IBOutlet weak var pccontrolTitleLabel: UILabel!
    @IBOutlet weak var pccontrollImage: UIImageView!
    @IBOutlet weak var pccontrolSlider: UISlider!
    
    override func awakeFromNib() {
        pccontrolSlider.continuous = false
        super.awakeFromNib()
    }
    
    func setItem(pc:Device, tag:Int){
        pccontrolSlider.tag = tag
        pccontrolTitleLabel.text = pc.name
//        pccontrollImage.image = pc.name
//        pccontrolSlider.value = pc.
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        UIColor.lightGrayColor().setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
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
