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
    @objc func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnLevel(_ sender: UIButton) {
        levelTapped(sender: sender)
    }
    @IBAction func btnCategoryAction(_ sender: UIButton) {
        categoryTapped(sender: sender)
    }
    @IBAction func btnZoneAction(_ sender: UIButton) {
        zoneTapped(sender: sender)
    }
    @IBAction func btnSave(_ sender: AnyObject) {
        save()
    }
    
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
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addObservers()
    }
    
    override func nameAndId(_ name: String, id: String) {
        
        switch button.tag {
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            zoneButton.setTitle("All", for: UIControlState())
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
        
        button.setTitle(name, for: UIControlState())
    }
    
}

// MARK: - View setup
extension SurveillanceSettingsVC {
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func setupViews() {
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        editPortRemote.inputAccessoryView = CustomToolBar()
        editPortLocal.inputAccessoryView  = CustomToolBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        editIPRemote.delegate   = self
        editPortRemote.delegate = self
        editUserName.delegate   = self
        editPassword.delegate   = self
        editName.delegate       = self
        editIPLocal.delegate    = self
        editPortLocal.delegate  = self
        
        if let surv = surv {
            
            editIPRemote.text = surv.ip
            if let port = surv.port { editPortRemote.text = "\(port)" }
            editUserName.text = surv.username
            editPassword.text = surv.password
            editName.text     = surv.name
            
            levelButton.setTitle(surv.surveillanceLevel, for: UIControlState())
            zoneButton.setTitle(surv.surveillanceZone, for: UIControlState())
            categoryButton.setTitle(surv.surveillanceCategory, for: UIControlState())
            
            if let levelId = surv.surveillanceLevelId as? Int { level = DatabaseZoneController.shared.getZoneById(levelId, location: surv.location!) }
            if let zoneId = surv.surveillanceLevelId as? Int { zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: surv.location!) }
            if let categoryId = surv.surveillanceLevelId as? Int { category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: surv.location!) }
            
            if let localIp = surv.localIp { editIPLocal.text = localIp }
            if let localPort = surv.localPort { editPortLocal.text = localPort }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: editPortRemote, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editIPRemote, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editPortLocal, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editIPLocal, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editUserName, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editPassword, keyboardFrame: keyboardFrame, backView: backView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
}

// MARK: - Logic
extension SurveillanceSettingsVC {
    fileprivate func save() {
        if  let remoteIp = editIPRemote.text,let remotePort = editPortRemote.text, let username =  editUserName.text, let password = editPassword.text, let name =  editName.text, let remotePortNumber = Int(remotePort),let localIp = editIPLocal.text, let localPort = editPortLocal.text {
            if surv == nil {
                if let parentLocation = parentLocation {
                    let surveillance = Surveillance(context: appDel.managedObjectContext!)
                    
                    surveillance.name                 = name
                    surveillance.username             = username
                    surveillance.password             = password
                    surveillance.surveillanceLevel    = levelButton.titleLabel?.text
                    surveillance.surveillanceZone     = zoneButton.titleLabel?.text
                    surveillance.surveillanceCategory = categoryButton.titleLabel?.text
                    surveillance.localIp              = localIp
                    surveillance.localPort            = localPort
                    surveillance.ip                   = remoteIp
                    surveillance.port                 = remotePortNumber as NSNumber?
                    
                    surveillance.isVisible = true
                    
                    surveillance.urlHome               = ""
                    surveillance.urlMoveUp             = ""
                    surveillance.urlMoveRight          = ""
                    surveillance.urlMoveLeft           = ""
                    surveillance.urlMoveDown           = ""
                    surveillance.urlAutoPan            = ""
                    surveillance.urlAutoPanStop        = ""
                    surveillance.urlPresetSequence     = ""
                    surveillance.urlPresetSequenceStop = ""
                    surveillance.urlGetImage           = ""
                    
                    surveillance.surveillanceLevelId    = level?.id
                    surveillance.surveillanceZoneId     = zoneSelected?.id
                    surveillance.surveillanceCategoryId = category?.id
                    
                    surveillance.tiltStep    = 1
                    surveillance.panStep     = 1
                    surveillance.autSpanStep = 1
                    surveillance.dwellTime   = 15
                    surveillance.location    = parentLocation
                    CoreDataController.sharedInstance.saveChanges()
                }
            }else if let surv = surv {
                
                surv.name     = name
                surv.username = username
                surv.password = password
                
                surv.surveillanceLevel    = levelButton.titleLabel?.text
                surv.surveillanceZone     = zoneButton.titleLabel?.text
                surv.surveillanceCategory = categoryButton.titleLabel?.text
                
                surv.surveillanceLevelId    = level?.id
                surv.surveillanceZoneId     = zoneSelected?.id
                surv.surveillanceCategoryId = category?.id
                
                surv.localIp   = localIp
                surv.localPort = localPort
                surv.ip        = remoteIp
                surv.port      = remotePortNumber as NSNumber?
                
                CoreDataController.sharedInstance.saveChanges()
            }
            
            self.dismiss(animated: true, completion: nil)
            delegate?.addEditSurveillanceFinished()
        }
    }
    
    fileprivate func levelTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(parentLocation)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func categoryTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(parentLocation)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func zoneTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level {
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(parentLocation, parentZone: level)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
}

// MARK: - Gesture Recognizer Delegate
extension SurveillanceSettingsVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view { if touchView.isDescendant(of: backView) { dismissEditing(); return false } }
        return true
    }
}

extension SurveillanceSettingsVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.5, scaleOneY: 1.5, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)
    }
}

extension SurveillanceSettingsVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}

// MARK: - TextField Delegate
extension SurveillanceSettingsVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showSurveillanceSettings(_ surv: Surveillance?, location:Location?) -> SurveillanceSettingsVC {
        let survSettVC = SurveillanceSettingsVC(surv: surv, location:location)
        self.present(survSettVC, animated: true, completion: nil)
        return survSettVC
    }
}
