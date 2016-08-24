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
    var digitalInputMode:Int
}

class ChangeDeviceParametarsVC: PopoverVC, UITextFieldDelegate {
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var lblChannel:UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnControlType: CustomGradientButton!
    @IBOutlet weak var btnLevel: UIButton!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnImages: UIButton!
    @IBOutlet weak var changeDeviceInputMode: CustomGradientButton!
    
    @IBOutlet weak var deviceInputHeight: NSLayoutConstraint!
    @IBOutlet weak var deviceInputTopSpace: NSLayoutConstraint!
    @IBOutlet weak var deviceImageHeight: NSLayoutConstraint!
    @IBOutlet weak var deviceImageLeading: NSLayoutConstraint!
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    func hideDeviceInput(isHidden:Bool) {
        if isHidden {
            deviceInputHeight.constant = 0
            deviceInputTopSpace.constant = 0
        } else {
            deviceInputHeight.constant = 30
            deviceInputTopSpace.constant = 8
        }
        backView.layoutIfNeeded()
    }
    
    func hideImageButton(isHidden:Bool) {
        if isHidden {
            deviceImageHeight.constant = 0
            deviceImageLeading.constant = 0
        } else {
            deviceImageHeight.constant = 30
            deviceImageLeading.constant = 7
        }
        backView.layoutIfNeeded()
    }
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var device:Device
    var appDel:AppDelegate!
    var editedDevice:EditedDevice?
    
    var isPresenting: Bool = true
    var delegate: DevicePropertiesDelegate?
    
