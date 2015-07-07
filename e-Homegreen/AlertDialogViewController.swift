//
//  AlertDialogViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class AlertDialogViewController: UIViewController {
    
    var message: String = ""
    var isPresenting: Bool = true
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var ipaddressLabel: UITextField!
    @IBOutlet weak var portLabel: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var titleLabe: UILabel!
    
    init(){
       super.init(nibName: "AlertDialogViewController", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, 300, 220)
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
        alertView.layer.insertSublayer(gradient, atIndex: 0)
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor = UIColor.lightGrayColor().CGColor
        alertView.layer.cornerRadius = 10
        alertView.clipsToBounds = true
        
        titleLabe.text = message
        
        cancelButton.backgroundColor = UIColor(red: 210, green: 213, blue: 219, alpha: 1.0)
        okButton.backgroundColor = UIColor(red: 210, green: 213, blue: 219, alpha: 1.0)
        ipaddressLabel.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancel(sender: AnyObject) {
        ipaddressLabel.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
 
    @IBAction func ok(sender: AnyObject) {
        let containerViewController = ContainerViewController()
        presentViewController(containerViewController, animated: false, completion: nil)
    }
    


}

extension AlertDialogViewController : UIViewControllerAnimatedTransitioning {
    
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
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
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
//                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }

   
    
}

extension AlertDialogViewController : UIViewControllerTransitioningDelegate {
    
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
    
    func showAleartWithMessage(message: String) {
        var ad = AlertDialogViewController()
        ad.message = message
        presentViewController(ad, animated: true, completion: nil)
    }
}
