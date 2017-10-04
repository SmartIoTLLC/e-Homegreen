//
//  ButtonCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 10/2/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class ButtonCell: UICollectionViewCell {
    
    var remote: RemoteDummy! {
        didSet {
            setButton(remote: remote)
        }
    }
    var buttonTag: Int?

    @IBOutlet weak var buttonView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateCell()
    }
    
    func updateCell() {
        backgroundColor = .clear
        
    }
    
    func setButton(remote: RemoteDummy) {
        switch remote.buttonColor {
        case UIColor.red?:
            buttonView.backgroundColor = .red
        case UIColor.gray?:
            buttonView.backgroundColor = .gray
        default:
            buttonView.backgroundColor = .red
        }
        
        switch remote.buttonShape {
        case "Circle":
            buttonView.frame.size = remote.buttonSize
            buttonView.layer.cornerRadius = remote.buttonSize.width / 2
        case "Rectangle":
            buttonView.frame.size = remote.buttonSize
        default:
            break
        }
    }

}
