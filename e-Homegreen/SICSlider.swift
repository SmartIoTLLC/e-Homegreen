//
//  SICSlider.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/14/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

class SICSlider: UISlider {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        tintColor = Colors.AndroidGrayColor
        isContinuous = true
    }
}
