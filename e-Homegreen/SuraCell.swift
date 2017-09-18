//
//  SuraCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/18/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class SuraCell: UITableViewCell {
    
    var sura: Sura? {
        didSet {
            if let id = sura?.id, let name = sura?.name {
                suraName.text = String(describing: id) + " - " + name
            }
        }
    }

    @IBOutlet weak var suraName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateCell()
    }
    
    func updateCell() {
        let bg = UIView()
        bg.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        selectedBackgroundView = bg
        backgroundColor = .clear
        suraName.textColor = .white
        suraName.font = UIFont(name: "Tahoma", size: 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
