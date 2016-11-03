//
//  EventParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/14/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class EventParametarVC: UIViewController, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    var event:Event?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var backView: UIView!
    
    var isPresenting: Bool = true
    
    @IBOutlet var superView: UIView!
    init(point:CGPoint){
        super.init(nibName: "EventParametarVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.point = point
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBOutlet weak var isBroadcast: UISwitch!
    @IBOutlet weak var isLocalcast: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EventParametarVC.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        isBroadcast.tag = 100
        isBroadcast.isOn = event!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: #selector(EventParametarVC.changeValue(_:)), for: UIControlEvents.valueChanged)
        isLocalcast.tag = 200
        isLocalcast.isOn = event!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: #selector(EventParametarVC.changeValue(_:)), for: UIControlEvents.valueChanged)
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        // Do any additional setup after loading the view.
    }
    
    func changeValue (_ sender:UISwitch){
        if sender.tag == 100 {
            if sender.isOn == true {
                isLocalcast.isOn = false
            } else {
                isLocalcast.isOn = false
            }
        } else if sender.tag == 200 {
            if sender.isOn == true {
                isBroadcast.isOn = false
            } else {
                isBroadcast.isOn = false
            }
        }
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if isBroadcast.isOn {
            event?.isBroadcast = true
        } else {
            event?.isBroadcast = false
        }
        if isLocalcast.isOn {
            event?.isLocalcast = true
        } else {
            event?.isLocalcast = false
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshEvent), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }
}

extension EventParametarVC : UIViewControllerAnimatedTransitioning {
    
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

extension EventParametarVC : UIViewControllerTransitioningDelegate {
    
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
    func showEventParametar(_ point:CGPoint, event:Event) {
        let ep = EventParametarVC(point: point)
        ep.event = event
        self.present(ep, animated: true, completion: nil)
    }
}
