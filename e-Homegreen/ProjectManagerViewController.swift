//
//  ProjectManagerViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/23/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ProjectManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddUserDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var appDel:AppDelegate!
    var users:[User] = []
    var sidebarMenuOpen : Bool!
    var tap : UITapGestureRecognizer!
    
    @IBOutlet weak var addButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
                revealViewController().rearViewRevealWidth = 200
            }else{
                revealViewController().rearViewRevealWidth = 200
            }
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(ProjectManagerViewController.closeSideMenu))

        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if NSUserDefaults.standardUserDefaults().boolForKey(Admin.IsLogged) == false {
            addButton.hidden = true
        }
        
        updateUserList()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addUser(sender: AnyObject) {
        showAddUser(nil).delegate = self
    }
    
    @IBAction func changeDataBase(sender: AnyObject) {
        
    }
    
    @IBAction func editDataBase(sender: AnyObject) {
        if let button = sender as? UIButton{
            performSegueWithIdentifier("settings", sender: button)
        }
    }
    
    @IBAction func deleteUser(sender: AnyObject) {
        if let button = sender as? UIButton{
            let optionMenu = UIAlertController(title: nil, message: "Delete user?", preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.appDel.managedObjectContext?.deleteObject(self.users[button.tag])
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.reloadData()
                })
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settings"{
            if let button = sender as? UIButton{
                if let vc = segue.destinationViewController as? SettingsViewController{
                    vc.user = users[button.tag]
                }
            }
        }
    }
    
    func addUserFinished() {
        reloadData()
    }
    
    func reloadData(){
        updateUserList()
        usersTableView.reloadData()
    }
    
    func updateUserList () {
        users = []
        let fetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptorOne = NSSortDescriptor(key: "username", ascending: true)
        //        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        //        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne]
        //        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        //        var predicateArray:[NSPredicate] = [predicateOne]
        
        //        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        //        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [User]
            users = fetResults!
        } catch  {
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as? UserCell{
            cell.editDatabaseButton.tag = indexPath.row
            cell.deleteUser.tag = indexPath.row
            cell.shareUser.tag = indexPath.row
            print(indexPath.row)
            cell.setItem(users[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(sidebarMenuOpen == true){
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(),{
            self.showAddUser(self.users[indexPath.row]).delegate = self
        })
    }
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            usersTableView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            usersTableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        
        if(position == FrontViewPosition.Left) {
            usersTableView.userInteractionEnabled = true
            sidebarMenuOpen = false
            self.view.removeGestureRecognizer(tap)
        } else {
            self.view.addGestureRecognizer(tap)
            usersTableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }
    
    
}

class UserCell: UITableViewCell{
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDataBaseNameLabel: UILabel!
    @IBOutlet weak var chooseDatabaseButton: UIButton!
    @IBOutlet weak var editDatabaseButton: UIButton!
    @IBOutlet weak var deleteUser: UIButton!
    @IBOutlet weak var shareUser: UIButton!
    
    func setItem(user:User){
        userNameLabel.text = user.username
        if let data = user.profilePicture{
            userImage.image = UIImage(data: data)
        }else{
            userImage.image = UIImage(named: "User")
        }
    }
    
}
