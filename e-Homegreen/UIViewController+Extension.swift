//
//  UIViewController+Extension.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/3/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

// Used for returning value in fucntion "showAlertView" which presents alert view
enum ReturnedValueFromAlertView {
    case Delete
    case Cancel
    case Ok
}

extension UIViewController {

    func sendFilterParametar(filterParametar:FilterItem){
        
    }
    
    func sendSearchBarText(text:String){
        
    }
    
    func imageLayerForGradientBackground() -> UIImage {
        
        var updatedFrame = self.navigationController?.navigationBar.bounds
        // take into account the status bar
        updatedFrame!.size.height += 20
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame!)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // Presents Alert view that has Delete and Cancel buttons.
    // Returns which action is selected
    func showAlertView(sender:UIView, message:String, completion: (action: ReturnedValueFromAlertView) -> ()){
        let optionMenu = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(action: ReturnedValueFromAlertView.Delete)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(action: ReturnedValueFromAlertView.Cancel)
        })
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    // Presents Alert view that has OK and Cancel buttons.
    // Returns which action is selected
    func showOKAlertView(sender:UIView, message:String, completion: (action: ReturnedValueFromAlertView) -> ()){
        let optionMenu = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(action: ReturnedValueFromAlertView.Ok)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(action: ReturnedValueFromAlertView.Cancel)
        })
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(okAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
}
