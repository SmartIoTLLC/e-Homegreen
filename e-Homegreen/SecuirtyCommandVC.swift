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
    var defaults = Foundation.UserDefaults.standard
    var isPresenting: Bool = true
    
    @IBOutlet weak var backViewHeight: NSLayoutConstraint!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popUpTextView: UITextView!
    
    
    init(point:CGPoint, security: Security){
        super.init(nibName: "SecuirtyCommandVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.point = point
        self.security = security
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SecuirtyCommandVC.handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.popUpTextView.text = security.securityDescription
        sizeText()
        
//        popUpTextView.delegate = self
    }
    
    func sizeText(){
        let fixedWidth = popUpTextView.frame.size.width
        popUpTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = popUpTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = popUpTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        if newFrame.size.height + 60 < 200{
            popUpTextView.frame = newFrame
            backViewHeight.constant = popUpTextView.frame.size.height + 50
        }else{
            backViewHeight.constant = 200
        }
    }
    
    func handleTap(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: popUpView){
            return false
        }
        return true
    }
    
    @IBAction func btnOk(_ sender: AnyObject) {
        
        let address = [security.addressOne.uint8Value, security.addressTwo.uint8Value, security.addressThree.uint8Value]
        if let gatewayId = self.security.gatewayId {
            if let gateway = CoreDataController.shahredInstance.fetchGatewayWithId(gatewayId){
                let notificationName = NotificationKey.Security.ControlModeStartBlinking
                switch security.securityName! {
                case "Away":
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.changeSecurityMode(address, mode: 0x01), gateway: gateway)
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notificationName) , object: self, userInfo: ["controlMode": SecurityControlMode.Away]))
                    break
                case "Night":
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.changeSecurityMode(address, mode: 0x02), gateway: gateway)
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notificationName) , object: self, userInfo: ["controlMode": SecurityControlMode.Night]))
                    break
                case "Day":
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.changeSecurityMode(address, mode: 0x03), gateway: gateway)
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notificationName) , object: self, userInfo: ["controlMode": SecurityControlMode.Day]))
                    break
                case "Vacation":
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.changeSecurityMode(address, mode: 0x04), gateway: gateway)
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notificationName) , object: self, userInfo: ["controlMode": SecurityControlMode.Vacation]))
                    break
                case "Panic":
                    if defaults.bool(forKey: UserDefaults.Security.IsPanic) {
                        SendingHandler.sendCommand(byteArray: OutgoingHandler.setPanic(address, panic: 0x01), gateway: gateway)
                        defaults.set(false, forKey: UserDefaults.Security.IsPanic)
                    } else {
                        SendingHandler.sendCommand(byteArray: OutgoingHandler.setPanic(address, panic: 0x00), gateway: gateway)
                        defaults.set(true, forKey: UserDefaults.Security.IsPanic)
                    }
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notificationName) , object: self, userInfo: ["controlMode": SecurityControlMode.Panic]))
                default: break
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SecuirtyCommandVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
            self.oldPoint = presentedControllerView.center
            presentedControllerView.center = self.point!
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            containerView.addSubview(presentedControllerView)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                
                presentedControllerView.center = self.point!
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }        
    }
}

extension SecuirtyCommandVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}
extension UIViewController {
    func showSecurityCommand(_ point:CGPoint, text:String, security: Security) {
        let sc = SecuirtyCommandVC(point: point, security: security)
        self.present(sc, animated: true, completion: nil)
    }
    func showSecurityInformation(_ point:CGPoint){
        let sc = SecurityNeedDisarmInformation(point: point)
        self.present(sc, animated: true, completion: nil)
    }
}
