//
//  UIViewController+Extension.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/3/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation


extension UIViewController {
    func sendFilterParametar(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String){
        
    }
    func sendFilterParametar(filterParametar:FilterItem){
        
    }
    
    func imageLayerForGradientBackground() -> UIImage {
        
        var updatedFrame = self.navigationController?.navigationBar.bounds
        // take into account the status bar
        updatedFrame!.size.height += 20
        var layer = CAGradientLayer.gradientLayerForBounds(updatedFrame!)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
