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

class AddUserXIB: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, SceneGalleryDelegate {
    
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
            if let data = user.profilePicture{
                userImageButton.setImage(UIImage(data: data), forState: .Normal)
            }
        }
        
    }
    
    @IBAction func changePicture(sender: AnyObject) {
        showGallery(1).delegate = self
    }
    
    func backImageFromGallery(data: NSData, imageIndex: Int) {
        imageData = data
        userImageButton.setImage(UIImage(data: data), forState: .Normal)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            if let image = imageData{
                user.profilePicture = image
            }
            saveChanges()
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
                user.profilePicture = imageData
                saveChanges()
                DatabaseMenuController.shared.createMenu(user)
            }
            

        }

        delegate?.addUserFinished()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
