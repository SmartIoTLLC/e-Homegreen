//
//  ClimaSettingsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ClimaSettingsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var message: String = ""
    var isPresenting: Bool = true
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffButton: UIButton!
    
    //Mode button
    @IBOutlet weak var btnCool: UIButton!
    @IBOutlet weak var btnHeat: UIButton!
    @IBOutlet weak var btnFan: UIButton!
    @IBOutlet weak var btnAuto: UIButton!
    
    //Fan button
    @IBOutlet weak var btnLow: UIButton!
    @IBOutlet weak var btnMed: UIButton!
    @IBOutlet weak var btnHigh: UIButton!
    @IBOutlet weak var btnAutoFan: UIButton!
    

    @IBOutlet weak var settingsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.view.tag = 1
        
        btnModeSetUp()
        btnFanSetUp()
        
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = settingsView.bounds
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
        settingsView.layer.insertSublayer(gradient, atIndex: 0)
        settingsView.layer.borderWidth = 1
        settingsView.layer.borderColor = UIColor.lightGrayColor().CGColor
        settingsView.layer.cornerRadius = 10
        settingsView.clipsToBounds = true
        
        onOffButton.layer.cornerRadius = 20
        onOffButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    
    var gradientLayerForButon:CAGradientLayer = CAGradientLayer()
    var gradientLayerForButon1:CAGradientLayer = CAGradientLayer()
    var gradientLayerForButon2:CAGradientLayer = CAGradientLayer()
    var gradientLayerForButon3:CAGradientLayer = CAGradientLayer()
    
    func btnModeSetUp(){
        
//        var gradientLayerForButon:CAGradientLayer = CAGradientLayer()
        gradientLayerForButon.frame = btnCool.bounds
        gradientLayerForButon.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnCool.layer.insertSublayer(gradientLayerForButon, atIndex: 0)
        btnCool.layer.cornerRadius = 5
        btnCool.layer.borderWidth = 1
        btnCool.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnCool.clipsToBounds = true
        btnCool.setImage(UIImage(named: "cool"), forState: .Normal)
        btnCool.imageEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 1)
        btnCool.setTitle("COOL", forState: .Normal)
        btnCool.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        
//        var gradientLayerForButon1:CAGradientLayer = CAGradientLayer()
        gradientLayerForButon1.frame = btnCool.bounds
        gradientLayerForButon1.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnHeat.layer.insertSublayer(gradientLayerForButon1, atIndex: 0)
        btnHeat.layer.cornerRadius = 5
        btnHeat.layer.borderWidth = 1
        btnHeat.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnHeat.clipsToBounds = true
        btnHeat.setImage(UIImage(named: "heat"), forState: .Normal)
        btnHeat.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnHeat.setTitle("HEAT", forState: .Normal)
        btnHeat.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        
