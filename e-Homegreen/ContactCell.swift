//
//  ContactCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/22/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    
    var contact: CNContact? {
        didSet {
            let firstName    = contact?.givenName ?? ""
            let lastName     = contact?.familyName ?? ""
            contactName.text = firstName + " " + lastName            
            if let phoneNumber = contact?.phoneNumbers.first?.value.stringValue {
                contactNumber.text = phoneNumber
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateCell()
    }
    
    func updateCell() {
        backgroundColor    = .clear
        
        let bg = UIView()
        bg.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        contactName.font                      = .tahoma(size: 15)
        contactName.textColor                 = .white
        contactName.adjustsFontSizeToFitWidth = true
        contactNumber.font                    = .tahoma(size: 12)
        contactNumber.textColor               = .white
    }
    
}
