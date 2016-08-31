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

class ResetPasswordXIB: CommonXIBTransitionVC {
    
    @IBOutlet weak var oldPasswordLabel: UILabel!
    
    @IBOutlet weak var oldPassswordTextField: EditTextField!
    @IBOutlet weak var newPasswordTextField: EditTextField!
    @IBOutlet weak var confirmPasswordTextField: EditTextField!
    
    @IBOutlet weak var cancelButon: CustomGradientButtonWhite!
    @IBOutlet weak var saveButton: CustomGradientButtonWhite!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    
    var user:User!
    
    var delegate:SettingsDelegate?
    
    init(user:User){
        super.init(nibName: "ResetPasswordXIB", bundle: nil)
        
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oldPassswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        if !AdminController.shared.isAdminLogged(){
//            topConstraint.constant = 73
        }else{
//            topConstraint.constant = 8
//            oldPasswordLabel.hidden = true
//            oldPassswordTextField.hidden = true
        }

    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            self.view.endEditing(true)
            return false
        }
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

extension ResetPasswordXIB : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension UIViewController {
    func showResetPassword(user:User) -> ResetPasswordXIB{
        let ressetPass = ResetPasswordXIB(user: user)
        self.presentViewController(ressetPass, animated: true, completion: nil)
        return ressetPass
    }
}
