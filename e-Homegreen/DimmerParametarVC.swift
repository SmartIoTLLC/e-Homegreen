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
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
        }else{
            lblLevel.text = ""
        }
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(devices[indexPathRow].zoneId), location: devices[indexPathRow].gateway.location), let name = zone.name {
            lblZone.text = "\(name)"
        }else{
            lblZone.text = ""
        }
        
        lblCategory.text = "\(DatabaseHandler.sharedInstance.returnCategoryWithId(Int(devices[indexPathRow].categoryId), location: devices[indexPathRow].gateway.location))"
        deviceAddress.text = "\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].address)))"
        deviceChannel.text = "\(devices[indexPathRow].channel)"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DimmerParametarVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DimmerParametarVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            self.view.endEditing(true)
            return false
        }
        return true
    }

    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if let numberOne = Int(editDelay.text!), let numberTwo = Int(editRunTime.text!), let numberThree = Int(editSkipState.text!) {
            if numberOne <= 65534 && numberTwo <= 65534 && numberThree <= 100 {
                getDeviceAndSave(numberOne, numberTwo:numberTwo, numberThree:numberThree)
                self.delegate?.saveClicked()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getDeviceAndSave (numberOne:Int, numberTwo:Int, numberThree:Int) {
        if let deviceObject = appDel.managedObjectContext!.objectWithID(devices[indexPathRow].objectID) as? Device {
            device = deviceObject
            print(device)
            device!.delay = numberOne
            device!.runtime = numberTwo
            device!.skipState = numberThree
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if editDelay.isFirstResponder(){
            if backView.frame.origin.y + editDelay.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.editDelay.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editRunTime.isFirstResponder(){
            if backView.frame.origin.y + editRunTime.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.editRunTime.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        if editSkipState.isFirstResponder(){
            if backView.frame.origin.y + editSkipState.frame.origin.y + 30 - self.scroll.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.editSkipState.frame.origin.y + 30 - self.scroll.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.centerY.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
}

extension DimmerParametarVC: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showDimmerParametar(indexPathRow: Int, devices:[Device]) {
        let ad = DimmerParametarVC()
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.presentViewController(ad, animated: true, completion: nil)
    }
}
