//
//  SecuritySettingsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SecuritySettingsViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate {

    @IBOutlet weak var backView: UIView!
    
    var isPresenting:Bool = false
    var defaults:NSUserDefaults!
    
    @IBOutlet weak var addOne: UITextField!
    @IBOutlet weak var addTwo: UITextField!
    @IBOutlet weak var addThree: UITextField!
    @IBOutlet weak var btnChooseGateway: CustomGradientButton!
    var gateways:[Gateway]?
    var securities:[Security]?
    var popoverVC:PopOverViewController = PopOverViewController()
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    func endEditingNow(){
        addOne.resignFirstResponder()
        addTwo.resignFirstResponder()
        addThree.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        addOne.inputAccessoryView = keyboardDoneButtonView
        addTwo.inputAccessoryView = keyboardDoneButtonView
        addThree.inputAccessoryView = keyboardDoneButtonView
        
        defaults = NSUserDefaults.standardUserDefaults()
        
        fetchSecurity()
        addOne.text = returnThreeCharactersForByte(Int(securities![0].addressOne))
        addTwo.text = returnThreeCharactersForByte(Int(securities![0].addressTwo))
        addThree.text = returnThreeCharactersForByte(Int(securities![0].addressThree))

        transitioningDelegate = self
        
        if let gateway = securities![0].gateway {
            btnChooseGateway.setTitle("\(gateway.name) \(gateway.gatewayDescription)" , forState: UIControlState.Normal)
        }
        
        
        // Do any additional setup after loading the view.
    }
    func saveGatewayToSecurities () {
        fetchSecurity()
        fetchGateways()
        if securities!.count > 0 && gateways!.count > 0{
            for security in securities! {
                security.gateway = gateways![0]
            }
            saveChanges()
        }
    }
    
    func fetchSecurity() {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Security")
        let sortDescriptorTwo = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        do {
            print(appDel)
            print(appDel.managedObjectContext!)
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Security]
            securities = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
//    func returnThreeCharactersForByte (number:Int) -> String {
//        return String(format: "%03d",number)
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var pickedGatewayName:String = ""
    var pickedGateway:Gateway?
    func saveText(text: String, gateway: Gateway) {
        pickedGateway = gateway
        btnChooseGateway.setTitle(text , forState: UIControlState.Normal)
//        fetchGateways()
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
    
    func fetchGateways () {
        var error:NSError?
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicateOne = NSPredicate(format: "name == %@", pickedGatewayName)
        let predicateTwo = NSPredicate(format: "name == %@", pickedGatewayName)
        let predicateThree = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateTwo, predicateThree])
        fetchRequest.predicate = compoundPredicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
            gateways = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    @IBAction func btnChooseGateway(sender: AnyObject) {
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 15
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if addOne.text != "" && addTwo.text != "" && addThree.text != "" {
            if let addressOne = Int(addOne.text!), let addressTwo = Int(addTwo.text!), let addressThree = Int(addThree.text!) {
                if let gateway = pickedGateway {
                    defaults.setObject(addressOne, forKey: UserDefaults.Security.AddressOne)
                    defaults.setObject(addressTwo, forKey: UserDefaults.Security.AddressTwo)
                    defaults.setObject(addressThree, forKey: UserDefaults.Security.AddressThree)
                    for security in securities! {
                        security.addressOne = addressOne
                        security.addressTwo = addressTwo
                        security.addressThree = addressThree
                    }
                    saveChanges()
//                    saveGatewayToSecurities()
//                    fetchSecurity()
//                    fetchGateways()
                    if securities!.count > 0 {
                        for security in securities! {
                            security.gateway = gateway
                        }
                        saveChanges()
                    }
                }
            }
        }
    }
    
    @IBAction func backBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.center.x += containerView!.bounds.size.width
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x -= containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x += containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
    
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
