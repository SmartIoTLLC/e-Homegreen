//
//  SecuritySettingsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SecuritySettingsViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate {

    @IBOutlet weak var backView: UIView!
    
    var isPresenting:Bool = false
    var defaults:NSUserDefaults!
    
    @IBOutlet weak var addOne: UITextField!
    @IBOutlet weak var addTwo: UITextField!
    @IBOutlet weak var addThree: UITextField!
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    func endEditingNow(){
        addOne.resignFirstResponder()
        addTwo.resignFirstResponder()
        addThree.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        addOne.inputAccessoryView = keyboardDoneButtonView
        addTwo.inputAccessoryView = keyboardDoneButtonView
        addThree.inputAccessoryView = keyboardDoneButtonView
        
        defaults = NSUserDefaults.standardUserDefaults()
        
        addOne.text = returnThreeCharactersForByte(defaults.integerForKey("EHGSecurityAddressOne"))
        addTwo.text = returnThreeCharactersForByte(defaults.integerForKey("EHGSecurityAddressTwo"))
        addThree.text = returnThreeCharactersForByte(defaults.integerForKey("EHGSecurityAddressThree"))

        transitioningDelegate = self

        // Do any additional setup after loading the view.
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnChooseGateway(sender: AnyObject) {
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 1
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if addOne.text != "" && addTwo.text != "" && addThree.text != "" {
            if let addressOne = Int(addOne.text!), let addressTwo = Int(addTwo.text!), let addressThree = Int(addThree.text!) {
                defaults.setObject(addressOne, forKey: "EHGSecurityAddressOne")
                defaults.setObject(addressTwo, forKey: "EHGSecurityAddressTwo")
                defaults.setObject(addressThree, forKey: "EHGSecurityAddressThree")
            }
        }
    }
    
    @IBAction func backBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.center.x += containerView!.bounds.size.width
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x -= containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x += containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }

}
