//
//  CameraVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/7/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    var lync:NSURL?
    var point:CGPoint?
    var oldPoint:CGPoint?
    
    var isPresenting: Bool = true
    
    var timer:NSTimer = NSTimer()
    
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    
    init(point:CGPoint, lync:NSURL){
        super.init(nibName: "CameraVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
        self.lync = lync
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap"))
        self.view.addGestureRecognizer(tapGesture)
        
        backView.layer.borderWidth = 2
        backView.layer.borderColor = UIColor.blackColor().CGColor
        backView.layer.cornerRadius = 5
        backView.clipsToBounds = true
        
        self.view.backgroundColor = UIColor.clearColor()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        

        // Do any additional setup after loading the view.
    }
    
    func update(){
        let task = NSURLSession.sharedSession().dataTaskWithURL(lync!){(data,response,error) in
            if error == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    self.image.image = UIImage(data: data!)
                })
            }
        }
        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(){
        timer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)        
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.height == 320{
                backViewHeightConstraint.constant = 250
            }else if self.view.frame.size.height == 375{
                backViewHeightConstraint.constant = 300
            }else if self.view.frame.size.height == 414{
                backViewHeightConstraint.constant = 350
            }else{
                backViewHeightConstraint.constant = 400
            }
        }else{
            
            backViewHeightConstraint.constant = 400
            
        }
    }

}

extension CameraVC : UIViewControllerAnimatedTransitioning {
    
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

extension CameraVC : UIViewControllerTransitioningDelegate {
    
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
    func showCamera(point:CGPoint, lync:NSURL) {
        let ad = CameraVC(point: point, lync:lync)
        self.view.window?.rootViewController?.presentViewController(ad, animated: true, completion: nil)
    }
}
