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
//import Zip

class ProjectManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddUserDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var appDel:AppDelegate!
    var users:[User] = []
    var sidebarMenuOpen : Bool = false
    var tap : UITapGestureRecognizer!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
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

        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !AdminController.shared.isAdminLogged() {
            addButton.isHidden = true
        }
        
        users = DatabaseUserController.shared.getAllUsers()
        
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings"{
            if let button = sender as? UIButton{
                if let vc = segue.destination as? SettingsViewController{
                    vc.user = users[button.tag]
                }
            }
        }
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        }
    }
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }

    @IBAction func addUser(_ sender: AnyObject) {
        showAddUser(nil).delegate = self
    }
    
    @IBAction func changeDataBase(_ sender: AnyObject) {
        if let button = sender as? UIButton{
            if AdminController.shared.setOtherUser(users[button.tag].objectID.uriRepresentation().absoluteString){
                self.view.makeToast(message: "\(users[button.tag].username!)'s database is in use!")
            }else{
                self.view.makeToast(message: "Error!!")
            }
        }
    }
    
    @IBAction func editDataBase(_ sender: AnyObject) {
        if let button = sender as? UIButton{
            performSegue(withIdentifier: "settings", sender: button)
        }
    }
    
    @IBAction func deleteUser(_ sender: UIButton) {
        showAlertView(sender, message: "Delete user?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                self.appDel.managedObjectContext?.delete(self.users[sender.tag])
                if self.users[sender.tag].username == DatabaseUserController.shared.getOtherUser()?.username{
                    let _ = AdminController.shared.setOtherUser(nil)
                }
                self.reloadData()
            }
        }
    }
    
    @IBAction func shareUser(_ sender: UIButton) {
        
        let user = self.users[sender.tag]
        let user_value:NSDictionary = user.hyp_dictionary(using: HYPPropertyMapperRelationshipType.array) as NSDictionary
        
        write(user_value)
        
        print(user_value)

        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonFilePath = documentsUrl.appendingPathComponent("archive.zip")
        
        let activityViewController = UIActivityViewController(activityItems: [jsonFilePath], applicationActivities: nil)
        if let presentationController = activityViewController.popoverPresentationController {
            presentationController.sourceView = sender
            presentationController.sourceRect = sender.bounds
        }
        
        self.present(activityViewController, animated: true, completion: nil)

        
    }
    
    func write(_ userData:NSDictionary){
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("test.json")
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // creating a .json file in the Documents folder
        if !fileManager.fileExists(atPath: jsonFilePath.absoluteString, isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: jsonFilePath.absoluteString, contents: nil, attributes: nil)
            if created {
                print("File created ")
            } else {
                print("Couldn't create file for some reason")
            }
        } else {
            print("File already exists")
        }
        
        let data:Data? = NSKeyedArchiver.archivedData(withRootObject: userData)
        if let data = data{
            try? data.write(to: URL(fileURLWithPath: jsonFilePath.path), options: [.atomic])
        }
        
//        do {
//            let zipFilePath = documentsDirectoryPath.URLByAppendingPathComponent("archive.zip")
//            try Zip.zipFiles([jsonFilePath], zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
//                print(progress)
//            })
//        }
//        catch {
//            print("Something went wrong")
//        }
        
        do {
            try fileManager.removeItem(atPath: jsonFilePath.path)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell{
            cell.chooseDatabaseButton.tag = (indexPath as NSIndexPath).row
            cell.editDatabaseButton.tag = (indexPath as NSIndexPath).row
            cell.deleteUser.tag = (indexPath as NSIndexPath).row
            cell.shareUser.tag = (indexPath as NSIndexPath).row
            print((indexPath as NSIndexPath).row)
            cell.setItem(users[(indexPath as NSIndexPath).row])
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if(sidebarMenuOpen == true){
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            if self.users[(indexPath as NSIndexPath).row].isLocked == false || self.users[(indexPath as NSIndexPath).row].username == DatabaseUserController.shared.getLoggedUser()?.username{
                self.showAddUser(self.users[(indexPath as NSIndexPath).row]).delegate = self
            }
        })
    }
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            usersTableView.isUserInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            usersTableView.isUserInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        
        if(position == FrontViewPosition.left) {
            usersTableView.isUserInteractionEnabled = true
            sidebarMenuOpen = false
            self.view.removeGestureRecognizer(tap)
        } else {
            self.view.addGestureRecognizer(tap)
            usersTableView.isUserInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if sidebarMenuOpen == true {
            self.revealViewController().revealToggle(animated: true)
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
    
    func setItem(_ user:User){
        self.backgroundColor = UIColor.clear
        
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
                chooseDatabaseButton.isEnabled = !(user.isLocked as! Bool)
                editDatabaseButton.isEnabled = !(user.isLocked as! Bool)
            }
        }else{
            chooseDatabaseButton.isEnabled = !(user.isLocked as! Bool)
            editDatabaseButton.isEnabled = !(user.isLocked as! Bool)
        }
        
        
    }
    
}

