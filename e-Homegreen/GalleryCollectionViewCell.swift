//
//  GalleryCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir on 8/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
        
    @IBOutlet weak var cellImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 5
    }

}
