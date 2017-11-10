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
    let defaults = Foundation.UserDefaults.standard
    var address:[UInt8]!
    var gateway: Gateway?
    
    init(point:CGPoint){
        super.init(nibName: "SecurityPadVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        address = [security.addressOne.uint8Value, security.addressTwo.uint8Value, security.addressThree.uint8Value]
        if let gatewayId = self.security.gatewayId {
            if let gateway = CoreDataController.sharedInstance.fetchGatewayWithId(gatewayId) {
                self.gateway = gateway
            }
        }

    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: popUpView) { return false }
        return true
    }
    
    @IBAction func btnOne(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x01), gateway: gateway)
    }
    @IBAction func btnTwo(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x02), gateway: gateway)
        
    }
    @IBAction func btnThree(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x03), gateway: gateway)
        
    }
    @IBAction func btnFour(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x04), gateway: gateway)
    }
    @IBAction func btnFive(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x05), gateway: gateway)
    }
    @IBAction func btnSix(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x06), gateway: gateway)
    }
    @IBAction func btnSeven(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x07), gateway: gateway)
    }
    @IBAction func btnEight(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x08), gateway: gateway)
    }
    @IBAction func btnNine(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x09), gateway: gateway)
    }
    @IBAction func btnStar(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x0B), gateway: gateway)
    }
    @IBAction func btnNull(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x00), gateway: gateway)
    }
    @IBAction func btnHash(_ sender: AnyObject) {
        guard let gateway = self.gateway else { NSLog("Error sending command to PLC. Gateway is nil for this security. Function: btnOne(sender: AnyObject)"); return }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendKeySecurity(address, key: 0x1A), gateway: gateway)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension UIViewController {
    func showSecurityPad (_ point:CGPoint, security: Security) {
        let sp = SecurityPadVC(point: point)
        sp.security = security
        self.present(sp, animated: true, completion: nil)
    }
}
