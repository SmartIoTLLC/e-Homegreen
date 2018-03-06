//
//  DigitalInputPopup.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/3/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DigitalInputPopup: PopoverVC {
    
    var deviceShouldResetImages: Bool = false
    var imagesToReset: [DeviceImage] = []
    var button:UIButton!
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    var device:Device
    var appDel:AppDelegate!
    var editedDevice:EditedDevice?
    var isPresenting: Bool = true
    var delegate: DevicePropertiesDelegate?
    
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
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnImages(_ sender: AnyObject, forEvent event: UIEvent) {
        showImagePicker(sender: sender, event: event)
    }
    @IBAction func btnImages(_ sender: AnyObject) {
    }
    @IBAction func changeDeviceInputMode(_ sender: UIButton) {
        changeDeviceInputModeTapped(sender: sender)
    }
    @IBAction func changeControlType(_ sender: UIButton) {
        changeControlTypeTapped(sender: sender)
    }
    @IBAction func btnLevel (_ sender: UIButton) {
        levelTapped(sender: sender)
    }
    @IBAction func btnZone (_ sender: UIButton) {
        zoneTapped(sender: sender)
    }
    @IBAction func btnCategory (_ sender: UIButton) {
        categoryTapped(sender: sender)
    }
    @IBAction func btnSave(_ sender: AnyObject) {
        save()
    }
    
    init(device: Device){
        self.device = device
        editedDevice = EditedDevice(levelId: device.parentZoneId.intValue, zoneId: device.zoneId.intValue, categoryId: device.categoryId.intValue, controlType: device.controlType, digitalInputMode: device.digitalInputMode!.intValue)
        super.init(nibName: "DigitalInputPopup", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addObservers()
    }
    
    @objc func handleResetImages(_ notification: Notification) {
        if let object = notification.object as? [String: Any] {
            if let id = object["deviceId"] as? NSManagedObjectID {
                if id == device.objectID {
                    deviceShouldResetImages = true
                }
                if let deviceImage = object["deviceImage"] as? DeviceImage {
                    imagesToReset.append(deviceImage)
                }
            }
        }
    }
    
    override func nameAndId(_ name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            if let level = level {
                editedDevice?.levelId = (level.id?.intValue)!
                btnZone.setTitle("All", for: UIControlState())
                zoneSelected = nil
            } else {
                // set default
                editedDevice?.levelId = 255
                btnZone.setTitle("All", for: UIControlState())
                zoneSelected = nil
            }
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            if let zoneSelected = zoneSelected {
                editedDevice?.zoneId = (zoneSelected.id?.intValue)!
            } else {
                // set default
                self.zoneSelected = nil
                editedDevice?.zoneId = 255
            }
            break
            
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            if let category = category{
                editedDevice?.categoryId = (category.id?.intValue)!
            } else {
                // set default
                editedDevice?.categoryId = 255
            }
            
            break
        case 4:
            editedDevice?.controlType = name
            btnControlType.setTitle(name, for: UIControlState())
            break
        case 5:
            editedDevice?.digitalInputMode = DigitalInput.modeInfoReverse[name]!
            changeDeviceInputMode.setTitle(name,for: UIControlState())
            break
        default:
            break
        }
        
        button.setTitle(name, for: UIControlState())
    }
}

