//
//  MultisensorParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 11/25/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class MultisensorParametarVC: UIViewController {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var device:Device?
    var appDel:AppDelegate!
    
    @IBOutlet weak var isEnabled: UISwitch!
    var isPresenting: Bool = true
    
    init(point:CGPoint){
        super.init(nibName: "MultisensorParametarVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        //        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.view.tag = 1
        self.view.backgroundColor = UIColor.clearColor()
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshParametar", name: NotificationKey.RefreshInterface, object: nil)
        
        isEnabled.on = device!.isEnabled.boolValue
        print("AAA")
        print(device!.objectID)
        print(device!.type)
        print(device!.interfaceParametar)
        print("AAA")
    }
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(NotificationKey.RefreshInterface)
    }
    func refreshParametar() {
        let address = [UInt8(Int(device!.gateway.addressOne)),UInt8(Int(device!.gateway.addressTwo)),UInt8(Int(device!.address))]
        print(device!.interfaceParametar[4])
        if isEnabled.on == true {
            if device!.interfaceParametar[4] >= 0x80 {
                
            } else {
                device!.interfaceParametar[4] = device!.interfaceParametar[4] + 0x80
            }
        } else {
            if device!.interfaceParametar[4] >= 0x80 {
                device!.interfaceParametar[4] = device!.interfaceParametar[4] - 0x80
            } else {
                
            }
        }
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "sendCommandToSetInterfaceParametar", userInfo: nil, repeats: false)
        SendingHandler.sendCommand(byteArray: Function.setInterfaceParametar(address, interfaceParametar: device!.interfaceParametar), gateway: device!.gateway)
    }
    //  This command was necessary because the gateway didn't send response sometimes
    func sendCommandToSetInterfaceParametar () {
        let address = [UInt8(Int(device!.gateway.addressOne)),UInt8(Int(device!.gateway.addressTwo)),UInt8(Int(device!.address))]
        SendingHandler.sendCommand(byteArray: Function.getInterfaceParametar(address, channel: UInt8(Int(device!.channel))), gateway: device!.gateway)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func returnSomeObject () -> Device? {
        do {
            let fetResults = try appDel.managedObjectContext!.objectWithID(device!.objectID) as? Device
            return fetResults!
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSet(sender: AnyObject) {
        let address = [UInt8(Int(device!.gateway.addressOne)),UInt8(Int(device!.gateway.addressTwo)),UInt8(Int(device!.address))]
        SendingHandler.sendCommand(byteArray: Function.getInterfaceParametar(address, channel: UInt8(Int(device!.channel))), gateway: device!.gateway)
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            print("Unresolved error \(error1.userInfo)")
            abort()
        }
    }
    
    func handleTap(gesture:UITapGestureRecognizer){
        let point:CGPoint = gesture.locationInView(self.view)
        let tappedView:UIView = self.view.hitTest(point, withEvent: nil)!
        if tappedView.tag == 1{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
extension MultisensorParametarVC : UIViewControllerAnimatedTransitioning {
    
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
extension MultisensorParametarVC : UIViewControllerTransitioningDelegate {
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
    func showMultisensorParametar(point:CGPoint, device:Device) {
        let msp = MultisensorParametarVC(point: point)
        msp.device = device
        //        self.view.window?.rootViewController?.presentViewController(cdp, animated: true, completion: nil)
        self.presentViewController(msp, animated: true, completion: nil)
    }
}