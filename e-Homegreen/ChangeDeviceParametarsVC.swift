//
//  ChangeDeviceParametarsVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 11/8/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

struct EditedDevice {
    var levelId:Int
    var zoneId:Int
    var categoryId:Int
    var controlType:String
}

class ChangeDeviceParametarsVC: UIViewController, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    
    
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var lblChannel:UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnControlType: CustomGradientButton!
    @IBOutlet weak var btnLevel: UIButton!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnImages: UIButton!
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var device:Device?
    var appDel:AppDelegate!
    var editedDevice:EditedDevice?
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    var isPresenting: Bool = true
    
    init(device: Device, point:CGPoint){
        super.init(nibName: "ChangeDeviceParametarsVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.device = device
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func saveText (text : String, id:Int) {
        print("\(text) \(id)")
        if text != "All" {
            if id == 2 {
                if let levelId = Int(DatabaseHandler.returnZoneIdWithName(text, gateway: device!.gateway)) {
                    editedDevice?.levelId = levelId
                }
                btnLevel.setTitle(text, forState: UIControlState.Normal)
            } else if id == 3 {
                if let zoneId = Int(DatabaseHandler.returnZoneIdWithName(text, gateway: device!.gateway)) {
                    editedDevice?.zoneId = zoneId
                }
                btnZone.setTitle(text, forState: UIControlState.Normal)
            } else if id == 4 {
                if let categoryId = Int(DatabaseHandler.returnCategoryIdWithName(text, gateway: device!.gateway)) {
                    editedDevice?.categoryId = categoryId
                }
                btnCategory.setTitle(text, forState: UIControlState.Normal)
            } else if id == 21 {
                editedDevice?.controlType = text
                btnControlType.setTitle(text,forState: UIControlState.Normal)
            }
        }
    }
    @IBAction func btnImages(sender: AnyObject, forEvent event: UIEvent) {
        let touches = event.touchesForView(sender as! UIView)
        let touch:UITouch = touches!.first!
        let touchPoint = touch.locationInView(self.view)
//        let touchPoint2 = touch.locationInView(sender as! UIView)
//        let touchPoint3 = touch.locationInView(self.view.parentViewController?.view)
        showDeviceImagesPicker(device!, point: touchPoint)
    }
    @IBAction func btnImages(sender: AnyObject) {
//        if let button = sender as? UIButton {
//            let pointInView = button.convertPoint(button.frame.origin, fromView: self.view)
//                showDeviceImagesPicker(device!, point: pointInView)
//        }
    }
    @IBAction func changeControlType(sender: AnyObject) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        popoverVC = mainStoryBoard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 21
        popoverVC.device = device!
        popoverVC.filterGateway = device?.gateway
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnLevel (sender: AnyObject) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        popoverVC = mainStoryBoard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 12
        popoverVC.filterGateway = device?.gateway
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
    
    @IBAction func btnZone (sender: AnyObject) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        popoverVC = mainStoryBoard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 13
        popoverVC.filterGateway = device?.gateway
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCategory (sender: AnyObject) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        popoverVC = mainStoryBoard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 14
        popoverVC.filterGateway = device?.gateway
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    @IBAction func btnSave(sender: AnyObject) {
        if txtFieldName.text != "" {
            device!.name = txtFieldName.text!
            device!.parentZoneId = NSNumber(integer: editedDevice!.levelId)
            device!.zoneId = NSNumber(integer: editedDevice!.zoneId)
            device!.categoryId = NSNumber(integer: editedDevice!.categoryId)
            device!.controlType = editedDevice!.controlType
            saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        //        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.view.tag = 1
        
        self.view.backgroundColor = UIColor.clearColor()
        
        txtFieldName.text = device!.name
        lblAddress.text = "\(returnThreeCharactersForByte(Int(device!.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device!.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device!.address)))"
        lblChannel.text = "\(device!.channel)"
        print(device!.parentZoneId)
        print(device!.zoneId)
        print(device!.categoryId)
        print(device!.controlType)
        btnLevel.setTitle("\(DatabaseHandler.returnZoneWithId(Int(device!.parentZoneId), gateway: device!.gateway))", forState: UIControlState.Normal)
        btnZone.setTitle("\(DatabaseHandler.returnZoneWithId(Int(device!.zoneId), gateway: device!.gateway))", forState: UIControlState.Normal)
        btnCategory.setTitle("\(DatabaseHandler.returnCategoryWithId(Int(device!.categoryId), gateway: device!.gateway))", forState: UIControlState.Normal)
        btnControlType.setTitle("\(device!.controlType)", forState: UIControlState.Normal)
        txtFieldName.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            print("Unresolved error \(error1.userInfo)")
            abort()
        }
    }
    
    
    
    
//    func returnThreeCharactersForByte (number:Int) -> String {
//        return String(format: "%03d",number)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleTap(gesture:UITapGestureRecognizer){
        let point:CGPoint = gesture.locationInView(self.view)
        let tappedView:UIView = self.view.hitTest(point, withEvent: nil)!
        if tappedView.tag == 1{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
extension ChangeDeviceParametarsVC : UIViewControllerAnimatedTransitioning {
    
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
            self.oldPoint = presentedControllerView.center
            presentedControllerView.center = self.point!
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
            containerView!.addSubview(presentedControllerView)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
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
                
                presentedControllerView.center = self.point!
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
}
extension ChangeDeviceParametarsVC : UIViewControllerTransitioningDelegate {
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
    func showChangeDeviceParametar(point:CGPoint, device:Device) {
        let cdp = ChangeDeviceParametarsVC(device: device, point: point)
        cdp.editedDevice = EditedDevice(levelId: Int(device.parentZoneId), zoneId: Int(device.zoneId), categoryId: Int(device.categoryId), controlType: device.controlType)
//        self.view.window?.rootViewController?.presentViewController(cdp, animated: true, completion: nil)
        self.presentViewController(cdp, animated: true, completion: nil)
    }
}
