//
//  AddRemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class AddRemoteViewController: CommonXIBTransitionVC, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate {
    
    fileprivate func openPopover(_ sender: AnyObject, popoverList: [PopOverItem]) {
        if let popoverVC = UIStoryboard(name: "Popover", bundle: nil).instantiateViewController(withIdentifier: "codePopover") as? PopOverViewController {
            popoverVC.modalPresentationStyle = .popover
            popoverVC.preferredContentSize = CGSize(width: 300, height: 200)
            popoverVC.delegate = self
            popoverVC.popOverList = popoverList
            if let popC = popoverVC.popoverPresentationController {
                popC.delegate = self
                popC.permittedArrowDirections = .any
                popC.sourceView = sender as? UIView
                popC.sourceRect = sender.bounds
                popC.backgroundColor = .lightGray
                present(popoverVC, animated: true, completion: nil)
            }
        }
    }
    
    func nameAndId(_ name: String, id: String) {
        switch usedButton.tag {
            case 0 : break // Sme li da se menja lokacija sa ovog ekrana??
            case 1 :
                if let levelTemp = FilterController.shared.getZoneByObjectId(id) {
                    levelButton.setTitle(levelTemp.name, for: UIControlState())
                    selectedLevel = levelTemp
                } else {
                    levelButton.setTitle("All", for: UIControlState())
                    selectedLevel = nil
                }
            case 2 :
                if let zoneTemp = FilterController.shared.getZoneByObjectId(id) {
                    zoneButton.setTitle(zoneTemp.name, for: UIControlState())
                    selectedZone = zoneTemp
                } else {
                    zoneButton.setTitle("All", for: UIControlState())
                    selectedZone = nil
            }
            default: break
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var filterParameter: FilterItem!
    var location: Location!
    var selectedLevel: Zone?
    var selectedZone: Zone?
    
    var heightForScrollView: CGFloat!
    var widthForScrollView: CGFloat!
    
    var usedButton: CustomGradientButton!
    
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
    @IBAction func levelButton(_ sender: CustomGradientButton) {
        usedButton = sender
        var popoverList: [PopOverItem] = []
        let list: [Zone] = DatabaseZoneController.shared.getLevelsByLocation(location)
        for level in list { popoverList.append(PopOverItem(name: level.name!, id: level.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: "0"), at: 0)
        openPopover(sender, popoverList: popoverList)
    }
    
    
    @IBOutlet weak var zoneButton: CustomGradientButton!
    @IBAction func zoneButton(_ sender: CustomGradientButton) {
        usedButton = sender
        var popoverList: [PopOverItem] = []
        if let level = selectedLevel {
            let list: [Zone] = DatabaseZoneController.shared.getZoneByLevel(location, parentZone: level)
            for zone in list { popoverList.append(PopOverItem(name: zone.name!, id: zone.objectID.uriRepresentation().absoluteString)) }
        }
        popoverList.insert(PopOverItem(name: "All", id: "0"), at: 0)
        openPopover(sender, popoverList: popoverList)
    }
    
    
    @IBOutlet weak var colorButton: CustomGradientButton!
    @IBOutlet weak var shapeButton: CustomGradientButton!
    @IBOutlet weak var cancelButton: CustomGradientButton!
    @IBOutlet weak var saveButton: CustomGradientButton!
    

    @IBAction func cancelButton(_ sender: CustomGradientButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: CustomGradientButton) {
        saveRemoteController()
    }
    
    override func viewDidLoad() {

        updateViews()
        setTextFieldDelegates()
        addObservers()
    }

}

// MARK: - Setup views
extension AddRemoteViewController {
    func updateViews() {
        
        hideKeyboardWhenTappedAround()
        
        scrollView.delegate = self

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        dismissView.backgroundColor = .clear
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        
        prepareButtons()
        heightForScrollView            = backView.frame.height
        widthForScrollView             = backView.frame.width
        scrollView.contentSize.height  = heightForScrollView
        scrollView.layer.cornerRadius  = 10
        scrollView.layer.masksToBounds = true
        
        backView.backgroundColor     = Colors.AndroidGrayColor
        backView.layer.cornerRadius  = 10
        backView.layer.masksToBounds = true
        backView.layer.borderWidth   = 1
        backView.layer.borderColor   = Colors.MediumGray
        backView.frame.size.height   = scrollView.contentSize.height
        backView.layoutIfNeeded()
        
        nameTF.text = "Remote Controller"
        columnsTF.set(value: "3")
        rowsTF.set(value: "3")
        addressOneTF.set(value: "0")
        addressTwoTF.set(value: "0")
        addressThreeTF.set(value: "0")
        channelTF.set(value: "0")
        heightTF.set(value: "60")
        widthTF.set(value: "100")
        topTF.set(value: "5")
        bottomTF.set(value: "5")
        
        locationButton.tag = 0
        levelButton.tag    = 1
        zoneButton.tag     = 2
        
        colorButton.addTarget(self, action: #selector(chooseColor), for: .touchUpInside)
        shapeButton.addTarget(self, action: #selector(chooseShape), for: .touchUpInside)
    }
    
    func prepareButtons() {
        setButton(button: locationButton, title: filterParameter.location)
        setButton(button: levelButton, title: filterParameter.levelName)
        setButton(button: zoneButton, title: filterParameter.zoneName)
        setButton(button: colorButton, title: ButtonColor.gray)
        setButton(button: shapeButton, title: ButtonShape.rectangle)
        setButton(button: cancelButton, title: "CANCEL")
        setButton(button: saveButton, title: "SAVE")
    }
    
    func setButton(button: CustomGradientButton, title: String) {
        button.titleLabel?.font = .tahoma(size: 15)
        button.setTitle(title, for: UIControlState())
        button.backgroundColor  = .clear
    }
    
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    func setTextFieldDelegates() {
        nameTF.delegate         = self
        columnsTF.delegate      = self
        rowsTF.delegate         = self
        addressOneTF.delegate   = self
        addressTwoTF.delegate   = self
        addressThreeTF.delegate = self
        channelTF.delegate      = self
        heightTF.delegate       = self
        widthTF.delegate        = self
        topTF.delegate          = self
        bottomTF.delegate       = self
    }
    
    @objc fileprivate func chooseColor() {
        showChooseButtonColorVC(color: ButtonColor.gray)
    }
    
    @objc fileprivate func colorRecieved(_ notification: Notification) {
        if let color = notification.object as? String {
            colorButton.setTitle(color, for: UIControlState())
        }
    }
    
    @objc fileprivate func chooseShape() {
        showChooseButtonShape(masterShape: ButtonShape.rectangle)
    }
    
    @objc fileprivate func shapeRecieved(_ notification: Notification) {
        if let shape = notification.object as? String {
            shapeButton.setTitle(shape, for: UIControlState())
        }
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(shapeRecieved(_:)), name: .ButtonShapeChosen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorRecieved(_:)), name: .ButtonColorChosen, object: nil)
    }
    
    @objc fileprivate func rotated() {
        
        if UIDevice.current.orientation == .portrait {
            backView.frame.size.height  = heightForScrollView
            backView.frame.size.width   = widthForScrollView
        } else {
            backView.frame.size.height  = widthForScrollView
            backView.frame.size.width   = heightForScrollView
        }
        backView.center.x           = scrollView.center.x
        backView.frame.origin.y     = scrollView.frame.origin.y
        backView.layoutIfNeeded()
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: nameTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: columnsTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: rowsTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: addressOneTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: addressTwoTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: addressThreeTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: channelTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: heightTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: widthTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: topTF, keyboardFrame: keyboardFrame, backView: backView)
        moveTextfield(textfield: bottomTF, keyboardFrame: keyboardFrame, backView: backView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}



// MARK: - Logic
extension AddRemoteViewController {
    // TODO: Create Remote from JSON
    // TODO: Create JSON from Remote
 
    fileprivate func getCG(of value: String) -> CGFloat {
        return CGFloat(Int(value)!)
    }
    
    fileprivate func saveRemoteController() {
        guard let name         = nameTF.text, name.count != 0 else { view.makeToast(message: "Must name the remote controller."); return }
        guard let columns      = columnsTF.text, columns.count != 0, columns != "0" else { view.makeToast(message: "Number of columns can't be 0."); return }
        guard let rows         = rowsTF.text,  rows.count != 0, rows != "0" else { view.makeToast(message: "Number of columns can't be 0"); return }
        guard let addressOne   = addressOneTF.text, addressOne.count != 0 else { view.makeToast(message: "Invalid address."); return }
        guard let addressTwo   = addressTwoTF.text, addressTwo.count != 0 else { view.makeToast(message: "Invalid address."); return }
        guard let addressThree = addressThreeTF.text, addressThree.count != 0 else { view.makeToast(message: "Invalid address."); return }
        guard let channel      = channelTF.text, channel.count != 0 else { self.view.makeToast(message: "Invalid channel."); return }
        guard let height       = heightTF.text, height.count != 0, Int(height)! > 9 else { view.makeToast(message: "Invalid height."); return }
        guard let width        = widthTF.text, width.count != 0, Int(width)! > 9 else { view.makeToast(message: "Invalid width."); return }
        
        var top    : Int!
        var bottom : Int!
        if let topString    = topTF.text, let topInt = Int(topString) { top = topInt } else { top = 0 }
        if let bottomString = bottomTF.text, let bottomInt = Int(bottomString) { bottom = bottomInt } else { bottom = 0 }
        
        let color = colorButton.titleLabel?.text!
        let shape = shapeButton.titleLabel?.text!
        
        if shape == ButtonShape.circle {
            guard Int(width) == Int(height) else { view.makeToast(message: "Circular buttons must have same width and height"); return }
        }
        
        if let moc = managedContext {
            let remoteInfo = RemoteInformation(
                addressOne   : Int(addressOne)!,
                addressTwo   : Int(addressTwo)!,
                addressThree : Int(addressThree)!,
                buttonColor  : color!,
                buttonShape  : shape!,
                buttonWidth  : Int(width)!,
                buttonHeight : Int(height)!,
                channel      : Int(channel)!,
                columns      : Int(columns)!,
                marginBottom : Int(bottom),
                marginTop    : Int(top),
                name         : name,
                rows         : Int(rows)!,
                location     : location
            )
            let remote = Remote(context: moc, remoteInformation: remoteInfo)
            if selectedLevel != nil { remote.parentZoneId = selectedLevel?.id } else { remote.parentZoneId = 255 }
            if selectedZone != nil { remote.zoneId = selectedZone?.id } else { remote.zoneId = 255 }
            
            DatabaseRemoteController.sharedInstance.saveRemote(remote: remote, to: location)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
            dismissVC()
        }

    }
}

// MARK: - TextField Delegate
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
    func showAddRemoteVC(filter: FilterItem, location: Location) {
        let vc = AddRemoteViewController()
        vc.filterParameter = filter
        vc.location        = location
        self.present(vc, animated: true, completion: nil)
    }
}

extension AddRemoteViewController: UIScrollViewDelegate {
    
}

extension UITextField {
    fileprivate func set(value: String) {
        self.text         = value
        self.keyboardType = .numberPad
    }
}
