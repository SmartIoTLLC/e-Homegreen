//
//  TestCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 3/6/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import UIKit

class TestCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.image = #imageLiteral(resourceName: "lightBulb")
        // Initialization code
    }

}
