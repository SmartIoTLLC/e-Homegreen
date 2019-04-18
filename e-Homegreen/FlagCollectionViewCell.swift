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
    
    let flag0 = UIImage(named: "16 Flag - Flag - 00")
    let flag1 = UIImage(named: "16 Flag - Flag - 01")
    
    func setItem(_ flag: Flag, filterParametar:FilterItem, tag: Int) {
        flagTitle.text = getName(flag, filterParametar: filterParametar)
        flagTitle.isUserInteractionEnabled = true
        
        flagImageView.tag = tag
        flagImageView.isUserInteractionEnabled = true
        
        flagButton.tag = tag
        
        if flag.setState.boolValue { flagButton.setTitle("Set False", for: UIControl.State())
        } else { flagButton.setTitle("Set True", for: UIControl.State()) }
        
        flagImageView.layer.cornerRadius = 5
        flagImageView.clipsToBounds      = true
        
        layer.cornerRadius = 5
        layer.borderColor  = UIColor.gray.cgColor
        layer.borderWidth  = 0.5
        
        getImagesFrom(flag)
    }        
    
    func getName(_ flag:Flag, filterParametar:FilterItem) -> String {
        var name:String = ""
        if flag.gateway.location.name != filterParametar.location { name += flag.gateway.location.name! + " " }
        
        if let id = flag.entityLevelId as? Int {
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: flag.gateway.location) {
                if zone.name != filterParametar.levelName { name += zone.name! + " " }
            }
        }
        if let id = flag.flagZoneId as? Int {
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: flag.gateway.location) {
                if zone.name != filterParametar.zoneName{ name += zone.name! + " " }
            }
        }
        name += flag.flagName
        return name
    }
    
    func getImagesFrom(_ flag:Flag) {
        
        if let id = flag.flagImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageOne = UIImage(data: data)
                } else {
                    if let defaultImage = flag.flagImageOneDefault { imageOne = UIImage(named: defaultImage)
                    } else { imageOne = flag0 } }
                
            } else {
                if let defaultImage = flag.flagImageOneDefault { imageOne = UIImage(named: defaultImage)
                } else { imageOne = flag0 } }
            
        } else {
            if let defaultImage = flag.flagImageOneDefault { imageOne = UIImage(named: defaultImage)
            } else { imageOne = flag0 } }
        
        if let id = flag.flagImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageTwo = UIImage(data: data)
                } else {
                    if let defaultImage = flag.flagImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                    } else { imageTwo = flag1 } }
                
            } else {
                if let defaultImage = flag.flagImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                } else { imageTwo = flag1 } }
            
        } else {
            if let defaultImage = flag.flagImageTwoDefault { imageTwo = UIImage(named: defaultImage)
            } else { imageTwo = flag1 } }
        
        
        if flag.setState.boolValue { flagImageView.image = imageTwo } else { flagImageView.image = imageOne }
        
        setNeedsDisplay()
    }
    
    func commandSentChangeImage () {
        flagImageView.image = imageTwo
        setNeedsDisplay()
        Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeImageToNormal), userInfo: nil, repeats: false)
    }
    
    @objc func changeImageToNormal () {
        flagImageView.image = imageOne
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGray.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).withAlphaComponent(0.95).cgColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).withAlphaComponent(1.0).cgColor]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                                  colors: colors as CFArray,
                                                  locations: colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
    }
    
}
