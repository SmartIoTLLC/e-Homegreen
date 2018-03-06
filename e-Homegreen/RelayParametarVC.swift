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
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func favoriteButton(_ sender: UIButton) {
        favButtonTapped()
    }
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
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func favButtonTapped() {
        let device = devices[indexPathRow]
        DatabaseDeviceController.shared.toggleFavoriteDevice(device: device, favoriteButton: favoriteButton)
    }
    
    func setupViews() {
        editDelay.delegate = self
        
        editDelay.inputAccessoryView = CustomToolBar()
        
        let deviceIn = devices[indexPathRow]
        let gateway  = deviceIn.gateway
        let location = gateway.location
        
        lblLocation.text = "\(gateway.name)"
        editDelay.text   = "\(deviceIn.delay)"
        lblName.text     = "\(deviceIn.name)"
        
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(deviceIn.parentZoneId), location: location), let name = zone.name {
            lblLevel.text = "\(name)"
        } else { lblLevel.text = "" }
        
        if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(Int(deviceIn.zoneId), location: location), let name = zone.name {
            lblZone.text = "\(name)"
        } else { lblZone.text = "" }
        
        lblCategory.text = "\(DatabaseHandler.sharedInstance.returnCategoryWithId(Int(deviceIn.categoryId), location: location))"
        deviceAddress.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne))):\(returnThreeCharactersForByte(Int(gateway.addressTwo))):\(returnThreeCharactersForByte(Int(deviceIn.address)))"
        deviceChannel.text = "\(deviceIn.channel)"
        switch deviceIn.isFavorite!.boolValue {
            case true: favoriteButton.setImage(#imageLiteral(resourceName: "favorite"), for: UIControlState())
            case false: favoriteButton.setImage(#imageLiteral(resourceName: "unfavorite"), for: UIControlState())
        }
        if let buttonImageView = favoriteButton.imageView { favoriteButton.bringSubview(toFront: buttonImageView) }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            editDelay.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if let numberOne = Int(editDelay.text!) {
            if numberOne <= 65534 {
                getDeviceAndSave(numberOne)
                self.delegate?.saveClicked()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func getDeviceAndSave (_ numberOne:Int) {
        if let moc = appDel.managedObjectContext {
            if let deviceObject = moc.object(with: devices[indexPathRow].objectID) as? Device {
                device        = deviceObject
                device!.delay = NSNumber(value: numberOne)
                CoreDataController.sharedInstance.saveChanges()
            }
        }
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    func returnCategoryWithId(_ id:Int) -> String {
        if id == 0 { return "All" }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", NSNumber(value: id as Int))
        fetchRequest.predicate = predicate
        
        do {
            if let moc = appDel.managedObjectContext {
                let fetResults = try moc.fetch(fetchRequest) as? [Category]
                if fetResults!.count != 0 { return "\(fetResults![0].name!)" } else { return "\(id)" }
            }
            
        } catch {}
        
        return ""
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue                
        
        moveTextfield(textfield: editDelay, keyboardFrame: keyboardFrame, backView: backView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
}

extension RelayParametarVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showRelayParametar(_ indexPathRow: Int, devices:[Device]) {
        let ad = RelayParametarVC()
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.present(ad, animated: true, completion: nil)
    }
}
