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
    private static var tapKey = "tapKey"
    
    func addTap(numberOfTapsRequired: Int = 1, numberOfTouchesRequired: Int = 1, cancelTouchesInView: Bool = true, action: @escaping () -> Void) {
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &UIView.tapKey, TapAction(action: action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapView))
        tapRecognizer.numberOfTapsRequired = numberOfTapsRequired
        tapRecognizer.numberOfTouchesRequired = numberOfTouchesRequired
        tapRecognizer.cancelsTouchesInView = cancelTouchesInView
        addGestureRecognizer(tapRecognizer)
    }
    
    func addLongPress(minimumPressDuration: CFTimeInterval, cancelTouchesInView: Bool = true, action: @escaping () -> Void) {
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &UIView.tapKey, TapAction(action: action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(tapView))
        longPress.minimumPressDuration = minimumPressDuration
        longPress.cancelsTouchesInView = cancelTouchesInView
        addGestureRecognizer(longPress)
    }
    
    @objc private func tapView() {
        if let tap = objc_getAssociatedObject(self, &UIView.tapKey) as? TapAction {
            tap.action()
        }
    }
}

private class TapAction {
    var action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
}

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
    
    func addShadows(opacity: Float = 0.55, isOn: Bool = true) {
        if isOn { layer.shadowColor = UIColor.black.cgColor
        } else { layer.shadowColor = UIColor.clear.cgColor }
        
        layer.shadowOffset       = CGSize(width: 0, height: 2)
        layer.shadowOpacity      = opacity
        layer.shadowRadius       = 1.0
        clipsToBounds            = false
        layer.shouldRasterize    = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addButtonShadows(isOn: Bool = true) {
        if isOn { layer.shadowColor = UIColor.black.cgColor
        } else { layer.shadowColor = UIColor.clear.cgColor }
        
        layer.shadowOffset       = CGSize(width: 0.75, height: 1.5)
        layer.shadowOpacity      = 1.0
        layer.shadowRadius       = 1.0
        clipsToBounds            = true
        layer.shouldRasterize    = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
