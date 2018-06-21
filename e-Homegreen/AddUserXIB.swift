//
//  AddUserXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/23/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

protocol AddUserDelegate{
    func addUserFinished()
}

class AddUserXIB: CommonXIBTransitionVC {
    
    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var userImageButton: UIButton!
    
    @IBOutlet weak var usernameTextField: EditTextField!
    @IBOutlet weak var passwordTextView: EditTextField!
    @IBOutlet weak var confirmPasswordtextView: EditTextField!
    
    @IBOutlet weak var superUserSwitch: UISwitch!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var delegate:AddUserDelegate?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var user:User?
    
    var imageData:Data?
    var customImage:String?
    var defaultImage:String?
    
    init(user:User?){
        super.init(nibName: "AddUserXIB", bundle: nil)
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        setupViews()
    }
    
    func setupViews() {
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        usernameTextField.delegate       = self
        passwordTextView.delegate        = self
        confirmPasswordtextView.delegate = self
        
        userImageButton.addLongPress(minimumPressDuration: 0.5) {
            self.deleteUsersCustomPhoto()
        }
        
        if let user = user {
            usernameTextField.text = user.username
            
            passwordTextView.isEnabled        = false
            confirmPasswordtextView.isEnabled = false
            
            superUserSwitch.isOn = user.isSuperUser as! Bool
            
            if let id = user.customImageId {
                if let image = DatabaseImageController.shared.getImageById(id) {
                    
                    if let data =  image.imageData {
                        userImageButton.setImage(UIImage(data: data), for: UIControlState())
                    } else {
                        if let defaultImage = user.defaultImage { userImageButton.setImage(UIImage(named: defaultImage), for: UIControlState())
                        } else { userImageButton.setImage(UIImage(named: "User"), for: UIControlState()) } }
                    
                } else {
                    if let defaultImage = user.defaultImage { userImageButton.setImage(UIImage(named: defaultImage), for: UIControlState())
                    } else { userImageButton.setImage(UIImage(named: "User"), for: UIControlState()) } }
            } else {
                if let defaultImage = user.defaultImage { userImageButton.setImage(UIImage(named: defaultImage), for: UIControlState())
                } else { userImageButton.setImage(UIImage(named: "User"), for: UIControlState()) } }
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { dismissEditing(); return false }
        return true
    }
    
    private func deleteUsersCustomPhoto() {
        self.showAlertView(userImageButton, message: "Are you sure you want to delete your profile photo?") { (returnValue) in
            
            switch returnValue {
                case .delete:
                    if let user = self.user {
                        user.customImageId = nil
                        
                        CoreDataController.sharedInstance.saveChanges()
                        
                        if let defaultImage = user.defaultImage {
                            self.userImageButton.setImage(UIImage(named: defaultImage), for: UIControlState())
                        } else {
                            self.userImageButton.setImage(UIImage(named: "User"), for: UIControlState())
                        }
                    }
                default: break
            }
        }

    }
    
    @IBAction func changePicture(_ sender: AnyObject) {
        showGallery(1, user: user, isForScenes: true).delegate = self
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        
        dismissEditing()
        
        if let moc = appDel.managedObjectContext {
            if let user = user {
                guard let username = usernameTextField.text , username != "" else { self.view.makeToast(message: "Enter username!"); return }
                
                user.username     = username
                user.isLocked     = false
                user.isSuperUser  = superUserSwitch.isOn as NSNumber
                
                user.lastScreenId = 13
                
                if let customImage = customImage { user.customImageId = customImage; user.defaultImage = nil }
                if let def         = defaultImage { user.defaultImage = def; user.customImageId = nil }
                if let data = imageData {
                    if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: moc) as? Image {
                        image.imageData    = data
                        image.imageId      = UUID().uuidString
                        user.customImageId = image.imageId
                        user.defaultImage  = nil
                        user.addImagesObject(image)
                    }
                }
                
                CoreDataController.sharedInstance.saveChanges()
                DatabaseMenuController.shared.createMenu(user)
            } else {
                guard let username = usernameTextField.text , username != "", let password = passwordTextView.text , password != "", let confirmpass = confirmPasswordtextView.text , confirmpass != "" else { self.view.makeToast(message: "All fields must be filled"); return }
                if password != confirmpass { self.view.makeToast(message: "Passwords do not match"); return }
                
                if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: moc) as? User {
                    user.username       = username
                    user.password       = password
                    user.isLocked       = false
                    user.isSuperUser    = superUserSwitch.isOn as NSNumber
                    user.openLastScreen = false
                    user.sortDevicesByUsage = false
                    if let customImage = customImage { user.customImageId = customImage }
                    if let def  = defaultImage { user.defaultImage = def }
                    
                    CoreDataController.sharedInstance.saveChanges()
                    DatabaseMenuController.shared.createMenu(user)
                    DatabaseFilterController.shared.createFilters(user)
                }
            }
        }
        
        delegate?.addUserFinished()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }


}

extension AddUserXIB : SceneGalleryDelegate {
    
    func returnedGaleryImage(_ image: Image, data: Data, imageIndex: Int) {
        customImage = image.imageId
        userImageButton.setImage(UIImage(data: data), for: UIControlState())
    }
    
    func backImageFromGallery(_ data: Data, imageIndex: Int) {
//        defaultImage = nil
//        customImage  = nil
//        imageData    = data
//        userImageButton.setImage(UIImage(data: data), for: UIControlState())
    }
    
    func backString(_ strText: String, imageIndex: Int) {
        userImageButton.setImage(UIImage(named: strText), for: UIControlState())
        defaultImage = strText
        customImage  = nil
        imageData    = nil
    }
    
    func backImage(_ image: Image, imageIndex: Int) {
        defaultImage = nil
        customImage  = image.imageId
        imageData    = nil
        userImageButton.setImage(UIImage(data: image.imageData! as Data), for: UIControlState())
    }
    
}

extension AddUserXIB : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if usernameTextField.isFirstResponder { passwordTextView.becomeFirstResponder()
        } else if passwordTextView.isFirstResponder { confirmPasswordtextView.becomeFirstResponder()
        } else { textField.resignFirstResponder() }
        
        return true
    }
}

extension UIViewController {
    func showAddUser(_ user:User?) -> AddUserXIB {
        let addUser = AddUserXIB(user:user)
        self.present(addUser, animated: true, completion: nil)
        return addUser
    }
}
