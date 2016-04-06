//
//  ConnectionSettingsVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

protocol AddEditGatewayDelegate{
    func add_editGatewayFinished()
}

class ConnectionSettingsVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var isPresenting: Bool = true
    
    var delegate:AddEditGatewayDelegate?
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var addressFirst: EditTextField!
    @IBOutlet weak var addressSecond: EditTextField!
    @IBOutlet weak var addressThird: EditTextField!
    
    @IBOutlet weak var name: EditTextField!
    
    @IBOutlet weak var txtDescription: UITextView!

    @IBOutlet weak var ipHost: EditTextField!
    @IBOutlet weak var port: EditTextField!
    @IBOutlet weak var localIP: EditTextField!
    @IBOutlet weak var localPort: EditTextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var location:Location?
    var gateway:Gateway?

    @IBOutlet weak var centarY: NSLayoutConstraint!
    
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtAutoReconnectDelay: EditTextField!
    
    init(gateway:Gateway?, location:Location?){
        super.init(nibName: "ConnectionSettingsVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.location = location
        self.gateway = gateway
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
    
    func endEditingNow(){
        port.resignFirstResponder()
        localPort.resignFirstResponder()
        txtAutoReconnectDelay.resignFirstResponder()
        centarY.constant = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ConnectionSettingsVC.endEditingNow) )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        port.inputAccessoryView = keyboardDoneButtonView
        localPort.inputAccessoryView = keyboardDoneButtonView
        txtAutoReconnectDelay.inputAccessoryView = keyboardDoneButtonView

        print(UIDevice.currentDevice().SSID)
        
        if UIScreen.mainScreen().scale > 2.5{
            txtDescription.layer.borderWidth = 1
        }else{
            txtDescription.layer.borderWidth = 0.5
        }
        txtDescription.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
//        let gradient:CAGradientLayer = CAGradientLayer()
//        gradient.frame = backView.bounds
//        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
//        backView.layer.insertSublayer(gradient, atIndex: 0)
//        backView.layer.borderWidth = 1
//        backView.layer.borderColor = UIColor.lightGrayColor().CGColor
//        backView.layer.cornerRadius = 10
//        backView.clipsToBounds = true
        
        ipHost.delegate = self
        port.delegate = self
        localIP.delegate = self
        localPort.delegate = self
        addressFirst.delegate = self
        addressSecond.delegate = self
        addressThird.delegate = self
        name.delegate = self
        txtDescription.delegate = self
        txtAutoReconnectDelay.delegate = self
        
        name.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)

        // Do any additional setup after loading the view.
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate


        // Default gateway address
        if let gateway = gateway{
            ipHost.text = gateway.remoteIp
            port.text = "\(gateway.remotePort)"
            localIP.text = gateway.localIp
            localPort.text = "\(gateway.localPort)"
            addressFirst.text = returnThreeCharactersForByte(Int(gateway.addressOne))
            addressSecond.text = returnThreeCharactersForByte(Int(gateway.addressTwo))
            addressThird.text = returnThreeCharactersForByte(Int(gateway.addressThree))
            txtDescription.text = gateway.gatewayDescription
            name.text = gateway.location.name
        }else{
            name.text = location?.name
            addressFirst.text = returnThreeCharactersForByte(1)
            addressSecond.text = returnThreeCharactersForByte(0)
            addressThird.text = returnThreeCharactersForByte(0)
            txtDescription.text = "G-ADP-01"
            localIP.text = "192.168.0.181"
            localPort.text = "5101"
            ipHost.text = "192.168.0.181"
            port.text = "5101"
        }
        
    }

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
        
        self.view.layoutIfNeeded()
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
        if ipHost.text == "" || port.text == "" || localIP.text == "" || localPort.text == "" || addressFirst.text == "" || addressSecond.text == "" || addressThird.text == "" || name.text == "" || txtAutoReconnectDelay.text == "" {
            
            UIView.hr_setToastThemeColor(color: UIColor.redColor())
            self.view.makeToast(message: "Please fill all text fields")
            
        } else {
            if let adrFirst = Int(addressFirst.text!), let adrSecond = Int(addressSecond.text!), let adrThird = Int(addressThird.text!) {
                if adrFirst <= 255 && adrSecond <= 255 && adrThird <= 255 {
                    
                    if gateway == nil{
                        if let location = location{
                            let gateway = Gateway(context: appDel.managedObjectContext!)
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
                            gateway.addressOne = Int(addressFirst.text!)!
                            gateway.addressTwo = Int(addressSecond.text!)!
                            gateway.addressThree = Int(addressThird.text!)!
                            gateway.gatewayDescription = txtDescription.text
                            gateway.turnedOn = true
                            gateway.autoReconnectDelay = NSNumber(integer: 3)
                            gateway.location = location
                            saveChanges()
                            self.dismissViewControllerAnimated(true, completion: nil)
                            delegate?.add_editGatewayFinished()
                        }
                    }else{
                        gateway?.name = name.text!
                        gateway?.remoteIp = ipHost.text!
                        gateway?.remotePort = Int(port.text!)!
                        gateway?.localIp = localIP.text!
                        gateway?.localPort = Int(localPort.text!)!
                        gateway?.addressOne = Int(addressFirst.text!)!
                        gateway?.addressTwo = Int(addressSecond.text!)!
                        gateway?.addressThree = Int(addressThird.text!)!
                        gateway?.gatewayDescription = txtDescription.text
                        saveChanges()
                        self.dismissViewControllerAnimated(true, completion: nil)
                        delegate?.add_editGatewayFinished()
                    }
                    
                }
            }
        }
    }

    var appDel:AppDelegate!
    var error:NSError? = nil

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
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.localPort.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtAutoReconnectDelay.isFirstResponder(){
            if backView.frame.origin.y + txtAutoReconnectDelay.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.txtAutoReconnectDelay.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
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
    func showConnectionSettings(gateway: Gateway?, location:Location?) -> ConnectionSettingsVC{
        let connSettVC = ConnectionSettingsVC(gateway: gateway, location: location)
        self.presentViewController(connSettVC, animated: true, completion: nil)
        return connSettVC
    }
}
