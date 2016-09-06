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
    
    func setItem(sequence:Sequence, filterParametar:FilterItem){
        sequenceTitle.text = getName(sequence, filterParametar: filterParametar)
    }
    
    func getName(sequence:Sequence, filterParametar:FilterItem) -> String{
        var name:String = ""
        if sequence.gateway.location.name != filterParametar.location{
            name += sequence.gateway.location.name! + " "
        }
        if sequence.entityLevel != filterParametar.levelName{
            name += sequence.entityLevel! + " "
        }
        if sequence.sequenceZone != filterParametar.zoneName{
            name += sequence.sequenceZone! + " "
        }
        name += sequence.sequenceName
        return name
    }
    
    func getImagesFrom(sequence:Sequence) {
        
        if let id = sequence.sequenceImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageOne = UIImage(data: data)
                }else{
                    if let defaultImage = sequence.sequenceImageOneDefault{
                        imageOne = UIImage(named: defaultImage)
                    }else{
                        imageOne = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequence.sequenceImageOneDefault{
                    imageOne = UIImage(named: defaultImage)
                }else{
                    imageOne = UIImage(named: "lightBulb")
                }
            }
        }else{
            if let defaultImage = sequence.sequenceImageOneDefault{
                imageOne = UIImage(named: defaultImage)
            }else{
                imageOne = UIImage(named: "lightBulb")
            }
        }
        
        if let id = sequence.sequenceImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTwo = UIImage(data: data)
                }else{
                    if let defaultImage = sequence.sequenceImageTwoDefault{
                        imageTwo = UIImage(named: defaultImage)
                    }else{
                        imageTwo = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequence.sequenceImageTwoDefault{
                    imageTwo = UIImage(named: defaultImage)
                }else{
                    imageTwo = UIImage(named: "lightBulb")
                }
            }
        }else{
            if let defaultImage = sequence.sequenceImageTwoDefault{
                imageTwo = UIImage(named: defaultImage)
            }else{
                imageTwo = UIImage(named: "lightBulb")
            }
        }
        
        sequenceImageView.image = imageOne
        setNeedsDisplay()
    }
    func commandSentChangeImage() {
        sequenceImageView.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SequenceCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    func changeImageToNormal () {
        sequenceImageView.image = imageOne
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
