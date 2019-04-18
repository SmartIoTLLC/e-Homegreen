//
//  EditTextField.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/23/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class EditTextField: UITextField {
    
    var tintedClearImage: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateTextField()
    }
    
    func updateTextField(){
        self.tintColor = UIColor.black
        self.textColor = UIColor.black
        self.font = .tahoma(size: 13)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.backgroundColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
    }
    
    fileprivate func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let uiImage = button.image(for: .highlighted) {
                    if tintedClearImage == nil { tintedClearImage = tintImage(uiImage, color: tintColor) }
                    button.setImage(tintedClearImage, for: UIControl.State())
                    button.setImage(tintedClearImage, for: .highlighted)
                }
            }
        }
    }
    
    func tintImage(_ image: UIImage, color: UIColor) -> UIImage {
        let size = image.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: CGPoint.zero)
        
        context!.setFillColor(color.cgColor)
        context!.setBlendMode(CGBlendMode.sourceIn)
        context!.setAlpha(1.0)
        
        let rect = CGRect(
            x: CGPoint.zero.x,
            y: CGPoint.zero.y,
            width: image.size.width,
            height: image.size.height)
        UIGraphicsGetCurrentContext()!.fill(rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage!
    }

}
