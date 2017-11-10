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
        
        appDel = UIApplication.shared.delegate as! AppDelegate

        setupViews()
    }
    
    func setupViews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        isBroadcast.tag = 100
        isBroadcast.isOn = flag!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        isLocalcast.tag = 200
        isLocalcast.isOn = flag!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if isBroadcast.isOn { flag?.isBroadcast = true } else { flag?.isBroadcast = false }
        if isLocalcast.isOn { flag?.isLocalcast = true } else { flag?.isLocalcast = false }
        
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshTimer), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func changeValue (_ sender:UISwitch) {
        if sender.tag == 100 {
            if sender.isOn == true { isLocalcast.isOn = false } else { isLocalcast.isOn = false }
        } else if sender.tag == 200 {
            if sender.isOn == true { isBroadcast.isOn = false } else { isBroadcast.isOn = false }
        }
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension UIViewController {
    func showFlagParametar(_ flag:Flag) {
        let fp = FlagParametarVC()
        fp.flag = flag
        present(fp, animated: true, completion: nil)
    }
}
