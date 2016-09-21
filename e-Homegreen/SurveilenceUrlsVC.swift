//
//  SurveilenceUrlsVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 11/26/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SurveilenceUrlsVC: UIViewController {
    
    var getImage = "/dms?nowprofileid=2"
    var moveRight = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=right&amp;panstep=1&amp;tiltstep=15"
    var moveLeft = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=left&amp;panstep=1&amp;tiltstep=15"
    var moveUp = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=up&amp;panstep=1&amp;tiltstep=15"
    var moveDown = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=down&amp;panstep=1&amp;tiltstep=15"
    var autoPan = "/cgi-bin/longcctvapn.cgi?action=go&speed=1"
    var stopAutoPan = "/cgi-bin/longcctvapn.cgi?action=stop"
    var presetSequence = "/cgi-bin/longcctvseq.cgi?action=go"
    var stopPresetSequence = "/cgi-bin/longcctvseq.cgi?action=stop"
    var home = "/cgi-bin/longcctvhome.cgi?action=gohome"
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    
    var isPresenting: Bool = true
    
    var surv:Surveillance?
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var txtGetImage: UITextField!
    @IBOutlet weak var txtMoveLeft: UITextField!
    @IBOutlet weak var txtMoveRight: UITextField!
    @IBOutlet weak var txtMoveUp: UITextField!
    @IBOutlet weak var txtMoveDown: UITextField!
    @IBOutlet weak var txtAutoPan: UITextField!
    @IBOutlet weak var txtStopAutoPan: UITextField!
    @IBOutlet weak var txtPresetSequence: UITextField!
    @IBOutlet weak var txtStopPresetSequence: UITextField!
    @IBOutlet weak var txtHome: UITextField!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    @IBOutlet weak var scroll: UIScrollView!
    
    init(point:CGPoint, surv:Surveillance){
        super.init(nibName: "SurveilenceUrlsVC", bundle: nil)
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
        
        txtGetImage.delegate = self
        txtMoveLeft.delegate = self
        txtMoveRight.delegate = self
        txtMoveUp.delegate = self
        txtMoveDown.delegate = self
        txtAutoPan.delegate = self
        txtStopAutoPan.delegate = self
        txtPresetSequence.delegate = self
        txtStopPresetSequence.delegate = self
        txtHome.delegate = self
        
        txtGetImage.placeholder = getImage
        txtMoveLeft.placeholder = moveLeft
        txtMoveRight.placeholder = moveRight
        txtMoveUp.placeholder = moveUp
        txtMoveDown.placeholder = moveDown
        txtAutoPan.placeholder = autoPan
        txtStopAutoPan.placeholder = stopAutoPan
        txtPresetSequence.placeholder = presetSequence
        txtStopPresetSequence.placeholder = stopPresetSequence
        txtHome.placeholder = home
        
        txtGetImage.text = surv!.urlGetImage
        txtMoveLeft.text = surv!.urlMoveLeft
        txtMoveRight.text = surv!.urlMoveRight
        txtMoveUp.text = surv!.urlMoveUp
        txtMoveDown.text = surv!.urlMoveDown
        txtAutoPan.text = surv!.urlAutoPan
        txtStopAutoPan.text = surv!.urlAutoPanStop
        txtPresetSequence.text = surv!.urlPresetSequence
        txtStopPresetSequence.text = surv!.urlPresetSequenceStop
        txtHome.text = surv!.urlHome
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SurveilenceUrlsVC.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveilenceUrlsVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveilenceUrlsVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if txtGetImage.text != "" {surv!.urlGetImage! = txtGetImage.text!}
        if txtMoveRight.text != "" {surv!.urlMoveRight! = txtMoveRight.text!}
        if txtMoveLeft.text != "" {surv!.urlMoveLeft! = txtMoveLeft.text!}
        if txtMoveUp.text != "" {surv!.urlMoveUp! = txtMoveUp.text!}
        if txtMoveDown.text != "" {surv!.urlMoveDown! = txtMoveDown.text!}
        if txtAutoPan.text != "" {surv!.urlAutoPan! = txtAutoPan.text!}
        if txtStopAutoPan.text != "" {surv!.urlAutoPanStop! = txtStopAutoPan.text!}
        if txtPresetSequence.text != "" {surv!.urlPresetSequence! = txtPresetSequence.text!}
        if txtStopPresetSequence.text != "" {surv!.urlPresetSequenceStop! = txtStopPresetSequence.text!}
        if txtHome.text != "" {surv!.urlHome! = txtHome.text!}
        CoreDataController.shahredInstance.saveChanges()
        
        resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if txtMoveRight.isFirstResponder(){
            if backView.frame.origin.y + txtMoveRight.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtMoveRight.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtMoveUp.isFirstResponder(){
            if backView.frame.origin.y + txtMoveUp.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtMoveUp.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtMoveDown.isFirstResponder(){
            if backView.frame.origin.y + txtMoveDown.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtMoveDown.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtAutoPan.isFirstResponder(){
            if backView.frame.origin.y + txtAutoPan.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtAutoPan.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtStopAutoPan.isFirstResponder(){
            if backView.frame.origin.y + txtStopAutoPan.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtStopAutoPan.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtPresetSequence.isFirstResponder(){
            if backView.frame.origin.y + txtPresetSequence.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtPresetSequence.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtStopPresetSequence.isFirstResponder(){
            if backView.frame.origin.y + txtStopPresetSequence.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtStopPresetSequence.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtHome.isFirstResponder(){
            if backView.frame.origin.y + txtHome.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtHome.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.centerY.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }


}

extension SurveilenceUrlsVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if txtGetImage.isFirstResponder(){
            txtMoveLeft.becomeFirstResponder()
        }else if txtMoveLeft.isFirstResponder(){
            txtMoveRight.becomeFirstResponder()
        }else if txtMoveRight.isFirstResponder(){
            txtMoveUp.becomeFirstResponder()
        }else if txtMoveUp.isFirstResponder(){
            txtMoveDown.becomeFirstResponder()
        }else if txtMoveDown.isFirstResponder(){
            txtAutoPan.becomeFirstResponder()
        }else if txtAutoPan.isFirstResponder(){
            txtStopAutoPan.becomeFirstResponder()
        }else if txtStopAutoPan.isFirstResponder(){
            txtPresetSequence.becomeFirstResponder()
        }else if txtPresetSequence.isFirstResponder(){
            txtStopPresetSequence.becomeFirstResponder()
        }else if txtStopPresetSequence.isFirstResponder(){
            txtHome.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
}

extension SurveilenceUrlsVC : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            dismissKeyboard()
            return false
        }
        return true
    }
}

extension SurveilenceUrlsVC : UIViewControllerAnimatedTransitioning {
    
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

extension SurveilenceUrlsVC : UIViewControllerTransitioningDelegate {
    
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
    func showCameraUrls (point:CGPoint, surveillance:Surveillance) {
        let scu = SurveilenceUrlsVC(point: point, surv: surveillance)
        self.presentViewController(scu, animated: true, completion: nil)
    }
}
