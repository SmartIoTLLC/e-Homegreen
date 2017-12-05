//
//  ButtonImageCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/29/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class ButtonImageCell: UICollectionViewCell {
    
    var isTapped:Bool = false {
        didSet {
            layer.borderWidth = 1
            
            if isTapped {
                layer.borderColor = UIColor.white.cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    var customImageMO: Image?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateViews()
    }
    
    fileprivate func updateViews() {
        backgroundColor           = .clear
        imageView.backgroundColor = .clear
        layer.cornerRadius        = 5
        layer.masksToBounds       = true
    }

}
