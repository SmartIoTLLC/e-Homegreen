//
//  RelayParametersCell.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 7/29/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

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
    
//    @IBOutlet weak var deviceInputHeight: NSLayoutConstraint!
//    @IBOutlet weak var deviceInputTopSpace: NSLayoutConstraint!
//    @IBOutlet weak var deviceImageHeight: NSLayoutConstraint!
//    @IBOutlet weak var deviceImageLeading: NSLayoutConstraint!
    
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
        
        txtFieldName.text = device.name
        lblAddress.text = "\(returnThreeCharactersForByte(Int(device.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device.address)))"
        lblChannel.text = "\(device.channel)"
        let level = DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location)
        if level != ""{
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        
        let zone = DatabaseHandler.returnZoneWithId(Int(device.zoneId), location: device.gateway.location)
        if zone != ""{
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        }else{
            btnZone.setTitle("All", forState: UIControlState.Normal)
        }
        
        let category = DatabaseHandler.returnCategoryWithId(Int(device.categoryId), location: device.gateway.location)
        if category != ""{
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        }else{
            btnCategory.setTitle("All", forState: UIControlState.Normal)
        }
        
        btnControlType.setTitle("\(device.controlType == ControlType.Curtain ? ControlType.Relay : device.controlType)", forState: UIControlState.Normal)
        if device.controlType != ControlType.Dimmer && device.controlType != ControlType.Relay{
            btnControlType.enabled = false
        }
        
        txtFieldName.delegate = self
        
        switchAllowCurtainControl.on = device.isCurtainModeAllowed.boolValue
        txtCurtainGroupId.text = "\(device.curtainGroupID.integerValue)"
        
        let chn = Int(device.channel)
        if device.controlType == ControlType.Sensor && (chn == 2 || chn == 3 || chn == 7 || chn == 10) {
            hideDeviceInput(false)
            if let diMode = device.digitalInputMode as? Int {
                changeControlMode.setTitle(DigitalInput.modeInfo[diMode], forState: .Normal)
            }
        } else {
            hideDeviceInput(true)
        }
        if device.controlType == ControlType.HumanInterfaceSeries && (chn == 2 || chn == 3) {
            hideDeviceInput(false)
            if let diMode = device.digitalInputMode as? Int {
                changeControlMode.setTitle(DigitalInput.modeInfo[diMode], forState: .Normal)
            }
        } else {
            hideDeviceInput(true)
        }
        if device.controlType == ControlType.Climate || (device.controlType == ControlType.Sensor && chn == 6) {
            hideImageButton(true)
        }
        if device.controlType == ControlType.Curtain && (chn == 2 || chn == 3) {
            hideDeviceInput(false)
            if let diMode = device.digitalInputMode as? Int {
                changeControlMode.setTitle(DigitalInput.modeInfo[diMode], forState: .Normal)
            }
        } else {
            hideDeviceInput(true)
        }
        //TODO: Dodaj i za gateway
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnControlType.tag = 4
        changeControlMode.tag = 5
    }
    override func nameAndId(name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            editedDevice?.levelId = (level?.id?.integerValue)!
            btnZone.setTitle("All", forState: .Normal)
            zoneSelected = nil
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            editedDevice?.zoneId = (zoneSelected?.id?.integerValue)!
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            editedDevice?.categoryId = (category?.id?.integerValue)!
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
        if switchAllowCurtainControl.on == false {
            btnControlType.enabled = true
        }else{
            btnControlType.enabled = false
        }
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
//        popoverList.append(PopOverItem(name: DigitalInput.Generic.description(), id: ""))
        popoverList.append(PopOverItem(name: DigitalInput.NormallyOpen.description(), id: ""))
        popoverList.append(PopOverItem(name: DigitalInput.NormallyClosed.description(), id: ""))
//        popoverList.append(PopOverItem(name: DigitalInput.MotionSensor.description(), id: ""))
//        popoverList.append(PopOverItem(name: DigitalInput.ButtonNormallyOpen.description(), id: ""))
//        popoverList.append(PopOverItem(name: DigitalInput.ButtonNormallyClosed.description(), id: ""))
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func changeControlType(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: ControlType.Dimmer, id: ""))
        popoverList.append(PopOverItem(name: ControlType.Relay, id: ""))
        popoverList.append(PopOverItem(name: ControlType.Curtain, id: ""))
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
            device.controlType = editedDevice!.controlType
            device.digitalInputMode = NSNumber(integer:editedDevice!.digitalInputMode)
            //            let defaultDeviceImages = DefaultDeviceImages().getNewImagesForDevice(device)
            //            // Basicaly checking if it is climate, and if it isn't, then delete and populate with new images:
            //            if let checkDeviceImages = device.deviceImages {
            //                if let devImages = Array(checkDeviceImages) as? [DeviceImage] {
            //                    if devImages.count > 0 {
            //                        for deviceImage in devImages {
            //                            appDel.managedObjectContext!.deleteObject(deviceImage)
            //                        }
            //                        for defaultDeviceImage in defaultDeviceImages {
            //                            let deviceImage = DeviceImage(context: appDel.managedObjectContext!)
            //                            deviceImage.defaultImage = defaultDeviceImage.defaultImage
            //                            deviceImage.state = NSNumber(integer:defaultDeviceImage.state)
            //                            deviceImage.device = device
            //                        }
            //                    }
            //                }
            //            }
            saveChanges()
            //            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func hideDeviceInput(isHidden:Bool) {
//        if isHidden {
//            deviceInputHeight.constant = 0
//            deviceInputTopSpace.constant = 0
//        } else {
//            deviceInputHeight.constant = 30
//            deviceInputTopSpace.constant = 8
//        }
//        backView.layoutIfNeeded()
    }
    func hideImageButton(isHidden:Bool) {
//        if isHidden {
//            deviceImageHeight.constant = 0
////            deviceImageLeading.constant = 0
//        } else {
//            deviceImageHeight.constant = 30
////            deviceImageLeading.constant = 7
//        }
//        backView.layoutIfNeeded()
    }
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            print("Unresolved error \(error1.userInfo)")
            abort()
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