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
    case topLeft = 1, topCenter, topRight, centerLeft, center, centerRight, bottomLeft, bottomCenter, bottomRight
    var description : String {
        get {
            switch(self) {
            case .topLeft: return "Top Left"
            case .topCenter: return "Top Center"
            case .topRight: return "Top Right"
            case .centerLeft: return "Center Left"
            case .center: return "Center"
            case .centerRight: return "CenterRight"
            case .bottomLeft: return "Bottom Left"
            case .bottomCenter: return "Bottom Center"
            case .bottomRight: return "Bottom Right"
            }
        }
    }
    
    static let allValues = [topLeft, topCenter, topRight, centerLeft, center, centerRight, bottomLeft, bottomCenter, bottomRight]
    
    static var count : Int {
        get { return NotificationPosition.bottomRight.rawValue }
    }
}

enum NotificationType : Int {
    case notification = 0, tts, notificationAndTTS
    static var count : Int {
        get { return NotificationType.notificationAndTTS.rawValue + 1 }
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
    
    var notificationType : NotificationType = .notification
    var notificationPosition : NotificationPosition = .topLeft
    
    var pc:Device
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    
    init(pc:Device){
        self.pc = pc
        socketIO = InOutSocket(port: 5000)
        super.init(nibName: "PCControlNotificationsXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func setupViews() {
        for item in NotificationPosition.allValues { notificationPositionList.append(PopOverItem(name: item.description, id: String(item.rawValue))) }
        
        if let tempPos = pc.notificationPosition { notificationPositionLabel.text = NotificationPosition(rawValue: Int(tempPos.int32Value))!.description
        } else { notificationPositionLabel.text = NotificationPosition(rawValue: 1)!.description }
        
        notificationSwitch.tag = SwitchTag.notificationSwitch.rawValue
        ttsSwitch.tag = SwitchTag.ttsSwitch.rawValue
        notificationTtsSwitch.tag = SwitchTag.notificationTtsSwitch.rawValue
        
        if let tempType = pc.notificationType {
            
            switch Int(tempType.int32Value) {
            case SwitchTag.notificationSwitch.rawValue: switchChanged(notificationSwitch)
            case SwitchTag.ttsSwitch.rawValue: switchChanged(ttsSwitch)
            case SwitchTag.notificationTtsSwitch.rawValue: switchChanged(notificationTtsSwitch)
            default: switchChanged(notificationSwitch)
            }
        }
        
        if let delay = pc.notificationDelay { delayTextField.text = String(describing: delay) }
        delayTextField.keyboardType = .numberPad
        delayTextField.inputAccessoryView = CustomToolBar()
        delayTextField.attributedPlaceholder = NSAttributedString(string:"0", attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        delayTextField.delegate = self
        
        if let display = pc.notificationDisplayTime { displayTimeTextField.text = String(describing: display) }
        displayTimeTextField.keyboardType = .numberPad
        displayTimeTextField.inputAccessoryView = CustomToolBar()
        displayTimeTextField.attributedPlaceholder = NSAttributedString(string:"0", attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        displayTimeTextField.delegate = self
        titleLabel.text = pc.name
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PCControlNotificationsXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func nameAndId(_ name: String, id: String) {
        notificationPositionLabel.text = name
        
        let pos = Int(id)
        
        if let position = pos { notificationPosition = NotificationPosition(rawValue: position)! }
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchChanged(_ sender: AnyObject) {
        
        switch sender.tag {
        case SwitchTag.notificationSwitch.rawValue:
            notificationSwitch.setOn(true, animated: true)
            ttsSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
            notificationType = .notification
            
        case SwitchTag.ttsSwitch.rawValue:
            ttsSwitch.setOn(true, animated: true)
            notificationSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
            notificationType = .tts
            
        case SwitchTag.notificationTtsSwitch.rawValue:
            notificationTtsSwitch.setOn(true, animated: true)
            notificationSwitch.setOn(false, animated: true)
            ttsSwitch.setOn(false, animated: true)
            notificationType = .notificationAndTTS
            
        default:
            notificationSwitch.setOn(true, animated: true)
            ttsSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
            notificationType = .notification
        }
    }
    
    @IBAction func chooseNotificationPosition(_ sender: AnyObject) {
        button = sender as! UIButton
        openPopover(sender, popOverList:notificationPositionList)
    }

    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        
        //TODO: Save notification settings, notificationPosition and notificationType already set, get delay and display time, here
        
        if let delay = delayTextField.text {
            if let delayTime = Int(delay) { pc.notificationDelay = delayTime as NSNumber? }
        }
        if let display = displayTimeTextField.text {
            if let displayTime = Int(display) { pc.notificationDisplayTime = displayTime as NSNumber? }
        }
        
        pc.notificationType = notificationType.rawValue as NSNumber?
        pc.notificationPosition = notificationPosition.rawValue as NSNumber?
        CoreDataController.sharedInstance.saveChanges()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: delayTextField, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: displayTimeTextField, keyboardFrame: keyboardFrame, backView: backView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
}

extension PCControlNotificationsXIB : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PCControlNotificationsXIB : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view { if touchView.isDescendant(of: backView) { dismissEditing(); return false } }
        return true
    }
}

extension PCControlNotificationsXIB : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            containerView.addSubview(presentedControllerView)
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension PCControlNotificationsXIB : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}

extension UIViewController {
    func showPCNotifications(_ pc:Device) {
        let pci = PCControlNotificationsXIB(pc:pc)
        self.present(pci, animated: true, completion: nil)
    }
}
