//
//  EventsCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class EventsCell: UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    func setCell(event: Event) {
        backgroundColor = .clear
        
        backgroundColor = UIColor.clear
        labelID.text = "\(event.eventId)"
        labelName.text = "\(event.eventName)"
        address.text = "\(returnThreeCharactersForByte(Int(event.gateway.addressOne))):\(returnThreeCharactersForByte(Int(event.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(event.address)))"
        
        if let id = event.eventImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageOne.image = UIImage(data: data)
                } else { if let defaultImage = event.eventImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = event.eventImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = event.eventImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        
        if let id = event.eventImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageTwo.image = UIImage(data: data)
                } else { if let defaultImage = event.eventImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = event.eventImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = event.eventImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
    }
    
}
