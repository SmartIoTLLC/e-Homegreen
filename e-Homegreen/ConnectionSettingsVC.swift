//
//  ConnectionSettingsVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreData

extension UIDevice {
    public var SSID: String? {
        get {
            if let interfaces = CNCopySupportedInterfaces() {
                let interfacesArray = interfaces.takeRetainedValue() as! [String]
                if let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfacesArray[0] as String) {
                    let interfaceData = unsafeInterfaceData.takeRetainedValue() as Dictionary!
                    return interfaceData[kCNNetworkInfoKeySSID] as? String
                }
            }
            return nil
            
        }
    }
}

class ConnectionSettingsVC: UIViewController, UITextFieldDelegate {
    
    var gatewayIndex:Int = -1
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var addressFirst: UITextField!
    @IBOutlet weak var addressSecond: UITextField!
    @IBOutlet weak var name: UITextField!
    

    @IBOutlet weak var ipHost: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var localIP: UITextField!
    @IBOutlet weak var localPort: UITextField!
    @IBOutlet weak var localSSID: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    

    @IBOutlet weak var centarY: NSLayoutConstraint!
    
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    
    init(){
        super.init(nibName: "ConnectionSettingsVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        println(UIDevice.currentDevice().SSID)
        
        addressFirst.layer.borderWidth = 0.5
        addressSecond.layer.borderWidth = 0.5
        name.layer.borderWidth = 0.5
        ipHost.layer.borderWidth = 0.5
        port.layer.borderWidth = 0.5
        localIP.layer.borderWidth = 0.5
        localPort.layer.borderWidth = 0.5
        localSSID.layer.borderWidth = 0.5
        addressFirst.layer.cornerRadius = 2
        addressSecond.layer.cornerRadius = 2
        name.layer.cornerRadius = 2
        ipHost.layer.cornerRadius = 2
        port.layer.cornerRadius = 2
        localIP.layer.cornerRadius = 2
        localPort.layer.cornerRadius = 2
        localSSID.layer.cornerRadius = 2
        addressFirst.layer.borderColor = UIColor.lightGrayColor().CGColor
        addressSecond.layer.borderColor = UIColor.lightGrayColor().CGColor
        name.layer.borderColor = UIColor.lightGrayColor().CGColor
        ipHost.layer.borderColor = UIColor.lightGrayColor().CGColor
        port.layer.borderColor = UIColor.lightGrayColor().CGColor
        localIP.layer.borderColor = UIColor.lightGrayColor().CGColor
        localPort.layer.borderColor = UIColor.lightGrayColor().CGColor
        localSSID.layer.borderColor = UIColor.lightGrayColor().CGColor
        ipHost.attributedPlaceholder = NSAttributedString(string:"IP/Host",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        port.attributedPlaceholder = NSAttributedString(string:"Port",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        localIP.attributedPlaceholder = NSAttributedString(string:"IP/Host",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        localPort.attributedPlaceholder = NSAttributedString(string:"Port",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        localSSID.attributedPlaceholder = NSAttributedString(string:"SSID",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        addressFirst.attributedPlaceholder = NSAttributedString(string:"Add",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        addressSecond.attributedPlaceholder = NSAttributedString(string:"Add",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        name.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = backView.bounds
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
        backView.layer.insertSublayer(gradient, atIndex: 0)
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.lightGrayColor().CGColor
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = true
        
        ipHost.delegate = self
        port.delegate = self
        localIP.delegate = self
        localPort.delegate = self
        localSSID.delegate = self
        addressFirst.delegate = self
        addressSecond.delegate = self
        name.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)

        // Do any additional setup after loading the view.

        // Default gateway address
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        if gatewayIndex == -1 {
            addressFirst.text = "\(1)"
            addressSecond.text = "\(0)"
        } else {
            fetchGateways()
            ipHost.text = "\(gateways[gatewayIndex].remoteIp)"
            port.text = "\(gateways[gatewayIndex].remotePort)"
            localIP.text = "\(gateways[gatewayIndex].localIp)"
            localPort.text = "\(gateways[gatewayIndex].localPort)"
            localSSID.text = "\(gateways[gatewayIndex].ssid)"
            addressFirst.text = "\(gateways[gatewayIndex].addressOne)"
            addressSecond.text = "\(gateways[gatewayIndex].addressTwo)"
            name.text = "\(gateways[gatewayIndex].name)"
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        println()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.centarY.constant = 0
        })
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        var info = notification.userInfo!
//        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        if localIP.isFirstResponder(){
//            if backView.frame.origin.y + localIP.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
//                UIView.animateWithDuration(0.8, animations: { () -> Void in
//                    self.topConstraint.constant = 15 - (self.backView.frame.origin.y + self.localIP.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height))
//                })
//            }
//        }
//        if localPort.isFirstResponder(){
//            if backView.frame.origin.y + localPort.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
//                UIView.animateWithDuration(0.8, animations: { () -> Void in
//                    self.topConstraint.constant = 15 - (self.backView.frame.origin.y + self.localPort.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height))
//                })
//            }
//        }
//        if localSSID.isFirstResponder(){
//            if backView.frame.origin.y + localSSID.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
//                UIView.animateWithDuration(0.8, animations: { () -> Void in
//                    self.topConstraint.constant = 15 - (self.backView.frame.origin.y + self.localSSID.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height))
//                })
//            }
//        }
//    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.height == 320{
                backViewHeightConstraint.constant = 250
            }else if self.view.frame.size.height == 375{
                backViewHeightConstraint.constant = 300
            }else if self.view.frame.size.height == 414{
                backViewHeightConstraint.constant = 350
            }else{
                backViewHeightConstraint.constant = 460
            }
        }else{
            
            backViewHeightConstraint.constant = 460
            
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
//        if ipHost.text == "" || port.text == "" || localIP.text == "" || localPort.text == "" || localSSID.text == "" || addressFirst.text == "" || addressSecond.text == "" || name.text == "" {
//            
//        } else {
//            if let remotePortNumber = port.text.toInt(), let localPortNumber = localPort.text.toInt() {
//                // Save gateway to database
//            }
//        }
        if gatewayIndex == -1 {
            var gateway = NSEntityDescription.insertNewObjectForEntityForName("Gateway", inManagedObjectContext: appDel.managedObjectContext!) as! Gateway
            gateway.name = name.text
            gateway.remoteIp = ipHost.text
            gateway.remotePort = port.text.toInt()!
            gateway.localIp = localIP.text
            gateway.localPort = localPort.text.toInt()!
            gateway.ssid = localSSID.text
            gateway.addressOne = addressFirst.text.toInt()!
            gateway.addressTwo = addressSecond.text.toInt()!
            gateway.turnedOn = true
            saveChanges()
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            gateways[gatewayIndex].remoteIp = ipHost.text
            gateways[gatewayIndex].remotePort = port.text.toInt()!
            gateways[gatewayIndex].localIp = localIP.text
            gateways[gatewayIndex].localPort = localPort.text.toInt()!
            gateways[gatewayIndex].ssid = localSSID.text
            gateways[gatewayIndex].addressOne = addressFirst.text.toInt()!
            gateways[gatewayIndex].addressTwo = addressSecond.text.toInt()!
            gateways[gatewayIndex].name = name.text
            saveChanges()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    var appDel:AppDelegate!
    var gateways:[Gateway] = []
    var error:NSError? = nil
    func fetchGateways() {
        var fetchRequest = NSFetchRequest(entityName: "Gateway")
        var sortDescriptor1 = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Gateway]
        if let results = fetResults {
            gateways = results
        } else {
            
        }
    }
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        NSNotificationCenter.defaultCenter().postNotificationName("updateGatewayListNotification", object: self, userInfo: nil)
    }
    @IBOutlet weak var scrollViewConnection: UIScrollView!
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        if name.isFirstResponder(){
            if backView.frame.origin.y + name.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    self.centarY.constant = 5 + (self.backView.frame.origin.y + self.name.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                })
            }
        }
        if ipHost.isFirstResponder(){
            if backView.frame.origin.y + ipHost.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    self.centarY.constant = 5 + (self.backView.frame.origin.y + self.ipHost.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                })
            }
        }
        if port.isFirstResponder(){
            if backView.frame.origin.y + port.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    self.centarY.constant = 5 + (self.backView.frame.origin.y + self.port.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                })
            }
        }
        if localIP.isFirstResponder(){
            if backView.frame.origin.y + localIP.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    self.centarY.constant = 5 + (self.backView.frame.origin.y + self.localIP.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                })
            }
        }
        if localPort.isFirstResponder(){
            if backView.frame.origin.y + localPort.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    self.centarY.constant = 5 + (self.backView.frame.origin.y + self.localPort.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                })
            }
        }
        if localSSID.isFirstResponder(){
            if backView.frame.origin.y + localSSID.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    self.centarY.constant = 5 + (self.backView.frame.origin.y + self.localSSID.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                })
            }
        }
    }

}

extension ConnectionSettingsVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
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
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
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



extension ConnectionSettingsVC : UIViewControllerTransitioningDelegate {
    
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
    func showConnectionSettings(gatewayIndex: Int) {
        var connSettVC = ConnectionSettingsVC()
        connSettVC.gatewayIndex = gatewayIndex
//        self.view.window?.rootViewController?.presentViewController(connSettVC, animated: true, completion: nil)
        self.presentViewController(connSettVC, animated: true, completion: nil)
    }
}