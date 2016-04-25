//
//  CreateAdminViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/22/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class CreateAdminViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: LogInTextField!
    @IBOutlet weak var passwordTextField: LogInTextField!
    @IBOutlet weak var confirmPasswordTextField: LogInTextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func createAdmin(sender: AnyObject) {
        guard let username = userNameTextField.text where username != "", let password = passwordTextField.text where password != "", let confirmPass = confirmPasswordTextField.text where confirmPass != "" else{
            self.view.makeToast(message: "All fields must be filled")
            return
        }
        guard confirmPass == password else {
            self.view.makeToast(message: "Passwords do not match")
            return
        }
        
        if AdminController.shared.setAdmin(username, password: password) == false{
            self.view.makeToast(message: "Something wrong, try again!")
            return
        }

        AdminController.shared.loginAdmin()
        
        if AdminController.shared.isAdminLogged(){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let sideMenu = storyboard.instantiateViewControllerWithIdentifier("SideMenu") as! SWRevealViewController
            self.presentViewController(sideMenu, animated: true, completion: nil)
        }else{
            self.view.makeToast(message: "Something wrong, try again!")
            return
        }
        
    }

}
