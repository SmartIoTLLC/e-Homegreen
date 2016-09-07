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

class ChangeDeviceParametarsVC: PopoverVC {
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var lblChannel:UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnControlType: CustomGradientButton!
    @IBOutlet weak var btnLevel: UIButton!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnImages: UIButton!
    
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
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.title = "Device Parameters"
        
        txtFieldName.text = device.name
        lblAddress.text = "\(returnThreeCharactersForByte(Int(device.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device.address)))"
        lblChannel.text = "\(device.channel)"
        level = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.parentZoneId), location: device.gateway.location)
        if level != nil{
            btnLevel.setTitle(level!.name, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        
        zoneSelected = DatabaseHandler.sharedInstance.returnZoneWithId(Int(device.zoneId), location: device.gateway.location)
        if zoneSelected != nil{
            btnZone.setTitle(zoneSelected!.name, forState: UIControlState.Normal)
        }else{
            btnZone.setTitle("All", forState: UIControlState.Normal)
        }
        
        let category = DatabaseHandler.sharedInstance.returnCategoryWithId(Int(device.categoryId), location: device.gateway.location)
        if category != ""{
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        }else{
           btnCategory.setTitle("All", forState: UIControlState.Normal)
        }
        
        btnControlType.setTitle("\(device.controlType == ControlType.Curtain ? ControlType.Relay : device.controlType)", forState: UIControlState.Normal)
        
        txtFieldName.delegate = self
        
        //TODO: Add for gateway when it is defined
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnControlType.tag = 4
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
        showDeviceImagesPicker(device, point: touchPoint)
    }
    
    @IBAction func btnImages(sender: AnyObject) {
    }
    @IBAction func changeDeviceInputMode(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: DigitalInput.NormallyOpen.description(), id: "")) // TODO: Dodati Id za NO
        popoverList.append(PopOverItem(name: DigitalInput.NormallyClosed.description(), id: "")) // TODO: Dodati Id za NC
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
            device.resetImages(appDel.managedObjectContext!)
            self.delegate?.saveClicked()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func handleTap(gesture:UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ChangeDeviceParametarsVC : UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ChangeDeviceParametarsVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendantOfView(backView){
                self.view.endEditing(true)
                return false
            }
        }
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
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.5, 1.5)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
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
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
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
        // If any kind of relay
        if device.controlType == ControlType.Relay || device.controlType == ControlType.Curtain{
            let cdp = RelayParametersCell(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }
        // If any kind of Digital input. It can be:
        // DigitalInput control type
        // Digital input in Intelligent switch
        // Digital input in sensor
        else if (device.controlType == ControlType.DigitalInput) ||
            (device.controlType == ControlType.IntelligentSwitch && (chn == DeviceInfo.IntelligentSwitchInputInterface.DigitalInput1.rawValue || chn == DeviceInfo.IntelligentSwitchInputInterface.DigitalInput2.rawValue)) ||
            (device.controlType == ControlType.Sensor && (chn == DeviceInfo.Multisensor10in1.DigitalInput1.rawValue || chn == DeviceInfo.Multisensor10in1.DigitalInput2.rawValue || chn == DeviceInfo.Multisensor10in1.DigitalInput3.rawValue || chn == DeviceInfo.Multisensor10in1.DigitalInput4.rawValue)){
            let cdp = DigitalInputPopup(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }
        // If any kind of clima
        else if device.controlType == ControlType.Climate {
            let cdp = HvacParametersCell(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }
        // If anything else
        else{
            let cdp = ChangeDeviceParametarsVC(device: device, point: point)
            cdp.delegate = scanDevicesViewController
            self.presentViewController(cdp, animated: true, completion: nil)
        }
    }
}
