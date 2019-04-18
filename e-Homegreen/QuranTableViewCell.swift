//
//  QuranTableViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 5/31/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

class QuranTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "QuranTableViewCell"
    
    private let titleLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setBackgroundView()
        addTitleLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setBackgroundView()
        addTitleLabel()
        
        setupConstraints()
    }
    
    private func addTitleLabel() {
        titleLabel.textColor     = .white
        titleLabel.font          = .tahoma(size: 15)
        
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.bottom.top.equalToSuperview()
        }
    }
    
    func setBackgroundView() {
        let bg = UIView()
        bg.backgroundColor     = UIColor.white.withAlphaComponent(0.4)
        selectedBackgroundView = bg
        backgroundColor        = .clear
    }
    
    func setCell(with object: Any) {
        if let sura = object as? Sura {            
            if let id = sura.id, let name = sura.name {
                titleLabel.text = String(describing: id) + " - " + name
            }
        }
        
        if let reciter = object as? Reciter {
            titleLabel.text = reciter.name
        }
        
    }
}

