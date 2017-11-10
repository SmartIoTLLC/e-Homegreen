//
//  SecurityLocationCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 9/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class SecurityLocationCell: UICollectionViewCell {
    
    @IBOutlet weak var loactionTitleLabel: UILabel!
    @IBOutlet weak var locationImageLabel: UIImageView!
    @IBOutlet weak var locationBottomLabel: UILabel!
    
    func setItem(_ location:Location, tag: Int) {
        loactionTitleLabel.text = location.name
        loactionTitleLabel.tag = tag
        loactionTitleLabel.isUserInteractionEnabled = true
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGray.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).withAlphaComponent(0.95).cgColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).withAlphaComponent(1.0).cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                                  colors: colors as CFArray,
                                                  locations: colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
    }
}
