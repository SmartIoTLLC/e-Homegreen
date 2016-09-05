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
    
    func setItem(scene:Scene, filterParametar:FilterItem){
        sceneCellLabel.text = getName(scene, filterParametar: filterParametar)
    }
    
    func getName(scene:Scene, filterParametar:FilterItem) -> String{
        var name:String = ""
        if scene.gateway.location.name != filterParametar.location{
            name += scene.gateway.location.name! + " "
        }
        if scene.entityLevel != filterParametar.levelName{
            name += scene.entityLevel! + " "
        }
        if scene.sceneZone != filterParametar.zoneName{
            name += scene.sceneZone! + " "
        }
        name += scene.sceneName
        return name
    }
    
    func getImagesFrom(scene:Scene) {
        
        if let id = scene.sceneImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageOne = UIImage(data: data)
                }else{
                    if let defaultImage = scene.sceneImageOneDefault{
                        imageOne = UIImage(named: defaultImage)
                    }else{
                        imageOne = UIImage(named: "Scene - All On - 00")
                    }
                }
            }else{
                if let defaultImage = scene.sceneImageOneDefault{
                    imageOne = UIImage(named: defaultImage)
                }else{
                    imageOne = UIImage(named: "Scene - All On - 00")
                }
            }
        }else{
            if let defaultImage = scene.sceneImageOneDefault{
                imageOne = UIImage(named: defaultImage)
            }else{
                imageOne = UIImage(named: "Scene - All On - 00")
            }
        }
        
        if let id = scene.sceneImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTwo = UIImage(data: data)
                }else{
                    if let defaultImage = scene.sceneImageTwoDefault{
                        imageTwo = UIImage(named: defaultImage)
                    }else{
                        imageTwo = UIImage(named: "Scene - All On - 01")
                    }
                }
            }else{
                if let defaultImage = scene.sceneImageTwoDefault{
                    imageTwo = UIImage(named: defaultImage)
                }else{
                    imageTwo = UIImage(named: "Scene - All On - 01")
                }
            }
        }else{
            if let defaultImage = scene.sceneImageTwoDefault{
                imageTwo = UIImage(named: defaultImage)
            }else{
                imageTwo = UIImage(named: "Scene - All On - 01")
            }
        }
        sceneCellImageView.image = imageOne
        setNeedsDisplay()
    }
    func changeImageForOneSecond() {
        sceneCellImageView.image = imageTwo
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SceneCollectionCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    func changeImageBack() {
        sceneCellImageView.image = imageOne
    }
    
    func changeImageToNormal () {
        sceneCellImageView.image = imageOne
    }
    
    @IBAction func btnSet(sender: AnyObject) {
        
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        UIColor.lightGrayColor().setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
}