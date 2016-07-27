//
//  FlagCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
class FlagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flagTitle: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var flagButton: UIButton!
    var imageOne:UIImage?
    var imageTwo:UIImage?
    
    func setItem(flag:Flag, filterParametar:FilterItem){
        flagTitle.text = getName(flag, filterParametar: filterParametar)
    }
    
    func getName(flag:Flag, filterParametar:FilterItem) -> String{
        var name:String = ""
        if flag.gateway.location.name != filterParametar.location{
            name += flag.gateway.location.name! + " "
        }
        if flag.entityLevel != filterParametar.levelName{
            name += flag.entityLevel! + " "
        }
        if flag.flagZone != filterParametar.zoneName{
            name += flag.flagZone! + " "
        }
        name += flag.flagName
        return name
    }
    
    func getImagesFrom(flag:Flag) {
        if let flagImage = UIImage(data: flag.flagImageOne) {
            imageOne = flagImage
        }
        if let flagImage = UIImage(data: flag.flagImageTwo) {
            imageTwo = flagImage
        }
        if flag.setState.boolValue {
            flagImageView.image = imageTwo
        } else {
            flagImageView.image = imageOne
        }
        setNeedsDisplay()
    }
    func commandSentChangeImage () {
        flagImageView.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(FlagCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    func changeImageToNormal () {
        flagImageView.image = imageOne
        setNeedsDisplay()
    }
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.AllCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGrayColor().setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace,
                                                  colors,
                                                  colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
    }
    
}