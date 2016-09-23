//
//  PopoverVC.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 9/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class PopoverVC: UIViewController, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate{
    var popoverVC:PopOverViewController = PopOverViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func openPopover(_ sender: AnyObject, popOverList:[PopOverItem]) {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        popoverVC = storyboard.instantiateViewController(withIdentifier: "codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 300, height: 200)
        popoverVC.delegate = self
        popoverVC.popOverList = popOverList
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGray
            present(popoverVC, animated: true, completion: nil)
        }
    }
    
    func openPopoverWithTwoRows(_ sender: AnyObject, popOverList:[PopOverItem]) {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        popoverVC = storyboard.instantiateViewController(withIdentifier: "codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 300, height: 200)
        popoverVC.delegate = self
        popoverVC.popOverList = popOverList
        popoverVC.cellWithTwoTextRows = true
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGray
            present(popoverVC, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func nameAndId(_ name : String, id:String){
        
    }
}
