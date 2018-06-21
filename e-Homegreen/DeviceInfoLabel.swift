//
//  DeviceInfoLabel.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

class DeviceInfoLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        textColor = .white
        textAlignment = .center
    }
    
    func setText(_ text: String, fontSize: CGFloat) {
        self.text = text
        font = .tahoma(size: fontSize)
    }
}
