//
//  FlagsCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class FlagsCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    func setCell(flag: Flag) {
        backgroundColor = UIColor.clear
        
        labelID.text   = "\(flag.flagId)"
        labelName.text = "\(flag.flagName)"
        address.text   = "\(returnThreeCharactersForByte(Int(flag.gateway.addressOne))):\(returnThreeCharactersForByte(Int(flag.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(flag.address)))"
        
        if let id = flag.flagImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageOne.image = UIImage(data: data)
                } else { if let defaultImage = flag.flagImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = flag.flagImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = flag.flagImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        
        if let id = flag.flagImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageTwo.image = UIImage(data: data)
                } else { if let defaultImage = flag.flagImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = flag.flagImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = flag.flagImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
    }
}
