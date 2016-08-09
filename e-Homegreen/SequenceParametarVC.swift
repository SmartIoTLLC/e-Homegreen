//
//  SequenceParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/14/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SequenceParametarVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    var sequence:Sequence?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var cyclesTextField: UITextField!
    @IBOutlet weak var isBroadcast: UISwitch!
    @IBOutlet weak var isLocalcast: UISwitch!
    
    var isPresenting: Bool = true
    
    init(point:CGPoint){
        super.init(nibName: "SequenceParametarVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissViewController"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        cyclesTextField.text = "\(sequence!.sequenceCycles)"
        isBroadcast.tag = 100
        isBroadcast.on = sequence!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        isLocalcast.tag = 200
        isLocalcast.on = sequence!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        cyclesTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
//        if let cycles = Int(cyclesTextField.text!) {
//            sequence?.sequenceCycles = cycles
//            saveChanges()
//            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshSequence, object: self, userInfo: nil)
//        }
        return true
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            if sender.on == true {
                isLocalcast.on = false
            } else {
                isLocalcast.on = false
            }
        } else if sender.tag == 200 {
            if sender.on == true {
                isBroadcast.on = false
            } else {
                isBroadcast.on = false
            }
        }
    }
    
    func dismissViewController () {
//        if cyclesTextField.text != "" {
//            if let cycles = Int(cyclesTextField.text!) {
//                sequence?.sequenceCycles = cycles
//                saveChanges()
//            }
//        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnSave(sender: AnyObject) {
        if isBroadcast.on {
            sequence?.isBroadcast = true
        } else {
            sequence?.isBroadcast = false
        }
        if isLocalcast.on {
            sequence?.isLocalcast = true
        } else {
            sequence?.isLocalcast = false
        }
        if cyclesTextField.text != "" {
            if let cycles = Int(cyclesTextField.text!) {
                sequence?.sequenceCycles = cycles
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshSequence, object: self, userInfo: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
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

extension SequenceParametarVC : UIViewControllerAnimatedTransitioning {
    
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

extension SequenceParametarVC : UIViewControllerTransitioningDelegate {
    
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
    func showSequenceParametar(point:CGPoint, sequence:Sequence) {
        let sp = SequenceParametarVC(point: point)
//        ad.indexPathRow = indexPathRow
        sp.sequence = sequence
        self.view.window?.rootViewController?.presentViewController(sp, animated: true, completion: nil)
    }
}
