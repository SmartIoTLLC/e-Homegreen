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
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        setupViews()
    }
    
    func setupViews() {
        let deviceIn = devices[indexPathRow]
        let gateway  = deviceIn.gateway
        let location = gateway.location
        
        lblLocation.text = "\(devices[indexPathRow].gateway.name)"
        lblName.text = "\(devices[indexPathRow].name)"
        
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(deviceIn.parentZoneId), location: location), let name = zone.name {
            lblLevel.text = "\(name)"
        } else { lblLevel.text = "" }
        
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(deviceIn.zoneId), location: location), let name = zone.name {
            lblZone.text = "\(name)"
        } else { lblZone.text = "" }
        
        lblCategory.text = "\(DatabaseHandler.sharedInstance.returnCategoryWithId(Int(deviceIn.categoryId), location: location))"
        deviceAddress.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne))):\(returnThreeCharactersForByte(Int(gateway.addressTwo))):\(returnThreeCharactersForByte(Int(deviceIn.address)))"
        deviceChannel.text = "\(deviceIn.channel)"
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        self.delegate?.saveClicked()
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDeviceAndSave (_ numberOne:Int, numberTwo:Int, numberThree:Int) {
        if let moc = appDel.managedObjectContext {
            if let deviceObject = moc.object(with: devices[indexPathRow].objectID) as? Device {
                device            = deviceObject
                device!.delay     = NSNumber(value: numberOne)
                device!.runtime   = NSNumber(value: numberTwo)
                device!.skipState = NSNumber(value: numberThree)
                CoreDataController.sharedInstance.saveChanges()
            }
        }
    }
}


extension IntelligentSwitchParameter : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
}

extension UIViewController {
    func showIntelligentSwitchParameter(_ indexPathRow: Int, devices:[Device]) {
        let ad = IntelligentSwitchParameter()
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.present(ad, animated: true, completion: nil)
    }
}
