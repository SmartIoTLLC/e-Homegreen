//
//  FlagParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/7/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class FlagParametarVC: CommonXIBTransitionVC {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    var flag:Flag?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var isBroadcast: UISwitch!
    @IBOutlet weak var isLocalcast: UISwitch!
    
    init(){
        super.init(nibName: "FlagParametarVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FlagParametarVC.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        isBroadcast.tag = 100
        isBroadcast.on = flag!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: #selector(FlagParametarVC.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        isLocalcast.tag = 200
        isLocalcast.on = flag!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: #selector(FlagParametarVC.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if isBroadcast.on {
            flag?.isBroadcast = true
        } else {
            flag?.isBroadcast = false
        }
        if isLocalcast.on {
            flag?.isLocalcast = true
        } else {
            flag?.isLocalcast = false
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshTimer, object: self, userInfo: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            if sender.on == true {
                isLocalcast.on = false
            } else {
                isLocalcast.on = false
            }
        } else if sender.tag == 200 {
            if sender.on == true {
                isBroadcast.on = false
            } else {
                isBroadcast.on = false
            }
        }
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

extension UIViewController {
    func showFlagParametar(flag:Flag) {
        let fp = FlagParametarVC()
        fp.flag = flag
        self.presentViewController(fp, animated: true, completion: nil)
    }
}