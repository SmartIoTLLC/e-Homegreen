//
//  UIViewController+Extension.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/3/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation


extension UIViewController {

    func sendFilterParametar(filterParametar:FilterItem){
        
    }
    
    func sendSearchBarText(text:String){
        
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
    
    func showAlertView(sender:UIView, message:String, completion: (action: Bool) -> ()){
        let optionMenu = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(action: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(action: false)
        })
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
}
