//
//  SceneCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ScenesCell: UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    func setCell(scene: Scene) {
        backgroundColor = .clear
        labelID.text    = "\(scene.sceneId)"
        labelName.text  = "\(scene.sceneName)"
        address.text    = "\(returnThreeCharactersForByte(Int(scene.gateway.addressOne))):\(returnThreeCharactersForByte(Int(scene.gateway.addressTwo))):\(Int(scene.address))"
        
        var imageOne: UIImage?
        var imageTwo: UIImage?
        
        if let customImageOne = scene.sceneImageOneCustom {
            if let imageObject = DatabaseImageController.shared.getImageById(customImageOne) {
                if let imageData = imageObject.imageData {
                    imageOne = UIImage(data: imageData)
                }
            } else {
                imageOne = UIImage(named: customImageOne)
            }
        } else if let defaultImageOne = scene.sceneImageOneDefault {
            imageOne = UIImage(named: defaultImageOne)
        }
        
        if let customImageTwo = scene.sceneImageTwoCustom {
            if let imageObject = DatabaseImageController.shared.getImageById(customImageTwo) {
                if let imageData = imageObject.imageData {
                    imageTwo = UIImage(data: imageData)
                }
            } else {
                imageTwo = UIImage(named: customImageTwo)
            }
            
        } else if let defaultImageTwo = scene.sceneImageTwoDefault {
            imageTwo = UIImage(named: defaultImageTwo)
        }
        
        if let imageOne = imageOne {
            self.imageOne.image = imageOne
        }
        if let imageTwo = imageTwo {
            self.imageTwo.image = imageTwo
        }
        
    }
    
    
}
