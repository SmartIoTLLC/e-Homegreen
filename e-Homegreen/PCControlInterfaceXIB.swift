//
//  PCControlInterfaceXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

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
    
    init(){
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
    }
    
    @IBAction func playAction(sender: AnyObject) {
    }

    @IBAction func runAction(sender: AnyObject) {
    }
    
    @IBAction func sendAction(sender: AnyObject) {
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
            if let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
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
    func showPCInterface() {
        let pci = PCControlInterfaceXIB()
        self.view.window?.rootViewController?.presentViewController(pci, animated: true, completion: nil)
    }
}
