//
//  SurveillanceSettingsVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/24/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SurveillanceSettingsVC: UIViewController,UITextFieldDelegate {
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var editID: UITextField!
    @IBOutlet weak var editPort: UITextField!
    @IBOutlet weak var editUserName: UITextField!
    @IBOutlet weak var editPassword: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    
    init(){
        super.init(nibName: "SurveillanceSettingsVC", bundle: nil)
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
            editID.layer.borderWidth = 1
            editPort.layer.borderWidth = 1
            editUserName.layer.borderWidth = 1
            editPassword.layer.borderWidth = 1
        }else{
            editID.layer.borderWidth = 0.5
            editPort.layer.borderWidth = 0.5
            editUserName.layer.borderWidth = 0.5
            editPassword.layer.borderWidth = 0.5
        }
        
        editID.layer.cornerRadius = 2
        editPort.layer.cornerRadius = 2
        editUserName.layer.cornerRadius = 2
        editPassword.layer.cornerRadius = 2
        
        editID.layer.borderColor = UIColor.lightGrayColor().CGColor
        editPort.layer.borderColor = UIColor.lightGrayColor().CGColor
        editUserName.layer.borderColor = UIColor.lightGrayColor().CGColor
        editPassword.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        editID.attributedPlaceholder = NSAttributedString(string:"IP/Host",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editPort.attributedPlaceholder = NSAttributedString(string:"Port",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editUserName.attributedPlaceholder = NSAttributedString(string:"IP/Host",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        editPassword.attributedPlaceholder = NSAttributedString(string:"Port",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = backView.bounds
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        backView.layer.insertSublayer(gradient, atIndex: 0)
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.lightGrayColor().CGColor
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = true
        
        editID.delegate = self
        editPort.delegate = self
        editUserName.delegate = self
        editPassword.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
        if editID.text == "" || editPort.text == "" || editUserName.text == "" || editPassword.text == ""{
            
            
        } else {
            let surveillance = NSEntityDescription.insertNewObjectForEntityForName("Surveilence", inManagedObjectContext: appDel.managedObjectContext!) as! Surveilence
            surveillance.ip = editID.text!
            surveillance.port = Int(editPort.text!)!
            surveillance.username = editUserName.text!
            surveillance.password = editPassword.text!
            saveChanges()
            self.dismissViewControllerAnimated(true, completion: nil)
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
    func showSurveillanceSettings() {
        let connSettVC = SurveillanceSettingsVC()
        self.presentViewController(connSettVC, animated: true, completion: nil)
    }
}
