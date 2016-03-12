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
    
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var commandTextField: UITextField!
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
//        SendingHandler.sendCommand(byteArray: Function.setPCState(pc.moduleAddress, command: <#T##Byte#>), gateway: <#T##Gateway#>)
    }
    
    @IBAction func playAction(sender: AnyObject) {
    }

    @IBAction func runAction(sender: AnyObject) {
        guard let appName = runLabel.text else {
            return
        }
//        SendingHandler.sendCommand(byteArray: Function.runApp(pc.moduleAddress, cmdLine: appName), gateway: pc.gateway)
//        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
//        0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1
//        let byteArray:[Byte] = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1,  0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1]
//        let byteArray:[Byte] = [0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1]
//        let data = NSData(bytes: byteArray, length: byteArray.count)
//        socketIO.socket.sendData(data, toHost: "192.168.0.255", port: 5100, withTimeout: -1, tag: 1)
        
        let s1 = "192.168.0.7"
        let cs1 = (s1 as NSString).UTF8String
        let first_parametar = UnsafeMutablePointer<UInt8>(cs1)
        let byteArray:[Byte] = [0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1]
//        let s2 = "08:9E:01:50:83:D1"
        let s2 = convertByteArrayToMacAddress(byteArray)
        let cs2 = (s2 as NSString).UTF8String
        let second_parametar = UnsafeMutablePointer<UInt8>(cs2)
//        let second_parametar = UnsafeMutablePointer<UInt8>([0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1])
        
//        var p1:UnsafeBufferPointer<Byte>?
//        let s: String = "192.168.0.255"
//        s.nulTerminatedUTF8.withUnsafeBufferPointer { p -> Void in
//            puts(UnsafePointer<Int8>(p.baseAddress))
//            p1 = p
//            Void()
//        }
//        var p2:UnsafeBufferPointer<Byte>?
//        let s2: String = "0x08:0x9E:0x01:0x50:0x83:0xD1"
//        s2.nulTerminatedUTF8.withUnsafeBufferPointer { p -> Void in
//            puts(UnsafePointer<Int8>(p.baseAddress))
//            p2 = p
//            Void()
//        }
//        guard let s12 = p1 as! UnsafeMutablePointer<Byte>( else {
//            return
//        }
//        guard let s22 = p1 as UnsafeMutablePointer<Byte> else {
//            return
//        }
        send_wol_packet(first_parametar, second_parametar)
    }
    var socketIO:InOutSocket
//    
    @IBAction func sendAction(sender: AnyObject) {
        guard let text = commandTextField.text else {
            return
        }
        SendingHandler.sendCommand(byteArray: Function.textToSpeech(pc.moduleAddress, text: text), gateway: pc.gateway)
    }
    
    @IBAction func addPathForVideo(sender: AnyObject) {
//        let vc = ListOfDevice_AppViewController()
        if let vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ListViewController") as? ListOfDevice_AppViewController {
            vc.typeOfFile = .Video
        self.presentViewController(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addPathForRunApp(sender: AnyObject) {
        if let vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ListViewController") as? ListOfDevice_AppViewController {
            vc.typeOfFile = .App
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func chooseOptionAction(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 6
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
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
