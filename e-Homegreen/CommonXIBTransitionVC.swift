//
//  CommonXIBTransitionVC.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 8/29/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class CommonXIBTransitionVC: UIViewController {
    
    var isPresenting: Bool = true        
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnView(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapOnView(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }

}

extension CommonXIBTransitionVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}



extension CommonXIBTransitionVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.5, scaleOneY: 1.5, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)
    }
}

extension CommonXIBTransitionVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
