//
//  ProgressBarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@objc protocol ProgressBarDelegate {
    func progressBarDidPressedExit()
}

class ProgressBarVC: UIViewController {
    var delegate:ProgressBarDelegate?
    
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblHowMuchOf: UILabel!
    
    var progressBarTitle:String = ""
    var percentage:Float = 0.0
    var howMuchOf:String = ""
    
    var isPresenting: Bool = true
    
    init (title:String, percentage: Float, howMuchOf:String) {
        super.init(nibName: "ProgressBarVC", bundle: nil)
        self.progressBarTitle = title
        self.percentage = percentage
        self.howMuchOf = howMuchOf
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBAction func btnExit(sender: AnyObject) {
        delegate?.progressBarDidPressedExit()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBarView.layer.borderWidth = 1
        progressBarView.layer.borderColor = UIColor.lightGrayColor().CGColor
        progressBarView.layer.cornerRadius = 5
        progressView.progress = percentage
        lblTitle.text = progressBarTitle
        lblPercentage.text = String.localizedStringWithFormat("%.01f", percentage) + " %"
        lblHowMuchOf.text = howMuchOf

        // Do any additional setup after loading the view.
    }
    
    func dissmissProgressBar () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func presentProgressBar () {
//        self.view.window?.rootViewController?.presentViewController(ad, animated: true, completion: nil)
    }


}

extension ProgressBarVC : UIViewControllerAnimatedTransitioning {
    
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
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
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
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension ProgressBarVC : UIViewControllerTransitioningDelegate {
    
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