//
//  SurveillanceSettingsVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/24/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

protocol AddEditSurveillanceDelegate{
    func addEditSurveillanceFinished()
}

class SurveillanceSettingsVC: UIViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var centarConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var levelButton: CustomGradientButton!
    @IBOutlet weak var zoneButton: CustomGradientButton!
    @IBOutlet weak var categoryButton: CustomGradientButton!
    @IBOutlet weak var editIPLocal: UITextField!
    @IBOutlet weak var editPortLocal: UITextField!
    @IBOutlet weak var editIPRemote: UITextField!
    @IBOutlet weak var editPortRemote: UITextField!
    @IBOutlet weak var editUserName: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var popoverVC:PopOverViewController = PopOverViewController()
    var isPresenting: Bool = true
    var delegate:AddEditSurveillanceDelegate?
    var appDel:AppDelegate!
    var error:NSError? = nil
    var surv:Surveillance?
    var parentLocation:Location?

    var levelSelected:Zone?
    var zoneSelected:Zone?
    var categorySelected:Category?
    
    init(surv: Surveillance?, location:Location?){
        super.init(nibName: "SurveillanceSettingsVC", bundle: nil)
        self.surv = surv
        self.parentLocation = location
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)

        editPortRemote.inputAccessoryView = keyboardDoneButtonView
        editPortLocal.inputAccessoryView = keyboardDoneButtonView

        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        editIPRemote.delegate = self
        editPortRemote.delegate = self
        editUserName.delegate = self
        editPassword.delegate = self
        editName.delegate = self
        editIPLocal.delegate = self
        editPortLocal.delegate = self
        
        if let surv = surv{
            
            editIPRemote.text = surv.ip
            if let port = surv.port{
                editPortRemote.text = "\(port)"
            }
            editUserName.text = surv.username
            editPassword.text = surv.password
            editName.text = surv.name
            
            levelButton.setTitle(surv.surveillanceLevel, forState: .Normal)
            zoneButton.setTitle(surv.surveillanceZone, forState: .Normal)
            categoryButton.setTitle(surv.surveillanceCategory, forState: .Normal)
            
            levelSelected = surv.cameraLevel
            zoneSelected = surv.cameraZone
            categorySelected = surv.cameraCategory

            if let localIp = surv.localIp {
                editIPLocal.text = localIp
            }
            if let localPort = surv.localPort {
                editPortLocal.text = localPort
            }
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissViewController"))
//        tapGesture.delegate = self
//        self.view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
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
            if self.view.frame.size.height < 600{
                backViewHeightConstraint.constant = 480
            }else{
                backViewHeightConstraint.constant = 526
            }
        }
    }
    
    func endEditingNow(){
        editPortRemote.resignFirstResponder()
        editPortLocal.resignFirstResponder()
        centarConstraint.constant = 0
    }
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func returnObjectIDandTypePopover(objectId: NSManagedObjectID?, popOver: Int) {
        if popOver == PopOver.Level.rawValue{
            if let objectid = objectId{
                levelSelected = DatabaseZoneController.shared.getZone(objectid)
                if let level = levelSelected{
                    levelButton.setTitle(level.name, forState: .Normal)
                }
            }else{
                levelSelected = nil
                levelButton.setTitle("All", forState: .Normal)
            }
        }
        if popOver == PopOver.Zone.rawValue{
            if let objectid = objectId{
                zoneSelected = DatabaseZoneController.shared.getZone(objectid)
                if let zone = zoneSelected{
                    zoneButton.setTitle(zone.name, forState: .Normal)
                }
            }else{
                zoneSelected = nil
                zoneButton.setTitle("All", forState: .Normal)
            }
        }
        if popOver == PopOver.Category.rawValue{
            if let objectid = objectId{
                categorySelected = DatabaseCategoryController.shared.getCategory(objectid)
                if let category = categorySelected{
                    categoryButton.setTitle(category.name, forState: .Normal)
                }
            }else{
                categorySelected = nil
                categoryButton.setTitle("All", forState: .Normal)
            }
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
//        appDel.establishAllConnections()
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnZoneAction(sender: UIButton) {
        popoverVC = UIStoryboard(name: "Popover", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        if sender.tag == 1{
            popoverVC.indexTab = 29
            popoverVC.levelList = DatabaseZoneController.shared.getLevels(parentLocation!)
            popoverVC.popOver = PopOver.Level
        }else if sender.tag == 2 {
            if let location = parentLocation, let levelId = levelSelected?.id {
                popoverVC.indexTab = 30
                popoverVC.zoneList = DatabaseZoneController.shared.getZonesOnLevel(location, levelId: Int(levelId))
                popoverVC.popOver = PopOver.Zone
            }else{
                popoverVC.indexTab = 30
                popoverVC.zoneList = []
                popoverVC.popOver = PopOver.Zone
            }
        }else{
            if let location = parentLocation, let levelId = levelSelected?.id {
                popoverVC.indexTab = 31
                popoverVC.categoryList = DatabaseCategoryController.shared.getCategories(location)
                popoverVC.popOver = PopOver.Category
            }else{
                popoverVC.indexTab = 31
                popoverVC.categoryList = []
                popoverVC.popOver = PopOver.Category
            }
        }
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    @IBAction func btnSave(sender: AnyObject) {
        if  let remoteIp = editIPRemote.text,let remotePort = editPortRemote.text, let username =  editUserName.text, let password = editPassword.text, let name =  editName.text, let remotePortNumber = Int(remotePort),let localIp = editIPLocal.text, let localPort = editPortLocal.text, let localPortNumber = Int(localPort)   {
            if surv == nil{
                if let parentLocation = parentLocation{
                    let surveillance = Surveillance(context: appDel.managedObjectContext!)
                    
                    surveillance.name = name
                    surveillance.username = username
                    surveillance.password = password
                    surveillance.surveillanceLevel = levelButton.titleLabel?.text
                    surveillance.surveillanceZone = zoneButton.titleLabel?.text
                    surveillance.surveillanceCategory = categoryButton.titleLabel?.text
                    surveillance.localIp = localIp
                    surveillance.localPort = localPort
                    surveillance.ip = remoteIp
                    surveillance.port = remotePortNumber
                    
                    surveillance.isVisible = true
                    
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
                    
                    surveillance.cameraLevel = levelSelected
                    surveillance.cameraZone = zoneSelected
                    surveillance.cameraCategory = categorySelected
                    
                    surveillance.tiltStep = 1
                    surveillance.panStep = 1
                    surveillance.autSpanStep = 1
                    surveillance.dwellTime = 15
                    surveillance.location = parentLocation
                    saveChanges()
                }
            }else if let surv = surv{
                
                surv.name = name
                surv.username = username
                surv.password = password
                
                surv.surveillanceLevel = levelButton.titleLabel?.text
                surv.surveillanceZone = zoneButton.titleLabel?.text
                surv.surveillanceCategory = categoryButton.titleLabel?.text
                
                surv.cameraLevel = levelSelected
                surv.cameraZone = zoneSelected
                surv.cameraCategory = categorySelected
                
                surv.localIp = localIp
                surv.localPort = localPort
                surv.ip = remoteIp
                surv.port = remotePortNumber
                
                saveChanges()
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
            delegate?.addEditSurveillanceFinished()
        }
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

extension SurveillanceSettingsVC: UITextFieldDelegate{
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
}

extension UIViewController {
    func showSurveillanceSettings(surv: Surveillance?, location:Location?) -> SurveillanceSettingsVC {
        let survSettVC = SurveillanceSettingsVC(surv: surv, location:location)
        self.presentViewController(survSettVC, animated: true, completion: nil)
        return survSettVC
    }
}
