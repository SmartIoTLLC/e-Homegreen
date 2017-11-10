//
//  PCControlCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class PCControlCell: UICollectionViewCell {
    
    @IBOutlet weak var pccontrolTitleLabel: UILabel!
    @IBOutlet weak var pccontrollImage: UIImageView!
    @IBOutlet weak var pccontrolSlider: UISlider!
    
    override func awakeFromNib() {
        pccontrolSlider.isContinuous = false
        super.awakeFromNib()
    }
    
    func setItem(_ pc:Device, tag:Int, filterParametar: FilterItem) {
        pccontrolSlider.tag = tag
        pccontrolTitleLabel.tag = tag
        pccontrolSlider.value = Float(pc.currentValue) / 100
        pccontrolTitleLabel.text = getName(pc, filterParametar: filterParametar)
    }
    
    func getName(_ pc:Device, filterParametar:FilterItem) -> String {
        var name:String = ""
        
        if pc.gateway.location.name != filterParametar.location { name += pc.gateway.location.name! + " " }
        
        if Int(pc.parentZoneId) != filterParametar.levelId {
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(pc.parentZoneId), location: pc.gateway.location), let nameOfZone = zone.name { name +=  nameOfZone + " " }
        }
        
        if Int(pc.zoneId) != filterParametar.zoneId {
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(pc.zoneId), location: pc.gateway.location), let nameOfZone = zone.name { name +=  nameOfZone + " " }
        }
        
        name += pc.name
        
        return name
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