//        var gradientLayerForButon2:CAGradientLayer = CAGradientLayer()
        gradientLayerForButon2.frame = btnCool.bounds
        gradientLayerForButon2.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnFan.layer.insertSublayer(gradientLayerForButon2, atIndex: 0)
        btnFan.layer.cornerRadius = 5
        btnFan.layer.borderWidth = 1
        btnFan.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnFan.clipsToBounds = true
        btnFan.setImage(UIImage(named: "fan"), forState: .Normal)
        btnFan.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnFan.setTitle("FAN", forState: .Normal)
        btnFan.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        
        
        gradientLayerForButon3.frame = btnCool.bounds
        gradientLayerForButon3.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnAuto.layer.insertSublayer(gradientLayerForButon3, atIndex: 0)
        btnAuto.layer.cornerRadius = 5
        btnAuto.layer.borderWidth = 1
        btnAuto.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnAuto.clipsToBounds = true
        btnAuto.setImage(UIImage(named: "fanauto"), forState: .Normal)
        btnAuto.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnAuto.setTitle("AUTO", forState: .Normal)
        btnAuto.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        
    }
    func btnFanSetUp(){
        
        var gradientLayerForFan:CAGradientLayer = CAGradientLayer()
        gradientLayerForFan.frame = btnCool.bounds
        gradientLayerForFan.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnLow.layer.insertSublayer(gradientLayerForFan, atIndex: 0)
        btnLow.layer.cornerRadius = 5
        btnLow.layer.borderWidth = 1
        btnLow.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnLow.clipsToBounds = true
        btnLow.setImage(UIImage(named: "lowfan"), forState: .Normal)
        btnLow.imageEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 1)
        btnLow.setTitle("LOW", forState: .Normal)
        btnLow.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        
        var gradientLayerForFan1:CAGradientLayer = CAGradientLayer()
        gradientLayerForFan1.frame = btnCool.bounds
        gradientLayerForFan1.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnMed.layer.insertSublayer(gradientLayerForFan1, atIndex: 0)
        btnMed.layer.cornerRadius = 5
        btnMed.layer.borderWidth = 1
        btnMed.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnMed.clipsToBounds = true
        btnMed.setImage(UIImage(named: "medfan"), forState: .Normal)
        btnMed.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnMed.setTitle("MED", forState: .Normal)
        btnMed.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        
        var gradientLayerForFan2:CAGradientLayer = CAGradientLayer()
        gradientLayerForFan2.frame = btnCool.bounds
        gradientLayerForFan2.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnHigh.layer.insertSublayer(gradientLayerForFan2, atIndex: 0)
        btnHigh.layer.cornerRadius = 5
        btnHigh.layer.borderWidth = 1
        btnHigh.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnHigh.clipsToBounds = true
        btnHigh.setImage(UIImage(named: "fan"), forState: .Normal)
        btnHigh.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnHigh.setTitle("FAN", forState: .Normal)
        btnHigh.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        
        var gradientLayerForFan3:CAGradientLayer = CAGradientLayer()
        gradientLayerForFan3.frame = btnCool.bounds
        gradientLayerForFan3.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnAutoFan.layer.insertSublayer(gradientLayerForFan3, atIndex: 0)
        btnAutoFan.layer.cornerRadius = 5
        btnAutoFan.layer.borderWidth = 1
        btnAutoFan.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnAutoFan.clipsToBounds = true
        btnAutoFan.setImage(UIImage(named: "fanauto"), forState: .Normal)
        btnAutoFan.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnAutoFan.setTitle("AUTO", forState: .Normal)
        btnAutoFan.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        
    }
    
    func removeLayers(){
        btnCool.backgroundColor = UIColor.clearColor()
        btnHeat.backgroundColor = UIColor.clearColor()
        btnFan.backgroundColor = UIColor.clearColor()
        btnAuto.backgroundColor = UIColor.clearColor()
        gradientLayerForButon.removeFromSuperlayer()
        gradientLayerForButon1.removeFromSuperlayer()
        gradientLayerForButon2.removeFromSuperlayer()
        gradientLayerForButon3.removeFromSuperlayer()
    }

    
    @IBAction func btnModePressed(sender: UIButton) {
//        removeLayers()
//        btnModeSetUp()
//        sender.backgroundColor = UIColor.grayColor()
        
    }
    

    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func handleTap(gesture:UITapGestureRecognizer){
        var point:CGPoint = gesture.locationInView(self.view)
        var tappedView:UIView = self.view.hitTest(point, withEvent: nil)!
        println(tappedView.tag)
        if tappedView.tag == 1{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func onOff(sender: AnyObject) {
    }
    
    
    init(){
        super.init(nibName: "ClimaSettingsViewController", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension ClimaSettingsViewController : UIViewControllerAnimatedTransitioning {
    
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

extension ClimaSettingsViewController : UIViewControllerTransitioningDelegate {
    
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
    
    func showClimaSettings(message: String) {
        var ad = ClimaSettingsViewController()
        ad.message = message
        presentViewController(ad, animated: true, completion: nil)
    }
}
