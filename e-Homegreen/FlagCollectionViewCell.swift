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
        if let id = flag.entityLevelId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: flag.gateway.location){
                if zone.name != filterParametar.levelName{
                    name += zone.name! + " "
                }
            }
        }
        if let id = flag.flagZoneId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: flag.gateway.location){
                if zone.name != filterParametar.zoneName{
                    name += zone.name! + " "
                }
            }
        }
        name += flag.flagName
        return name
    }
    
    func getImagesFrom(flag:Flag) {
        
        if let id = flag.flagImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageOne = UIImage(data: data)
                }else{
                    if let defaultImage = flag.flagImageOneDefault{
                        imageOne = UIImage(named: defaultImage)
                    }else{
                        imageOne = UIImage(named: "16 Flag - Flag - 00")
                    }
                }
            }else{
                if let defaultImage = flag.flagImageOneDefault{
                    imageOne = UIImage(named: defaultImage)
                }else{
                    imageOne = UIImage(named: "16 Flag - Flag - 00")
                }
            }
        }else{
            if let defaultImage = flag.flagImageOneDefault{
                imageOne = UIImage(named: defaultImage)
            }else{
                imageOne = UIImage(named: "16 Flag - Flag - 00")
            }
        }
        
        if let id = flag.flagImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTwo = UIImage(data: data)
                }else{
                    if let defaultImage = flag.flagImageTwoDefault{
                        imageTwo = UIImage(named: defaultImage)
                    }else{
                        imageTwo = UIImage(named: "16 Flag - Flag - 01")
                    }
                }
            }else{
                if let defaultImage = flag.flagImageTwoDefault{
                    imageTwo = UIImage(named: defaultImage)
                }else{
                    imageTwo = UIImage(named: "16 Flag - Flag - 01")
                }
            }
        }else{
            if let defaultImage = flag.flagImageTwoDefault{
                imageTwo = UIImage(named: defaultImage)
            }else{
                imageTwo = UIImage(named: "16 Flag - Flag - 01")
            }
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