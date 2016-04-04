//
//  LogInViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class LogInViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: LogInTextField!
    @IBOutlet weak var passwordTextField: LogInTextField!
    
    var appDel:AppDelegate!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
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
        
        if let adminUsername = prefs.stringForKey(Admin.Username) where adminUsername == username, let adminPassword = prefs.stringForKey(Admin.Password) where adminPassword == password{
            
            prefs.setValue(true, forKey: Admin.IsLogged)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let sideMenu = storyboard.instantiateViewControllerWithIdentifier("SideMenu") as! SWRevealViewController
            self.presentViewController(sideMenu, animated: true, completion: nil)
            
        }else{
            if let user = updateUserList(username, password: password){
                prefs.setValue(true, forKey: Login.IsLoged)
                prefs.setValue(user.objectID.URIRepresentation().absoluteString, forKey: Login.User)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let sideMenu = storyboard.instantiateViewControllerWithIdentifier("SideMenu") as! SWRevealViewController
                self.presentViewController(sideMenu, animated: true, completion: nil)
            }else{
               self.view.makeToast(message: "Check username or password") 
            }
        }
        
    }
    
    func updateUserList (username:String, password:String) -> User? {
        let fetchRequest = NSFetchRequest(entityName: "User")
//        let sortDescriptorOne = NSSortDescriptor(key: "username", ascending: true)
        //        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        //        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptorOne]
        let predicateOne = NSPredicate(format: "username == %@", username)
        let predicateTwo = NSPredicate(format: "password == %@", password)
        let predicateArray:[NSPredicate] = [predicateOne, predicateTwo]
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [User]
            if fetResults?.count != 0{
                return fetResults?[0]
            }else{
                return nil
            }
            
            
        } catch  {
            
        }
        return nil
    }

}
