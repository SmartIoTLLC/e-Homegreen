//
//  ResetPasswordXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/18/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func resetPasswordFinished()
}

class ResetPasswordXIB: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var oldPasswordLabel: UILabel!
    
    @IBOutlet weak var oldPassswordTextField: EditTextField!
    @IBOutlet weak var newPasswordTextField: EditTextField!
    @IBOutlet weak var confirmPasswordTextField: EditTextField!
    
    @IBOutlet weak var cancelButon: CustomGradientButtonWhite!
    @IBOutlet weak var saveButton: CustomGradientButtonWhite!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    var isPresenting: Bool = true
    
    var user:User!
    
    var delegate:SettingsDelegate?
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    init(user:User){
        super.init(nibName: "ResetPasswordXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        oldPassswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ResetPasswordXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        if !AdminController.shared.isAdminLogged(){
            topConstraint.constant = 73
        }else{
            topConstraint.constant = 8
            oldPasswordLabel.hidden = true
            oldPassswordTextField.hidden = true
        }

        // Do any additional setup after loading the view.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        if !AdminController.shared.isAdminLogged(){
            guard let oldPass = oldPassswordTextField.text where oldPass != "" else{
                self.view.makeToast(message: "All fields must be filled")
                return
            }
            if oldPass != user.password{
                self.view.makeToast(message: "Your old password is not correct")
                return
            }
        }
        
        guard let newPass = newPasswordTextField.text where newPass != "", let confirmPass = confirmPasswordTextField.text where confirmPass != "" else{
            self.view.makeToast(message: "All fields must be filled")
            return
        }

        
        if newPass != confirmPass {
            self.view.makeToast(message: "Passwords do not match")
            return
        }
        
        user.password = newPass
        self.dismissViewControllerAnimated(true, completion: nil)
        delegate?.resetPasswordFinished()
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension ResetPasswordXIB : UIViewControllerAnimatedTransitioning {
    
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
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
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
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension ResetPasswordXIB : UIViewControllerTransitioningDelegate {
    
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
    func showResetPassword(user:User) -> ResetPasswordXIB{
        let ressetPass = ResetPasswordXIB(user: user)
        self.presentViewController(ressetPass, animated: true, completion: nil)
        return ressetPass
    }
}
