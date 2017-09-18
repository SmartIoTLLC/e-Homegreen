//
//  ReciterCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/15/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class ReciterCell: UITableViewCell {
    
    @IBOutlet weak var reciterLabel: UILabel!

    var reciter: Reciter? {
        didSet {
            reciterLabel.text = reciter?.name
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        updateCell()
    }
    
    func updateCell() {
        let bg = UIView()
        bg.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        selectedBackgroundView = bg
        backgroundColor = .clear
        reciterLabel.font = UIFont(name: "Tahoma", size: 17)
        reciterLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
