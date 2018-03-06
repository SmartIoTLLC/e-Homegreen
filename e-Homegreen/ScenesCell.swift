//
//  SceneCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/8/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class SceneCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var sceneCellLabel: UILabel!
    @IBOutlet weak var sceneCellImageView: UIImageView!
    @IBOutlet weak var btnSet: CustomGradientButtonWhite!
    var imageOne:UIImage?
    var imageTwo:UIImage?
    let allOn0 = UIImage(named: "Scene - All On - 00")
    let allOn1 = UIImage(named: "Scene - All On - 01")
    
    func setItem(_ scene:Scene, filterParametar:FilterItem, tag: Int) {
        sceneCellLabel.text = getName(scene, filterParametar: filterParametar)
        
        sceneCellLabel.tag = tag
        sceneCellLabel.isUserInteractionEnabled = true
        
        sceneCellImageView.tag = tag
        sceneCellImageView.isUserInteractionEnabled = true
        sceneCellImageView.layer.cornerRadius = 5
        sceneCellImageView.clipsToBounds = true
        
        btnSet.tag = tag
        
        getImagesFrom(scene)
    }
    
    func getName(_ scene:Scene, filterParametar:FilterItem) -> String {
        var name:String = ""
        if scene.gateway.location.name != filterParametar.location { name += scene.gateway.location.name! + " " }
        if let id = scene.entityLevelId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: scene.gateway.location) {
                if zone.name != filterParametar.levelName { name += zone.name! + " " }
            }
        }
        
        if let id = scene.sceneZoneId as? Int {
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: scene.gateway.location) {
                if zone.name != filterParametar.zoneName { name += zone.name! + " " }
            }
        }
        
        name += scene.sceneName
        return name
    }
    
    func getImagesFrom(_ scene:Scene) {
        
        if let id = scene.sceneImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData {
                    imageOne = UIImage(data: data)
                } else {
                    if let defaultImage = scene.sceneImageOneDefault { imageOne = UIImage(named: defaultImage)
                    } else { imageOne = allOn0 }
                }
                
            } else {
                if let defaultImage = scene.sceneImageOneDefault { imageOne = UIImage(named: defaultImage)
                } else { imageOne = allOn0 }
            }
            
        } else {
            if let defaultImage = scene.sceneImageOneDefault { imageOne = UIImage(named: defaultImage)
            } else { imageOne = allOn0 }
        }
        
        if let id = scene.sceneImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData {
                    imageTwo = UIImage(data: data)
                    
                } else {
                    if let defaultImage = scene.sceneImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                    } else { imageTwo = allOn1 }
                }
            } else {
                if let defaultImage = scene.sceneImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                } else { imageTwo = allOn1 }
            }
        } else {
            if let defaultImage = scene.sceneImageTwoDefault { imageTwo = UIImage(named: defaultImage)
            } else { imageTwo = allOn1 }
        }
        
        sceneCellImageView.image = imageOne
        setNeedsDisplay()
    }
    func changeImageForOneSecond() {
        sceneCellImageView.image = imageTwo
        Foundation.Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SceneCollectionCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    func changeImageBack() {
        sceneCellImageView.image = imageOne
    }
    
    @objc func changeImageToNormal () {
        sceneCellImageView.image = imageOne
    }
    
    @IBAction func btnSet(_ sender: AnyObject) {
        
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        UIColor.lightGray.setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).withAlphaComponent(0.95).cgColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).withAlphaComponent(1.0).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
}
