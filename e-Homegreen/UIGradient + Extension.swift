//
//  UIGradient + Extension.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/29/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    class func gradientLayerForBounds(bounds: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = [Colors.DarkGray, Colors.MediumGray]
        return layer
    }
}
