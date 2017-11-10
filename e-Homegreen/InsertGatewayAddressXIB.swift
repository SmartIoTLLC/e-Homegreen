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
    case zone=0, categories
}

protocol AddAddressDelegate{
    func addAddressFinished(_ address:Address)
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
        
        setupViews()
    }
    
    func setupViews() {
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        addressOne.delegate = self
        addressTwo.delegate = self
        addressThree.delegate = self
        
        addressOne.inputAccessoryView = CustomToolBar()
        addressTwo.inputAccessoryView = CustomToolBar()
        addressThree.inputAccessoryView = CustomToolBar()
        
        if whatToScan == ScanType.zone { titleLabel.text = "Scan zones from address" } else { titleLabel.text = "Scan categories from address" }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view!.isDescendant(of: backView) { dismissEditing(); return false }
        return true
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scan(_ sender: AnyObject) {
        guard let firstAddress = addressOne.text , firstAddress != "", let secondAddress = addressTwo.text , secondAddress != "", let thirdAddress = addressThree.text , thirdAddress != "" else { self.view.makeToast(message: "All fields must be filled"); return }
        
        guard let addressOne = Int(firstAddress), let addressTwo = Int(secondAddress), let addressThree = Int(thirdAddress) else { self.view.makeToast(message: "Insert number in field"); return }
        
        self.dismiss(animated: true) { 
            self.delegate?.addAddressFinished(Address(firstByte: addressOne, secondByte: addressTwo, thirdByte: addressThree))
        }
        
    }

}

extension InsertGatewayAddressXIB : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension UIViewController {
    func showAddAddress(_ whatToScan:ScanType) -> InsertGatewayAddressXIB {
        let addAddress = InsertGatewayAddressXIB(whatToScan: whatToScan)
        self.present(addAddress, animated: true, completion: nil)
        return addAddress
    }
}
