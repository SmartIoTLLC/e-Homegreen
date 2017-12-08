//
//  SequencesCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class SequencesCell: UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    func setCell(sequence: Sequence) {
        backgroundColor = .clear
        labelID.text    = "\(sequence.sequenceId)"
        labelName.text  = "\(sequence.sequenceName)"
        address.text    = "\(returnThreeCharactersForByte(Int(sequence.gateway.addressOne))):\(returnThreeCharactersForByte(Int(sequence.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(sequence.address)))"
        
        if let id = sequence.sequenceImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageOne.image = UIImage(data: data)
                } else { if let defaultImage = sequence.sequenceImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = sequence.sequenceImageOneDefault{ imageOne.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = sequence.sequenceImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        
        if let id = sequence.sequenceImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageOne.image = UIImage(data: data)
                } else { if let defaultImage = sequence.sequenceImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = sequence.sequenceImageTwoDefault{ imageTwo.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = sequence.sequenceImageTwoDefault { imageTwo.image = UIImage(named: defaultImage) } }
    }
}
