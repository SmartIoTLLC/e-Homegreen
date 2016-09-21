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
        self.tintColor = UIColor.blackColor()
        self.textColor = UIColor.blackColor()
        self.font = UIFont(name: "Tahoma", size: 13)
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
    }
    
    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let uiImage = button.imageForState(.Highlighted) {
                    if tintedClearImage == nil {
                        tintedClearImage = tintImage(uiImage, color: tintColor)
                    }
                    button.setImage(tintedClearImage, forState: .Normal)
                    button.setImage(tintedClearImage, forState: .Highlighted)
                }
            }
        }
    }
    
    func tintImage(image: UIImage, color: UIColor) -> UIImage {
        let size = image.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.drawAtPoint(CGPointZero)
        
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextSetBlendMode(context!, CGBlendMode.SourceIn)
        CGContextSetAlpha(context!, 1.0)
        
        let rect = CGRectMake(
            CGPointZero.x,
            CGPointZero.y,
            image.size.width,
            image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext()!, rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage!
    }

}
