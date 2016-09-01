//
//  SecurityPadVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SecurityPadVC: CommonXIBTransitionVC {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    
    @IBOutlet weak var popUpView: UIView!
    
    var security:Security!
    let defaults = NSUserDefaults.standardUserDefaults()
    var address:[UInt8]!
    var gateway: Gateway?
    
    init(point:CGPoint){
        super.init(nibName: "SecurityPadVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        address = [security.addressOne.unsignedCharValue, security.addressTwo.unsignedCharValue, security.addressThree.unsignedCharValue]
        if let gatewayId = self.security.gatewayId {
            if let gateway = CoreDataController.shahredInstance.fetchGatewayWithId(gatewayId){
                self.gateway = gateway
            }
        }

    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(popUpView){
            return false
        }
        return true
    }
    
    @IBAction func btnOne(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x01), gateway: gateway)
    }
    @IBAction func btnTwo(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x02), gateway: gateway)
        
    }
    @IBAction func btnThree(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x03), gateway: gateway)
        
    }
    @IBAction func btnFour(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x04), gateway: gateway)
    }
    @IBAction func btnFive(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x05), gateway: gateway)
    }
    @IBAction func btnSix(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x06), gateway: gateway)
    }
    @IBAction func btnSeven(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x07), gateway: gateway)
    }
    @IBAction func btnEight(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x08), gateway: gateway)
    }
    @IBAction func btnNine(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x09), gateway: gateway)
    }
    @IBAction func btnStar(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x0B), gateway: gateway)
    }
    @IBAction func btnNull(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x00), gateway: gateway)
    }
    @IBAction func btnHash(sender: AnyObject) {
        guard let gateway = self.gateway else{
            NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)")
            return
        }
        SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x1A), gateway: gateway)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension UIViewController {
    func showSecurityPad (point:CGPoint, security: Security) {
        let sp = SecurityPadVC(point: point)
        sp.security = security
        self.presentViewController(sp, animated: true, completion: nil)
    }
}
