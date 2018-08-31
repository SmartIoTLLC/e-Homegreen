//
//  MacroDetailsCell.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 4/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit

class MacroDetailsCell: UITableViewCell {
    // var deviceName: UILabel!
    var deviceChannel: UILabel!
    var deviceType: UILabel!
    var macroActionCommand: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenHeight = DatabaseMacrosController.sharedInstance.screenHeight
        let screenWidth = DatabaseMacrosController.sharedInstance.screenWidth
        
        let cellHeight = CGFloat(95)
        let cellWidth = screenWidth!
        
        //        deviceName = UILabel()
        //        deviceName.frame = CGRect(x: 8, y: 10, width: cellWidth/2, height: 25)
        //        deviceName.textColor = .white
        //        deviceName.font = .tahoma(size: 17)
        
        deviceType = UILabel()
        deviceType.frame = CGRect(x: 13, y: 0, width: cellWidth/2, height: 18.5)
        deviceType.center.y = cellHeight / 2
        deviceType.textColor = .white
        deviceType.font = .tahoma(size: 14)
        
        deviceChannel = UILabel()
        deviceChannel.frame = CGRect(x: 13, y: deviceType.frame.minY - 25 - 5, width: cellWidth/2, height: 25)
        deviceChannel.textColor = .white
        deviceChannel.font = .tahoma(size: 17)
        
        macroActionCommand = UILabel()
        macroActionCommand.frame = CGRect(x: 13, y: deviceType.frame.maxY + 5, width: cellWidth/2, height: 18.5)
        macroActionCommand.textColor = .white
        macroActionCommand.font = .tahoma(size: 14)
        
        //add to view
        //contentView.addSubview(deviceName)
        contentView.addSubview(deviceChannel)
        contentView.addSubview(deviceType)
        contentView.addSubview(macroActionCommand)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
