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
//    2B162531-FD29-4758-85B4-555A6DFF00FF
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
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        editMajor.inputAccessoryView = CustomToolBar()
        editMinor.inputAccessoryView = CustomToolBar()
        
        if UIScreen.main.scale > 2.5{
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(IBeaconSettingsVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(IBeaconSettingsVC.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if editName.text == "" || editUUID.text == "" || editMinor.text == "" || editMajor.text == ""{
           
        } else {
            if let minor = UInt16(editMinor.text!), let major = UInt16(editMajor.text!) {
                if uuidRegex.numberOfMatches(in: editUUID.text!, options: [], range: NSMakeRange(0, editUUID.text!.characters.count)) > 0{
                    if iBeacon == nil{
                        let iBeaconNew = NSEntityDescription.insertNewObject(forEntityName: "IBeacon", into: appDel.managedObjectContext!) as! IBeacon
                        iBeaconNew.name = editName.text!
                        iBeaconNew.uuid = editUUID.text!
                        iBeaconNew.major = NSNumber(value: major as UInt16)
                        iBeaconNew.minor =  NSNumber(value: minor as UInt16)
                    } else {
                        iBeacon!.name = editName.text!
                        iBeacon!.uuid = editUUID.text!
                        iBeacon!.major =  NSNumber(value: major as UInt16)
                        iBeacon!.minor = NSNumber(value: minor as UInt16)
                    }
                    CoreDataController.shahredInstance.saveChanges()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshIBeacon), object: self, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if editUUID.isFirstResponder{
            if backView.frame.origin.y + editUUID.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editUUID.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editMajor.isFirstResponder{
            if backView.frame.origin.y + editMajor.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editMajor.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editMinor.isFirstResponder{
            if backView.frame.origin.y + editMinor.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarConstraint.constant = 0 - (5 + (self.backView.frame.origin.y + self.editMinor.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }

 
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }


}

extension IBeaconSettingsVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            containerView.addSubview(presentedControllerView)
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension IBeaconSettingsVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}

extension UIViewController {
    func showiBeaconSettings(_ iBeacon:IBeacon?) {
        let iBeaSet = IBeaconSettingsVC(iBeacon: iBeacon)
        self.present(iBeaSet, animated: true, completion: nil)
    }
}
