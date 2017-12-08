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

class RelayParametersCell: PopoverVC {
    
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
    @IBOutlet weak var changeControlMode: CustomGradientButton!
    @IBOutlet weak var switchAllowCurtainControl: UISwitch!
    @IBOutlet weak var txtCurtainGroupId: UITextField!
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func switchTrigered(_ sender: AnyObject) {
    }
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnImages(_ sender: AnyObject, forEvent event: UIEvent) {
        showImagePicker(sender: sender, event: event)
    }
    @IBAction func changeControlMode(_ sender: UIButton) {
        changeControlModeTapped(sender: sender)
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
        editedDevice = EditedDevice(levelId: Int(device.parentZoneId), zoneId: Int(device.zoneId), categoryId: Int(device.categoryId), controlType: device.controlType, digitalInputMode: Int(device.digitalInputMode!))
        super.init(nibName: "RelayParametersCell", bundle: nil)
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
    
    override func nameAndId(_ name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            if let level = level { editedDevice?.levelId = (level.id?.intValue)! } else { editedDevice?.levelId = 255 }
            btnZone.setTitle("All", for: UIControlState())
            zoneSelected = nil
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            
            if let zoneSelected = zoneSelected { editedDevice?.zoneId = (zoneSelected.id?.intValue)! } else { zoneSelected = nil; editedDevice?.zoneId = 255 }
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            if let category = category { editedDevice?.categoryId = (category.id?.intValue)! } else { editedDevice?.categoryId = 255 }
            break
        case 4:
            editedDevice?.controlType = name
            btnControlType.setTitle(name, for: UIControlState())
            break
        case 5:
            editedDevice?.digitalInputMode = DigitalInput.modeInfoReverse[name]!
            changeControlMode.setTitle(name,for: UIControlState())
            break
        default:
            break
        }
        
        button.setTitle(name, for: UIControlState())
    }
    
}

// MARK: - View setup
extension RelayParametersCell {
    
    func setupViews() {
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        txtCurtainGroupId.inputAccessoryView = CustomToolBar()
        
        txtFieldName.text = device.name
        lblAddress.text   = "\(returnThreeCharactersForByte(Int(device.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device.address)))"
        lblChannel.text   = "\(device.channel)"
        
        level = DatabaseZoneController.shared.getZoneById(Int(device.parentZoneId), location: device.gateway.location)
        if let level = level { btnLevel.setTitle(level.name, for: UIControlState()) } else { btnLevel.setTitle("All", for: UIControlState()) }
        
        zoneSelected = DatabaseZoneController.shared.getZoneById(Int(device.zoneId), location: device.gateway.location)
        if let zoneSelected = zoneSelected { btnZone.setTitle(zoneSelected.name, for: UIControlState()) } else { btnZone.setTitle("All", for: UIControlState()) }
        
        let category = DatabaseCategoryController.shared.getCategoryById(Int(device.categoryId), location: device.gateway.location)
        if category != nil { btnCategory.setTitle(category?.name, for: UIControlState()) } else { btnCategory.setTitle("All", for: UIControlState()) }
        
        if var digInputMode = device.digitalInputMode?.intValue {
            if digInputMode == 1 || digInputMode == 2 {} else { digInputMode = 1 }
            let controlType = DigitalInput.modeInfo[digInputMode]
            // It can be only NO and NC. If nothing is selected from those two set default value (NormallyOpen)
            if controlType != "" || controlType != DigitalInput.NormallyOpen.description() || controlType != DigitalInput.NormallyClosed.description() {
                changeControlMode.setTitle(controlType, for: UIControlState())
            } else { changeControlMode.setTitle(DigitalInput.NormallyOpen.description(), for: UIControlState()) }
        }
        
        btnControlType.setTitle("\(device.controlType == ControlType.Curtain ? ControlType.Relay : device.controlType)", for: UIControlState())
        
        txtFieldName.delegate = self
        
        switchAllowCurtainControl.isOn = device.isCurtainModeAllowed.boolValue
        txtCurtainGroupId.text         = "\(device.curtainGroupID.intValue)"
        
        // Setting control mode.
        // If device original type is Dimmer, then Control Type could change but control mode mustn't
        if device.type == ControlType.Dimmer { changeControlMode.isEnabled = false } else { changeControlMode.isEnabled = true }
        
        btnLevel.tag          = 1
        btnZone.tag           = 2
        btnCategory.tag       = 3
        btnControlType.tag    = 4
        changeControlMode.tag = 5
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: txtCurtainGroupId, keyboardFrame: keyboardFrame, backView: backView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func handleTap(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Logic
extension RelayParametersCell {
    fileprivate func showImagePicker(sender: AnyObject, event: UIEvent) {
        if let sender = sender as? UIView {
            let touches = event.touches(for: sender)
            if let touch = touches?.first {
                let touchPoint = touch.location(in: view)
                showDeviceImagesPicker(device, point: touchPoint)
            }
        }
    }
    
    fileprivate func changeControlModeTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: DigitalInput.NormallyOpen.description(), id: ""))
        popoverList.append(PopOverItem(name: DigitalInput.NormallyClosed.description(), id: ""))
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func changeControlTypeTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: ControlType.Dimmer, id: ""))
        popoverList.append(PopOverItem(name: ControlType.Relay, id: ""))
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
        if let level = level {
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
            if let moc = appDel.managedObjectContext {
                device.name                 = txtFieldName.text!
                device.isCurtainModeAllowed = switchAllowCurtainControl.isOn as NSNumber
                if let groupId = txtCurtainGroupId.text {
                    if let _ = Int(groupId) { device.curtainGroupID = NSNumber(value: Int(groupId)!) }
                }
                device.parentZoneId = NSNumber(value: editedDevice!.levelId as Int)
                device.zoneId       = NSNumber(value: editedDevice!.zoneId as Int)
                device.categoryId   = NSNumber(value: editedDevice!.categoryId as Int)
                
                if editedDevice!.controlType == ControlType.Relay {
                    if device.isCurtainModeAllowed.boolValue { device.controlType = ControlType.Curtain } else { device.controlType = ControlType.Relay }
                    
                } else {
                    if editedDevice!.controlType == ControlType.Curtain {
                        if device.isCurtainModeAllowed.boolValue { device.controlType = ControlType.Curtain // Stay curtain
                        } else { device.controlType = ControlType.Relay } // if isCurtainModeAllowed is disabbled, set it to relay
                        
                    } else { device.controlType = editedDevice!.controlType }
                }
                
                device.digitalInputMode = NSNumber(value: editedDevice!.digitalInputMode as Int)
                
                device.resetImages(moc)
                CoreDataController.sharedInstance.saveChanges()
                
                self.dismiss(animated: true, completion: nil)
                self.delegate?.saveClicked()
            }
        }
    }
}

// MARK: - TextField Delegate
extension RelayParametersCell : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Gesture recognizer delegate
extension RelayParametersCell : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view { if touchView.isDescendant(of: backView) { dismissEditing(); return false } }
        return true
    }
}

extension RelayParametersCell : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.5, scaleOneY: 1.5, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)        
    }
}

extension RelayParametersCell : UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
}
