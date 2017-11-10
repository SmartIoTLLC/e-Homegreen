//
//  ScanCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ScanCell:UITableViewCell {
    @IBOutlet weak var lblRow: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var isEnabledSwitch: UISwitch!
    @IBOutlet weak var isVisibleSwitch: UISwitch!
    
    func setItem(device: Device, tag: Int) {
        self.backgroundColor = .clear
        lblRow.text = "\(tag + 1)"
        lblDesc.text = device.name
        lblAddress.text = "Address: \(returnThreeCharactersForByte(Int(device.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device.address))), Channel: \(device.channel)"
        if device.controlType == ControlType.Curtain { lblType.text = "Control type: \(ControlType.Relay)" } else { lblType.text = "Control type: \(device.controlType)" }
        
        let zone = "Level: \(DatabaseHandler.sharedInstance.returnZoneWithIdForScanDevicesCell(Int(device.parentZoneId), location: device.gateway.location)) Zone: \(DatabaseHandler.sharedInstance.returnZoneWithIdForScanDevicesCell(Int(device.zoneId), location: device.gateway.location))"
        let category = "Category: \(DatabaseHandler.sharedInstance.returnCategoryWithIdForScanDevicesCell(Int(device.categoryId), location: device.gateway.location))"
        
        isEnabledSwitch.tag = tag
        isVisibleSwitch.tag = tag
        lblZone.text = zone
        lblCategory.text = category
        isVisibleSwitch.isOn = device.isVisible.boolValue
        isEnabledSwitch.isOn = device.isEnabled.boolValue
    }
    
}
