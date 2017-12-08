//
//  CardsCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class CardsCell: UITableViewCell{
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardIdLabel: UILabel!
    @IBOutlet weak var address: UILabel!
    
    func setCell(card: Card) {
        backgroundColor = .clear
        
        labelID.text       = "\(card.id)"
        cardNameLabel.text = card.cardName
        cardIdLabel.text   = card.cardId
        address.text       = "\(String(format: "%03d", card.gateway.addressOne.intValue)):\(String(format: "%03d", card.gateway.addressTwo.intValue)):\(String(format: "%03d", card.timerAddress.intValue)):\(card.timerId)"
    }
    
}
