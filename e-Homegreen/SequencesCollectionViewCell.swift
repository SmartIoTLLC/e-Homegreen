//
//  SequencesCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class SequenceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sequenceTitle: UILabel!
    @IBOutlet weak var sequenceImageView: UIImageView!
    @IBOutlet weak var sequenceButton: UIButton!
    var imageOne:UIImage?
    var imageTwo:UIImage?
    let lightBulb = UIImage(named: "lightBulb")
    
    func setItem(_ sequence:Sequence, filterParametar:FilterItem, tag: Int) {
        sequenceTitle.text = getName(sequence, filterParametar: filterParametar)
        sequenceTitle.isUserInteractionEnabled = true
        
        sequenceImageView.tag = tag
        sequenceImageView.isUserInteractionEnabled = true
        sequenceImageView.layer.cornerRadius = 5
        sequenceImageView.clipsToBounds = true
        
        sequenceButton.tag = tag
        
        layer.cornerRadius = 5
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.5
        
        getImagesFrom(sequence)
    }
    
    func getName(_ sequence:Sequence, filterParametar:FilterItem) -> String {
        var name:String = ""
        if sequence.gateway.location.name != filterParametar.location { name += sequence.gateway.location.name! + " " }
        if let id = sequence.entityLevelId as? Int {
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: sequence.gateway.location){
                if zone.name != filterParametar.levelName { name += zone.name! + " " }
            }
        }
        
        if let id = sequence.sequenceZoneId as? Int {
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: sequence.gateway.location) {
                if zone.name != filterParametar.zoneName { name += zone.name! + " " }
            }
        }
        name += sequence.sequenceName
        return name
    }
    
    func getImagesFrom(_ sequence:Sequence) {
        
        if let id = sequence.sequenceImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData { imageOne = UIImage(data: data)
                } else {
                    if let defaultImage = sequence.sequenceImageOneDefault { imageOne = UIImage(named: defaultImage)
                    } else { imageOne = lightBulb } }
                
            } else {
                if let defaultImage = sequence.sequenceImageOneDefault { imageOne = UIImage(named: defaultImage)
                } else { imageOne = lightBulb } }
            
        } else {
            if let defaultImage = sequence.sequenceImageOneDefault { imageOne = UIImage(named: defaultImage)
            } else { imageOne = lightBulb }
        }
        
        if let id = sequence.sequenceImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData { imageTwo = UIImage(data: data)
                } else {
                    if let defaultImage = sequence.sequenceImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                    } else { imageTwo = lightBulb } }
                
            } else {
                if let defaultImage = sequence.sequenceImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                } else { imageTwo = lightBulb } }
            
        } else {
            if let defaultImage = sequence.sequenceImageTwoDefault { imageTwo = UIImage(named: defaultImage)
            } else { imageTwo = lightBulb }
        }
        
        sequenceImageView.image = imageOne
        setNeedsDisplay()
    }
    
    func commandSentChangeImage() {
        sequenceImageView.image = imageTwo
        setNeedsDisplay()
        Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeImageToNormal), userInfo: nil, repeats: false)
    }
    
    func changeImageToNormal () {
        sequenceImageView.image = imageOne
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
