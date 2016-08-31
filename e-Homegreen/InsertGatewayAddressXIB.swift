//
//  InsertGatewayAddressXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/6/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

struct Address {
    var firstByte:Int
    var secondByte:Int
    var thirdByte:Int
}

enum ScanType:Int {
    case Zone=0, Categories
}

protocol AddAddressDelegate{
    func addAddressFinished(address:Address)
}

class InsertGatewayAddressXIB: CommonXIBTransitionVC {
    
    var delegate:AddAddressDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addressOne: EditTextField!
    @IBOutlet weak var addressTwo: EditTextField!
    @IBOutlet weak var addressThree: EditTextField!
    
    @IBOutlet weak var scan: CustomGradientButtonWhite!
    @IBOutlet weak var cancel: CustomGradientButtonWhite!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    var whatToScan:ScanType!
    
    init(whatToScan:ScanType){
        super.init(nibName: "InsertGatewayAddressXIB", bundle: nil)
        self.whatToScan = whatToScan

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.redColor())
        
        addressOne.delegate = self
        addressTwo.delegate = self
        addressThree.delegate = self
        
        addressOne.inputAccessoryView = CustomToolBar()
        addressTwo.inputAccessoryView = CustomToolBar()
        addressThree.inputAccessoryView = CustomToolBar()
        
        if whatToScan == ScanType.Zone{
            titleLabel.text = "Scan zones from address"
        }else{
            titleLabel.text = "Scan categories from address"
        }

    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            self.view.endEditing(true)
            return false
        }
        return true
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func scan(sender: AnyObject) {
        guard let firstAddress = addressOne.text where firstAddress != "", let secondAddress = addressTwo.text where secondAddress != "", let thirdAddress = addressThree.text where thirdAddress != "" else{
            self.view.makeToast(message: "All fields must be filled")
            return
        }
        guard let addressOne = Int(firstAddress), let addressTwo = Int(secondAddress), let addressThree = Int(thirdAddress) else{
            self.view.makeToast(message: "Insert number in field")
            return
        }
        self.dismissViewControllerAnimated(true) { 
            self.delegate?.addAddressFinished(Address(firstByte: addressOne, secondByte: addressTwo, thirdByte: addressThree))
        }
        
    }

}

extension InsertGatewayAddressXIB : UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension UIViewController {
    func showAddAddress(whatToScan:ScanType) -> InsertGatewayAddressXIB {
        let addAddress = InsertGatewayAddressXIB(whatToScan: whatToScan)
        self.presentViewController(addAddress, animated: true, completion: nil)
        return addAddress
    }
}
