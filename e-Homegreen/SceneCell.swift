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
        address.text    = "\(returnThreeCharactersForByte(scene.gateway.addressOne.intValue)):\(returnThreeCharactersForByte(scene.gateway.addressTwo.intValue)):\(scene.address.intValue)"
        
        if let id = scene.sceneImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data = image.imageData {
                    imageOne.image = UIImage(data: data)
                } else { if let defaultImage = scene.sceneImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = scene.sceneImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = scene.sceneImageOneDefault { imageOne.image = UIImage(named: defaultImage) } }
        
        if let id = scene.sceneImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data = image.imageData {
                    imageOne.image = UIImage(data: data)
                } else { if let defaultImage = scene.sceneImageTwoDefault { imageOne.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = scene.sceneImageTwoDefault { imageOne.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = scene.sceneImageTwoDefault { imageOne.image = UIImage(named: defaultImage) } }
        
    }
    
    
}
