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
    var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
    
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
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func endEditingNow(){
        editMajor.resignFirstResponder()
        editMinor.resignFirstResponder()
        centarConstraint.constant = 0
        UIView.animate(withDuration: 0.3,
            delay: 0,
            options: UIViewAnimationOptions.curveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        updateViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name:.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        centarConstraint.constant = 0
        UIView.animate(withDuration: 0.3,
            delay: 0,
            options: UIViewAnimationOptions.curveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        return true
    }
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if editName.text == "" || editUUID.text == "" || editMinor.text == "" || editMajor.text == "" {
           
        } else {
            if let minor = UInt16(editMinor.text!), let major = UInt16(editMajor.text!) {
                if uuidRegex.numberOfMatches(in: editUUID.text!, options: [], range: NSMakeRange(0, editUUID.text!.count)) > 0 {
                    if iBeacon == nil {
                        if let iBeaconNew = NSEntityDescription.insertNewObject(forEntityName: "IBeacon", into: appDel.managedObjectContext!) as? IBeacon {
                            iBeaconNew.name = editName.text!
                            iBeaconNew.uuid = editUUID.text!
                            iBeaconNew.major = NSNumber(value: major as UInt16)
                            iBeaconNew.minor =  NSNumber(value: minor as UInt16)
                        }
                    } else {
                        iBeacon!.name = editName.text!
                        iBeacon!.uuid = editUUID.text!
                        iBeacon!.major =  NSNumber(value: major as UInt16)
                        iBeacon!.minor = NSNumber(value: minor as UInt16)
                    }
                    CoreDataController.sharedInstance.saveChanges()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshIBeacon), object: self, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: editUUID, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editMajor, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editMinor, keyboardFrame: keyboardFrame, backView: backView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }

}

extension IBeaconSettingsVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.        
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.05, scaleOneY: 1.05, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)
    }
}

extension IBeaconSettingsVC {
    
    func updateViews() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)

        editMajor.inputAccessoryView = CustomToolBar()
        editMinor.inputAccessoryView = CustomToolBar()
        
        if UIScreen.main.scale > 2.5 {
            editName.layer.borderWidth = 1
            editUUID.layer.borderWidth = 1
            editMajor.layer.borderWidth = 1
            editMinor.layer.borderWidth = 1
        } else {
            editName.layer.borderWidth = 0.5
            editUUID.layer.borderWidth = 0.5
            editMajor.layer.borderWidth = 0.5
            editMinor.layer.borderWidth = 0.5
        }
        
        editName.layer.cornerRadius = 2
        editUUID.layer.cornerRadius = 2
        editMajor.layer.cornerRadius = 2
        editMinor.layer.cornerRadius = 2
        
        editName.layer.borderColor = UIColor.lightGray.cgColor
        editUUID.layer.borderColor = UIColor.lightGray.cgColor
        editMajor.layer.borderColor = UIColor.lightGray.cgColor
        editMinor.layer.borderColor = UIColor.lightGray.cgColor
        
        editName.attributedPlaceholder = NSAttributedString(string:"Name",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        editUUID.attributedPlaceholder = NSAttributedString(string:"UUID",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        editMajor.attributedPlaceholder = NSAttributedString(string:"Major",
                                                             attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        editMinor.attributedPlaceholder = NSAttributedString(string:"Minor",
                                                             attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        
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
        editUUID.text = "2B162531-FD29-4758-85B4-555A6DFF00FF"
        editUUID.tag = 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
}

extension IBeaconSettingsVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}

extension UIViewController {
    func showiBeaconSettings(_ iBeacon:IBeacon?) {
        let iBeaSet = IBeaconSettingsVC(iBeacon: iBeacon)
        self.present(iBeaSet, animated: true, completion: nil)
    }
}
