//
//  CurtainModuleCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class CurtainModuleCell:UICollectionViewCell {
    @IBOutlet weak var title: MarqueeLabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var leftButton: CustomGradientButtonWhite!
    @IBOutlet weak var rightButton: CustomGradientButtonWhite!
    
    func refreshDevice(device:Device) {
        
    }
    
    @IBOutlet weak var channel: MarqueeLabel!
    @IBOutlet weak var name: MarqueeLabel!
    @IBOutlet weak var category: MarqueeLabel!
    @IBOutlet weak var level: MarqueeLabel!
    @IBOutlet weak var deviceZone: MarqueeLabel!
    
}