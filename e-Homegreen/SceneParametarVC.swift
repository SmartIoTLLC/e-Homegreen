//
//  SceneParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/14/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SceneParametarVC: UIViewController, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    var scene:Scene?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var isBroadcast: UISwitch!
    @IBOutlet weak var isLocalcast: UISwitch!
    
    var isPresenting: Bool = true
    
    init(point:CGPoint){
        super.init(nibName: "SceneParametarVC", bundle: nil)
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
        isBroadcast.tag = 100
        isBroadcast.on = scene!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        isLocalcast.tag = 200
        isLocalcast.on = scene!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if isBroadcast.on {
            scene?.isBroadcast = true
        } else {
            scene?.isBroadcast = false
        }
        if isLocalcast.on {
            scene?.isLocalcast = true
        } else {
            scene?.isLocalcast = false
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshScene, object: self, userInfo: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
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

extension SceneParametarVC : UIViewControllerAnimatedTransitioning {
    
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

extension SceneParametarVC : UIViewControllerTransitioningDelegate {
    
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
    func showSceneParametar(point:CGPoint, scene:Scene) {
        let sp = SceneParametarVC(point: point)
//        ad.indexPathRow = indexPathRow
        sp.scene = scene
        self.view.window?.rootViewController?.presentViewController(sp, animated: true, completion: nil)
    }
}