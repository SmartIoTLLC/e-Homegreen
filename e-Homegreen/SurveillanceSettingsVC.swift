//
//  SurveillanceSettingsVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/24/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SurveillanceSettingsVC: UIViewController,UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var centarConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var editLevel: UITextField!
    @IBOutlet weak var editZone: UITextField!
    @IBOutlet weak var editCategory: UITextField!
    @IBOutlet weak var editName: UITextField!
    
    
    @IBOutlet weak var editIPLocal: UITextField!
    @IBOutlet weak var editPortLocal: UITextField!
    @IBOutlet weak var editSSID: UITextField!
    
    
    @IBOutlet weak var editIPRemote: UITextField!
    @IBOutlet weak var editPortRemote: UITextField!
    @IBOutlet weak var editUserName: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var surv:Surveillance?
    
    var isNew = false
    
    init(surv: Surveillance?){
        super.init(nibName: "SurveillanceSettingsVC", bundle: nil)
        self.surv = surv
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if UIScreen.mainScreen().scale > 2.5{
            editIPRemote.layer.borderWidth = 1
            editPortRemote.layer.borderWidth = 1
            editUserName.layer.borderWidth = 1
            editPassword.layer.borderWidth = 1
            editLocation.layer.borderWidth = 1
            editName.layer.borderWidth = 1
            editIPLocal.layer.borderWidth = 1
            editPortLocal.layer.borderWidth = 1
            editSSID.layer.borderWidth = 1
            editLevel.layer.borderWidth = 1
            editZone.layer.borderWidth = 1
            editCategory.layer.borderWidth = 1
        }else{
            editIPRemote.layer.borderWidth = 0.5
            editPortRemote.layer.borderWidth = 0.5
            editUserName.layer.borderWidth = 0.5
            editPassword.layer.borderWidth = 0.5
            editLocation.layer.borderWidth = 0.5
            editName.layer.borderWidth = 0.5
            editIPLocal.layer.borderWidth = 0.5
            editPortLocal.layer.borderWidth = 0.5
            editSSID.layer.borderWidth = 0.5
            editLevel.layer.borderWidth = 0.5
            editZone.layer.borderWidth = 0.5
            editCategory.layer.borderWidth = 0.5
        }
        
        editIPRemote.layer.cornerRadius = 2
        editPortRemote.layer.cornerRadius = 2
        editUserName.layer.cornerRadius = 2
        editPassword.layer.cornerRadius = 2
        editLocation.layer.cornerRadius = 2
        editName.layer.cornerRadius = 2
        editIPLocal.layer.cornerRadius = 2
        editPortLocal.layer.cornerRadius = 2
        editSSID.layer.cornerRadius = 2
        editLevel.layer.cornerRadius = 2
        editZone.layer.cornerRadius = 2
        editCategory.layer.cornerRadius = 2
        
        editIPRemote.layer.borderColor = UIColor.lightGrayColor().CGColor
        editPortRemote.layer.borderColor = UIColor.lightGrayColor().CGColor
        editUserName.layer.borderColor = UIColor.lightGrayColor().CGColor
        editPassword.layer.borderColor = UIColor.lightGrayColor().CGColor
        editLocation.layer.borderColor = UIColor.lightGrayColor().CGColor
        editName.layer.borderColor = UIColor.lightGrayColor().CGColor
        editIPLocal.layer.borderColor = UIColor.lightGrayColor().CGColor
        editPortLocal.layer.borderColor = UIColor.lightGrayColor().CGColor
        editSSID.layer.borderColor = UIColor.lightGrayColor().CGColor
        editLevel.layer.borderColor = UIColor.lightGrayColor().CGColor
        editZone.layer.borderColor = UIColor.lightGrayColor().CGColor
        editCategory.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        editIPRemote.attributedPlaceholder = NSAttributedString(string:"IP/Host",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editPortRemote.attributedPlaceholder = NSAttributedString(string:"Port",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editUserName.attributedPlaceholder = NSAttributedString(string:"Username",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editPassword.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editLocation.attributedPlaceholder = NSAttributedString(string:"Location",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editName.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editIPLocal.attributedPlaceholder = NSAttributedString(string:"IP local",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editPortLocal.attributedPlaceholder = NSAttributedString(string:"Local Port",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editSSID.attributedPlaceholder = NSAttributedString(string:"SSID",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editLevel.attributedPlaceholder = NSAttributedString(string:"Level",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editZone.attributedPlaceholder = NSAttributedString(string:"Zone",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editCategory.attributedPlaceholder = NSAttributedString(string:"Category",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        editIPRemote.delegate = self
        editPortRemote.delegate = self
        editUserName.delegate = self
        editPassword.delegate = self
        editLocation.delegate = self
        editName.delegate = self
        editIPLocal.delegate = self
        editPortLocal.delegate = self
        editSSID.delegate = self
        editLevel.delegate = self
        editZone.delegate = self
        editCategory.delegate = self
        
        if surv != nil{
            editIPRemote.text = surv?.ip
            editPortRemote.text = "\(surv!.port!)"
            editUserName.text = surv?.username
            editPassword.text = surv?.password
            if isNew {editName.text = ""} else {editName.text = surv?.name}
//            editName.text = surv?.name
            if surv?.location != nil{
                if isNew {editLocation.text = ""} else {editLocation.text = surv?.locationDELETETHIS}
//                editLocation.text = surv?.location
            }
            if surv?.localIp != nil{
                editIPLocal.text = surv?.localIp
            }
            if surv?.localPort != nil{
                editPortLocal.text = surv?.localPort
            }
            if surv?.ssid != nil{
                editSSID.text = surv?.ssid
            }
            if surv?.surveillanceLevel != nil{
                editLevel.text = surv?.surveillanceLevel
            }
            if surv?.surveillanceZone != nil{
                editZone.text = surv?.surveillanceZone
            }
            if surv?.surveillanceCategory != nil{
                editCategory.text = surv?.surveillanceCategory
            }
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissViewController"))
//        tapGesture.delegate = self
//        self.view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.centarConstraint.constant = 0
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        return true
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation.isLandscape {
            print("UIDevice.currentDevice().orientation.isLandscape")
        }
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.height == 320{
                backViewHeightConstraint.constant = 250
            }else if self.view.frame.size.height == 375{
                backViewHeightConstraint.constant = 300
            }else if self.view.frame.size.height == 414{
                backViewHeightConstraint.constant = 350
            }else{
                backViewHeightConstraint.constant = 480
            }
        }else{
            backViewHeightConstraint.constant = 480
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if editIPRemote.text == "" || editPortRemote.text == "" || editUserName.text == "" || editPassword.text == "" || editName.text == ""{
            
            
        } else {
            if surv == nil || isNew{
                let surveillance = Surveillance(context: appDel.managedObjectContext!)
                surveillance.ip = editIPRemote.text!
                surveillance.port = Int(editPortRemote.text!)!
                surveillance.username = editUserName.text!
                surveillance.password = editPassword.text!
                surveillance.isVisible = true
                surveillance.name = editName.text!
                surveillance.urlHome = ""
                surveillance.urlMoveUp = ""
                surveillance.urlMoveRight = ""
                surveillance.urlMoveLeft = ""
                surveillance.urlMoveDown = ""
                surveillance.urlAutoPan = ""
                surveillance.urlAutoPanStop = ""
                surveillance.urlPresetSequence = ""
                surveillance.urlPresetSequenceStop = ""
                surveillance.urlGetImage = ""
                if editLocation.text != ""{
                    surveillance.locationDELETETHIS = editLocation.text!
                }
                if editIPLocal.text != ""{
                    surveillance.localIp = editIPLocal.text!
                }
                if editPortLocal.text != ""{
                    surveillance.localPort = editPortLocal.text!
                }
                if editSSID.text != ""{
                    surveillance.ssid = editSSID.text!
                }
                if editLevel.text != ""{
                    surveillance.localIp = editIPLocal.text!
                }
                if editZone.text != ""{
                    surveillance.localPort = editPortLocal.text!
                }
                if editCategory.text != ""{
                    surveillance.ssid = editSSID.text!
                }
                
                surveillance.tiltStep = 1
                surveillance.panStep = 1
                surveillance.autSpanStep = 1
                surveillance.dwellTime = 15
                saveChanges()
            }else if surv != nil || !isNew{
                surv!.ip = editIPRemote.text!
                surv!.port = Int(editPortRemote.text!)!
                surv!.username = editUserName.text!
                surv!.password = editPassword.text!
                surv!.name = editName.text!
                
                if editLocation.text != ""{
                    surv!.locationDELETETHIS = editLocation.text!
                }
                if editIPLocal.text != ""{
                    surv!.localIp = editIPLocal.text!
                }
                if editPortLocal.text != ""{
                    surv!.localPort = editPortLocal.text!
                }
                if editSSID.text != ""{
                    surv!.ssid = editSSID.text!
                }
                if editLevel.text != ""{
                    surv!.localIp = editIPLocal.text!
                }
                if editZone.text != ""{
                    surv!.localPort = editPortLocal.text!
                }
                if editCategory.text != ""{
                    surv!.ssid = editSSID.text!
                }
                
                saveChanges()
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        if editPortRemote.isFirstResponder(){
            if backView.frame.origin.y + editPortRemote.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editPortRemote.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editIPRemote.isFirstResponder(){
            if backView.frame.origin.y + editIPRemote.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editIPRemote.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editPortLocal.isFirstResponder(){
            if backView.frame.origin.y + editPortLocal.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editPortLocal.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editIPLocal.isFirstResponder(){
            if backView.frame.origin.y + editIPLocal.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editIPLocal.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editUserName.isFirstResponder(){
            if backView.frame.origin.y + editUserName.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editUserName.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editPassword.isFirstResponder(){
            if backView.frame.origin.y + editPassword.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editPassword.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editSSID.isFirstResponder(){
            if backView.frame.origin.y + editSSID.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editSSID.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editUserName.isFirstResponder(){
            if backView.frame.origin.y + editUserName.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editUserName.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editPassword.isFirstResponder(){
            if backView.frame.origin.y + editPassword.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editPassword.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editSSID.isFirstResponder(){
            if backView.frame.origin.y + editSSID.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editSSID.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editLevel.isFirstResponder(){
            if backView.frame.origin.y + editLevel.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editLevel.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editZone.isFirstResponder(){
            if backView.frame.origin.y + editZone.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editZone.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editCategory.isFirstResponder(){
            if backView.frame.origin.y + editCategory.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editCategory.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshSurveillance, object: self, userInfo: nil)
        
        appDel.establishAllConnections()
    }

}

extension SurveillanceSettingsVC : UIViewControllerAnimatedTransitioning {
    
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

extension SurveillanceSettingsVC : UIViewControllerTransitioningDelegate {
    
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
    func showSurveillanceSettings(surv: Surveillance?, isNew:Bool) {
        let connSettVC = SurveillanceSettingsVC(surv: surv)
        connSettVC.isNew = isNew
        self.presentViewController(connSettVC, animated: true, completion: nil)
    }
}
