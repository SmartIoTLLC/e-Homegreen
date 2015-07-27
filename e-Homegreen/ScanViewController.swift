//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit

class ScanViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var rangeFrom: UITextField!
    @IBOutlet weak var rangeTo: UITextField!
    
    var isPresenting:Bool = true
    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        transitioningDelegate = self
//    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        var gradient:CAGradientLayer = CAGradientLayer()
        if self.view.frame.size.height > self.view.frame.size.width{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        }else{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        }
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func backButton(sender: UIStoryboardSegue) {
        
        self.performSegueWithIdentifier("scanUnwind", sender: self)
    }
    
    @IBAction func findDevice(sender: AnyObject) {
        
    }
    
    @IBAction func findNames(sender: AnyObject) {
        
    }
    
    @IBAction func deleteAll(sender: AnyObject) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("scanCell") as? ScanCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblDesc.text = "4564"
            return cell
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    
//    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
//        return 0.5
//    }
//    
//    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        if isPresenting == true{
//            isPresenting = false
//            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
//            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
//            let containerView = transitionContext.containerView()
//            
//            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
//            presentedControllerView.center.x += containerView.bounds.size.width
//            //            presentedControllerView.center.y += containerView.bounds.size.height
//            //            presentedControllerView.alpha = 0
//            //            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
//            containerView.addSubview(presentedControllerView)
//            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
//                presentedControllerView.center.x -= containerView.bounds.size.width
//                //                presentedControllerView.center.y -= containerView.bounds.size.height
//                //                presentedControllerView.alpha = 1
//                //                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
//                }, completion: {(completed: Bool) -> Void in
//                    transitionContext.completeTransition(completed)
//            })
//        }else{
//            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
//            let containerView = transitionContext.containerView()
//            
//            // Animate the presented view off the bottom of the view
//            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
//                presentedControllerView.center.x += containerView.bounds.size.width
//                //                presentedControllerView.center.y += containerView.bounds.size.height
//                //                presentedControllerView.alpha = 0
//                //                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
//                }, completion: {(completed: Bool) -> Void in
//                    transitionContext.completeTransition(completed)
//            })
//        }
//    }
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




}

class ScanCell:UITableViewCell{
    
    @IBOutlet weak var lblDesc: UILabel!
    
}
