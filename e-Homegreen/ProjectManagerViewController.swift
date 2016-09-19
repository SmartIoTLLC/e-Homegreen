//
//  ProjectManagerViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/23/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import Foundation
import NSManagedObject_HYPPropertyMapper
import Zip

class ProjectManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddUserDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var appDel:AppDelegate!
    var users:[User] = []
    var sidebarMenuOpen : Bool = false
    var tap : UITapGestureRecognizer!
    
    
    
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
        usersTableView.tableFooterView = UIView()
        usersTableView.reloadData()
        
        changeFullScreeenImage()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(ProjectManagerViewController.closeSideMenu))

        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        UIView.hr_setToastThemeColor(color: UIColor.redColor())
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if !AdminController.shared.isAdminLogged() {
            addButton.hidden = true
        }
        
        users = DatabaseUserController.shared.getAllUsers()
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func fullScreen(sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        }
    }
    
    func changeFullScreeenImage(){
        if UIApplication.sharedApplication().statusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        }
    }

    @IBAction func addUser(sender: AnyObject) {
        showAddUser(nil).delegate = self
    }
    
    @IBAction func changeDataBase(sender: AnyObject) {
        if let button = sender as? UIButton{
            if AdminController.shared.setOtherUser(users[button.tag].objectID.URIRepresentation().absoluteString){
                self.view.makeToast(message: "\(users[button.tag].username!)'s database is in use!")
            }else{
                self.view.makeToast(message: "Error!!")
            }
        }
    }
    
    @IBAction func editDataBase(sender: AnyObject) {
        if let button = sender as? UIButton{
            performSegueWithIdentifier("settings", sender: button)
        }
    }
    
    @IBAction func deleteUser(sender: UIButton) {
        showAlertView(sender, message: "Delete user?") { (action) in
            if action == ReturnedValueFromAlertView.Delete{
                self.appDel.managedObjectContext?.deleteObject(self.users[sender.tag])
                if self.users[sender.tag].username == DatabaseUserController.shared.getOtherUser()?.username{
                    AdminController.shared.setOtherUser(nil)
                }
                self.reloadData()
            }
        }
    }
    
    @IBAction func shareUser(sender: UIButton) {
        
        let user = self.users[sender.tag]
        let user_value:NSDictionary = user.hyp_dictionaryUsingRelationshipType(HYPPropertyMapperRelationshipType.Array)
        
        write(user_value)
        
        print(user_value)

        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let jsonFilePath = documentsUrl.URLByAppendingPathComponent("archive.zip")
        
        let activityViewController = UIActivityViewController(activityItems: [jsonFilePath], applicationActivities: nil)
        if let presentationController = activityViewController.popoverPresentationController {
            presentationController.sourceView = sender
            presentationController.sourceRect = sender.bounds
        }
        
        self.presentViewController(activityViewController, animated: true, completion: nil)

        
    }
    
    func write(userData:NSDictionary){
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        
        let jsonFilePath = documentsDirectoryPath.URLByAppendingPathComponent("test.json")
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        
        // creating a .json file in the Documents folder
        if !fileManager.fileExistsAtPath(jsonFilePath.absoluteString, isDirectory: &isDirectory) {
            let created = fileManager.createFileAtPath(jsonFilePath.absoluteString, contents: nil, attributes: nil)
            if created {
                print("File created ")
            } else {
                print("Couldn't create file for some reason")
            }
        } else {
            print("File already exists")
        }
        
        var data:NSData? = NSKeyedArchiver.archivedDataWithRootObject(userData)
        if let data = data{
            data.writeToFile(jsonFilePath.path!, atomically: true)
        }
        
        do {
            let zipFilePath = documentsDirectoryPath.URLByAppendingPathComponent("archive.zip")
            try Zip.zipFiles([jsonFilePath], zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                print(progress)
            })
        }
        catch {
            print("Something went wrong")
        }
        
        do {
            try fileManager.removeItemAtPath(jsonFilePath.path!)
        } catch let error as NSError {
            print("ERROR: \(error)")
        }

        
    }
    
    
    
    func addUserFinished() {
        reloadData()
    }
    
    func reloadData(){
        users = DatabaseUserController.shared.getAllUsers()
        usersTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as? UserCell{
            cell.chooseDatabaseButton.tag = indexPath.row
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
            if self.users[indexPath.row].isLocked == false || self.users[indexPath.row].username == DatabaseUserController.shared.getLoggedUser()?.username{
                self.showAddUser(self.users[indexPath.row]).delegate = self
            }
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
        
        if sidebarMenuOpen == true {
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
        self.backgroundColor = UIColor.clearColor()
        
        userNameLabel.text = user.username
        
        if let id = user.customImageId{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    userImage.image = UIImage(data: data)
                }else{
                    if let defaultImage = user.defaultImage{
                        userImage.image = UIImage(named: defaultImage)
                    }else{
                       userImage.image = UIImage(named: "User")
                    }
                }
            }else{
                if let defaultImage = user.defaultImage{
                    userImage.image = UIImage(named: defaultImage)
                }else{
                    userImage.image = UIImage(named: "User")
                }
            }
        }else{
            if let defaultImage = user.defaultImage{
                userImage.image = UIImage(named: defaultImage)
            }else{
                userImage.image = UIImage(named: "User")
            }
        }

        if !AdminController.shared.isAdminLogged() {
            if user.username != DatabaseUserController.shared.getLoggedUser()?.username{
                chooseDatabaseButton.enabled = !(user.isLocked as! Bool)
                editDatabaseButton.enabled = !(user.isLocked as! Bool)
            }
        }else{
            chooseDatabaseButton.enabled = !(user.isLocked as! Bool)
            editDatabaseButton.enabled = !(user.isLocked as! Bool)
        }
        
        
    }
    
}

