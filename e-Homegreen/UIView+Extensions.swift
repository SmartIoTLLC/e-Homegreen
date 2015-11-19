//
//  UIView+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 11/17/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    func rotate(times:Float){
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = times
        layer.addAnimation(rotateAnimation, forKey: "rotate")
    }
    func rotateAndEmphase(times:Float){
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1,1.1,1.2,1.1,1]
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation,rotateAnimation]
        group.duration = 1
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        group.repeatCount = times
        layer.addAnimation(group, forKey: "rotateAndEmphase")
    }
    func bouncingEffectOnTouch (times:Float) {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.7, 1.5, 1.0]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.repeatCount = times
        scaleAnimation.duration = 1
        layer.addAnimation(scaleAnimation, forKey: "bouncingEffectOnTouch")
    }
    func collapseInReturnToNormal (times:Float) {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.7, 1.0]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.repeatCount = times
        scaleAnimation.duration = 1
        layer.addAnimation(scaleAnimation, forKey: "bouncingEffectOnTouch")
    }
    func collapseInReturnToNormalMenu (times:Float) {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.5, 1.0]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.repeatCount = times
        scaleAnimation.duration = 1
        layer.addAnimation(scaleAnimation, forKey: "bouncingEffectOnTouch")
    }
    func fadeIn (times:Float) {
        var animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 1
        animation.fromValue = NSNumber(float: 0.0)
        animation.toValue = NSNumber(float: 1.0)
        animation.repeatCount = times
        layer.addAnimation(animation, forKey: "fadeIn")
    }
    func fadeOut (times:Float) {
        var animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.5
        animation.fromValue = NSNumber(float: 1.0)
        animation.toValue = NSNumber(float: 0.0)
        animation.repeatCount = times
        layer.addAnimation(animation, forKey: "fadeOut")
    }
}