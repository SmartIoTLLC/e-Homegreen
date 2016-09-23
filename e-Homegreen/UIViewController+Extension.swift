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
    case delete
    case cancel
    case ok
}

extension UIViewController {

    func sendFilterParametar(_ filterParametar:FilterItem){
        
    }
    
    func sendSearchBarText(_ text:String){
        
    }
    
    func imageLayerForGradientBackground() -> UIImage {
        
        var updatedFrame = self.navigationController?.navigationBar.bounds
        // take into account the status bar
        updatedFrame!.size.height += 20
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame!)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // Presents Alert view that has Delete and Cancel buttons.
    // Returns which action is selected
    func showAlertView(_ sender:UIView, message:String, completion: @escaping (_ action: ReturnedValueFromAlertView) -> ()){
        let optionMenu = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(ReturnedValueFromAlertView.delete)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(ReturnedValueFromAlertView.cancel)
        })
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // Presents Alert view that has OK and Cancel buttons.
    // Returns which action is selected
    func showOKAlertView(_ sender:UIView, message:String, completion: @escaping (_ action: ReturnedValueFromAlertView) -> ()){
        let optionMenu = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(ReturnedValueFromAlertView.ok)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(ReturnedValueFromAlertView.cancel)
        })
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(okAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
}
