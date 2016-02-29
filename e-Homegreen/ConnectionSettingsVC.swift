//
//  ConnectionSettingsVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ConnectionSettingsVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var gatewayIndex:Int = -1
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var addressFirst: UITextField!
    @IBOutlet weak var addressSecond: UITextField!
    @IBOutlet weak var addressThird: UITextField!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var txtDescription: UITextView!

    @IBOutlet weak var ipHost: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var localIP: UITextField!
    @IBOutlet weak var localPort: UITextField!
    @IBOutlet weak var localSSID: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    

    @IBOutlet weak var centarY: NSLayoutConstraint!
    
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtAutoReconnectDelay: UITextField!
    
    init(){
        super.init(nibName: "ConnectionSettingsVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.centarY.constant = 0
            })
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(UIDevice.currentDevice().SSID)
        
        if UIScreen.mainScreen().scale > 2.5{
            addressFirst.layer.borderWidth = 1
            addressSecond.layer.borderWidth = 1
            addressThird.layer.borderWidth = 1
            txtDescription.layer.borderWidth = 1
            name.layer.borderWidth = 1
            ipHost.layer.borderWidth = 1
            port.layer.borderWidth = 1
            localIP.layer.borderWidth = 1
            localPort.layer.borderWidth = 1
            localSSID.layer.borderWidth = 1
        }else{
            addressFirst.layer.borderWidth = 0.5
            addressSecond.layer.borderWidth = 0.5
            addressThird.layer.borderWidth = 0.5
            txtDescription.layer.borderWidth = 0.5
            name.layer.borderWidth = 0.5
            ipHost.layer.borderWidth = 0.5
            port.layer.borderWidth = 0.5
            localIP.layer.borderWidth = 0.5
            localPort.layer.borderWidth = 0.5
            localSSID.layer.borderWidth = 0.5
        }
        addressFirst.layer.cornerRadius = 2
        addressSecond.layer.cornerRadius = 2
        addressThird.layer.cornerRadius = 2
        name.layer.cornerRadius = 2
        ipHost.layer.cornerRadius = 2
        port.layer.cornerRadius = 2
        localIP.layer.cornerRadius = 2
        localPort.layer.cornerRadius = 2
        localSSID.layer.cornerRadius = 2
        addressFirst.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtDescription.layer.borderColor = UIColor.lightGrayColor().CGColor
        addressSecond.layer.borderColor = UIColor.lightGrayColor().CGColor
        addressThird.layer.borderColor = UIColor.lightGrayColor().CGColor
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
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = backView.bounds
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
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
        addressThird.delegate = self
        name.delegate = self
        txtDescription.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)

        // Do any additional setup after loading the view.

        // Default gateway address
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        if gatewayIndex == -1 {
            name.text = ""
            addressFirst.text = returnThreeCharactersForByte(1)
            addressSecond.text = returnThreeCharactersForByte(0)
            addressThird.text = returnThreeCharactersForByte(0)
            txtDescription.text = "G-ADP-01"
            localIP.text = "192.168.0.181"
            localPort.text = "5101"
            localSSID.text = ""
            ipHost.text = "192.168.0.181"
            port.text = "5101"
            
        } else {
            fetchGateways()
            ipHost.text = "\(gateways[gatewayIndex].remoteIp)"
            port.text = "\(gateways[gatewayIndex].remotePort)"
            localIP.text = "\(gateways[gatewayIndex].localIp)"
            localPort.text = "\(gateways[gatewayIndex].localPort)"
            localSSID.text = "\(gateways[gatewayIndex].ssid)"
            addressFirst.text = returnThreeCharactersForByte(Int(gateways[gatewayIndex].addressOne))
            addressSecond.text = returnThreeCharactersForByte(Int(gateways[gatewayIndex].addressTwo))
            addressThird.text = returnThreeCharactersForByte(Int(gateways[gatewayIndex].addressThree))
            txtDescription.text = "\(gateways[gatewayIndex].gatewayDescription)"
            name.text = "\(gateways[gatewayIndex].name)"
        }
        
    }
