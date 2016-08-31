//
//  IntelligentSwitchParameter.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/25/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class IntelligentSwitchParameter: CommonXIBTransitionVC {
    
    @IBOutlet weak var backView: UIView!

    var indexPathRow: Int = -1
    
    var devices:[Device] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var delegate: DevicePropertiesDelegate?
    var device:Device?
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var deviceAddress: UILabel!
    @IBOutlet weak var deviceChannel: UILabel!
    
    
    init(){
        super.init(nibName: "IntelligentSwitchParameter", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        lblLocation.text = "\(devices[indexPathRow].gateway.name)"
        lblName.text = "\(devices[indexPathRow].name)"
        
        if let zone = DatabaseHandler.returnZoneWithId(Int(devices[indexPathRow].parentZoneId), location: devices[indexPathRow].gateway.location), let name = zone.name {
            lblLevel.text = "\(name)"
        }else{
            lblLevel.text = ""
        }
        if let zone = DatabaseHandler.returnZoneWithId(Int(devices[indexPathRow].zoneId), location: devices[indexPathRow].gateway.location), let name = zone.name {
            lblZone.text = "\(name)"
        }else{
            lblZone.text = ""
        }
        
        lblCategory.text = "\(DatabaseHandler.returnCategoryWithId(Int(devices[indexPathRow].categoryId), location: devices[indexPathRow].gateway.location))"
        deviceAddress.text = "\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].address)))"
        deviceChannel.text = "\(devices[indexPathRow].channel)"

    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        self.delegate?.saveClicked()
        self.dismissViewControllerAnimated(true, completion: nil)
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
}


extension IntelligentSwitchParameter : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
}

extension UIViewController {
    func showIntelligentSwitchParameter(indexPathRow: Int, devices:[Device]) {
        let ad = IntelligentSwitchParameter()
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.presentViewController(ad, animated: true, completion: nil)
    }
}