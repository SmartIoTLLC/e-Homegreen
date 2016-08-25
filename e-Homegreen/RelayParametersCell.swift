//
//  RelayParametersCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 7/29/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol DevicePropertiesDelegate {
    func saveClicked()
}

class RelayParametersCell: PopoverVC, UITextFieldDelegate {
    
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var lblChannel:UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnControlType: CustomGradientButton!
    @IBOutlet weak var btnLevel: UIButton!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnImages: UIButton!
    @IBOutlet weak var changeControlMode: CustomGradientButton!
    @IBOutlet weak var switchAllowCurtainControl: UISwitch!
    @IBOutlet weak var txtCurtainGroupId: UITextField!
    
    var button:UIButton!
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    var point:CGPoint?
    var oldPoint:CGPoint?
    var device:Device
    var appDel:AppDelegate!
    var editedDevice:EditedDevice?
    var isPresenting: Bool = true
    var delegate: DevicePropertiesDelegate?
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(device: Device, point:CGPoint){
        self.device = device
        self.point = point
        editedDevice = EditedDevice(levelId: Int(device.parentZoneId), zoneId: Int(device.zoneId), categoryId: Int(device.categoryId), controlType: device.controlType, digitalInputMode: Int(device.digitalInputMode!))
        super.init(nibName: "RelayParametersCell", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RelayParametersCell.handleTap(_:)))
        //        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.view.tag = 1
        
        self.view.backgroundColor = UIColor.clearColor()
        
        txtCurtainGroupId.inputAccessoryView = CustomToolBar()
        
        txtFieldName.text = device.name
        lblAddress.text = "\(returnThreeCharactersForByte(Int(device.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device.address)))"
        lblChannel.text = "\(device.channel)"
        level = DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location)
        if let level = level {
            btnLevel.setTitle(level.name, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        
        zoneSelected = DatabaseHandler.returnZoneWithId(Int(device.zoneId), location: device.gateway.location)
        if let zoneSelected = zoneSelected{
            btnZone.setTitle(zoneSelected.name, forState: UIControlState.Normal)
        }else{
            btnZone.setTitle("All", forState: UIControlState.Normal)
        }
        
        let category = DatabaseHandler.returnCategoryWithId(Int(device.categoryId), location: device.gateway.location)
        if category != ""{
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        }else{
            btnCategory.setTitle("All", forState: UIControlState.Normal)
        }
        
        if var digInputMode = device.digitalInputMode?.integerValue{
            if digInputMode == 1 || digInputMode == 2 {
            }else{
                digInputMode = 1
            }
            let controlType = DigitalInput.modeInfo[digInputMode]
            // It can be only NO and NC. If nothing is selected from those two set default value (NormallyOpen)
            if controlType != "" || controlType != DigitalInput.NormallyOpen.description() || controlType != DigitalInput.NormallyClosed.description(){
                changeControlMode.setTitle(controlType, forState: UIControlState.Normal)
            }else{
                changeControlMode.setTitle(DigitalInput.NormallyOpen.description(), forState: UIControlState.Normal)
            }
        }
        
        btnControlType.setTitle("\(device.controlType == ControlType.Curtain ? ControlType.Relay : device.controlType)", forState: UIControlState.Normal)
        
        txtFieldName.delegate = self
        
        switchAllowCurtainControl.on = device.isCurtainModeAllowed.boolValue
        txtCurtainGroupId.text = "\(device.curtainGroupID.integerValue)"
        
        // Setting control mode.
        // If device original type is Dimmer, then Control Type could change but control mode mustn't
        if device.type == ControlType.Dimmer{
            changeControlMode.enabled = false
        }else{
            changeControlMode.enabled = true
        }
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnControlType.tag = 4
        changeControlMode.tag = 5
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConnectionSettingsVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
    }
    override func nameAndId(name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            if let level = level {
                editedDevice?.levelId = (level.id?.integerValue)!
            }else{
                editedDevice?.levelId = 255
            }
            btnZone.setTitle("All", forState: .Normal)
            zoneSelected = nil
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            
            if let zoneSelected = zoneSelected {
               editedDevice?.zoneId = (zoneSelected.id?.integerValue)!
            }else{
                zoneSelected = nil
                editedDevice?.zoneId = 255
            }
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            if let category = category{
                editedDevice?.categoryId = (category.id?.integerValue)!
            }else{
                editedDevice?.categoryId = 255
            }
            break
        case 4:
            editedDevice?.controlType = name
            btnControlType.setTitle(name, forState: UIControlState.Normal)
            break
        case 5:
            editedDevice?.digitalInputMode = DigitalInput.modeInfoReverse[name]!
            changeControlMode.setTitle(name,forState: UIControlState.Normal)
            break
        default:
            break
        }
        
        button.setTitle(name, forState: .Normal)
    }
    
    @IBAction func switchTrigered(sender: AnyObject) {

    }
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnImages(sender: AnyObject, forEvent event: UIEvent) {
        let touches = event.touchesForView(sender as! UIView)
        let touch:UITouch = touches!.first!
        let touchPoint = touch.locationInView(self.view)
        //        let touchPoint2 = touch.locationInView(sender as! UIView)
        //        let touchPoint3 = touch.locationInView(self.view.parentViewController?.view)
        showDeviceImagesPicker(device, point: touchPoint)
    }
    @IBAction func btnImages(sender: AnyObject) {
//        if let button = sender as? UIButton {
//            let pointInView = button.convertPoint(button.frame.origin, fromView: self.view)
//            showDeviceImagesPicker(device!, point: pointInView)
//        }
    }
    @IBAction func changeControlMode(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: DigitalInput.NormallyOpen.description(), id: ""))
        popoverList.append(PopOverItem(name: DigitalInput.NormallyClosed.description(), id: ""))
