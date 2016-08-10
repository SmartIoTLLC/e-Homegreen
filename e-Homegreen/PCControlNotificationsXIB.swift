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
    case TopLeft = 0, TopCenter, TopRight, CenterLeft, Center, CenterRight, BottomLeft, BottomCenter, BottomRight
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
                return "Settings"
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
            return NotificationPosition.BottomRight.rawValue + 1
        }
    }
}

class PCControlNotificationsXIB: PopoverVC, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    var isPresenting: Bool = true
    
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
    
    var notificationCommandList = [PopOverItem]()
    
    var button : UIButton!
    var fullScreenByte:Byte = 0x00
    
    var tagIndex = 0 // cuvam tag od dugmeta koje poziva popover
    var runCommand:String? // run komanda
    var pathForVideo:String? // putanja selektovanog videa
    
    var pc:Device
    
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
            notificationCommandList.append(PopOverItem(name: item.description, id: String(item.rawValue)))
        }
        
        notificationPositionLabel.text = notificationCommandList.first?.name
        
        notificationSwitch.tag = SwitchTag.notificationSwitch.rawValue
        ttsSwitch.tag = SwitchTag.ttsSwitch.rawValue
        notificationTtsSwitch.tag = SwitchTag.notificationTtsSwitch.rawValue
        
        delayTextField.keyboardType = .NumberPad
        delayTextField.tintColor = UIColor.whiteColor()
        delayTextField.layer.borderWidth = 1
        delayTextField.layer.cornerRadius = 2
        delayTextField.layer.borderColor = UIColor.lightGrayColor().CGColor

        delayTextField.attributedPlaceholder = NSAttributedString(string:"0",
                                                                    attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        delayTextField.delegate = self
        
        displayTimeTextField.keyboardType = .NumberPad
        displayTimeTextField.tintColor = UIColor.whiteColor()
        displayTimeTextField.layer.borderWidth = 1
        displayTimeTextField.layer.cornerRadius = 2
        displayTimeTextField.layer.borderColor = UIColor.lightGrayColor().CGColor

        displayTimeTextField.attributedPlaceholder = NSAttributedString(string:"0",
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        displayTimeTextField.delegate = self
        titleLabel.text = pc.name
        self.view.backgroundColor = UIColor.clearColor()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PCControlNotificationsXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendantOfView(backView){
                self.view.endEditing(true)
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var socketIO:InOutSocket
    
    @IBAction func switchChanged(sender: AnyObject) {
        
        switch sender.tag {
        case SwitchTag.notificationSwitch.rawValue:
            notificationSwitch.setOn(true, animated: true)
            ttsSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
            
            //TODO: Notification funcionality
            
        case SwitchTag.ttsSwitch.rawValue:
            ttsSwitch.setOn(true, animated: true)
            notificationSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
            
            //TODO: TTS funcionality
            
        case SwitchTag.notificationTtsSwitch.rawValue:
            notificationTtsSwitch.setOn(true, animated: true)
            notificationSwitch.setOn(false, animated: true)
            ttsSwitch.setOn(false, animated: true)
            
            //TODO: Notification & TTS funcionality
            
        default:
            notificationSwitch.setOn(true, animated: true)
            ttsSwitch.setOn(false, animated: true)
            notificationTtsSwitch.setOn(false, animated: true)
        }
    }
    
    override func nameAndId(name: String, id: String) {
        notificationPositionLabel.text = name
    }
    
    @IBAction func chooseNotificationPosition(sender: AnyObject) {
        button = sender as! UIButton
        openPopover(sender, popOverList:notificationCommandList)
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewController()
    }
    @IBAction func saveAction(sender: AnyObject) {
        self.dismissViewController()
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
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
            containerView!.addSubview(presentedControllerView)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
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
                
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
                
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
        self.view.window?.rootViewController?.presentViewController(pci, animated: true, completion: nil)
    }
}
