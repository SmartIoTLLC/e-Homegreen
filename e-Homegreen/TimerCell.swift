//
//  TimerCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class TimersCell: UITableViewCell{
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    func setCell(timer: Timer) {
        backgroundColor = .clear
        
        labelID.text   = "\(timer.timerId)"
        labelName.text = timer.timerName
        address.text   = "\(returnThreeCharactersForByte(Int(timer.gateway.addressOne))):\(returnThreeCharactersForByte(Int(timer.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(timer.address)))"
        
        if let id = timer.timerImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageOne.image = UIImage(data: data)
                } else { if let defaultImage = timer.timerImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = timer.timerImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = timer.timerImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        
        if let id = timer.timerImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageTwo.image = UIImage(data: data)
                } else { if let defaultImage = timer.timerImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = timer.timerImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = timer.timerImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
        
    }
    
}
