//
//  MacrosCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/7/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class MacrosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var macroTitleLabel: MarqueeLabel!
    @IBOutlet weak var macroImage: UIImageView!
    @IBOutlet weak var cancelButton: CustomGradientButtonWhite!
    
    var imageOne:UIImage?
    var imageTwo:UIImage?
    
    func setItem(_ macro:Macro, filterParametar:FilterItem){
        macroTitleLabel.text = getName(macro, filterParametar: filterParametar)
        macroImage.image = getImage(macro: macro)
    }
    
    func getName(_ macro:Macro, filterParametar:FilterItem) -> String{
        var name:String = ""
        if macro.location.name != filterParametar.location{
            name += macro.location.name! + " "
        }
        if let id = macro.entityLevelId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: macro.location){
                if zone.name != filterParametar.levelName{
                    name += zone.name! + " "
                }
            }
        }
        if let id = macro.macroZoneId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: macro.location){
                if zone.name != filterParametar.zoneName{
                    name += zone.name! + " "
                }
            }
        }
        name += macro.name
        return name
    }
    
    func getImage(macro: Macro) -> UIImage?{
        if let id = macro.macroImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    return UIImage(data: data)
                }else{
                    if let defaultImage = macro.macroImageOneCustom{
                        return UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = macro.macroImageOneDefault{
                    return UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = macro.macroImageOneDefault{
                return UIImage(named: defaultImage)
            }
        }
        return UIImage(named: "12 Appliance - Bell - 00")
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
