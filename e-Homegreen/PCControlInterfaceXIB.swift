//
//  PCControlInterfaceXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
//import wol.h

enum FileType{
    case Video
    case App
    
    var description:String{
        switch self {
        case Video: return "Media"
        case App: return "Application"
        }
    }
}

enum PowerOption{
    case ShutDown, Restart, Sleep, Hibernate, LogOff
    var description:String{
        switch self{
        case ShutDown: return "Shut Down"
        case Restart: return "Restart"
        case Sleep: return "Sleep"
        case Hibernate: return "Hibernate"
        case LogOff: return "LogOff"
        }
    }
    static let allValues = [ShutDown, Restart, Sleep, Hibernate, LogOff]
}

class PCControlInterfaceXIB: PopoverVC, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    var isPresenting: Bool = true
    
    
    @IBOutlet weak var fullScreenSwitch: UISwitch!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var runSwitch: UISwitch!
    @IBOutlet weak var mediaPathLabel: UILabel!
    @IBOutlet weak var appPathLabel: UILabel!
    @IBOutlet weak var voiceCommandButton: UIButton!
    
    var runCommandList = [PopOverItem]()
    var playCommandList = [PopOverItem]()
    var powerCommandList = [PopOverItem]()

    var fullScreenByte:Byte = 0x00
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var commandTextField: UITextField!
    
    @IBOutlet weak var centerX: NSLayoutConstraint!
    
    
    var tagIndex = 0 // cuvam tag od dugmeta koje poziva popover
    var runCommand:String? // run komanda
    var pathForVideo:String? // putanja selektovanog videa
    
    var pc:Device
    var button:UIButton!
    
    init(pc:Device){
        self.pc = pc
        socketIO = InOutSocket(port: 5000)
        super.init(nibName: "PCControlInterfaceXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshLists(){
        runCommandList.removeAll()
        playCommandList.removeAll()
        if let list = pc.pcCommands {
            if let commandArray = Array(list) as? [PCCommand] {
                for item in commandArray{
                    if item.commandType == CommandType.Application.rawValue {
                        runCommandList.append(PopOverItem(name: item.name!, id: item.comand!))
                    }
                    if item.commandType == CommandType.Media.rawValue {
                        playCommandList.append(PopOverItem(name: item.name!, id: item.comand!))
                    }
                }
            }
        }
        if runCommandList.count != 0 {
            runLabel.text = runCommandList.first?.name
            appPathLabel.text = runCommandList.first?.id
        }
        if playCommandList.count != 0 {
            playLabel.text = playCommandList.first?.name
            mediaPathLabel.text = playCommandList.first?.id
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        refreshLists()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLists()
        
        for option in PowerOption.allValues{
            powerCommandList.append(PopOverItem(name: option.description, id: ""))
        }
        
        if powerCommandList.count != 0 {
            powerLabel.text = powerCommandList.first?.name
        }

        commandTextField.attributedPlaceholder = NSAttributedString(string:"Enter Command",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        commandTextField.delegate = self
        
        titleLabel.text = pc.name
        
        self.view.backgroundColor = UIColor.clearColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PCControlInterfaceXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PCControlInterfaceXIB.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PCControlInterfaceXIB.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendantOfView(backView){
                return false
            }
        }
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if commandTextField.isFirstResponder(){
            if backView.frame.origin.y + commandTextField.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerX.constant = 0 - (5 + (self.backView.frame.origin.y + self.commandTextField.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.centerX.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func powerAction(sender: AnyObject) {
        if let text = powerLabel.text{
            switch text{
            case PowerOption.ShutDown.description:
                
                break
            case PowerOption.Restart.description:
                
                break
            case PowerOption.Sleep.description:
                
                break
            case PowerOption.Hibernate.description:
                
                break
            case PowerOption.LogOff.description:
                
                break
            default: print("")
                
            }
        }
    }
    
    @IBAction func playAction(sender: AnyObject) {
        guard let videoName = playLabel.text where videoName != "-", let path =  pathForVideo  else {
            return
        }
        if fullScreenSwitch.on {
            fullScreenByte = 0x00
        }else{
            fullScreenByte = 0x01
        }
        SendingHandler.sendCommand(byteArray: Function.playVideo(pc.moduleAddress, fileName: path, fullScreen: fullScreenByte, by: 0x01), gateway: pc.gateway)
    }

    @IBAction func runAction(sender: AnyObject) {
        guard let appName = runLabel.text where appName != "-", let command =  runCommand  else {
            return
        }
        if runSwitch.on {
            fullScreenByte = 0x00
        }else{
            fullScreenByte = 0x01
        }
        SendingHandler.sendCommand(byteArray: Function.runApp(pc.moduleAddress, cmdLine: command), gateway: pc.gateway)
//        let s1 = "192.168.0.7"
//        let cs1 = (s1 as NSString).UTF8String
//        let first_parametar = UnsafeMutablePointer<UInt8>(cs1)
//        let byteArray:[Byte] = [0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1]
//
//        let s2 = convertByteArrayToMacAddress(byteArray)
//        let cs2 = (s2 as NSString).UTF8String
//        let second_parametar = UnsafeMutablePointer<UInt8>(cs2)
//        send_wol_packet(first_parametar, second_parametar)
    }
    
    var socketIO:InOutSocket
    
    @IBAction func sendAction(sender: AnyObject) {
        guard let text = commandTextField.text else {
            return
        }
        
        SendingHandler.sendCommand(byteArray: Function.sendNotification(pc.moduleAddress, text: text, notificationType: NotificationType(rawValue: Int((pc.notificationType?.intValue)!))!, notificationPosition: NotificationPosition(rawValue: Int((pc.notificationPosition?.intValue)!))!, delayTime: Int((pc.notificationDelay?.intValue)!), displayTime: Int((pc.notificationDisplayTime?.intValue)!)), gateway: pc.gateway)
    }
    
    @IBAction func addPathForVideo(sender: AnyObject) {        
        if let navVC = UIStoryboard(name: "PCControl", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ListViewController") as? UINavigationController{
            if let vc = navVC.topViewController as? ListOfDevice_AppViewController{
                vc.typeOfFile = .Video
                vc.device = pc
                self.presentViewController(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addPathForRunApp(sender: AnyObject) {
        if let navVC = UIStoryboard(name: "PCControl", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ListViewController") as? UINavigationController{
            if let vc = navVC.topViewController as? ListOfDevice_AppViewController{
                vc.typeOfFile = .App
                vc.device = pc
                self.presentViewController(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func powerOption(sender: UIButton) {
        button = sender
        openPopover(sender, popOverList:powerCommandList)

    }
    
    @IBAction func playOption(sender: UIButton) {
        button = sender
        openPopoverWithTwoRows(sender, popOverList: playCommandList)
    }
    
    @IBAction func runOption(sender: UIButton) {
        button = sender
        openPopoverWithTwoRows(sender, popOverList:runCommandList)
    }
    
    override func nameAndId(name: String, id: String) {
        if button.tag == 1{
            powerLabel.text = name
        }
        if button.tag == 2{
            playLabel.text = name
            pathForVideo = id + name
            mediaPathLabel.text = id
        }
        if button.tag == 3{
            runLabel.text = name
            runCommand = id
            appPathLabel.text = id
        }
    }
    
    func returnNameAndPath(name: String, path: String?) {
        if tagIndex == 1{
            powerLabel.text = name
        }else if tagIndex == 2{
            playLabel.text = name
            if let path = path{
                pathForVideo = path + name
            }
        }else{
            runLabel.text = name
            runCommand = path
        }
    }
    
    @IBAction func voiceCommand(sender: AnyObject) {
        print("Send voice command!")
    }
    
}

extension PCControlInterfaceXIB : UIViewControllerAnimatedTransitioning {
    
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

extension PCControlInterfaceXIB : UIViewControllerTransitioningDelegate {
    
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
    func showPCInterface(pc:Device) {
        let pci = PCControlInterfaceXIB(pc:pc)
        self.presentViewController(pci, animated: true, completion: nil)
    }
}
