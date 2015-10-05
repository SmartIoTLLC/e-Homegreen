//
//  SecurityPadVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SecurityPadVC: UIViewController, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var backViewHeight: NSLayoutConstraint!
    
    var isPresenting: Bool = true
    var security:Security!
    let defaults = NSUserDefaults.standardUserDefaults()
    var address:[UInt8]!
    
    init(point:CGPoint){
        super.init(nibName: "SecurityPadVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        address = [UInt8(defaults.integerForKey("EHGSecurityAddressOne")), UInt8(defaults.integerForKey("EHGSecurityAddressTwo")), UInt8(defaults.integerForKey("EHGSecurityAddressThree"))]
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.height == 320{
                backViewHeight.constant = 300
                
            }else {
                backViewHeight.constant = 365
            }
        }else{
            backViewHeight.constant = 365
        }
    }
    
    @IBAction func btnOne(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x01), gateway: security.gateway!)
    }
    @IBAction func btnTwo(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x02), gateway: security.gateway!)
    }
    @IBAction func btnThree(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x03), gateway: security.gateway!)
    }
    @IBAction func btnFour(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x04), gateway: security.gateway!)
    }
    @IBAction func btnFive(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x05), gateway: security.gateway!)
    }
    @IBAction func btnSix(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x06), gateway: security.gateway!)
    }
    @IBAction func btnSeven(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x07), gateway: security.gateway!)
    }
    @IBAction func btnEight(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x08), gateway: security.gateway!)
    }
    @IBAction func btnNine(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x09), gateway: security.gateway!)
    }
    @IBAction func btnStar(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x0B), gateway: security.gateway!)
    }
    @IBAction func btnNull(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x00), gateway: security.gateway!)
    }
    @IBAction func btnHash(sender: AnyObject) {
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x1A), gateway: security.gateway!)
    }
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SecurityPadVC : UIViewControllerAnimatedTransitioning {
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

extension SecurityPadVC : UIViewControllerTransitioningDelegate {
    
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
    func showSecurityPad (point:CGPoint, security: Security) {
        let sp = SecurityPadVC(point: point)
        sp.security = security
        self.view.window?.rootViewController?.presentViewController(sp, animated: true, completion: nil)
    }
}