// MARK: - Setup views
extension DigitalInputPopup {
    func setupViews() {
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChangeDeviceParametarsVC.handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        txtFieldName.text = device.name
        lblAddress.text   = "\(returnThreeCharactersForByte(device.gateway.addressOne.intValue)):\(returnThreeCharactersForByte(device.gateway.addressTwo.intValue)):\(returnThreeCharactersForByte(device.address.intValue))"
        lblChannel.text   = "\(device.channel)"
        
        level = DatabaseZoneController.shared.getZoneById(device.parentZoneId.intValue, location: device.gateway.location)
        if let level = level { btnLevel.setTitle(level.name, for: UIControlState()) } else { btnLevel.setTitle("All", for: UIControlState()) }
        
        zoneSelected = DatabaseZoneController.shared.getZoneById(device.zoneId.intValue, location: device.gateway.location)
        if let zoneSelected = zoneSelected , zoneSelected.name != "Default" { btnZone.setTitle(zoneSelected.name, for: UIControlState()) } else { btnZone.setTitle("All", for: UIControlState()) }
        
        let category = DatabaseCategoryController.shared.getCategoryById(device.categoryId.intValue, location: device.gateway.location)
        if category != nil { btnCategory.setTitle(category?.name, for: UIControlState()) } else { btnCategory.setTitle("All", for: UIControlState()) }
        
        if let digInputMode = device.digitalInputMode?.intValue {
            let controlType = DigitalInput.modeInfo[digInputMode]
            if controlType != "" { changeDeviceInputMode.setTitle(controlType, for: UIControlState()) } else { changeDeviceInputMode.setTitle("All", for: UIControlState()) }
        }
        
        btnControlType.setTitle("\(device.controlType == ControlType.Curtain ? ControlType.Relay : device.controlType)", for: UIControlState())
        
        // Set current device input mode.
        // In DigitalInput struct is defined "ids" and "values" for digitalInputMode
        if let diMode = device.digitalInputMode as? Int { changeDeviceInputMode.setTitle(DigitalInput.modeInfo[diMode], for: UIControlState()) }
        
        txtFieldName.delegate = self
        
        //TODO: Dodaj i za gateway
        btnLevel.tag              = 1
        btnZone.tag               = 2
        btnCategory.tag           = 3
        btnControlType.tag        = 4
        changeDeviceInputMode.tag = 5
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleResetImages(_:)), name: .deviceShouldResetImages, object: nil)
    }
}

// MARK: - Logic
extension DigitalInputPopup {
    fileprivate func changeControlTypeTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if device.controlType == ControlType.Sensor{
            popoverList.append(PopOverItem(name: ControlType.Sensor, id: ""))
        }else if device.controlType == ControlType.IntelligentSwitch{
            popoverList.append(PopOverItem(name: ControlType.IntelligentSwitch, id: ""))
        }
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func levelTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(device.gateway.location)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func zoneTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(device.gateway.location, parentZone: level)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func categoryTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(device.gateway.location)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func save() {
        if txtFieldName.text != "" {
            device.name         = txtFieldName.text!
            device.parentZoneId = NSNumber(value: editedDevice!.levelId as Int)
            device.zoneId       = NSNumber(value: editedDevice!.zoneId as Int)
            device.categoryId   = NSNumber(value: editedDevice!.categoryId as Int)
            if editedDevice!.controlType == ControlType.Relay && device.isCurtainModeAllowed.boolValue { device.controlType = ControlType.Curtain } else { device.controlType = editedDevice!.controlType }
            if deviceShouldResetImages {
                imagesToReset.forEach({ (image) in device.resetSingleImage(image: image) })
                imagesToReset = []
            }
            deviceShouldResetImages = false
            device.digitalInputMode = NSNumber(value: editedDevice!.digitalInputMode as Int)
            CoreDataController.sharedInstance.saveChanges()
            self.delegate?.saveClicked()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func changeDeviceInputModeTapped(sender: UIButton) {
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
    
    fileprivate func showImagePicker(sender: AnyObject, event: UIEvent) {
        if let sender = sender as? UIView {
            let touches = event.touches(for: sender)
            if let touch:UITouch = touches?.first {
                let touchPoint = touch.location(in: view)
                showDeviceImagesPicker(device, point: touchPoint)
            }
        }
    }
    
    func handleTap(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TextField Delegate
extension DigitalInputPopup : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Gesture recognizer delegate
extension DigitalInputPopup : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view { if touchView.isDescendant(of: backView) { dismissEditing(); return false } }
        return true
    }
}

extension DigitalInputPopup : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.5, scaleOneY: 1.5, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)
    }
}

extension DigitalInputPopup : UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
}
