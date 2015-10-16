//
//  IBeaconSettingsVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/13/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class IBeaconSettingsVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var isPresenting: Bool = true
    var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .CaseInsensitive)
    
    @IBOutlet weak var centarConstraint: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editUUID: UITextField!
    @IBOutlet weak var editMajor: UITextField!
    @IBOutlet weak var editMinor: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var iBeacon:IBeacon?
    
    init(iBeacon:IBeacon?){
        super.init(nibName: "IBeaconSettingsVC", bundle: nil)
        transitioningDelegate = self
        self.iBeacon = iBeacon
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func endEditingNow(){
        editMajor.resignFirstResponder()
        editMinor.resignFirstResponder()
        centarConstraint.constant = 0
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        editMajor.inputAccessoryView = keyboardDoneButtonView
        editMinor.inputAccessoryView = keyboardDoneButtonView

        
        if UIScreen.mainScreen().scale > 2.5{
            editName.layer.borderWidth = 1
            editUUID.layer.borderWidth = 1
            editMajor.layer.borderWidth = 1
            editMinor.layer.borderWidth = 1
        }else{
            editName.layer.borderWidth = 0.5
            editUUID.layer.borderWidth = 0.5
            editMajor.layer.borderWidth = 0.5
            editMinor.layer.borderWidth = 0.5
        }
        
        editName.layer.cornerRadius = 2
        editUUID.layer.cornerRadius = 2
        editMajor.layer.cornerRadius = 2
        editMinor.layer.cornerRadius = 2
        
        editName.layer.borderColor = UIColor.lightGrayColor().CGColor
        editUUID.layer.borderColor = UIColor.lightGrayColor().CGColor
        editMajor.layer.borderColor = UIColor.lightGrayColor().CGColor
        editMinor.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        editName.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editUUID.attributedPlaceholder = NSAttributedString(string:"UUID",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editMajor.attributedPlaceholder = NSAttributedString(string:"Major",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editMinor.attributedPlaceholder = NSAttributedString(string:"Minor",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        editName.delegate = self
        editUUID.delegate = self
        if iBeacon != nil {
            editName.text = iBeacon?.name!
            editUUID.text = iBeacon?.uuid!
            editMajor.text = "\(iBeacon!.major!)"
            editMinor.text = "\(iBeacon!.minor!)"
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    func handleTap(gesture:UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        centarConstraint.constant = 0
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if editName.text == "" || editUUID.text == "" || editMinor.text == "" || editMajor.text == ""{
           
        } else {
            if uuidRegex.numberOfMatchesInString(editUUID.text!, options: [], range: NSMakeRange(0, editUUID.text!.characters.count)) > 0{
                if iBeacon == nil{
                    let iBeaconNew = NSEntityDescription.insertNewObjectForEntityForName("IBeacon", inManagedObjectContext: appDel.managedObjectContext!) as! IBeacon
                    iBeaconNew.name = editName.text!
                    iBeaconNew.uuid = editUUID.text!
                    iBeaconNew.major = Int(editMajor.text!)!
                    iBeaconNew.minor = Int(editMinor.text!)!
                    saveChanges()
                }else{
                    iBeacon!.name = editName.text!
                    iBeacon!.uuid = editUUID.text!
                    iBeacon!.major = Int(editMajor.text!)!
                    iBeacon!.minor = Int(editMinor.text!)!
                    
                    saveChanges()
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        NSNotificationCenter.defaultCenter().postNotificationName("refreshIBeaconList", object: self, userInfo: nil)
        appDel.startIBeacon()
        
        appDel.establishAllConnections()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if editUUID.isFirstResponder(){
            if backView.frame.origin.y + editUUID.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editUUID.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editMajor.isFirstResponder(){
            if backView.frame.origin.y + editMajor.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editMajor.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editMinor.isFirstResponder(){
            if backView.frame.origin.y + editMinor.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editMinor.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }

 
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }


}

extension IBeaconSettingsVC : UIViewControllerAnimatedTransitioning {
    
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



extension IBeaconSettingsVC : UIViewControllerTransitioningDelegate {
    
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
    func showiBeaconSettings(iBeacon:IBeacon?) {
        let iBeaSet = IBeaconSettingsVC(iBeacon: iBeacon)
        self.presentViewController(iBeaSet, animated: true, completion: nil)
    }
}
