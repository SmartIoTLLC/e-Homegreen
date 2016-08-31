//
//  RelayParametarVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 8/4/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class RelayParametarVC: CommonXIBTransitionVC {
    
    @IBOutlet weak var backView: UIView!

    var indexPathRow: Int = -1
    var devices:[Device] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    var device:Device?
    var delegate: DevicePropertiesDelegate?
    
    @IBOutlet weak var centerY: NSLayoutConstraint!
    
    @IBOutlet weak var editDelay: UITextField!
    @IBOutlet weak var overRideID: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var deviceAddress: UILabel!
    @IBOutlet weak var deviceChannel: UILabel!
    
    init(){
        super.init(nibName: "RelayParametarVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        editDelay.delegate = self
        
        editDelay.inputAccessoryView = CustomToolBar()
        
        lblLocation.text = "\(devices[indexPathRow].gateway.name)"
        editDelay.text = "\(devices[indexPathRow].delay)"
        lblName.text = "\(devices[indexPathRow].name)"
        
        if let zone = DatabaseHandler.returnZoneWithId(Int(devices[indexPathRow].parentZoneId), location: devices[indexPathRow].gateway.location), name = zone.name{
            lblLevel.text = "\(name)"
        }else{
            lblLevel.text = ""
        }
        if let zone = DatabaseHandler.returnZoneWithId(Int(devices[indexPathRow].zoneId), location: devices[indexPathRow].gateway.location), name = zone.name{
            lblZone.text = "\(name)"
        }else{
            lblZone.text = ""
        }
        lblCategory.text = "\(DatabaseHandler.returnCategoryWithId(Int(devices[indexPathRow].categoryId), location: devices[indexPathRow].gateway.location))"
        deviceAddress.text = "\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].address)))"
        deviceChannel.text = "\(devices[indexPathRow].channel)"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RelayParametarVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RelayParametarVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            editDelay.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if let numberOne = Int(editDelay.text!) {
            if numberOne <= 65534 {
                getDeviceAndSave(numberOne)
                self.delegate?.saveClicked()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func getDeviceAndSave (numberOne:Int) {
        if let deviceObject = appDel.managedObjectContext!.objectWithID(devices[indexPathRow].objectID) as? Device {
            device = deviceObject
            print(device)
            device!.delay = numberOne
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func returnCategoryWithId(id:Int) -> String {
        if id == 0{
            return "All"
        }
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        if editDelay.isFirstResponder(){
            if backView.frame.origin.y + editDelay.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height{
                
                self.centerY.constant = 0 - (5 + (self.backView.frame.origin.y + self.editDelay.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
                
            }
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.centerY.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
}

extension RelayParametarVC: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showRelayParametar(indexPathRow: Int, devices:[Device]) {
        let ad = RelayParametarVC()
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.presentViewController(ad, animated: true, completion: nil)
    }
}
