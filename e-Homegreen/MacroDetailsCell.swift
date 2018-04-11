//
//  MacroDetailsCell.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 4/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit

class MacroDetailsCell: UITableViewCell {
    var deviceName: UILabel!
    var deviceChannel: UILabel!
    var deviceType: UILabel!
    var macroActionCommand: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        deviceName = UILabel()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
