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

class AddUserXIB: UIViewController {
    
    var isPresenting: Bool = true
    
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
    
    var imageData:NSData?
    var customImage:String?
    var defaultImage:String?
    
    init(user:User?){
        super.init(nibName: "AddUserXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.redColor())
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        usernameTextField.delegate = self
        passwordTextView.delegate = self
        confirmPasswordtextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddUserXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        if let user = user{
            usernameTextField.text = user.username
            
            if let issuperuser = user.isSuperUser as? Bool{
                superUserSwitch.on = issuperuser
            }
            if let id = user.customImageId{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        userImageButton.setImage(UIImage(data: data), forState: .Normal)
                    }else{
                        if let defaultImage = user.defaultImage{
                            userImageButton.setImage(UIImage(named: defaultImage), forState: .Normal)
                        }else{
                            userImageButton.setImage(UIImage(named: "User"), forState: .Normal)
                        }
                    }
                }else{
                    if let defaultImage = user.defaultImage{
                        userImageButton.setImage(UIImage(named: defaultImage), forState: .Normal)
                    }else{
                        userImageButton.setImage(UIImage(named: "User"), forState: .Normal)
                    }
                }
            }else{
                if let defaultImage = user.defaultImage{
                    userImageButton.setImage(UIImage(named: defaultImage), forState: .Normal)
                }else{
                   userImageButton.setImage(UIImage(named: "User"), forState: .Normal)
                }
            }

        }
        
    }
    
    @IBAction func changePicture(sender: AnyObject) {
        showGallery(1, user: user).delegate = self
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if let user = user{
            guard let username = usernameTextField.text where username != "" else{
                self.view.makeToast(message: "Enter username!")
                return
            }
            user.username = username
            user.isLocked = false
            user.isSuperUser = superUserSwitch.on
            
            user.lastScreenId = 13
            
            if let customImage = customImage{
                user.customImageId = customImage
                user.defaultImage = nil
            }
            if let def = defaultImage {
                user.defaultImage = def
                user.customImageId = nil
            }
            if let data = imageData{
                if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                    image.imageData = data
                    image.imageId = NSUUID().UUIDString
                    user.customImageId = image.imageId
                    user.defaultImage = nil
                    user.addImagesObject(image)
                    
                }
            }

            CoreDataController.shahredInstance.saveChanges()
            DatabaseMenuController.shared.createMenu(user)
        }else{
            guard let username = usernameTextField.text where username != "", let password = passwordTextView.text where password != "", let confirmpass = confirmPasswordtextView.text where confirmpass != "" else{
                self.view.makeToast(message: "All fields must be filled")
                return
            }
            if password != confirmpass {
                self.view.makeToast(message: "Passwords do not match")
                return
            }
            
            if let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: appDel.managedObjectContext!) as? User{
                
                user.username = username
                user.password = password
                user.isLocked = false
                user.isSuperUser = superUserSwitch.on
                user.openLastScreen = false
                if let customImage = customImage{
                    user.customImageId = customImage
                }
                if let def = defaultImage {
                    user.defaultImage = def
                }
                if let data = imageData{
                    if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                        image.imageData = data
                        image.imageId = NSUUID().UUIDString
                        user.customImageId = image.imageId
                        
                        user.addImagesObject(image)
                        
                    }
                }
                
                CoreDataController.shahredInstance.saveChanges()
                DatabaseMenuController.shared.createMenu(user)
                DatabaseFilterController.shared.createFilters(user)
            }
            

        }

        delegate?.addUserFinished()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


}

extension AddUserXIB : SceneGalleryDelegate {
    
    func backImageFromGallery(data: NSData, imageIndex: Int) {
        defaultImage = nil
        customImage = nil
        imageData = data
        userImageButton.setImage(UIImage(data: data), forState: .Normal)
    }
    
    func backString(strText: String, imageIndex: Int) {
        userImageButton.setImage(UIImage(named: strText), forState: .Normal)
        defaultImage = strText
        customImage = nil
        imageData = nil
    }
    
    func backImage(image: Image, imageIndex: Int) {
        defaultImage = nil
        customImage = image.imageId
        imageData = nil
        userImageButton.setImage(UIImage(data: image.imageData!), forState: .Normal)
    }
    
}

extension AddUserXIB : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if usernameTextField.isFirstResponder(){
            passwordTextView.becomeFirstResponder()
        }else if passwordTextView.isFirstResponder(){
            confirmPasswordtextView.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        
        return true
    }
}

extension AddUserXIB : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            dismissKeyboard()
            return false
        }
        return true
    }
}

extension AddUserXIB : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension AddUserXIB : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}

extension UIViewController {
    func showAddUser(user:User?) -> AddUserXIB {
        let addUser = AddUserXIB(user:user)
        self.presentViewController(addUser, animated: true, completion: nil)
        return addUser
    }
}
