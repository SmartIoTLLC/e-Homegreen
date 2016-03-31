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
    
    let prefs = NSUserDefaults.standardUserDefaults()

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createAdmin(sender: AnyObject) {
        guard let username = userNameTextField.text where username != "", let password = passwordTextField.text where password != "", let confirmPass = confirmPasswordTextField.text where confirmPass != "" else{
            return
        }
        guard confirmPass == password else {
            return
        }
        
        prefs.setValue(username, forKey: Admin.Username)
        prefs.setValue(password, forKey: Admin.Password)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sideMenu = storyboard.instantiateViewControllerWithIdentifier("SideMenu") as! SWRevealViewController
        self.presentViewController(sideMenu, animated: true, completion: nil)

        
    }

}