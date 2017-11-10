//
//  DimmerParametarVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 8/4/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DimmerParametarVC: CommonXIBTransitionVC {
    
    @IBOutlet weak var backView: UIView!

    var indexPathRow: Int = -1
    
    var devices:[Device] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var delegate: DevicePropertiesDelegate?
    var device:Device?
    
    @IBOutlet weak var editDelay: UITextField!
    @IBOutlet weak var editRunTime: UITextField!
    @IBOutlet weak var editSkipState: UITextField!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var deviceAddress: UILabel!
    @IBOutlet weak var deviceChannel: UILabel!
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    
    @IBOutlet weak var scroll: UIScrollView!
    
    init(){
        super.init(nibName: "DimmerParametarVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func setupViews() {
        editDelay.inputAccessoryView = CustomToolBar()
        editRunTime.inputAccessoryView = CustomToolBar()
        editSkipState.inputAccessoryView = CustomToolBar()
        
        editDelay.delegate = self
        editRunTime.delegate = self
        editSkipState.delegate = self
        editDelay.text = "\(devices[indexPathRow].delay)"
        editRunTime.text = "\(devices[indexPathRow].runtime)"
        editSkipState.text = "\(devices[indexPathRow].skipState)"
        
        lblLocation.text = "\(devices[indexPathRow].gateway.name)"
        lblName.text = "\(devices[indexPathRow].name)"
        
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(devices[indexPathRow].parentZoneId), location: devices[indexPathRow].gateway.location), let name = zone.name {
            lblLevel.text = "\(name)"
        } else { lblLevel.text = "" }
        
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(devices[indexPathRow].zoneId), location: devices[indexPathRow].gateway.location), let name = zone.name {
            lblZone.text = "\(name)"
        } else { lblZone.text = "" }
        
        lblCategory.text = "\(DatabaseHandler.sharedInstance.returnCategoryWithId(Int(devices[indexPathRow].categoryId), location: devices[indexPathRow].gateway.location))"
        deviceAddress.text = "\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].address)))"
        deviceChannel.text = "\(devices[indexPathRow].channel)"
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { dismissEditing(); return false }
        return true
    }

    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if let numberOne = Int(editDelay.text!), let numberTwo = Int(editRunTime.text!), let numberThree = Int(editSkipState.text!) {
            if numberOne <= 65534 && numberTwo <= 65534 && numberThree <= 100 {
                getDeviceAndSave(numberOne, numberTwo:numberTwo, numberThree:numberThree)
                self.delegate?.saveClicked()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDeviceAndSave (_ numberOne:Int, numberTwo:Int, numberThree:Int) {
        if let deviceObject = appDel.managedObjectContext!.object(with: devices[indexPathRow].objectID) as? Device {
            device = deviceObject
            device!.delay = NSNumber(value: numberOne)
            device!.runtime = NSNumber(value: numberTwo)
            device!.skipState = NSNumber(value: numberThree)
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: editDelay, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editRunTime, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: editSkipState, keyboardFrame: keyboardFrame, backView: backView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
}

extension DimmerParametarVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showDimmerParametar(_ indexPathRow: Int, devices:[Device]) {
        let ad = DimmerParametarVC()
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.present(ad, animated: true, completion: nil)
    }
}
