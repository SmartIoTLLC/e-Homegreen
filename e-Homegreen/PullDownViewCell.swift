//
//  PullDownViewCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 7/6/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class PullDownViewCell: UITableViewCell {
    
    @IBOutlet weak var tableItem: UILabel!
    
}

class PullDownViewTwoRowsCell: UITableViewCell {
    
    @IBOutlet weak var tableItemName: UILabel!
    @IBOutlet weak var tableItemDescription: UILabel!
}
