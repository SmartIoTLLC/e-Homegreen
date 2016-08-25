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
    
    
    init(point:CGPoint, security: Security){
        super.init(nibName: "SecuirtyCommandVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
        self.security = security
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.popUpTextView.text = security.securityDescription
        sizeText()
        
//        popUpTextView.delegate = self
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
    
    @IBAction func btnOk(sender: AnyObject) {
        
        let address = [security.addressOne.unsignedCharValue, security.addressTwo.unsignedCharValue, security.addressThree.unsignedCharValue]
        if let gatewayId = self.security.gatewayId {
            if let gateway = CoreDataController.shahredInstance.fetchGatewayWithId(gatewayId){
                let notificationName = NotificationKey.Security.ControlModeStartBlinking
                switch security.securityName! {
                case "Away":
                    SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x01), gateway: gateway)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: notificationName , object: self, userInfo: ["controlMode": SecurityControlMode.Away]))
                    break
                case "Night":
                    SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x02), gateway: gateway)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: notificationName , object: self, userInfo: ["controlMode": SecurityControlMode.Night]))
                    break
                case "Day":
                    SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x03), gateway: gateway)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: notificationName , object: self, userInfo: ["controlMode": SecurityControlMode.Day]))
                    break
                case "Vacation":
                    SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x04), gateway: gateway)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: notificationName , object: self, userInfo: ["controlMode": SecurityControlMode.Vacation]))
                    break
                case "Panic":
                    if defaults.boolForKey(UserDefaults.Security.IsPanic) {
                        SendingHandler.sendCommand(byteArray: Function.setPanic(address, panic: 0x01), gateway: gateway)
                        defaults.setBool(false, forKey: UserDefaults.Security.IsPanic)
                    } else {
                        SendingHandler.sendCommand(byteArray: Function.setPanic(address, panic: 0x00), gateway: gateway)
                        defaults.setBool(true, forKey: UserDefaults.Security.IsPanic)
                    }
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: notificationName , object: self, userInfo: ["controlMode": SecurityControlMode.Panic]))
                default: break
                }
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        let sc = SecuirtyCommandVC(point: point, security: security)
        self.presentViewController(sc, animated: true, completion: nil)
    }
    func showSecurityInformation(point:CGPoint){
        let sc = SecurityNeedDisarmInformation(point: point)
        self.presentViewController(sc, animated: true, completion: nil)
    }
}
