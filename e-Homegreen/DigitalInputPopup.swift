//
//  DigitalInputPopup.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/3/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class DigitalInputPopup: PopoverVC, UITextFieldDelegate {
    
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
        super.init(nibName: "DigitalInputPopup", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChangeDeviceParametarsVC.handleTap(_:)))
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
        
        
        // Set current device input mode.
        // In DigitalInput struct is defined "ids" and "values" for digitalInputMode
        if let diMode = device.digitalInputMode as? Int {
            changeDeviceInputMode.setTitle(DigitalInput.modeInfo[diMode], forState: .Normal)
        }
        
        txtFieldName.delegate = self
        
        //TODO: Dodaj i za gateway
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnControlType.tag = 4
        changeDeviceInputMode.tag = 5
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
        showDeviceImagesPicker(device, point: touchPoint)
    }
    @IBAction func btnImages(sender: AnyObject) {
    }
    @IBAction func changeDeviceInputMode(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: DigitalInput.Generic.description(), id: DigitalInput.modeInfo[DigitalInput.DigitalInputMode.Generic]!))
        popoverList.append(PopOverItem(name: DigitalInput.NormallyOpen.description(), id: DigitalInput.modeInfo[DigitalInput.DigitalInputMode.NormallyOpen]!))
        popoverList.append(PopOverItem(name: DigitalInput.NormallyClosed.description(), id: DigitalInput.modeInfo[DigitalInput.DigitalInputMode.NormallyClosed]!))
        popoverList.append(PopOverItem(name: DigitalInput.MotionSensor.description(), id: DigitalInput.modeInfo[DigitalInput.DigitalInputMode.MotionSensor]!))
        popoverList.append(PopOverItem(name: DigitalInput.ButtonNormallyOpen.description(), id: DigitalInput.modeInfo[DigitalInput.DigitalInputMode.ButtonNormallyOpen]!))
        popoverList.append(PopOverItem(name: DigitalInput.ButtonNormallyClosed.description(), id: DigitalInput.modeInfo[DigitalInput.DigitalInputMode.ButtonNormallyClosed]!))
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func changeControlType(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: ControlType.HumanInterfaceSeries, id: ""))
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
            device.parentZoneId = NSNumber(integer: editedDevice!.levelId)
            device.zoneId = NSNumber(integer: editedDevice!.zoneId)
            device.categoryId = NSNumber(integer: editedDevice!.categoryId)
            if editedDevice!.controlType == ControlType.Relay && device.isCurtainModeAllowed.boolValue {
                device.controlType = ControlType.Curtain
            }else{
                device.controlType = editedDevice!.controlType
            }
            device.digitalInputMode = NSNumber(integer:editedDevice!.digitalInputMode)
            saveChanges()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
extension DigitalInputPopup : UIViewControllerAnimatedTransitioning {
    
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

extension DigitalInputPopup : UIViewControllerTransitioningDelegate {
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