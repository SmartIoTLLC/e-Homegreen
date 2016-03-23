//
//  EditTextField.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/23/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class EditTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateTextField()
    }
    
    
    func updateTextField(){
        self.font = UIFont(name: "Tahoma", size: 13)
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 2
        if let place = self.placeholder{
            self.attributedPlaceholder = NSAttributedString(string: place,
                                                            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        }
    }

}
