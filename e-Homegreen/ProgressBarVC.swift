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
        modalPresentationStyle = UIModalPresentationStyle.custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func btnExit(_ sender: AnyObject) {
        delegate?.progressBarDidPressedExit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        progressBarView.layer.borderWidth = 1
        progressBarView.layer.borderColor = UIColor.lightGray.cgColor
        progressBarView.layer.cornerRadius = 5
        progressView.progress = percentage
        lblTitle.text = progressBarTitle
        lblPercentage.text = String.localizedStringWithFormat("%.01f", percentage) + " %"
        lblHowMuchOf.text = howMuchOf
    }
    
    func dissmissProgressBar () {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ProgressBarVC : UIViewControllerAnimatedTransitioning {
    
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
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            containerView.addSubview(presentedControllerView)
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
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
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension ProgressBarVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
