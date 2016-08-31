//
//  PCControlNotificationsXIB.swift
//  e-Homegreen
//
//  Created by Marko Stajic on 8/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
//import wol.h

enum NotificationPosition : Int, CustomStringConvertible {
    case TopLeft = 1, TopCenter, TopRight, CenterLeft, Center, CenterRight, BottomLeft, BottomCenter, BottomRight
    var description : String {
        get {
            switch(self) {
            case .TopLeft:
                return "Top Left"
            case .TopCenter:
                return "Top Center"
            case .TopRight:
                return "Top Right"
            case .CenterLeft:
                return "Center Left"
            case .Center:
                return "Center"
            case .CenterRight:
                return "CenterRight"
            case .BottomLeft:
                return "Bottom Left"
            case .BottomCenter:
                return "Bottom Center"
            case .BottomRight:
                return "Bottom Right"
            }
        }
    }
    
    static let allValues = [TopLeft, TopCenter, TopRight, CenterLeft, Center, CenterRight, BottomLeft, BottomCenter, BottomRight]
    
    static var count : Int {
        get {
            return NotificationPosition.BottomRight.rawValue
        }
    }
}

enum NotificationType : Int {
    case Notification = 0, TTS, NotificationAndTTS
    static var count : Int {
        get {
            return NotificationType.NotificationAndTTS.rawValue + 1
        }
    }
}

class PCControlNotificationsXIB: PopoverVC {
    
    var isPresenting: Bool = true

    var socketIO:InOutSocket
    
    enum SwitchTag : Int {
        case notificationSwitch
        case ttsSwitch
        case notificationTtsSwitch
    }
    
    @IBOutlet weak var delayTextField: UITextField!
    @IBOutlet weak var displayTimeTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var ttsSwitch: UISwitch!
    @IBOutlet weak var notificationTtsSwitch: UISwitch!
    @IBOutlet weak var notificationPositionLabel: UILabel!
    
    var notificationPositionList = [PopOverItem]()
    
    var button : UIButton!
    var fullScreenByte:Byte = 0x00
    
    var tagIndex = 0 // cuvam tag od dugmeta koje poziva popover
    
    var notificationType : NotificationType = .Notification
    var notificationPosition : NotificationPosition = .TopLeft
    
    var pc:Device
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    
    init(pc:Device){
        self.pc = pc
        socketIO = InOutSocket(port: 5000)
        super.init(nibName: "PCControlNotificationsXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in NotificationPosition.allValues {
            notificationPositionList.append(PopOverItem(name: item.description, id: String(item.rawValue)))
        }
        
        if let tempPos = pc.notificationPosition {
            notificationPositionLabel.text = NotificationPosition(rawValue: Int(tempPos.intValue))!.description
        }else{
            notificationPositionLabel.text = NotificationPosition(rawValue: 1)!.description
        }
        
        
        notificationSwitch.tag = SwitchTag.notificationSwitch.rawValue
        ttsSwitch.tag = SwitchTag.ttsSwitch.rawValue
        notificationTtsSwitch.tag = SwitchTag.notificationTtsSwitch.rawValue
        
        if let tempType = pc.notificationType {
            
            switch Int(tempType.intValue) {
            case SwitchTag.notificationSwitch.rawValue:
                switchChanged(notificationSwitch)
            case SwitchTag.ttsSwitch.rawValue:
                switchChanged(ttsSwitch)
            case SwitchTag.notificationTtsSwitch.rawValue:
                switchChanged(notificationTtsSwitch)
            default:
                switchChanged(notificationSwitch)
            }
        }
        
        if let delay = pc.notificationDelay {
            delayTextField.text = String(delay)
        }
        delayTextField.keyboardType = .NumberPad
        delayTextField.inputAccessoryView = CustomToolBar()

        delayTextField.attributedPlaceholder = NSAttributedString(string:"0",
                                                                    attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        delayTextField.delegate = self
        
        if let display = pc.notificationDisplayTime {
            displayTimeTextField.text = String(display)
        }
        displayTimeTextField.keyboardType = .NumberPad
        displayTimeTextField.inputAccessoryView = CustomToolBar()

        displayTimeTextField.attributedPlaceholder = NSAttributedString(string:"0",
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        displayTimeTextField.delegate = self
        titleLabel.text = pc.name
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PCControlNotificationsXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PCControlNotificationsXIB.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PCControlNotificationsXIB.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func nameAndId(name: String, id: String) {
        notificationPositionLabel.text = name
        
        let pos = Int(id)
        
        if let position = pos {
            notificationPosition = NotificationPosition(rawValue: position)!
        }
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func switchChanged(sender: AnyObject) {
        
        switch sender.tag {
        case SwitchTag.notificationSwitch.rawValue:
            notificationSwitch.setOn(true, animated: true)
            ttsSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
            notificationType = .Notification
            
        case SwitchTag.ttsSwitch.rawValue:
            ttsSwitch.setOn(true, animated: true)
            notificationSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
            notificationType = .TTS
            
        case SwitchTag.notificationTtsSwitch.rawValue:
            notificationTtsSwitch.setOn(true, animated: true)
            notificationSwitch.setOn(false, animated: true)
            ttsSwitch.setOn(false, animated: true)
            notificationType = .NotificationAndTTS
            
        default:
            notificationSwitch.setOn(true, animated: true)
            ttsSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
            notificationType = .Notification
        }
    }
    
    @IBAction func chooseNotificationPosition(sender: AnyObject) {
        button = sender as! UIButton
        openPopover(sender, popOverList:notificationPositionList)
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        //TODO: Save notification settings, notificationPosition and notificationType already set, get delay and display time, here
        
        if let delay = delayTextField.text {
            if let delayTime = Int(delay) {
                pc.notificationDelay = delayTime
            }
        }
        if let display = displayTimeTextField.text {
            if let displayTime = Int(display) {
                pc.notificationDisplayTime = displayTime
            }
        }
        
        pc.notificationType = notificationType.rawValue
        pc.notificationPosition = notificationPosition.rawValue
        CoreDataController.shahredInstance.saveChanges()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if delayTextField.isFirstResponder(){
            if backView.frame.origin.y + delayTextField.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.delayTextField.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        if displayTimeTextField.isFirstResponder(){
            if backView.frame.origin.y + displayTimeTextField.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.displayTimeTextField.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.centerY.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
}

extension PCControlNotificationsXIB : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PCControlNotificationsXIB : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendantOfView(backView){
                self.view.endEditing(true)
                return false
            }
        }
        return true
    }
}

extension PCControlNotificationsXIB : UIViewControllerAnimatedTransitioning {
    
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
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.5, 1.5)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension PCControlNotificationsXIB : UIViewControllerTransitioningDelegate {
    
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
    func showPCNotifications(pc:Device) {
        let pci = PCControlNotificationsXIB(pc:pc)
        self.presentViewController(pci, animated: true, completion: nil)
    }
}