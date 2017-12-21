//
//  SurveilenceUrlsVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 11/26/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SurveilenceUrlsVC: CommonXIBTransitionVC {
    
    var getImage = "/dms?nowprofileid=2"
    var moveRight = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=right&amp;panstep=1&amp;tiltstep=15"
    var moveLeft = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=left&amp;panstep=1&amp;tiltstep=15"
    var moveUp = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=up&amp;panstep=1&amp;tiltstep=15"
    var moveDown = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=down&amp;panstep=1&amp;tiltstep=15"
    var autoPan = "/cgi-bin/longcctvapn.cgi?action=go&speed=1"
    var stopAutoPan = "/cgi-bin/longcctvapn.cgi?action=stop"
    var presetSequence = "/cgi-bin/longcctvseq.cgi?action=go"
    var stopPresetSequence = "/cgi-bin/longcctvseq.cgi?action=stop"
    var home = "/cgi-bin/longcctvhome.cgi?action=gohome"
    
    var surv:Surveillance?
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var txtGetImage: UITextField!
    @IBOutlet weak var txtMoveLeft: UITextField!
    @IBOutlet weak var txtMoveRight: UITextField!
    @IBOutlet weak var txtMoveUp: UITextField!
    @IBOutlet weak var txtMoveDown: UITextField!
    @IBOutlet weak var txtAutoPan: UITextField!
    @IBOutlet weak var txtStopAutoPan: UITextField!
    @IBOutlet weak var txtPresetSequence: UITextField!
    @IBOutlet weak var txtStopPresetSequence: UITextField!
    @IBOutlet weak var txtHome: UITextField!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    @IBOutlet weak var scroll: UIScrollView!
    
    init(surv:Surveillance){
        super.init(nibName: "SurveilenceUrlsVC", bundle: nil)
        self.surv = surv
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        txtGetImage.delegate = self
        txtMoveLeft.delegate = self
        txtMoveRight.delegate = self
        txtMoveUp.delegate = self
        txtMoveDown.delegate = self
        txtAutoPan.delegate = self
        txtStopAutoPan.delegate = self
        txtPresetSequence.delegate = self
        txtStopPresetSequence.delegate = self
        txtHome.delegate = self
        
        txtGetImage.placeholder = getImage
        txtMoveLeft.placeholder = moveLeft
        txtMoveRight.placeholder = moveRight
        txtMoveUp.placeholder = moveUp
        txtMoveDown.placeholder = moveDown
        txtAutoPan.placeholder = autoPan
        txtStopAutoPan.placeholder = stopAutoPan
        txtPresetSequence.placeholder = presetSequence
        txtStopPresetSequence.placeholder = stopPresetSequence
        txtHome.placeholder = home
        
        txtGetImage.text = surv!.urlGetImage
        txtMoveLeft.text = surv!.urlMoveLeft
        txtMoveRight.text = surv!.urlMoveRight
        txtMoveUp.text = surv!.urlMoveUp
        txtMoveDown.text = surv!.urlMoveDown
        txtAutoPan.text = surv!.urlAutoPan
        txtStopAutoPan.text = surv!.urlAutoPanStop
        txtPresetSequence.text = surv!.urlPresetSequence
        txtStopPresetSequence.text = surv!.urlPresetSequenceStop
        txtHome.text = surv!.urlHome
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SurveilenceUrlsVC.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SurveilenceUrlsVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SurveilenceUrlsVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if txtGetImage.text != "" {surv!.urlGetImage! = txtGetImage.text!}
        if txtMoveRight.text != "" {surv!.urlMoveRight! = txtMoveRight.text!}
        if txtMoveLeft.text != "" {surv!.urlMoveLeft! = txtMoveLeft.text!}
        if txtMoveUp.text != "" {surv!.urlMoveUp! = txtMoveUp.text!}
        if txtMoveDown.text != "" {surv!.urlMoveDown! = txtMoveDown.text!}
        if txtAutoPan.text != "" {surv!.urlAutoPan! = txtAutoPan.text!}
        if txtStopAutoPan.text != "" {surv!.urlAutoPanStop! = txtStopAutoPan.text!}
        if txtPresetSequence.text != "" {surv!.urlPresetSequence! = txtPresetSequence.text!}
        if txtStopPresetSequence.text != "" {surv!.urlPresetSequenceStop! = txtStopPresetSequence.text!}
        if txtHome.text != "" {surv!.urlHome! = txtHome.text!}
        CoreDataController.sharedInstance.saveChanges()
        
        resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if txtMoveRight.isFirstResponder{
            if backView.frame.origin.y + txtMoveRight.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtMoveRight.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtMoveUp.isFirstResponder{
            if backView.frame.origin.y + txtMoveUp.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtMoveUp.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtMoveDown.isFirstResponder{
            if backView.frame.origin.y + txtMoveDown.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtMoveDown.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtAutoPan.isFirstResponder{
            if backView.frame.origin.y + txtAutoPan.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtAutoPan.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtStopAutoPan.isFirstResponder{
            if backView.frame.origin.y + txtStopAutoPan.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtStopAutoPan.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtPresetSequence.isFirstResponder{
            if backView.frame.origin.y + txtPresetSequence.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtPresetSequence.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtStopPresetSequence.isFirstResponder{
            if backView.frame.origin.y + txtStopPresetSequence.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtStopPresetSequence.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if txtHome.isFirstResponder{
            if backView.frame.origin.y + txtHome.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtHome.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }
    
//    func keyboardWillHide(_ notification: Notification) {
//        self.centerY.constant = 0
//        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
//    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }


}

extension SurveilenceUrlsVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if txtGetImage.isFirstResponder{
            txtMoveLeft.becomeFirstResponder()
        }else if txtMoveLeft.isFirstResponder{
            txtMoveRight.becomeFirstResponder()
        }else if txtMoveRight.isFirstResponder{
            txtMoveUp.becomeFirstResponder()
        }else if txtMoveUp.isFirstResponder{
            txtMoveDown.becomeFirstResponder()
        }else if txtMoveDown.isFirstResponder{
            txtAutoPan.becomeFirstResponder()
        }else if txtAutoPan.isFirstResponder{
            txtStopAutoPan.becomeFirstResponder()
        }else if txtStopAutoPan.isFirstResponder{
            txtPresetSequence.becomeFirstResponder()
        }else if txtPresetSequence.isFirstResponder{
            txtStopPresetSequence.becomeFirstResponder()
        }else if txtStopPresetSequence.isFirstResponder{
            txtHome.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
}


extension UIViewController {
    func showCameraUrls (surveillance:Surveillance) {
        let scu = SurveilenceUrlsVC(surv: surveillance)
        self.present(scu, animated: true, completion: nil)
    }
}
