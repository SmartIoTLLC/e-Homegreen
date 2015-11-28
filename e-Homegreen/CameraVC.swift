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
    
    
    @IBOutlet weak var leftButton: LeftCustomButtom!
    @IBOutlet weak var rightButton: CustomButton!
    @IBOutlet weak var topButton: TopButton!
    @IBOutlet weak var bottomButtom: BottomButton!
    @IBOutlet weak var btnAutoPan: CustomGradientButtonWhite!
    @IBOutlet weak var btnhome: CustomGradientButtonWhite!
    @IBOutlet weak var btnPresetSequence: CustomGradientButtonWhite!
    
    var isAutoPanStop = false
    var isPresetSequenceStop = false
    
    var surv:Surveilence!
    var point:CGPoint?
    var oldPoint:CGPoint?
    
    var moveCam:MoveCameraHandler = MoveCameraHandler()
    
    var isPresenting: Bool = true
    
    var timer:NSTimer = NSTimer()
    
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    
    init(point:CGPoint, surv:Surveilence){
        super.init(nibName: "CameraVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
        self.surv = surv
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

        // Do any additional setup after loading the view.
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            print("vodoravno")
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func exitButton(sender: AnyObject) {
        timer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//    @IBAction func btnAutoSpan(sender: AnyObject) {
//        moveCam.autoSpan(surv)
//    }
//    
//    @IBAction func btnStop(sender: AnyObject) {
//        moveCam.stop(surv)
//    }
//    
//    @IBAction func btnPresetSequence(sender: AnyObject) {
//        moveCam.presetSequence(surv)
//    }
    
    @IBAction func btnAutoPan(sender: AnyObject) {
        var title = ""
        if isAutoPanStop { title = "AUTO PAN" } else { title = "STOP" }
        btnAutoPan.setTitle(title, forState: .Normal)
        moveCam.autoPan(surv, isStopNecessary: isAutoPanStop)
        isAutoPanStop = !isAutoPanStop
    }
    
    @IBAction func btnHome(sender: AnyObject) {
//        moveCam.stop(surv)
        moveCam.home(surv)
    }
    
    @IBAction func btnPresetSequence(sender: AnyObject) {
        var title = ""
        if isPresetSequenceStop { title = "PRESET SEQUENCE" } else { title = "STOP" }
        isPresetSequenceStop = !isPresetSequenceStop
        btnPresetSequence.setTitle(title, forState: .Normal)
        moveCam.presetSequence(surv, isStopNecessary: isPresetSequenceStop)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    
    func update(){
        if surv.imageData != nil{
            self.image.image = UIImage(data: surv.imageData!)
        }else{
            self.image.image = UIImage(named: "loading")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftButtomAction(sender: AnyObject) {
        moveCam.moveCamera(surv, position: "left")
    }
    
    @IBAction func rightButtomAction(sender: AnyObject) {
        moveCam.moveCamera(surv, position: "right")
    }
    
    @IBAction func topButtomAction(sender: AnyObject) {
        moveCam.moveCamera(surv, position: "up")
    }
    
    @IBAction func bottomButtomAction(sender: AnyObject) {
        moveCam.moveCamera(surv, position: "down")
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
    func showCamera(point:CGPoint, surv:Surveilence) {
        let ad = CameraVC(point: point, surv:surv)
        self.view.window?.rootViewController?.presentViewController(ad, animated: true, completion: nil)
    }
}

