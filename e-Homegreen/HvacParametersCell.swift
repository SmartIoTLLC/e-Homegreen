//
//  HvacParametersCell.swift
//  e-Homegreen
//
//  Created by Marko Stajic on 8/3/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

enum SwitchTag : Int {
    case humidity
    case temperature
    case cool
    case fan
    case heat
    case autoMode
    case low
    case high
    case med
    case autoSpeed
}

class HvacParametersCell: PopoverVC {
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var lblChannel:UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnControlType: CustomGradientButton!
    @IBOutlet weak var btnLevel: UIButton!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!    
    
    @IBOutlet weak var switchHumidity: UISwitch!
    @IBOutlet weak var switchTemperature: UISwitch!
    
    @IBOutlet weak var switchCool: UISwitch!
    @IBOutlet weak var switchFan: UISwitch!
    @IBOutlet weak var switchHeat: UISwitch!
    @IBOutlet weak var switchAutoMode: UISwitch!
    
    @IBOutlet weak var switchLow: UISwitch!
    @IBOutlet weak var switchHigh: UISwitch!
    @IBOutlet weak var switchMed: UISwitch!
    @IBOutlet weak var switchAutoSpeed: UISwitch!
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?

    var device:Device
    var appDel:AppDelegate!
    var editedDevice:EditedDevice?
    var isPresenting: Bool = true
    var delegate: DevicePropertiesDelegate?
    
