//
//  SecuirtyCommandVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SecuirtyCommandVC: UIViewController, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    
    var devices:[Device] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    var security:Security!
    var defaults = NSUserDefaults.standardUserDefaults()
    var isPresenting: Bool = true
    
    
    @IBOutlet weak var backViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popUpTextView: UITextView!
    init(point:CGPoint){
        super.init(nibName: "SecuirtyCommandVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBAction func btnOk(sender: AnyObject) {
        let address = [UInt8(defaults.integerForKey(UserDefaults.Security.AddressOne)), UInt8(defaults.integerForKey(UserDefaults.Security.AddressTwo)), UInt8(defaults.integerForKey(UserDefaults.Security.AddressThree))]
//        let address = [UInt8(defaults.integerForKey(UserDefaults.Security.AddressOne)), UInt8(defaults.integerForKey(UserDefaults.Security.AddressTwo)), UInt8(defaults.integerForKey(UserDefaults.Security.AddressThree))]
        switch security.name {
        case "Away":
            if security.gateway != nil {
                SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x01), gateway: security.gateway!)
            }
        case "Night":
            if security.gateway != nil {
                
            }
            SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x02), gateway: security.gateway!)
        case "Day":
            if security.gateway != nil {
                
            }
            SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x03), gateway: security.gateway!)
        case "Vacation":
            if security.gateway != nil {
                
            }
            SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x04), gateway: security.gateway!)
        case "Panic":
            if defaults.boolForKey(UserDefaults.Security.IsPanic) {
                if security.gateway != nil {
                    SendingHandler.sendCommand(byteArray: Function.setPanic(address, panic: 0x01), gateway: security.gateway!)
                    defaults.setBool(false, forKey: UserDefaults.Security.IsPanic)
                }
            } else {
                if security.gateway != nil {
                    SendingHandler.sendCommand(byteArray: Function.setPanic(address, panic: 0x00), gateway: security.gateway!)
                    defaults.setBool(true, forKey: UserDefaults.Security.IsPanic)
                }
            }
        default: break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        popUpTextView.text = security.modeExplanation
        sizeText()
        
//        popUpTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func sizeText(){
        let fixedWidth = popUpTextView.frame.size.width
        popUpTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = popUpTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = popUpTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        if newFrame.size.height + 60 < 200{
            popUpTextView.frame = newFrame
            backViewHeight.constant = popUpTextView.frame.size.height + 50
        }else{
            backViewHeight.constant = 200
        }
    }
    
    func handleTap(gesture:UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(popUpView){
            return false
        }
        return true
    }


}

extension SecuirtyCommandVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            self.oldPoint = presentedControllerView.center
            presentedControllerView.center = self.point!
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
            containerView!.addSubview(presentedControllerView)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
                presentedControllerView.center = self.point!
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }        
    }
}

extension SecuirtyCommandVC : UIViewControllerTransitioningDelegate {
    
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
extension UIViewController {
    func showSecurityCommand(point:CGPoint, text:String, security: Security) {
        let sc = SecuirtyCommandVC(point: point)
        sc.security = security
        self.view.window?.rootViewController?.presentViewController(sc, animated: true, completion: nil)
    }
}
