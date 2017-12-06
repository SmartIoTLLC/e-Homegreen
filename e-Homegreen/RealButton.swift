//
//  RealButton.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/6/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation

class RealButton: UIButton {
    
    var needsShadow: Bool! = true {
        didSet {
            setShadow()
        }
    }
    
    var shadowLayer: CAShapeLayer!
    
    var buttonShape: String!
    var button: RemoteButton? {
        didSet {
            buttonShape = button?.buttonShape
        }
    }
    
    fileprivate func setShadow() {
        if needsShadow {
            if shadowLayer == nil {
                shadowLayer = CAShapeLayer()
                switch buttonShape {
                    case ButtonShape.rectangle : shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 3).cgPath
                    case ButtonShape.circle    : shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2).cgPath
                    default: break
                }
                shadowLayer.fillColor     = UIColor.clear.cgColor
                shadowLayer.shadowColor   = UIColor.black.cgColor
                shadowLayer.shadowPath    = shadowLayer.path
                shadowLayer.shadowOffset  = CGSize(width: 0.75, height: 2)
                shadowLayer.shadowOpacity = 1.0
                shadowLayer.shadowRadius  = 1
                
                layer.insertSublayer(shadowLayer, at: 0)
            }
        } else {
            if shadowLayer != nil {
                shadowLayer.removeFromSuperlayer()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
