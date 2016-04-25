//
//  LogInViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: LogInTextField!
    @IBOutlet weak var passwordTextField: LogInTextField!
    
    var appDel:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInAction(sender: AnyObject) {
        guard let username = userNameTextField.text where username != "", let password = passwordTextField.text where password != "" else{
            self.view.makeToast(message: "All fields must be filled")
            return
        }
        
        if let admin = AdminController.shared.getAdmin() where admin.username == username && admin.password == password {
            
            AdminController.shared.loginAdmin()
            
            if AdminController.shared.isAdminLogged(){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let sideMenu = storyboard.instantiateViewControllerWithIdentifier("SideMenu") as! SWRevealViewController
                self.presentViewController(sideMenu, animated: true, completion: nil)
            }else{
                self.view.makeToast(message: "Something wrong, try again!")
                return
            }
            
        }else{
            if let user = DatabaseUserController.shared.getUser(username, password: password){
                DatabaseUserController.shared.loginUser()
                if DatabaseUserController.shared.setUser(user.objectID.URIRepresentation().absoluteString){
                    
                    DatabaseLocationController.shared.startMonitoringAllLocationByUser(user)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let sideMenu = storyboard.instantiateViewControllerWithIdentifier("SideMenu") as! SWRevealViewController
                    self.presentViewController(sideMenu, animated: true, completion: nil)
                }else{
                    self.view.makeToast(message: "Error")
                }
            }else{
                self.view.makeToast(message: "Check username or password")
            }
        }
        
    }
    


}
