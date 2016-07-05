//
//  LogInViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var userNameTextField: LogInTextField!
    @IBOutlet weak var passwordTextField: LogInTextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var appDel:AppDelegate!
    
    var users:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        tableView.layer.borderWidth = 1
        tableView.hidden = true
        
        userNameTextField.delegate = self
        
        users = DatabaseUserController.shared.getUserForDropDownMenu()

        let tap = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.dismissKeyboard))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(){
        tableView.hidden = true
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(tableView){
            return false
        }
        return true
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
                let settings = Menu.Settings.controller
                sideMenu.setFrontViewController(settings, animated: true)
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
                    var controller:UINavigationController = Menu.Settings.controller
                    if user.openLastScreen.boolValue == true{
                        if let id = user.lastScreenId as? Int, let menu = Menu(rawValue: id) {
                            controller = menu.controller
                        }
                    }
                    
                    sideMenu.setFrontViewController(controller, animated: true)
                    self.presentViewController(sideMenu, animated: true, completion: nil)
                }else{
                    self.view.makeToast(message: "Error")
                }
            }else{
                self.view.makeToast(message: "Check username or password")
            }
        }
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        tableView.hidden = false
    }
    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
//        passwordTextField.resignFirstResponder()
//        tableView.hidden = false
//        return false
//    }

}

extension LogInViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "defaultCell")
        cell.textLabel?.text = users[indexPath.row].username
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        userNameTextField.text = cell?.textLabel?.text
        self.dismissKeyboard()
        tableView.hidden = true
    }
}
