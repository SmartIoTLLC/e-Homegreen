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
    
    var users:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 5
        tableView.isHidden = true
        
        userNameTextField.delegate = self
        
        if let admin = AdminController.shared.getAdmin() { users.append(admin.username) }
        if let usersDB = DatabaseUserController.shared.getUserForDropDownMenu() {
            for user in usersDB {
                if user.username != nil {
                    users.append(user.username!)
                }
            }
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.dismissEditing))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    override func dismissEditing() {
        tableView.isHidden = true
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: tableView) { return false }
        return true
    }
    
    @IBAction func logInAction(_ sender: AnyObject) {
        guard let username = userNameTextField.text , username != "", let password = passwordTextField.text , password != "" else {
            view.makeToast(message: "All fields must be filled")
            return
        }
        
        if let admin = AdminController.shared.getAdmin() , admin.username == username && admin.password == password {
            
            AdminController.shared.loginAdmin()
            
            if AdminController.shared.isAdminLogged() {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let sideMenu = storyboard.instantiateViewController(withIdentifier: "SideMenu") as! SWRevealViewController
                let settings = Menu.settings.controller
                sideMenu.setFront(settings, animated: true)
                present(sideMenu, animated: true, completion: nil)
            } else {
                view.makeToast(message: "Something wrong, try again!")
                return
            }
            
        } else {
            if let user = DatabaseUserController.shared.getUser(username, password: password) {
                DatabaseUserController.shared.loginUser()
                if DatabaseUserController.shared.setUser(user.objectID.uriRepresentation().absoluteString) {
                    
                    DatabaseLocationController.shared.startMonitoringAllLocationByUser(user)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let sideMenu = storyboard.instantiateViewController(withIdentifier: "SideMenu") as! SWRevealViewController
                    var controller:UINavigationController = user.isSuperUser.boolValue ? Menu.settings.controller : Menu.notSuperUserSettings.controller
                    if user.openLastScreen.boolValue == true {
                        if let id = user.lastScreenId as? Int, let menu = Menu(rawValue: id) {
                            controller = menu.controller
                        }
                    }
                    
                    sideMenu.setFront(controller, animated: true)
                    self.present(sideMenu, animated: true, completion: nil)
                } else {
                    view.makeToast(message: "Error")
                }
            } else {
                view.makeToast(message: "Check username or password")
            }
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        tableView.isHidden = false
        return false
    }

}

extension LogInViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "defaultCell")
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        userNameTextField.text = cell?.textLabel?.text
        dismissEditing()
        tableView.isHidden = true
        passwordTextField.becomeFirstResponder()
    }
}