//    func returnThreeCharactersForByte (number:Int) -> String {
//        return String(format: "%03d",number)
//    }
    override func viewWillAppear(animated: Bool) {
        print("")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.centarY.constant = 0
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
    
    override func viewWillLayoutSubviews() {
//        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
//            if self.view.frame.size.height == 320{
//                backViewHeightConstraint.constant = 250
//            }else if self.view.frame.size.height == 375{
//                backViewHeightConstraint.constant = 300
//            }else if self.view.frame.size.height == 414{
//                backViewHeightConstraint.constant = 350
//            }else{
//                backViewHeightConstraint.constant = 480
//            }
//        }else{
//            
//            backViewHeightConstraint.constant = 480
//            
//        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        if ipHost.text == "" || port.text == "" || localIP.text == "" || localPort.text == "" || localSSID.text == "" || addressFirst.text == "" || addressSecond.text == "" || addressThird.text == "" || name.text == "" {
            
        } else {
            //            if let remoPort = Int(port.text!), let locaPort = Int(localPort.text!), let adrFirst = Int(addressFirst.text!), let adrSecond = Int(addressSecond.text!), let adrThird = Int(addressThird.text!) {
            if let adrFirst = Int(addressFirst.text!), let adrSecond = Int(addressSecond.text!), let adrThird = Int(addressThird.text!) {
                if adrFirst <= 255 && adrSecond <= 255 && adrThird <= 255 {
                    if gatewayIndex == -1 {
                        let gateway = Gateway(context: appDel.managedObjectContext!)
//                        let gateway = NSEntityDescription.insertNewObjectForEntityForName("Gateway", inManagedObjectContext: appDel.managedObjectContext!) as! Gateway
                        gateway.name = name.text!
                        if ipHost.text == "" {
                            gateway.remoteIp = "0"
                        } else {
                            gateway.remoteIp = ipHost.text!
                        }
                        if port.text == "" {
                            gateway.remotePort = 0
                        } else {
                            gateway.remotePort = Int(port.text!)!
                        }
                        gateway.localIp = localIP.text!
                        gateway.localPort = Int(localPort.text!)!
                        gateway.ssid = localSSID.text!
                        gateway.addressOne = Int(addressFirst.text!)!
                        gateway.addressTwo = Int(addressSecond.text!)!
                        gateway.addressThree = Int(addressThird.text!)!
                        gateway.gatewayDescription = txtDescription.text
                        gateway.turnedOn = true
                        gateway.autoReconnectDelay = NSNumber(integer: 3)
                        createZonesAndCategories(gateway)
                        saveChanges()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        gateways[gatewayIndex].name = name.text!
                        gateways[gatewayIndex].remoteIp = ipHost.text!
                        gateways[gatewayIndex].remotePort = Int(port.text!)!
                        gateways[gatewayIndex].localIp = localIP.text!
                        gateways[gatewayIndex].localPort = Int(localPort.text!)!
                        gateways[gatewayIndex].ssid = localSSID.text!
                        gateways[gatewayIndex].addressOne = Int(addressFirst.text!)!
                        gateways[gatewayIndex].addressTwo = Int(addressSecond.text!)!
                        gateways[gatewayIndex].addressThree = Int(addressThird.text!)!
                        gateways[gatewayIndex].gatewayDescription = txtDescription.text
                        saveChanges()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
    }
    func createZonesAndCategories(gateway:Gateway) {
        if let zonesJSON = DataImporter.createZonesFromFileFromNSBundle() {
            for zoneJSON in zonesJSON {
                let zone = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as! Zone
                if zoneJSON.id == 254 || zoneJSON.id == 255 {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.gateway) = (zoneJSON.id, zoneJSON.name, zoneJSON.description, zoneJSON.level, NSNumber(bool: false), gateway)
                } else {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.gateway) = (zoneJSON.id, zoneJSON.name, zoneJSON.description, zoneJSON.level, NSNumber(bool: true), gateway)
                }
                saveChanges()
                
            }
        }
        if let categoriesJSON = DataImporter.createCategoriesFromFileFromNSBundle() {
            for categoryJSON in categoriesJSON {
                let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.gateway) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: false), gateway)
                } else {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.gateway) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: true), gateway)
                }
                saveChanges()
            }
        }
    }
    var appDel:AppDelegate!
    var gateways:[Gateway] = []
    var error:NSError? = nil
    func fetchGateways() {
        let fetchRequest = NSFetchRequest(entityName: "Gateway")
        let sortDescriptor1 = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
            gateways = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
//        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
//        if let results = fetResults {
//            gateways = results
//        } else {
//            
//        }
    }
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.Gateway.Refresh, object: self, userInfo: nil)
        appDel.establishAllConnections()
    }
    
    @IBOutlet weak var scrollViewConnection: UIScrollView!
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if txtDescription.isFirstResponder(){
            if backView.frame.origin.y + txtDescription.frame.origin.y + 65 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = 5 + (self.backView.frame.origin.y + self.txtDescription.frame.origin.y + 65 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                
            }
        }
        if name.isFirstResponder(){
            if backView.frame.origin.y + name.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = 5 + (self.backView.frame.origin.y + self.name.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                
            }
        }
        if ipHost.isFirstResponder(){
            if backView.frame.origin.y + ipHost.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = 5 + (self.backView.frame.origin.y + self.ipHost.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                
            }
        }
        if port.isFirstResponder(){
            if backView.frame.origin.y + port.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = 5 + (self.backView.frame.origin.y + self.port.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                
            }
        }
        if localIP.isFirstResponder(){
            if backView.frame.origin.y + localIP.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = 5 + (self.backView.frame.origin.y + self.localIP.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                
            }
        }
        if localPort.isFirstResponder(){
            if backView.frame.origin.y + localPort.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = 5 + (self.backView.frame.origin.y + self.localPort.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                
            }
        }
        if localSSID.isFirstResponder(){
            if backView.frame.origin.y + localSSID.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                self.centarY.constant = 5 + (self.backView.frame.origin.y + self.localSSID.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
                
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }

}

extension ConnectionSettingsVC : UIViewControllerAnimatedTransitioning {
    
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
        let connSettVC = ConnectionSettingsVC()
        connSettVC.gatewayIndex = gatewayIndex
        self.presentViewController(connSettVC, animated: true, completion: nil)
    }
}
