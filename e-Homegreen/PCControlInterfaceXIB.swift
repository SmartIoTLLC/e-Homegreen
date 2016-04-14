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
        case Video: return "Video"
        case App: return "Application"
        }
    }
}

class PCControlInterfaceXIB: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    
    var isPresenting: Bool = true
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    @IBOutlet weak var fullScreenSwitch: UISwitch!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var fullScreenByte:Byte = 0x00
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var commandTextField: UITextField!
    
    var tagIndex = 0 // cuvam tag od dugmeta koje poziva popover
    var runCommand:String? // run komanda
    var pathForVideo:String? // putanja selektovanog videa
    
    var pc:Device
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commandTextField.layer.borderWidth = 1
        commandTextField.layer.cornerRadius = 2
        commandTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        commandTextField.attributedPlaceholder = NSAttributedString(string:"Enter Command",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        commandTextField.delegate = self
        
        titleLabel.text = pc.name
        
        self.view.backgroundColor = UIColor.clearColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissViewController"))
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
        SendingHandler.sendCommand(byteArray: Function.textToSpeech(pc.moduleAddress, text: text), gateway: pc.gateway)
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
    
    @IBAction func chooseOptionAction(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.device = pc
        tagIndex = sender.tag
        if sender.tag == 1{
           popoverVC.indexTab = 23
        }else if sender.tag == 2{
            popoverVC.indexTab = 24
        }else{
           popoverVC.indexTab = 25
        }
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
        self.view.window?.rootViewController?.presentViewController(pci, animated: true, completion: nil)
    }
}
