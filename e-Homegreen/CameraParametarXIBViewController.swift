//
//  CameraParametarXIBViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/2/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class CameraParametarXIBViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    
    var isPresenting: Bool = true
    
    var surv:Surveillance!
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var panStepSlider: UISlider!
    @IBOutlet weak var tiltStepSlider: UISlider!
    @IBOutlet weak var autoPanStepSlider: UISlider!
    @IBOutlet weak var dwellTimeSlider: UISlider!
    
    @IBOutlet weak var panStepLabel: UILabel!
    @IBOutlet weak var tiltStepLabel: UILabel!
    @IBOutlet weak var autoPanStepLabel: UILabel!
    @IBOutlet weak var dwellTimeLabel: UILabel!
    
    init(point:CGPoint, surv:Surveillance){
        super.init(nibName: "CameraParametarXIBViewController", bundle: nil)
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
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.view.backgroundColor = UIColor.clearColor()
        
        panStepSlider.addTarget(self, action: #selector(CameraParametarXIBViewController.changePanStep(_:)), forControlEvents: .ValueChanged)
        tiltStepSlider.addTarget(self, action: #selector(CameraParametarXIBViewController.changeTiltStep(_:)), forControlEvents: .ValueChanged)
        autoPanStepSlider.addTarget(self, action: #selector(CameraParametarXIBViewController.changeAutoPanStep(_:)), forControlEvents: .ValueChanged)
        dwellTimeSlider.addTarget(self, action: #selector(CameraParametarXIBViewController.changeDwellTimeSlider(_:)), forControlEvents: .ValueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraParametarXIBViewController.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        panStepSlider.value = Float(surv.panStep!)
        tiltStepSlider.value = Float(surv.tiltStep!)
        autoPanStepSlider.value = Float(surv.autSpanStep!)
        dwellTimeSlider.value = Float(surv.dwellTime!)
        
        panStepLabel.text = "\(panStepSlider.value)"
        tiltStepLabel.text = "\(tiltStepSlider.value)"
        autoPanStepLabel.text = "\(autoPanStepSlider.value)"
        dwellTimeLabel.text = "\(dwellTimeSlider.value)"

        // Do any additional setup after loading the view.
    }
    
    func changePanStep(slider: UISlider){
        slider.value = round(slider.value)
        panStepLabel.text = "\(round(slider.value))"
    }
    
    func changeTiltStep(slider: UISlider){
        slider.value = round(slider.value)
        tiltStepLabel.text = "\(round(slider.value))"
    }
    
    func changeAutoPanStep(slider: UISlider){
        slider.value = round(slider.value)
        autoPanStepLabel.text = "\(round(slider.value))"
    }
    
    func changeDwellTimeSlider(slider: UISlider){
        slider.value = round(slider.value)
        dwellTimeLabel.text = "\(round(slider.value))"
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        
        surv!.panStep = panStepSlider.value
        surv!.tiltStep = tiltStepSlider.value
        surv!.autSpanStep = autoPanStepSlider.value
        surv!.dwellTime = dwellTimeSlider.value
        CoreDataController.shahredInstance.saveChanges()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension CameraParametarXIBViewController : UIViewControllerAnimatedTransitioning {
    
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
            containerView.addSubview(presentedControllerView)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
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
                
                presentedControllerView.center = self.point!
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension CameraParametarXIBViewController : UIViewControllerTransitioningDelegate {
    
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
    func showCameraParametar(point:CGPoint, surveillance:Surveillance) {
        let sp = CameraParametarXIBViewController(point: point, surv: surveillance)
        self.presentViewController(sp, animated: true, completion: nil)
    }
}
