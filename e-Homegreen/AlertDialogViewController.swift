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
    
    init(){
       super.init(nibName: "AlertDialogViewController", bundle: nil)
//        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.15)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}

//extension AlertDialogViewController : UIViewControllerAnimatedTransitioning {
//    
//    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
//        return 0.5 //Add your own duration here
//    }
//    
//    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        //Add presentation and dismiss animation transition here.
//    }
//}

//extension AlertDialogViewController : UIViewControllerTransitioningDelegate {
//    
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return self
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return self
//    }
//    
//}

extension UIViewController {
    
    func showAleartWithMessage(message: String) {
        var ad = AlertDialogViewController()
        ad.message = message
        presentViewController(ad, animated: true, completion: nil)
    }
}
