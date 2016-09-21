//
//  ImportZoneTableViewCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ImportZoneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var switchVisible: UISwitch!
    @IBOutlet weak var btnZonePicker: CustomGradientButton!
    
    @IBOutlet weak var controlTypeButton: CustomGradientButton!
    var zoneItem:Zone!
    
    func setItem(zone: Zone){
        self.zoneItem = zone
        if let type = TypeOfControl(rawValue: (zone.allowOption.integerValue)){
            controlTypeButton.setTitle(type.description, forState: .Normal)
        }
        btnZonePicker.enabled = false
    }
    
    @IBAction func changeControlType(sender: AnyObject) {
        if zoneItem.allowOption.integerValue == 1{
            DatabaseZoneController.shared.changeAllowOption(2, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.Confirm.description , forState: .Normal)
            return
        }
        if zoneItem.allowOption.integerValue == 2{
            DatabaseZoneController.shared.changeAllowOption(3, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.NotAllowed.description , forState: .Normal)
            return
        }
        if zoneItem.allowOption.integerValue == 3{
            DatabaseZoneController.shared.changeAllowOption(1, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.Allowed.description , forState: .Normal)
            return
        }
    }
    
}
