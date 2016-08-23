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
    func addEditGatewayFinished()
}

class ConnectionSettingsVC: UIViewController {
    
    var isPresenting: Bool = true
    
    var delegate:AddEditGatewayDelegate?
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var addressFirst: EditTextField!
    @IBOutlet weak var addressSecond: EditTextField!
    @IBOutlet weak var addressThird: EditTextField!
    @IBOutlet weak var txtDescription: EditTextField!
    
    @IBOutlet weak var ipHost: EditTextField!
    @IBOutlet weak var port: EditTextField!
    
    @IBOutlet weak var localIP: EditTextField!
    @IBOutlet weak var localPort: EditTextField!
    
    @IBOutlet weak var txtAutoReconnectDelay: EditTextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var centarY: NSLayoutConstraint!
    @IBOutlet weak var scrollViewConnection: UIScrollView!
    
    var location:Location?
    var gateway:Gateway?
    var gatewayType:String!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    init(gateway:Gateway?, location:Location?,gatewayType:String){
        super.init(nibName: "ConnectionSettingsVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.location = location
        self.gateway = gateway
        self.gatewayType = gatewayType
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        port.inputAccessoryView = CustomToolBar()
        localPort.inputAccessoryView = CustomToolBar()
        txtAutoReconnectDelay.inputAccessoryView = CustomToolBar()
        addressFirst.inputAccessoryView = CustomToolBar()
        addressSecond.inputAccessoryView = CustomToolBar()
        addressThird.inputAccessoryView = CustomToolBar()

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
        
        ipHost.delegate = self
        port.delegate = self
        localIP.delegate = self
        localPort.delegate = self
        addressFirst.delegate = self
        addressSecond.delegate = self
        addressThird.delegate = self
        txtDescription.delegate = self
        txtAutoReconnectDelay.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)

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
            txtAutoReconnectDelay.text = "\(gateway.autoReconnectDelay!)"
        }else{
            addressFirst.text = returnThreeCharactersForByte(1)
            addressSecond.text = returnThreeCharactersForByte(0)
            addressThird.text = returnThreeCharactersForByte(0)
            txtDescription.text = "G-ADP-01"
            localIP.text = "192.168.0.181"
            localPort.text = "5101"
            ipHost.text = "192.168.0.181"
            port.text = "5101"
            txtAutoReconnectDelay.text = "3"
        }
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if txtDescription.isFirstResponder(){
            if backView.frame.origin.y + txtDescription.frame.origin.y + 65 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.txtDescription.frame.origin.y + 65 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if ipHost.isFirstResponder(){
            if backView.frame.origin.y + ipHost.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.ipHost.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if port.isFirstResponder(){
            if backView.frame.origin.y + port.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.port.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if localIP.isFirstResponder(){
            if backView.frame.origin.y + localIP.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.localIP.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
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
    
    func keyboardWillHide(notification: NSNotification) {
        self.centarY.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        
        guard let adrFirst = addressFirst.text where adrFirst != "", let adrSecond = addressSecond.text where  adrSecond != "", let adrThird = addressThird.text where adrThird != "", let heartbeat = txtAutoReconnectDelay.text where heartbeat != "", let port = port.text where port != "", let localport = localPort.text where localport != "", let ip = ipHost.text where ip != "", let localip = localIP.text where localip != "" else {
            UIView.hr_setToastThemeColor(color: UIColor.redColor())
            self.view.makeToast(message: "Please fill all text fields")
            return
        }
        
        guard let aFirst = Int(adrFirst) where aFirst <= 255, let aSecond = Int(adrSecond) where aSecond <= 255, let aThird = Int(adrThird) where aThird <= 255 else{
            UIView.hr_setToastThemeColor(color: UIColor.redColor())
            self.view.makeToast(message: "Gateway address must be a number and in range from 0 to 255")
            return
        }
        
        guard let portNumber = Int(port), let localPortNUmber = Int(localport)  else{
            UIView.hr_setToastThemeColor(color: UIColor.redColor())
            self.view.makeToast(message: "Port must be number")
            return
        }
        
        guard let hb = Int(heartbeat) else{
            UIView.hr_setToastThemeColor(color: UIColor.redColor())
            self.view.makeToast(message: "Heartbeat must be a number")
            return
        }

        if let gateway = gateway{
            gateway.remoteIp = ip
            gateway.remotePort = portNumber
            gateway.localIp = localip
            gateway.localPort = localPortNUmber
            gateway.addressOne = aFirst
            gateway.addressTwo = aSecond
            gateway.addressThree = aThird
            gateway.gatewayDescription = txtDescription.text!
            gateway.autoReconnectDelay = hb
            gateway.gatewayType = gatewayType
            CoreDataController.shahredInstance.saveChanges()
            self.dismissViewControllerAnimated(true, completion: nil)
            delegate?.addEditGatewayFinished()
        }else{
            if let location = location{
                let gateway = Gateway(context: appDel.managedObjectContext!)

                gateway.remoteIp = ip
                gateway.remotePort = portNumber
                gateway.localIp = localip
                gateway.localPort = localPortNUmber
                gateway.addressOne = aFirst
                gateway.addressTwo = aSecond
                gateway.addressThree = aThird
                gateway.gatewayDescription = txtDescription.text!
                gateway.turnedOn = true
                gateway.location = location
                gateway.gatewayId = NSUUID().UUIDString
                gateway.autoReconnectDelay = NSNumber(integer: hb)
                gateway.gatewayType = gatewayType
                CoreDataController.shahredInstance.saveChanges()
                self.dismissViewControllerAnimated(true, completion: nil)
                delegate?.addEditGatewayFinished()
            }
        }
        appDel.establishAllConnections()
        
    }

}

extension ConnectionSettingsVC: UITextFieldDelegate{
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        if textField == addressFirst || textField == addressSecond || textField == addressThird{
            let maxLength = 3
            let currentString: NSString = textField.text!
            let newString: NSString =
                currentString.stringByReplacingCharactersInRange(range, withString: string)
            return newString.length <= maxLength
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ConnectionSettingsVC: UITextViewDelegate{
    
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
    func showConnectionSettings(gateway: Gateway?, location:Location?, gatewayType:String) -> ConnectionSettingsVC{
        let connSettVC = ConnectionSettingsVC(gateway: gateway, location: location, gatewayType: gatewayType)
        self.presentViewController(connSettVC, animated: true, completion: nil)
        return connSettVC
    }
}
