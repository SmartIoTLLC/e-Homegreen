//
//  SaltoAccessCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/27/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class SaltoAccessCell: UICollectionViewCell {
    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var saltoName: UILabel!
    @IBOutlet weak var saltoImage: UIImageView!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var unlockButton: UIButton!
    let image0 = UIImage(named: "14 Security - Lock - 00")
    let image1 = UIImage(named: "14 Security - Lock - 01")
    
    override func awakeFromNib() {
        lockButton.layer.cornerRadius       = 5
        unlockButton.layer.cornerRadius     = 5
        disabledCellView.layer.cornerRadius = 5
    }
    
    func setCell(device: Device, tag: Int) {
        saltoName.text   = device.cellTitle
        saltoName.tag    = tag
        saltoImage.tag   = tag
        unlockButton.tag = tag
        lockButton.tag   = tag
        
        saltoName.isUserInteractionEnabled  = true
        saltoImage.isUserInteractionEnabled = true
        
        if device.currentValue == 0 { saltoImage.image = image0 } else { saltoImage.image = image1 }
        if device.isEnabled.boolValue { disabledCellView.isHidden = true } else { infoView.isHidden = false }
        if device.info { infoView.isHidden = false; backView.isHidden = true } else { infoView.isHidden = true; backView.isHidden = false }
    }
    
    @IBOutlet weak var disabledCellView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
}
