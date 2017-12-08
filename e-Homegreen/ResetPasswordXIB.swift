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
        
        oldPassswordTextField.delegate    = self
        newPasswordTextField.delegate     = self
        confirmPasswordTextField.delegate = self

    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { dismissEditing(); return false }
        return true
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        if !AdminController.shared.isAdminLogged() {
            guard let oldPass = oldPassswordTextField.text , oldPass != "" else { self.view.makeToast(message: "All fields must be filled"); return }
            
            if oldPass != user.password { self.view.makeToast(message: "Your old password is not correct"); return }
        }
        
        guard let newPass = newPasswordTextField.text , newPass != "", let confirmPass = confirmPasswordTextField.text , confirmPass != "" else {
            self.view.makeToast(message: "All fields must be filled")
            return
        }

        
        if newPass != confirmPass { self.view.makeToast(message: "Passwords do not match"); return }
        
        user.password = newPass
        self.dismiss(animated: true, completion: nil)
        delegate?.resetPasswordFinished()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ResetPasswordXIB : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension UIViewController {
    func showResetPassword(_ user:User) -> ResetPasswordXIB{
        let ressetPass = ResetPasswordXIB(user: user)
        self.present(ressetPass, animated: true, completion: nil)
        return ressetPass
    }
}
