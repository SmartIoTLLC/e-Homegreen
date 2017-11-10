//
//  TimerParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/6/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class TimerParametarVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var isBroadcast: UISwitch!
    @IBOutlet weak var isLocalcast: UISwitch!
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    var timer:Timer?
    var appDel:AppDelegate!
    var error:NSError? = nil
    var isPresenting: Bool = true
    
    init(point:CGPoint){
        super.init(nibName: "TimerParametarVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        setupViews()
    }
    
    func setupViews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        isBroadcast.tag = 100
        isBroadcast.isOn = timer!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: #selector(changeValue(_:)), for: UIControlEvents.valueChanged)
        isLocalcast.tag = 200
        isLocalcast.isOn = timer!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: #selector(changeValue(_:)), for: UIControlEvents.valueChanged)
    }
    
    func changeValue (_ sender:UISwitch){
        if sender.tag == 100 {
            if sender.isOn == true { isLocalcast.isOn = false } else { isLocalcast.isOn = false }
        } else if sender.tag == 200 {
            if sender.isOn == true { isBroadcast.isOn = false } else { isBroadcast.isOn = false }
        }
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if isBroadcast.isOn { timer?.isBroadcast = true } else { timer?.isBroadcast = false }
        if isLocalcast.isOn { timer?.isLocalcast = true } else { timer?.isLocalcast = false }
        
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshTimer), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension TimerParametarVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true {
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
        } else {
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

extension TimerParametarVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
extension UIViewController {
    func showTimerParametar(_ point:CGPoint, timer:Timer) {
        let st = TimerParametarVC(point: point)
        st.timer = timer
        self.present(st, animated: true, completion: nil)
    }
}
