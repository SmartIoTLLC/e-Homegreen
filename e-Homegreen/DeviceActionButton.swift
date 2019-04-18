//
//  DeviceActionButton.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let buttonCornerRadius: CGFloat = 5
}

class DeviceActionButton: CustomGradientButtonWhite {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = LocalConstants.buttonCornerRadius
        clipsToBounds = true
    }
    
    func setTitle(_ title: String, fontSize: CGFloat = 16) {
        setAttributedTitle(NSAttributedString(
            string: title,
            attributes: [NSAttributedString.Key.font: UIFont.tahoma(size: fontSize)]
        ), for: UIControl.State())
    }
}
