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

class SurveillanceSettingsVC: PopoverVC {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var centarConstraint: NSLayoutConstraint!
    
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
    
    var isPresenting: Bool = true
    var delegate:AddEditSurveillanceDelegate?
    var appDel:AppDelegate!
    var error:NSError? = nil
    var surv:Surveillance?
    var parentLocation:Location!
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
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

        editPortRemote.inputAccessoryView = CustomToolBar()
        editPortLocal.inputAccessoryView = CustomToolBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SurveillanceSettingsVC.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
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
            
            if let levelId = surv.surveillanceLevelId as? Int {
                level = DatabaseZoneController.shared.getZoneById(levelId, location: surv.location!)
            }
            if let zoneId = surv.surveillanceLevelId as? Int {
                zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: surv.location!)
            }
            if let categoryId = surv.surveillanceLevelId as? Int {
                category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: surv.location!)
            }
            

            if let localIp = surv.localIp {
                editIPLocal.text = localIp
            }
            if let localPort = surv.localPort {
                editPortLocal.text = localPort
            }
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveillanceSettingsVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveillanceSettingsVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)

    }
    
    override func nameAndId(name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            zoneButton.setTitle("All", forState: .Normal)
            zoneSelected = nil
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            break
        default:
            break
        }
        
        button.setTitle(name, forState: .Normal)
    }

    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnLevel(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(parentLocation)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnCategoryAction(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(parentLocation)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnZoneAction(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(parentLocation, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
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
                    
                    surveillance.surveillanceLevelId = level?.id
                    surveillance.surveillanceZoneId = zoneSelected?.id
                    surveillance.surveillanceCategoryId = category?.id
                    
                    surveillance.tiltStep = 1
                    surveillance.panStep = 1
                    surveillance.autSpanStep = 1
                    surveillance.dwellTime = 15
                    surveillance.location = parentLocation
                    CoreDataController.shahredInstance.saveChanges()
                }
            }else if let surv = surv{
                
                surv.name = name
                surv.username = username
                surv.password = password
                
                surv.surveillanceLevel = levelButton.titleLabel?.text
                surv.surveillanceZone = zoneButton.titleLabel?.text
                surv.surveillanceCategory = categoryButton.titleLabel?.text
                
                surv.surveillanceLevelId = level?.id
                surv.surveillanceZoneId = zoneSelected?.id
                surv.surveillanceCategoryId = category?.id
                
                surv.localIp = localIp
                surv.localPort = localPort
                surv.ip = remoteIp
                surv.port = remotePortNumber
                
                CoreDataController.shahredInstance.saveChanges()
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
            delegate?.addEditSurveillanceFinished()
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
    
    func keyboardWillHide(notification: NSNotification) {
        self.centarConstraint.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
}

extension SurveillanceSettingsVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendantOfView(backView){
                self.view.endEditing(true)
                return false
            }
        }
        return true
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
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.5, 1.5)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
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
                //                presentedControllerView.center.y += containerView.bounds.size.height
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
