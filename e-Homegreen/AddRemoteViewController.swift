//
//  AddRemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class AddRemoteViewController: CommonXIBTransitionVC {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var newRemote: RemoteDummy!
    
    @IBOutlet weak var nameTF: EditTextField!
    @IBOutlet weak var columnsTF: EditTextField!
    @IBOutlet weak var rowsTF: EditTextField!
    @IBOutlet weak var addressOneTF: EditTextField!
    @IBOutlet weak var addressTwoTF: EditTextField!
    @IBOutlet weak var addressThreeTF: EditTextField!
    @IBOutlet weak var channelTF: EditTextField!
    @IBOutlet weak var heightTF: EditTextField!
    @IBOutlet weak var widthTF: EditTextField!
    @IBOutlet weak var topTF: EditTextField!
    @IBOutlet weak var bottomTF: EditTextField!
    
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var locationButton: CustomGradientButton!
    @IBOutlet weak var levelButton: CustomGradientButton!
    @IBOutlet weak var zoneButton: CustomGradientButton!
    @IBOutlet weak var colorButton: CustomGradientButton!
    @IBOutlet weak var shapeButton: CustomGradientButton!
    @IBOutlet weak var cancelButton: CustomGradientButton!
    @IBOutlet weak var saveButton: CustomGradientButton!
    

    @IBAction func cancelButton(_ sender: CustomGradientButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: CustomGradientButton) {
        guard let name = nameTF.text, name.count != 0 else {
            self.view.makeToast(message: "Must name the remote controller.")
            return
        }
        guard let columns = columnsTF.text, columns.count != 0, columns != "0" else {
            self.view.makeToast(message: "Number of columns can't be 0.")
            return
        }
        guard let rows = rowsTF.text,  rows.count != 0, rows != "0" else {
            self.view.makeToast(message: "Number of columns can't be 0")
            return
        }
        guard let addressOne = addressOneTF.text, addressOne.count != 0 else {
            self.view.makeToast(message: "Invalid address.")
            return
        }
        guard let addressTwo = addressTwoTF.text, addressTwo.count != 0 else {
            self.view.makeToast(message: "Invalid address.")
            return
        }
        guard let addressThree = addressThreeTF.text, addressThree.count != 0 else {
            self.view.makeToast(message: "Invalid address.")
            return
        }
        guard let channel = channelTF.text, channel.count != 0 else {
            self.view.makeToast(message: "Invalid channel.")
            return
        }
        guard let height = heightTF.text, height.count != 0, Int(height)! > 9 else {
            self.view.makeToast(message: "Invalid height.")
            return
        }
        guard let width = widthTF.text, width.count != 0, Int(width)! > 9 else {
            self.view.makeToast(message: "Invalid width.")
            return
        }
        
        var top: Int!
        var bottom: Int!
        if let topString = topTF.text, let topInt = Int(topString) {
            top = topInt
        } else { top = 0 }
        
        if let bottomString = bottomTF.text, let bottomInt = Int(bottomString) {
            bottom = bottomInt
        } else { bottom = 0 }
        
        var color: UIColor!
        var shape: String!
        if colorButton.titleLabel?.text == "Gray" {
            color = .gray
        } else { color = .red }
        
        if shapeButton.titleLabel?.text == "Rectangle" {
            shape = "Rectangle"
        } else { shape = "Circle" }
        
        if shape == "Circle" {
            if Int(width) != Int(height) {
                self.view.makeToast(message: "Circle must have same width and height")
                return
            }
        }
        
        newRemote = RemoteDummy(buggerOff: "Buggerica")
        newRemote.name = "Dummy remote"
        newRemote.columns = Int(columns)
        newRemote.rows = Int(rows)
        newRemote.address = addressOne + addressTwo + addressThree
        newRemote.channel = channel
        newRemote.buttonSize = CGSize(width: CGFloat(Int(width)!), height: CGFloat(Int(height)!))
        newRemote.buttonShape = shape
        newRemote.buttonMargins = UIEdgeInsets(top: CGFloat(top), left: 16, bottom: CGFloat(bottom), right: 16)
        newRemote.buttonColor = color
        // ako je circle -> height i width se moraju poklapati
        
        /* ograniciti ako je broj kolumni veci od availableCollectionWidth / columns
         -32pt
        */
        
    }
    
    override func viewDidLoad() {
        scrollView.contentSize = backView.frame.size
        scrollView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        updateViews()
        setTextFieldDelegates()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func rotated() {
        view.layoutIfNeeded()
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: nameTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: columnsTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: rowsTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: addressOneTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: addressTwoTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: addressThreeTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: channelTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: heightTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: widthTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: topTF, keyboardFrame: keyboardFrame)
        moveTextfield(textfield: bottomTF, keyboardFrame: keyboardFrame)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: { 
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: { 
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveTextfield(textfield: EditTextField, keyboardFrame: CGRect) {
        if textfield.isFirstResponder {
            if backView.frame.origin.y + textfield.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height {
                self.view.frame.origin.y = -(5 + (self.backView.frame.origin.y + textfield.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
            }
        }
    }
    
    func updateViews() {
        view.backgroundColor = .clear
        
        backView.backgroundColor = Colors.AndroidGrayColor
        backView.layer.cornerRadius = 10
        backView.layer.masksToBounds = true
        backView.layer.borderWidth = 1
        backView.layer.borderColor = Colors.MediumGray
        
        dismissView.backgroundColor = .clear
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        
        prepareButtons()
    }
    
    func prepareButtons() {
        setButton(button: locationButton, title: "All")
        setButton(button: levelButton, title: "All")
        setButton(button: zoneButton, title: "All")
        setButton(button: colorButton, title: "Gray")
        setButton(button: shapeButton, title: "Rectangle")
        setButton(button: cancelButton, title: "CANCEL")
        setButton(button: saveButton, title: "SAVE")
    }
    
    func setButton(button: CustomGradientButton, title: String) {
        button.titleLabel?.font = UIFont(name: "Tahoma", size: 17)
        button.setTitle(title, for: UIControlState())
        button.backgroundColor = .clear
    }
    
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    func setTextFieldDelegates() {
        nameTF.delegate = self
        columnsTF.delegate = self
        rowsTF.delegate = self
        addressOneTF.delegate = self
        addressTwoTF.delegate = self
        addressThreeTF.delegate = self
        channelTF.delegate = self
        heightTF.delegate = self
        widthTF.delegate = self
        topTF.delegate = self
        bottomTF.delegate = self
    }
}

extension AddRemoteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == addressOneTF || textField == addressTwoTF || textField == addressThreeTF {
            let maxLength = 3
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showAddRemoteVC() {
        let vc = AddRemoteViewController()
        self.present(vc, animated: true, completion: nil)
    }
}
