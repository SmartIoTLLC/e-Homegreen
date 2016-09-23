//
//  CustomToolBar.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/6/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class CustomToolBar: UIToolbar {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateToolBar()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateToolBar()
    }
    
    func updateToolBar(){
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CustomToolBar.endEditingNow) )
        let toolbarButtons = [flexibleSpace, item]
        self.setItems(toolbarButtons, animated: false)
    }
    
    func endEditingNow(){
        self.parentViewController?.view.endEditing(true)
    }
    
}

