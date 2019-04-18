//
//  ContactTableViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/6/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit
import Contacts

private struct LocalConstants {
    static let nameLabelHeight: CGFloat = 30
    static let numberLabelHeight: CGFloat = 12
}

class ContactTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "ContactTableViewCell"
    
    private let nameLabel: UILabel = UILabel()
    private let numberLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addNameLabel()
        addNumberLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addNameLabel()
        addNumberLabel()
        
        setupConstraints()
    }
    
    private func addNameLabel() {
        nameLabel.font                      = .tahoma(size: 15)
        nameLabel.textColor                 = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        
        addSubview(nameLabel)
    }
    
    private func addNumberLabel() {
        numberLabel.font                    = .tahoma(size: 12)
        numberLabel.textColor               = .white
        
        addSubview(numberLabel)
    }
    
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(GlobalConstants.sidePadding / 2)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.nameLabelHeight)
        }
        
        numberLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.numberLabelHeight)
        }
    }
    
    func setCell(with contact: CNContact) {
        nameLabel.text = contact.givenName + " " + contact.familyName
        
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            numberLabel.text = phoneNumber
        }
    }
}