    init(device: Device){
        self.device = device
        editedDevice = EditedDevice(levelId: Int(device.parentZoneId), zoneId: Int(device.zoneId), categoryId: Int(device.categoryId), controlType: device.controlType, digitalInputMode: Int(device.digitalInputMode!))
        super.init(nibName: "HvacParametersCell", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchHumidity.tag = SwitchTag.humidity.rawValue
        switchTemperature.tag = SwitchTag.temperature.rawValue
        switchCool.tag = SwitchTag.cool.rawValue
        switchFan.tag = SwitchTag.fan.rawValue
        switchHeat.tag = SwitchTag.heat.rawValue
        switchAutoMode.tag = SwitchTag.autoMode.rawValue
        switchLow.tag = SwitchTag.low.rawValue
        switchHigh.tag = SwitchTag.high.rawValue
        switchMed.tag = SwitchTag.med.rawValue
        switchAutoSpeed.tag = SwitchTag.autoSpeed.rawValue
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HvacParametersCell.handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.title = "Device Parameters"
        
        txtFieldName.text = device.name
        lblAddress.text = "\(returnThreeCharactersForByte(Int(device.gateway.addressOne))):\(returnThreeCharactersForByte(Int(device.gateway.addressTwo))):\(returnThreeCharactersForByte(Int(device.address)))"
        lblChannel.text = "\(device.channel)"
        
        level = DatabaseZoneController.shared.getZoneById(Int(device.parentZoneId), location: device.gateway.location)
        if let level = level, level.name != "Default" {
            btnLevel.setTitle(level.name, for: UIControlState())
        }else{
            btnLevel.setTitle("All", for: UIControlState())
        }
        
        zoneSelected = DatabaseZoneController.shared.getZoneById(Int(device.zoneId), location: device.gateway.location)
        if let zoneSelected = zoneSelected, zoneSelected.name != "Defalut" {
            btnZone.setTitle(zoneSelected.name, for: UIControlState())
        }else{
            btnZone.setTitle("All", for: UIControlState())
        }
        
        let category = DatabaseCategoryController.shared.getCategoryById(Int(device.categoryId), location: device.gateway.location)
        if category != nil{
            btnCategory.setTitle(category?.name, for: UIControlState())
        }else{
            btnCategory.setTitle("All", for: UIControlState())
        }
        
        btnControlType.setTitle("\(device.controlType == ControlType.Curtain ? ControlType.Relay : device.controlType)", for: UIControlState())
        
        txtFieldName.delegate = self
        
        if device.humidityVisible == true {
            switchHumidity.setOn(true, animated: false)
        }else{
            switchHumidity.setOn(false, animated: false)
        }
        
        if device.temperatureVisible == true {
            switchTemperature.setOn(true, animated: false)
        }else{
            switchTemperature.setOn(false, animated: false)
        }
        
        if device.coolModeVisible == true {
            switchCool.setOn(true, animated: false)
        }else{
            switchCool.setOn(false, animated: false)
        }
        
        if device.heatModeVisible == true {
            switchHeat.setOn(true, animated: false)
        }else{
            switchHeat.setOn(false, animated: false)
        }
        if device.fanModeVisible == true {
            switchFan.setOn(true, animated: false)
        }else{
            switchFan.setOn(false, animated: false)
        }
        if device.autoModeVisible == true {
            switchAutoMode.setOn(true, animated: false)
        }else{
            switchAutoMode.setOn(false, animated: false)
        }
        if device.lowSpeedVisible == true {
            switchLow.setOn(true, animated: false)
        }else{
            switchLow.setOn(false, animated: false)
        }
        if device.medSpeedVisible == true {
            switchMed.setOn(true, animated: false)
        }else{
            switchMed.setOn(false, animated: false)
        }
        if device.highSpeedVisible == true {
            switchHigh.setOn(true, animated: false)
        }else{
            switchHigh.setOn(false, animated: false)
        }
        if device.autoSpeedVisible == true {
            switchAutoSpeed.setOn(true, animated: false)
        }else{
            switchAutoSpeed.setOn(false, animated: false)
        }

        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnControlType.tag = 4
    }
    override func nameAndId(_ name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            if let level = level{
                editedDevice?.levelId = (level.id?.intValue)!
                btnZone.setTitle("All", for: UIControlState())
                zoneSelected = nil
            }else{
                editedDevice?.levelId = 255
                btnZone.setTitle("All", for: UIControlState())
                zoneSelected = nil
            }
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            if let zoneSelected = zoneSelected {
                editedDevice?.zoneId = (zoneSelected.id?.intValue)!
            }else{
                editedDevice?.zoneId = (zoneSelected?.id?.intValue)!
                editedDevice?.zoneId = 255
            }
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            if let category = category{
                editedDevice?.categoryId = (category.id?.intValue)!
            }else{
                editedDevice?.categoryId = 255
            }
            break
        case 4:
            editedDevice?.controlType = name
            btnControlType.setTitle(name, for: UIControlState())
            break
        default:
            break
        }
        
        button.setTitle(name, for: UIControlState())
    }

    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func changeControlType(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        popoverList.append(PopOverItem(name: ControlType.Climate, id: ""))
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnLevel (_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(device.gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnZone (_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(device.gateway.location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnCategory (_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(device.gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnSave(_ sender: AnyObject) {
        if txtFieldName.text != "" {
            device.name = txtFieldName.text!
            device.parentZoneId = NSNumber(value: editedDevice!.levelId as Int)
            device.zoneId = NSNumber(value: editedDevice!.zoneId as Int)
            device.categoryId = NSNumber(value: editedDevice!.categoryId as Int)
            device.controlType = editedDevice!.controlType
            device.digitalInputMode = NSNumber(value: editedDevice!.digitalInputMode as Int)
            device.humidityVisible = switchHumidity.isOn as NSNumber?
            device.temperatureVisible = switchTemperature.isOn as NSNumber?
            device.coolModeVisible = switchCool.isOn as NSNumber?
            device.fanModeVisible = switchFan.isOn as NSNumber?
            device.heatModeVisible = switchHeat.isOn as NSNumber?
            device.autoModeVisible = switchAutoMode.isOn as NSNumber?
            device.lowSpeedVisible = switchLow.isOn as NSNumber?
            device.highSpeedVisible = switchHigh.isOn as NSNumber?
            device.medSpeedVisible = switchMed.isOn as NSNumber?
            device.autoSpeedVisible = switchAutoSpeed.isOn as NSNumber?
            
            device.resetImages(appDel.managedObjectContext!)
            CoreDataController.shahredInstance.saveChanges()
            
            // Why was the next line commented out?
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
            
            
            self.delegate?.saveClicked()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleTap(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }

}

extension HvacParametersCell : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension HvacParametersCell : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendant(of: backView){
                self.view.endEditing(true)
                return false
            }
        }
        return true
    }
}

extension HvacParametersCell : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            containerView.addSubview(presentedControllerView)
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension HvacParametersCell : UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
}
