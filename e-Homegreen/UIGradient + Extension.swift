//
//  UIGradient + Extension.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/29/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    class func gradientLayerForBounds(_ bounds: CGRect, isReversed: Bool = false) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        if !isReversed {
            layer.colors = [Colors.DarkGray, Colors.MediumGray]
        } else {
            layer.colors = [Colors.MediumGray, Colors.DarkGray]
        }
        
        return layer
    }
    
    class func gradientLayerForBounds(_ bounds: CGRect, colors: [CGColor]) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame  = bounds
        layer.colors = colors
        
        return layer
    }
    
}
