//
//  SceneGalleryVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 8/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SceneGalleryVC: UIViewController {
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var backview: UIView!
    
    init(){
        super.init(nibName: "SceneGalleryVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
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
        gradient.frame = backview.bounds
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        backview.layer.insertSublayer(gradient, atIndex: 0)
        backview.layer.borderWidth = 1
        backview.layer.borderColor = UIColor.lightGrayColor().CGColor
        backview.layer.cornerRadius = 10
        backview.clipsToBounds = true
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)

        // Do any additional setup after loading the view.
    }
    
    func handleTap(gesture:UITapGestureRecognizer){
        var point:CGPoint = gesture.locationInView(self.view)
        var tappedView:UIView = self.view.hitTest(point, withEvent: nil)!
        println(tappedView.tag)
        if tappedView.tag == 1{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension SceneGalleryVC : UIViewControllerAnimatedTransitioning {
    
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
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
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
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension SceneGalleryVC :  UIViewControllerTransitioningDelegate{
    
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
    func showGallery() {
        var galleryVC = SceneGalleryVC()
        self.presentViewController(galleryVC, animated: true, completion: nil)
    }
}
