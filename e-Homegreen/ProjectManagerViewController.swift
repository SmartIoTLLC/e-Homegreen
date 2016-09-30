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

class ProjectManagerViewController: UIViewController {
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var users:[User] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            
            revealViewController().rearViewRevealWidth = 200
        }
        
        reloadData()
        
        changeFullScreeenImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        if !AdminController.shared.isAdminLogged() {
            addButton.isHidden = true
        }
        
        usersTableView.tableFooterView = UIView()
        
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
                DatabaseUserController.shared.removeUser(user: self.users[sender.tag])
                if self.users[sender.tag].username == DatabaseUserController.shared.getOtherUser()?.username{
                    let _ = AdminController.shared.setOtherUser(nil)
                }
                self.users.remove(at: sender.tag)
                self.usersTableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: .fade)
                
            }
        }
    }
    let container: UIView = UIView()
    let loadingView: UIView = UIView()
    @IBAction func shareUser(_ sender: UIButton) {
        
        
        container.bounds = self.view.bounds
        container.center = self.view.center
        container.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
       
        self.view.addSubview(self.container)
        self.view.bringSubview(toFront: self.container)
        actInd.startAnimating()
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            let user = self.users[sender.tag]
            let user_value:NSDictionary = user.hyp_dictionary(using: HYPPropertyMapperRelationshipType.array) as NSDictionary
            
            self.write(user_value)
            
            DispatchQueue.main.async {
                
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let jsonFilePath = documentsUrl.appendingPathComponent("userJSON.zip")
                
                let activityViewController = UIActivityViewController(activityItems: [jsonFilePath], applicationActivities: nil)
                
                activityViewController.completionWithItemsHandler = { activity, success, items, error in

                        if FileManager.default.fileExists(atPath: jsonFilePath.path) {
                            do {
                                try FileManager.default.removeItem(atPath: jsonFilePath.path)
                                print("file has been removed")
                            } catch {
                                print("file didn't remove")
                            }
                        }

                }
                
                if let presentationController = activityViewController.popoverPresentationController {
                    presentationController.sourceView = sender
                    presentationController.sourceRect = sender.bounds
                }
                
                actInd.stopAnimating()
                self.container.removeFromSuperview()
                
                self.present(activityViewController, animated: true, completion: nil)
                
                
                
            }
            
        }
        
    }
    
    func write(_ userData:NSDictionary){
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("user.json")
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
        
        do {
            let zipFilePath = documentsDirectoryPath.appendingPathComponent("userJSON.zip")
            try Zip.zipFiles(paths: [jsonFilePath], zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                print(progress)
            })
        }
        catch {
            print("Something went wrong")
        }
        
        do {
            try fileManager.removeItem(atPath: jsonFilePath.path)
        } catch let error as NSError {
            print("ERROR: \(error)")
        }

        
    }
    
    func reloadData(){
        users = DatabaseUserController.shared.getAllUsers()
        usersTableView.reloadData()
    }
    
}

extension ProjectManagerViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell{
            cell.chooseDatabaseButton.tag = indexPath.row
            cell.editDatabaseButton.tag = indexPath.row
            cell.deleteUser.tag = indexPath.row
            cell.shareUser.tag = indexPath.row
            cell.setItem(users[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            if self.users[indexPath.row].isLocked == false || self.users[indexPath.row].username == DatabaseUserController.shared.getLoggedUser()?.username{
                self.showAddUser(self.users[indexPath.row]).delegate = self
            }
        })
    }
}

extension ProjectManagerViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            usersTableView.isUserInteractionEnabled = true
        } else {
            usersTableView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        
        if(position == FrontViewPosition.left) {
            usersTableView.isUserInteractionEnabled = true
        } else {
            usersTableView.isUserInteractionEnabled = false
        }
    }
}

extension ProjectManagerViewController: AddUserDelegate{
    func addUserFinished() {
        reloadData()
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

