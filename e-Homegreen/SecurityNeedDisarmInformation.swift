//
//  SecurityNeedDisarmInformation.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/10/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class SecurityNeedDisarmInformation: CommonXIBTransitionVC {
    
    var indexPathRow: Int = -1
    
    var devices:[Device] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    init(point:CGPoint){
        super.init(nibName: "SecurityNeedDisarmInformation", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.infoLabel.text = Messages.Security.NeedToDisarmFirst
        
    }
    
    func handleTap(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: popUpView){
            return false
        }
        return true
    }
    
    @IBAction func btnOk(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
