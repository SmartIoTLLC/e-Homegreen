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
    
    func setCell(deviceImages: [DeviceImage], indexPathRow: Int) {
        backgroundColor = .clear
        deviceState.text = ""
        
        if let stateText = deviceImages[indexPathRow].text {
            deviceState.text = stateText
        } else {
            let av = Int(100 / (deviceImages.count - 1))
            
            switch indexPathRow {
                case 0                      : deviceState.text = "0"
                case deviceImages.count - 1 : deviceState.text = "\((indexPathRow - 1) * av + 1) - 100"
                default                     : deviceState.text = "\((indexPathRow - 1) * av + 1) - \((indexPathRow - 1) * av + av)"
            }
        }
            
        if let id = deviceImages[indexPathRow].customImageId {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { deviceImage.image = UIImage(data: data)
                } else { deviceImage.image = UIImage(named: deviceImages[indexPathRow].defaultImage!) }
                
            } else { deviceImage.image = UIImage(named: deviceImages[indexPathRow].defaultImage!) }
        } else { deviceImage.image = UIImage(named: deviceImages[indexPathRow].defaultImage!) }
        
    }
    
}
