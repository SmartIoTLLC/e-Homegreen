//
//  ScanCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ScanCell:UITableViewCell{
    @IBOutlet weak var lblRow: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var isEnabledSwitch: UISwitch!
    @IBOutlet weak var isVisibleSwitch: UISwitch!
    
    func setItemWithParameters(row row: String, description: String, address: String, type: String, isEnabledSwitch: Bool, zone: String, category: String, isVisibleSwitch: Bool){
        self.backgroundColor = UIColor.clearColor()
        self.lblRow.text = row
        self.lblDesc.text = description
        self.lblAddress.text = address
        self.lblType.text = type
        self.isEnabledSwitch.on = isEnabledSwitch
        self.lblZone.text = zone
        self.lblCategory.text = category
        self.isVisibleSwitch.on = isVisibleSwitch
    }
}