//        popoverList.append(PopOverItem(name: "NC and Reset", id: ""))
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func changeControlType(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: ControlType.Dimmer, id: ""))
        popoverList.append(PopOverItem(name: ControlType.Relay, id: ""))
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnLevel (sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = FilterController.shared.getLevelsByLocation(device.gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnZone (sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = FilterController.shared.getZoneByLevel(device.gateway.location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnCategory (sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = FilterController.shared.getCategoriesByLocation(device.gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnSave(sender: AnyObject) {
        if txtFieldName.text != "" {
            device.name = txtFieldName.text!
            device.isCurtainModeAllowed = switchAllowCurtainControl.on
            if let groupId = txtCurtainGroupId.text{
                if let _ = Int(groupId){
                    device.curtainGroupID = Int(groupId)!
                }
            }
            device.parentZoneId = NSNumber(integer: editedDevice!.levelId)
            device.zoneId = NSNumber(integer: editedDevice!.zoneId)
            device.categoryId = NSNumber(integer: editedDevice!.categoryId)
            if editedDevice!.controlType == ControlType.Relay {
                if device.isCurtainModeAllowed.boolValue {
                    device.controlType = ControlType.Curtain
                }else{
                    device.controlType = ControlType.Relay
                }
            }else{
                if editedDevice!.controlType == ControlType.Curtain {
                    if device.isCurtainModeAllowed.boolValue {
                        device.controlType = ControlType.Curtain // Stay crtain
                    }else{
                        device.controlType = ControlType.Relay  // if isCurtainModeAllowed is disabbled, set it to relay
                    }
                }else{
                    device.controlType = editedDevice!.controlType
                }
            }
            device.digitalInputMode = NSNumber(integer:editedDevice!.digitalInputMode)
            
            device.resetImages(appDel.managedObjectContext!)
            CoreDataController.shahredInstance.saveChanges()
            //            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            self.delegate?.saveClicked()
        }
    }

    func handleTap(gesture:UITapGestureRecognizer){
        let point:CGPoint = gesture.locationInView(self.view)
        let tappedView:UIView = self.view.hitTest(point, withEvent: nil)!
        if tappedView.tag == 1{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if txtCurtainGroupId.isFirstResponder(){
            if backView.frame.origin.y + txtCurtainGroupId.frame.origin.y + 30 - self.scrollView.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.txtCurtainGroupId.frame.origin.y + 30 - self.scrollView.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.centerY.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
}
extension RelayParametersCell : UIViewControllerAnimatedTransitioning {
    
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

extension RelayParametersCell : UIViewControllerTransitioningDelegate {
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