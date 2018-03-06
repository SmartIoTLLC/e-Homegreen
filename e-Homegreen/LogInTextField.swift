//
//  LogInTextField.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class LogInTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        
        updateTextField()
    }
    
    
    func updateTextField(){
        self.font = .tahoma(size: 13)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        if let place = self.placeholder{
            self.attributedPlaceholder = NSAttributedString(string: place,
                attributes:[NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        }
    }

}
