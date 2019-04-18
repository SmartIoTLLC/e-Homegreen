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
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnImages(_ sender: AnyObject, forEvent event: UIEvent) {
        showDeviceImagesPicker(sender: sender, event: event)
    }
    @IBAction func btnImages(_ sender: AnyObject) {
    }
    @IBAction func changeControlType(_ sender: UIButton) {
        changeControlType(via: sender)
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
        super.init(nibName: "ChangeDeviceParametarsVC", bundle: nil)
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
        if let object = notification.object as? [String: NSManagedObjectID] {
            if let id = object["deviceId"] {
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
        
        switch button.tag {
        case 1: // "All" selected
            if let levelTemp = FilterController.shared.getZoneByObjectId(id), let id = levelTemp.id {
                editedDevice?.levelId = (id.intValue)
                level = levelTemp
            } else {
                // Set default levelId
                editedDevice?.levelId = 255
                btnZone.setTitle("All", for: UIControl.State())
                level = nil
            }
            break
        case 2:
            if let zoneTemp = FilterController.shared.getZoneByObjectId(id), let id = zoneTemp.id {
                editedDevice?.zoneId = (id.intValue)
                zoneSelected = zoneTemp
            } else {
                // Set default zoneId
                editedDevice?.zoneId = 255
                zoneSelected = nil
            }
            break
        case 3:
            if let categoryTemp = FilterController.shared.getCategoryByObjectId(id), let id = categoryTemp.id {
                editedDevice?.categoryId = (id.intValue)
                category = categoryTemp
            } else {
                // Set default categoryId
                editedDevice?.categoryId = 255
                category = nil
            }
            break
        case 4:
            editedDevice?.controlType = name
            btnControlType.setTitle(name, for: UIControl.State())
            break
        default:
            break
        }
        
        button.setTitle(name, for: UIControl.State())
    }
}

// MARK: - Setup views
extension ChangeDeviceParametarsVC {
    func setupViews() {
        appDel = UIApplication.shared.delegate as! AppDelegate
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.title = "Device Parameters"
        
        txtFieldName.text = device.name
        lblAddress.text = "\(returnThreeCharactersForByte(Int(device.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device.address)))"
        lblChannel.text = "\(device.channel)"
        
        level = DatabaseZoneController.shared.getZoneById(Int(device.parentZoneId), location: device.gateway.location)
        if let level = level, level.name != "Default" { btnLevel.setTitle(level.name, for: UIControl.State()) } else { btnLevel.setTitle("All", for: UIControl.State()) }
        
        zoneSelected = DatabaseZoneController.shared.getZoneById(Int(device.zoneId), location: device.gateway.location)
        if zoneSelected != nil { btnZone.setTitle(zoneSelected!.name, for: UIControl.State()) } else { btnZone.setTitle("All", for: UIControl.State()) }
        
        let category = DatabaseCategoryController.shared.getCategoryById(Int(device.categoryId), location: device.gateway.location)
        if category != nil { btnCategory.setTitle(category?.name, for: UIControl.State()) } else { btnCategory.setTitle("All", for: UIControl.State()) }
        
        btnControlType.setTitle("\(device.controlType == ControlType.Curtain ? ControlType.Relay : device.controlType)", for: UIControl.State())
        
        txtFieldName.delegate = self
        
        //TODO: Add for gateway when it is defined
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnControlType.tag = 4
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleResetImages(_:)), name: .deviceShouldResetImages, object: nil)
    }
    
    @objc func handleTap(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Logic
extension ChangeDeviceParametarsVC {
    fileprivate func changeControlType(via sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if device.controlType == ControlType.Sensor{
            popoverList.append(PopOverItem(name: ControlType.Sensor, id: ""))
        }else if device.controlType == ControlType.Dimmer{
            popoverList.append(PopOverItem(name: ControlType.Dimmer, id: "")) // TODO: Dodati Id za Dimmer
            popoverList.append(PopOverItem(name: ControlType.Relay, id: "")) // TODO: Dodati Id za Relay
        }else if device.controlType == ControlType.SaltoAccess{
            popoverList.append(PopOverItem(name: ControlType.SaltoAccess, id: ""))
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
        popoverList.insert(PopOverItem(name: "All", id: "0"), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func zoneTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(device.gateway.location, parentZone: level)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        popoverList.insert(PopOverItem(name: "All", id: "0"), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func categoryTapped(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(device.gateway.location)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: "0"), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func save() {
        if txtFieldName.text != "" {
            if let moc = appDel.managedObjectContext {
                device.name             = txtFieldName.text!
                device.parentZoneId     = NSNumber(value: editedDevice!.levelId as Int)
                device.zoneId           = NSNumber(value: editedDevice!.zoneId as Int)
                device.categoryId       = NSNumber(value: editedDevice!.categoryId as Int)
                device.controlType      = editedDevice!.controlType
                device.digitalInputMode = NSNumber(value: editedDevice!.digitalInputMode as Int)
                CoreDataController.sharedInstance.saveChanges()
                if deviceShouldResetImages {
                    imagesToReset.forEach { (image) in
                        device.resetSingleImage(image: image)
                        imagesToReset = []
                    }
                    device.resetImages(moc)
                }
                deviceShouldResetImages = false
                
                self.delegate?.saveClicked()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func showDeviceImagesPicker(sender: AnyObject, event: UIEvent) {
        if let sender = sender as? UIView {
            let touches = event.touches(for: sender)
            if let touch = touches?.first {
                let touchPoint = touch.location(in: view)
                showDeviceImagesPicker(device, point: touchPoint)
            }
        }
    }
}

// MARK: - TextField Delegate
extension ChangeDeviceParametarsVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Gesture recognizer
extension ChangeDeviceParametarsVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view { if touchView.isDescendant(of: backView) { dismissEditing(); return false } }
        return true
    }
}

extension ChangeDeviceParametarsVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.5, scaleOneY: 1.5, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)        
    }
}

extension ChangeDeviceParametarsVC : UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
}

extension UIViewController {
    func showChangeDeviceParametar(device:Device, scanDevicesViewController: DevicePropertiesDelegate) {
        let chn = Int(device.channel)
        // If any kind of relay
        if device.controlType == ControlType.Relay || device.controlType == ControlType.Curtain{
            let cdp = RelayParametersCell(device: device)
            cdp.delegate = scanDevicesViewController
            self.present(cdp, animated: true, completion: nil)
        }
        // If any kind of Digital input. It can be:
        // DigitalInput control type
        // Digital input in Intelligent switch
        // Digital input in sensor
        else if (device.controlType == ControlType.DigitalInput) ||
            (device.controlType == ControlType.IntelligentSwitch && (chn == DeviceInfo.IntelligentSwitchInputInterface.digitalInput1.rawValue || chn == DeviceInfo.IntelligentSwitchInputInterface.digitalInput2.rawValue)) ||
            (device.controlType == ControlType.Sensor && (chn == DeviceInfo.Multisensor10in1.digitalInput1.rawValue || chn == DeviceInfo.Multisensor10in1.digitalInput2.rawValue || chn == DeviceInfo.Multisensor10in1.digitalInput3.rawValue || chn == DeviceInfo.Multisensor10in1.digitalInput4.rawValue)){
            let cdp = DigitalInputPopup(device: device)
            cdp.delegate = scanDevicesViewController
            self.present(cdp, animated: true, completion: nil)
        }
        // If any kind of clima
        else if device.controlType == ControlType.Climate {
            let cdp = HvacParametersCell(device: device)
            cdp.delegate = scanDevicesViewController
            self.present(cdp, animated: true, completion: nil)
        }
        // If anything else
        else{
            let cdp = ChangeDeviceParametarsVC(device: device)
            cdp.delegate = scanDevicesViewController
            self.present(cdp, animated: true, completion: nil)
        }
    }
}
