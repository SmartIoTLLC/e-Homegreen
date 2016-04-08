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
    
    func getName(scene:Scene, filterParametar:FilterItem) -> String?{
        var sceneLocation = ""
        var sceneLevel = ""
        var sceneZone = ""
        
        sceneLocation = scene.gateway.location.name!
        
        if let level = scene.entityLevel{
            sceneLevel = level
        }
        if let zone = scene.sceneZone{
            sceneZone = zone
        }
        
        var sceneTitle = ""
        
        if filterParametar.location == "All" {
            sceneTitle = sceneLocation + " " + sceneLevel + " " + sceneZone + " " + scene.sceneName
        }else{
            if filterParametar.location == "All"{
                sceneTitle += " " + sceneLocation
            }
            if filterParametar.levelName == "All"{
                sceneTitle += " " + sceneLevel
            }
            if filterParametar.zoneName == "All"{
                sceneTitle += " " + sceneZone
            }
            sceneTitle += " " + scene.sceneName
        }

        return sceneTitle
    }
    
    func getImagesFrom(scene:Scene) {
        if let sceneImage = UIImage(data: scene.sceneImageOne) {
            imageOne = sceneImage
        }
        
        if let sceneImage = UIImage(data: scene.sceneImageTwo) {
            imageTwo = sceneImage
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