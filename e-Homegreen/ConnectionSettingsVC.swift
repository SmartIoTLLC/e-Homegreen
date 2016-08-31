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

class ConnectionSettingsVC: CommonXIBTransitionVC {
    
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
        
        ipHost.delegate = self
        port.delegate = self
        localIP.delegate = self
        localPort.delegate = self
        addressFirst.delegate = self
        addressSecond.delegate = self
        addressThird.delegate = self
        txtDescription.delegate = self
        txtAutoReconnectDelay.delegate = self
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendantOfView(backView){
                self.view.endEditing(true)
                return false
            }
        }
        return true
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        
        guard let adrFirst = addressFirst.text where adrFirst != "", let adrSecond = addressSecond.text where  adrSecond != "", let adrThird = addressThird.text where adrThird != "", let heartbeat = txtAutoReconnectDelay.text where heartbeat != "", let port = port.text where port != "", let localport = localPort.text where localport != "", let ip = ipHost.text where ip != "", let localip = localIP.text where localip != "", let gatewayName = txtDescription.text where gatewayName != "" else {
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
            gateway.gatewayDescription = gatewayName
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
                gateway.gatewayDescription = gatewayName
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

extension UIViewController {
    func showConnectionSettings(gateway: Gateway?, location:Location?, gatewayType:String) -> ConnectionSettingsVC{
        let connSettVC = ConnectionSettingsVC(gateway: gateway, location: location, gatewayType: gatewayType)
        self.presentViewController(connSettVC, animated: true, completion: nil)
        return connSettVC
    }
}
