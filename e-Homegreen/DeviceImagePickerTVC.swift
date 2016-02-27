//
//  DeviceImagePickerTVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/26/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class DeviceImagePickerTVC: UITableViewCell {

    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var deviceState: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