    init(device: Device, point:CGPoint){
        self.device = device
        self.point = point
        editedDevice = EditedDevice(levelId: Int(device.parentZoneId), zoneId: Int(device.zoneId), categoryId: Int(device.categoryId), controlType: device.controlType, digitalInputMode: Int(device.digitalInputMode!))
        super.init(nibName: "ChangeDeviceParametarsVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChangeDeviceParametarsVC.handleTap(_:)))
        //        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.view.tag = 1
        self.view.backgroundColor = UIColor.clearColor()
        self.title = "Device Parameters"
        
        txtFieldName.text = device.name
        lblAddress.text = "\(returnThreeCharactersForByte(Int(device.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device.address)))"
        lblChannel.text = "\(device.channel)"
        level = DatabaseHandler.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location)
        if level != nil{
            btnLevel.setTitle(level!.name, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        
        zoneSelected = DatabaseHandler.returnZoneWithId(Int(device.zoneId), location: device.gateway.location)
        if zoneSelected != nil{
            btnZone.setTitle(zoneSelected!.name, forState: UIControlState.Normal)
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
        
        txtFieldName.delegate = self
        
        let chn = Int(device.channel)
        // When DigitalInput, then DeviceInputMode should be presented
        // Digital input on Sensor can be on one of the following channels: 2, 3, 7 and 10
        if device.controlType == ControlType.Sensor && (chn == 2 || chn == 3 || chn == 7 || chn == 10) {
            hideDeviceInput(false)
            if let diMode = device.digitalInputMode as? Int {
                changeDeviceInputMode.setTitle(DigitalInput.modeInfo[diMode], forState: .Normal)
            }
        } else {
            hideDeviceInput(true)
        }
        // When DigitalInput, then DeviceInputMode should be presented
        // Digital input on Intelligent Switch can be on one of the following channels: 2, 3, 7 and 10
        if device.controlType == ControlType.HumanInterfaceSeries && (chn == 2 || chn == 3) {
            hideDeviceInput(false)
            if let diMode = device.digitalInputMode?.integerValue {
                changeDeviceInputMode.setTitle(DigitalInput.modeInfo[diMode], forState: .Normal)
            }
        } else {
            hideDeviceInput(true)
        }
        if device.controlType == ControlType.Climate || (device.controlType == ControlType.Sensor && chn == 6) {
            hideImageButton(true)
        }
        //TODO: Add for gateway when it is defined
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnControlType.tag = 4
        changeDeviceInputMode.tag = 5
    }
    override func nameAndId(name: String, id: String) {
        
        switch button.tag{
        case 1: // "All" selected
            if let levelTemp = FilterController.shared.getZoneByObjectId(id), let id = levelTemp.id{
                editedDevice?.levelId = (id.integerValue)
                level = levelTemp
            }else{
                // Set default levelId
                editedDevice?.levelId = 255
                btnZone.setTitle("All", forState: .Normal)
                level = nil
            }
            break
        case 2:
            if let zoneTemp = FilterController.shared.getZoneByObjectId(id), let id = zoneTemp.id{
                editedDevice?.zoneId = (id.integerValue)
                zoneSelected = zoneTemp
            }else{
                // Set default zoneId
                editedDevice?.zoneId = 255
                zoneSelected = nil
            }
            break
        case 3:
            if let categoryTemp = FilterController.shared.getCategoryByObjectId(id), let id = categoryTemp.id{
                editedDevice?.categoryId = (id.integerValue)
                category = categoryTemp
            }else{
                // Set default categoryId
                editedDevice?.categoryId = 255
                category = nil
            }
            break
        case 4:
            editedDevice?.controlType = name
            btnControlType.setTitle(name, forState: UIControlState.Normal)
            break
        case 5:
            editedDevice?.digitalInputMode = DigitalInput.modeInfoReverse[name]!
            changeDeviceInputMode.setTitle(name,forState: UIControlState.Normal)
            break
        default:
            break
        }
        
        button.setTitle(name, forState: .Normal)
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
//                showDeviceImagesPicker(device!, point: pointInView)
//        }
    }
    @IBAction func changeDeviceInputMode(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
//        popoverList.append(PopOverItem(name: DigitalInput.Generic.description(), id: ""))
        popoverList.append(PopOverItem(name: DigitalInput.NormallyOpen.description(), id: "")) // TODO: Dodati Id za NO
        popoverList.append(PopOverItem(name: DigitalInput.NormallyClosed.description(), id: "")) // TODO: Dodati Id za NC
//        popoverList.append(PopOverItem(name: DigitalInput.MotionSensor.description(), id: ""))
//        popoverList.append(PopOverItem(name: DigitalInput.ButtonNormallyOpen.description(), id: ""))
//        popoverList.append(PopOverItem(name: DigitalInput.ButtonNormallyClosed.description(), id: ""))
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func changeControlType(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if device.controlType == ControlType.Sensor{

            popoverList.append(PopOverItem(name: ControlType.Sensor, id: ""))
        }else if device.controlType == ControlType.Dimmer{
            popoverList.append(PopOverItem(name: ControlType.Dimmer, id: "")) // TODO: Dodati Id za Dimmer
            popoverList.append(PopOverItem(name: ControlType.Relay, id: "")) // TODO: Dodati Id za Relay
        }
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnLevel (sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = FilterController.shared.getLevelsByLocation(device.gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: "0"), atIndex: 0)
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
        
        popoverList.insert(PopOverItem(name: "All", id: "0"), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnCategory (sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = FilterController.shared.getCategoriesByLocation(device.gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: "0"), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if txtFieldName.text != "" {
            device.name = txtFieldName.text!
            device.parentZoneId = NSNumber(integer: editedDevice!.levelId)
            device.zoneId = NSNumber(integer: editedDevice!.zoneId)
            device.categoryId = NSNumber(integer: editedDevice!.categoryId)
            device.controlType = editedDevice!.controlType
            device.digitalInputMode = NSNumber(integer:editedDevice!.digitalInputMode)
            CoreDataController.shahredInstance.saveChanges()
            self.delegate?.saveClicked()
            self.dismissViewControllerAnimated(true, completion: nil)
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
    func showChangeDeviceParametar(point:CGPoint, device:Device, scanDevicesViewController: DevicePropertiesDelegate) {
        let chn = Int(device.channel)
        if device.controlType == ControlType.Relay || device.controlType == ControlType.Curtain{
            let cdp = RelayParametersCell(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }else if device.controlType == ControlType.HumanInterfaceSeries && (chn == 2 || chn == 3){
            let cdp = DigitalInputPopup(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }else if device.controlType == ControlType.Climate {
            let cdp = HvacParametersCell(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }else if device.controlType == ControlType.Sensor && (chn == 2 || chn == 3 || chn == 7 || chn == 10){
            let cdp = DigitalInputPopup(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }else{
            let cdp = ChangeDeviceParametarsVC(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }
    }
}
