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
    var gatewayType:TypeOfLocationDevice!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    init(gateway:Gateway?, location:Location?, gatewayType:TypeOfLocationDevice) {
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
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func setupViews() {
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
        
        // Default gateway address
        if let gateway = gateway {
            ipHost.text = gateway.remoteIp
            port.text = "\(gateway.remotePort)"
            localIP.text = gateway.localIp
            localPort.text = "\(gateway.localPort)"
            addressFirst.text = returnThreeCharactersForByte(Int(gateway.addressOne))
            addressSecond.text = returnThreeCharactersForByte(Int(gateway.addressTwo))
            addressThird.text = returnThreeCharactersForByte(Int(gateway.addressThree))
            txtDescription.text = gateway.gatewayDescription
            txtAutoReconnectDelay.text = "\(gateway.autoReconnectDelay!)"
        } else {
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
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view { if touchView.isDescendant(of: backView) { dismissEditing(); return false } }
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
        
        guard let aFirst = Int(adrFirst) , aFirst <= 255, let aSecond = Int(adrSecond) , aSecond <= 255, let aThird = Int(adrThird) , aThird <= 255 else {
            UIView.hr_setToastThemeColor(color: UIColor.red)
            self.view.makeToast(message: "Gateway address must be a number and in range from 0 to 255")
            return
        }
        
        guard let portNumber = Int(port), let localPortNUmber = Int(localport) else {
            UIView.hr_setToastThemeColor(color: UIColor.red)
            self.view.makeToast(message: "Port must be number")
            return
        }
        
        guard let hb = Int(heartbeat) else {
            UIView.hr_setToastThemeColor(color: UIColor.red)
            self.view.makeToast(message: "Heartbeat must be a number")
            return
        }

        if let gateway = gateway {
            gateway.remoteIp = ip
            gateway.remotePort = NSNumber(value: portNumber)
            gateway.localIp = localip
            gateway.localPort = NSNumber(value: localPortNUmber)
            gateway.addressOne = NSNumber(value: aFirst)
            gateway.addressTwo = NSNumber(value: aSecond)
            gateway.addressThree = NSNumber(value: aThird)
            gateway.gatewayDescription = gatewayName
            gateway.autoReconnectDelay = hb as NSNumber?
            
            CoreDataController.sharedInstance.saveChanges()
            self.dismiss(animated: true, completion: nil)
            delegate?.addEditGatewayFinished()
        } else {
            if let location = location {
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
                gateway.gatewayType = NSNumber(value: gatewayType.rawValue)
                CoreDataController.sharedInstance.saveChanges()
                self.dismiss(animated: true, completion: nil)
                delegate?.addEditGatewayFinished()
            }
        }
        appDel.establishAllConnections()
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: txtDescription, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: ipHost, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: port, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: localIP, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: localPort, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: txtAutoReconnectDelay, keyboardFrame: keyboardFrame, backView: backView)        
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }

}

extension ConnectionSettingsVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == addressFirst || textField == addressSecond || textField == addressThird {
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
    func showConnectionSettings(_ gateway: Gateway?, location:Location?, gatewayType:TypeOfLocationDevice) -> ConnectionSettingsVC{
        let connSettVC = ConnectionSettingsVC(gateway: gateway, location: location, gatewayType: gatewayType)
        self.present(connSettVC, animated: true, completion: nil)
        return connSettVC
    }
}
