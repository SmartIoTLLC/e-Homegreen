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
        
        appDel = UIApplication.shared.delegate as! AppDelegate


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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendant(of: backView){
                self.view.endEditing(true)
                return false
            }
        }
        return true
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        
        guard let adrFirst = addressFirst.text , adrFirst != "", let adrSecond = addressSecond.text ,  adrSecond != "", let adrThird = addressThird.text , adrThird != "", let heartbeat = txtAutoReconnectDelay.text , heartbeat != "", let port = port.text , port != "", let localport = localPort.text , localport != "", let ip = ipHost.text , ip != "", let localip = localIP.text , localip != "", let gatewayName = txtDescription.text , gatewayName != "" else {
            UIView.hr_setToastThemeColor(color: UIColor.red)
            self.view.makeToast(message: "Please fill all text fields")
            return
        }
        
        guard let aFirst = Int(adrFirst) , aFirst <= 255, let aSecond = Int(adrSecond) , aSecond <= 255, let aThird = Int(adrThird) , aThird <= 255 else{
            UIView.hr_setToastThemeColor(color: UIColor.red)
            self.view.makeToast(message: "Gateway address must be a number and in range from 0 to 255")
            return
        }
        
        guard let portNumber = Int(port), let localPortNUmber = Int(localport)  else{
            UIView.hr_setToastThemeColor(color: UIColor.red)
            self.view.makeToast(message: "Port must be number")
            return
        }
        
        guard let hb = Int(heartbeat) else{
            UIView.hr_setToastThemeColor(color: UIColor.red)
            self.view.makeToast(message: "Heartbeat must be a number")
            return
        }

        if let gateway = gateway{
            gateway.remoteIp = ip
            gateway.remotePort = NSNumber(value: portNumber)
            gateway.localIp = localip
            gateway.localPort = NSNumber(value: localPortNUmber)
            gateway.addressOne = NSNumber(value: aFirst)
            gateway.addressTwo = NSNumber(value: aSecond)
            gateway.addressThree = NSNumber(value: aThird)
            gateway.gatewayDescription = gatewayName
            gateway.autoReconnectDelay = hb as NSNumber?
            gateway.gatewayType = gatewayType
            CoreDataController.shahredInstance.saveChanges()
            self.dismiss(animated: true, completion: nil)
            delegate?.addEditGatewayFinished()
        }else{
            if let location = location{
                let gateway = Gateway(context: appDel.managedObjectContext!)

                gateway.remoteIp = ip
                gateway.remotePort = NSNumber(value: portNumber)
                gateway.localIp = localip
                gateway.localPort = NSNumber(value: localPortNUmber)
                gateway.addressOne = NSNumber(value: aFirst)
                gateway.addressTwo = NSNumber(value: aSecond)
                gateway.addressThree = NSNumber(value: aThird)
                gateway.gatewayDescription = gatewayName
                gateway.turnedOn = true
                gateway.location = location
                gateway.gatewayId = UUID().uuidString
                gateway.autoReconnectDelay = NSNumber(value: hb as Int)
                gateway.gatewayType = gatewayType
                CoreDataController.shahredInstance.saveChanges()
                self.dismiss(animated: true, completion: nil)
                delegate?.addEditGatewayFinished()
            }
        }
        appDel.establishAllConnections()
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if txtDescription.isFirstResponder{
            if backView.frame.origin.y + txtDescription.frame.origin.y + 65 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.txtDescription.frame.origin.y + 65 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if ipHost.isFirstResponder{
            if backView.frame.origin.y + ipHost.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.ipHost.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if port.isFirstResponder{
            if backView.frame.origin.y + port.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.port.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if localIP.isFirstResponder{
            if backView.frame.origin.y + localIP.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.localIP.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if localPort.isFirstResponder{
            if backView.frame.origin.y + localPort.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.localPort.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if txtAutoReconnectDelay.isFirstResponder{
            if backView.frame.origin.y + txtAutoReconnectDelay.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centarY.constant = -(5 + (self.backView.frame.origin.y + self.txtAutoReconnectDelay.frame.origin.y + 30 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.centarY.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }

}

extension ConnectionSettingsVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if textField == addressFirst || textField == addressSecond || textField == addressThird{
            let maxLength = 3
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showConnectionSettings(_ gateway: Gateway?, location:Location?, gatewayType:String) -> ConnectionSettingsVC{
        let connSettVC = ConnectionSettingsVC(gateway: gateway, location: location, gatewayType: gatewayType)
        self.present(connSettVC, animated: true, completion: nil)
        return connSettVC
    }
}
