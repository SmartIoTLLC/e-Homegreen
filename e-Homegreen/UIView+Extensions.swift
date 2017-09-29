//
//  UIView+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 11/17/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import QuartzCore

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    func rotate(_ times:Float){
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = times
        layer.add(rotateAnimation, forKey: "rotate")
    }
    func collapseInReturnToNormal (_ times:Float) {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.7, 1.0]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.repeatCount = times
        scaleAnimation.duration = 1
        layer.add(scaleAnimation, forKey: "bouncingEffectOnTouch")
    }
    
    func setGradientBackground() {
        let colorOne = Colors.MediumGray
        let colorTwo = Colors.DarkGray
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorOne, colorTwo]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds
        
        layer.addSublayer(gradientLayer)
    }
}
