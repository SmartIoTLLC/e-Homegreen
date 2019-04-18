//
//  AddRemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

private struct LocalConstants {
    static let scrollViewContentSize: CGSize = CGSize(width: GlobalConstants.screenSize.width - 32, height: 627)
}

class AddRemoteViewController: CommonXIBTransitionVC {
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var filterParameter: FilterItem!
    var location: Location!
    var selectedLevel: Zone?
    var selectedZone: Zone?
    
    var heightForScrollView: CGFloat!
    var widthForScrollView: CGFloat!
    
    var usedButton: CustomGradientButton!
    
    var existingRemote: Remote?
    var isNew: Bool = true
    
    @IBOutlet weak var scrollView: UIScrollView!
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
        openLevelPopover(sender: sender)
    }
    @IBOutlet weak var zoneButton: CustomGradientButton!
    @IBAction func zoneButton(_ sender: CustomGradientButton) {
        openZonePopover(sender: sender)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareTextfields()
    }
    
    override func viewDidLoad() {
        updateViews()
        setTextFieldDelegates()
        addObservers()
    }

}

// MARK: - Navigation
extension AddRemoteViewController {
    fileprivate func openZonePopover(sender: CustomGradientButton) {
        usedButton = sender
        var popoverList: [PopOverItem] = []
        if let level = selectedLevel {
            let list: [Zone] = DatabaseZoneController.shared.getZoneByLevel(location, parentZone: level)
            for zone in list { popoverList.append(PopOverItem(name: zone.name!, id: zone.objectID.uriRepresentation().absoluteString)) }
        }
        popoverList.insert(PopOverItem(name: "All", id: "0"), at: 0)
        openPopover(sender, popoverList: popoverList)
    }
    
    fileprivate func openLevelPopover(sender: CustomGradientButton) {
        usedButton = sender
        var popoverList: [PopOverItem] = []
        let list: [Zone] = DatabaseZoneController.shared.getLevelsByLocation(location)
        for level in list { popoverList.append(PopOverItem(name: level.name!, id: level.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: "0"), at: 0)
        openPopover(sender, popoverList: popoverList)
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

        scrollView.contentSize = LocalConstants.scrollViewContentSize
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
    
    fileprivate func prepareTextfields() {
        if isNew {
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
        } else {
            if let remote = existingRemote {
                nameTF.text = remote.name
                columnsTF.set(value: "\(remote.columns!)")
                rowsTF.set(value: "\(remote.rows!)")
                addressOneTF.set(value: "\(remote.addressOne!)")
                addressTwoTF.set(value: "\(remote.addressTwo!)")
                addressThreeTF.set(value: "\(remote.addressThree!)")
                channelTF.set(value: "\(remote.channel!)")
                heightTF.set(value: "\(remote.buttonHeight!)")
                widthTF.set(value: "\(remote.buttonWidth!)")
                topTF.set(value: "\(remote.marginTop!)")
                bottomTF.set(value: "\(remote.marginBottom!)")
            }
        }
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
        button.setTitle(title, for: UIControl.State())
        button.backgroundColor  = .clear
    }
    
    @objc func dismissVC() {
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
        showChooseButtonColorOrShapeVC(masterValue: ButtonColor.gray)
    }
    
    @objc fileprivate func colorRecieved(_ notification: Notification) {
        if let color = notification.object as? String {
            colorButton.setTitle(color, for: UIControl.State())
        }
    }
    
    @objc fileprivate func chooseShape() {
        showChooseButtonColorOrShapeVC(masterValue: ButtonShape.rectangle, isForColors: false)
    }
    
    @objc fileprivate func shapeRecieved(_ notification: Notification) {
        if let shape = notification.object as? String {
            shapeButton.setTitle(shape, for: UIControl.State())
        }
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shapeRecieved(_:)), name: .ButtonShapeChosen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorRecieved(_:)), name: .ButtonColorChosen, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
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
            
            if isNew {
                let remote = Remote(context: moc, remoteInformation: remoteInfo)
                remote.parentZoneId = (selectedLevel != nil) ? selectedLevel?.id : 255
                remote.zoneId       = (selectedZone != nil) ? selectedZone?.id : 255
                
                DatabaseRemoteController.sharedInstance.saveRemote(remote: remote, to: location)
            } else {
                if let remote = existingRemote {
                    DatabaseRemoteController.sharedInstance.updateRemote(remote: remote, remoteInfo: remoteInfo)
                }
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
            dismissVC()
        }

    }
}

// MARK: - Popover Presentation Controller Delegate
extension AddRemoteViewController: UIPopoverPresentationControllerDelegate, PopOverIndexDelegate {
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
                levelButton.setTitle(levelTemp.name, for: UIControl.State())
                selectedLevel = levelTemp
            } else {
                levelButton.setTitle("All", for: UIControl.State())
                selectedLevel = nil
            }
        case 2 :
            if let zoneTemp = FilterController.shared.getZoneByObjectId(id) {
                zoneButton.setTitle(zoneTemp.name, for: UIControl.State())
                selectedZone = zoneTemp
            } else {
                zoneButton.setTitle("All", for: UIControl.State())
                selectedZone = nil
            }
        default: break
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
    func showAddRemoteVC(filter: FilterItem, location: Location, remote: Remote? = nil) {
        let vc = AddRemoteViewController()
        if remote == nil { vc.isNew = true } else { vc.isNew = false }
        vc.existingRemote  = remote
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
