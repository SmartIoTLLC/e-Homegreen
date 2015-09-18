//
//  ProgressBarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ProgressBarVC: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblHowMuchOf: UILabel!

//    super.init(nib
    override init (nibName:String?, bundle:NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//
//extension DimmerParametarVC : UIViewControllerAnimatedTransitioning {
//    
//    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
//        return 0.5 //Add your own duration here
//    }
//    
//    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        //Add presentation and dismiss animation transition here.
//        if isPresenting == true{
//            isPresenting = false
//            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
//            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
//            let containerView = transitionContext.containerView()
//            
//            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
//            self.oldPoint = presentedControllerView.center
//            presentedControllerView.center = self.point!
//            presentedControllerView.alpha = 0
//            presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
//            containerView.addSubview(presentedControllerView)
//            
//            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
//                
//                presentedControllerView.center = self.oldPoint!
//                presentedControllerView.alpha = 1
//                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
//                
//                }, completion: {(completed: Bool) -> Void in
//                    transitionContext.completeTransition(completed)
//            })
//        }else{
//            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
//            let containerView = transitionContext.containerView()
//            
//            // Animate the presented view off the bottom of the view
//            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
//                
//                presentedControllerView.center = self.point!
//                presentedControllerView.alpha = 0
//                presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
//                
//                }, completion: {(completed: Bool) -> Void in
//                    transitionContext.completeTransition(completed)
//            })
//        }
//        
//    }
//}
//
//extension DimmerParametarVC : UIViewControllerTransitioningDelegate {
//    
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return self
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if dismissed == self {
//            return self
//        }
//        else {
//            return nil
//        }
//    }
//    
//}
//extension ProgressBarVC {
//    func abc () {
//        
//    }
//}
//extension UIViewController {
//    func showDimmerParametar(point:CGPoint, indexPathRow: Int, devices:[Device]) {
//        var ad = DimmerParametarVC(point: point)
//        ad.indexPathRow = indexPathRow
//        ad.devices = devices
//        self.view.window?.rootViewController?.presentViewController(ad, animated: true, completion: nil)
//    }
//}
