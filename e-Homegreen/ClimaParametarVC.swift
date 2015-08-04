//
//  ClimaParametarVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 8/4/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ClimaParametarVC: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    
    var isPresenting: Bool = true
    
    init(point:CGPoint){
        super.init(nibName: "ClimaParametarVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        //        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.view.tag = 1
        
        
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = backView.bounds
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
        backView.layer.insertSublayer(gradient, atIndex: 0)
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.lightGrayColor().CGColor
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = true
        
        self.view.backgroundColor = UIColor.clearColor()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleTap(gesture:UITapGestureRecognizer){
        var point:CGPoint = gesture.locationInView(self.view)
        var tappedView:UIView = self.view.hitTest(point, withEvent: nil)!
        println(tappedView.tag)
        if tappedView.tag == 1{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }


}

extension ClimaParametarVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
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
            containerView.addSubview(presentedControllerView)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
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

extension ClimaParametarVC : UIViewControllerTransitioningDelegate {
    
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
    func showClimaParametar(point:CGPoint) {
        var ad = ClimaParametarVC(point: point)
        self.view.window?.rootViewController?.presentViewController(ad, animated: true, completion: nil)
    }
}
