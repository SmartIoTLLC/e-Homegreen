//
//  ButtonSettingsVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/16/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class ButtonSettingsVC: CommonXIBTransitionVC, UITextFieldDelegate {
    
    var button: RemoteButton!
    var imageString: String?
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var backgroundView: CustomGradientBackground!
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nameTF: EditTextField!
    @IBOutlet weak var addressOneTF: EditTextField!
    
    @IBOutlet weak var addressTwoTF: EditTextField!
    @IBOutlet weak var addressThreeTF: EditTextField!
    @IBOutlet weak var channelTF: EditTextField!
    
    @IBOutlet weak var buttonType: CustomGradientButton!
    @IBOutlet weak var buttonTypeIDTF: EditTextField!
    
    @IBOutlet weak var heightTF: EditTextField!
    @IBOutlet weak var widthTF: EditTextField!

    @IBOutlet weak var buttonInternalType: CustomGradientButton!
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var scaleXTF: EditTextField!
    @IBOutlet weak var scaleYTF: EditTextField!
    
    @IBOutlet weak var topMarginTF: EditTextField!
    
    @IBOutlet weak var visibilityButton: CustomGradientButton!
    @IBOutlet weak var buttonColor: CustomGradientButton!
    @IBOutlet weak var buttonShape: CustomGradientButton!
    
    @IBOutlet weak var cancelButton: CustomGradientButton!
    @IBOutlet weak var saveButton: CustomGradientButton!
    
    override func viewDidLoad() {
        
        setupTextfieldDelegates()
        setupViews()
        updateViews()
        
        addObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setButtonImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = backgroundViewHeight.constant
    }
    
    // MARK: - Button look
    func receivedButtonColor(_ notification: Notification) {
        if let color = notification.object as? String {
            buttonColor.setTitle(color, for: UIControlState())
        }
    }
    
    func receivedButtonShape(_ notification: Notification) {
        if let shape = notification.object as? String {
            buttonShape.setTitle(shape, for: UIControlState())
        }
    }
    
    @objc fileprivate func setButtonImage() {
        if let buttonImage = button.image {
            imageButton.setBackgroundImage(UIImage(data: buttonImage as Data), for: UIControlState())            
        } else {
            imageButton.setBackgroundImage(#imageLiteral(resourceName: "galleryIcon").withRenderingMode(.alwaysTemplate), for: UIControlState())
            (imageButton.subviews[0] as! UIImageView).tintColor = .white            
        }
        (imageButton.subviews[0] as! UIImageView).contentMode = .scaleAspectFit
        
        UIView.animate(withDuration: 0.5, animations: {
            self.imageButton.alpha = 1
        })
    }
    
    // MARK: - Button Type
    @objc fileprivate func setButton() {
        switch buttonType.titleLabel!.text! {
            case ButtonType.irButton    : setSceneMode()
            case ButtonType.sceneButton : setHEXmode()
            case ButtonType.hexButton   : setIRmode()
            default: break
        }
    }
    
    fileprivate func setIRmode() {
        buttonType.setTitle(ButtonType.irButton, for: UIControlState())
        
        addressOneTF.setEnabled()
        addressTwoTF.setEnabled()
        addressThreeTF.setEnabled()
        channelTF.setEnabled()
        
        if button.irId != nil { buttonTypeIDTF.text = "\(button.irId!)" }
        buttonTypeIDTF.placeholder = "Enter IR ID"
    }
    
    fileprivate func setSceneMode() {
        buttonType.setTitle(ButtonType.sceneButton, for: UIControlState())
        
        addressOneTF.setEnabled()
        addressTwoTF.setEnabled()
        addressThreeTF.setEnabled()
        channelTF.setDisabled()
        if button.sceneId != nil { buttonTypeIDTF.text = String(describing: button.sceneId!) }
        buttonTypeIDTF.placeholder = "Enter scene ID"
    }
    
    fileprivate func setHEXmode() {
        buttonType.setTitle(ButtonType.hexButton, for: UIControlState())
        
        addressOneTF.setDisabled()
        addressTwoTF.setDisabled()
        addressThreeTF.setDisabled()
        channelTF.setDisabled()
        
        if button.hexString != nil { buttonTypeIDTF.text = button.hexString! }
        buttonTypeIDTF.placeholder = "Enter hex code"
    }
    
    // MARK: - Button Internal Type
    @objc fileprivate func setButtonInternalType() {
        switch buttonInternalType.titleLabel!.text! {
            case ButtonInternalType.regular     : setImageInternalType()
            case ButtonInternalType.image       : setImageButtonInternalType()
            case ButtonInternalType.imageButton : setRegularInteralType()
            default: break
        }
    }
    
    fileprivate func setRegularInteralType() {
        buttonInternalType.setTitle(ButtonInternalType.regular, for: UIControlState())
        imageButton.isEnabled = false
        scaleXTF.setDisabled()
        scaleYTF.setDisabled()
    }
    
    fileprivate func setImageInternalType() {
        buttonInternalType.setTitle(ButtonInternalType.image, for: UIControlState())
        imageButton.isEnabled = true
        scaleXTF.setEnabled()
        scaleYTF.setEnabled()
    }
    
    fileprivate func setImageButtonInternalType() {
        buttonInternalType.setTitle(ButtonInternalType.imageButton, for: UIControlState())
        imageButton.isEnabled = true
        scaleXTF.setEnabled()
        scaleYTF.setEnabled()
    }
    
    // MARK: - Button visibility
    @objc fileprivate func setButtonVisibility() {
        switch visibilityButton.titleLabel!.text! {
            case ButtonState.visible    : visibilityButton.setTitle(ButtonState.invisible, for: UIControlState())
            case ButtonState.invisible  : visibilityButton.setTitle(ButtonState.disable, for: UIControlState())
            case ButtonState.disable    : visibilityButton.setTitle(ButtonState.visible, for: UIControlState())
            default: break
        }
    }
    
    // MARK: - Save
    @objc fileprivate func saveChanges() {
        
        if let name         = nameTF.text, name != "" { button.name = name }
        if let addressOne   = addressOneTF.text, addressOne != "" { button.addressOne = getNS(of: addressOne) }
        if let addressTwo   = addressTwoTF.text, addressTwo != "" { button.addressTwo = getNS(of: addressTwo) }
        if let addressThree = addressThreeTF.text, addressThree != "" { button.addressThree = getNS(of: addressThree) }
        if let channel      = channelTF.text, channel != "" { button.channel = getNS(of: channel) }
        
        if let info = buttonTypeIDTF.text, info != "" {
            switch button.buttonType! {
                case ButtonType.hexButton   : button.hexString = info
                case ButtonType.irButton    : button.irId = getNS(of: info)
                case ButtonType.sceneButton : button.sceneId = getNS(of: info)
                default: break
            }
        }
        
        if let height      = heightTF.text, height != "" { button.buttonHeight = getNS(of: height) }
        if let width       = widthTF.text, width != "" { button.buttonWidth = getNS(of: width) }
        if let scaleX      = scaleXTF.text, scaleX != "" { button.imageScaleX = NSNumber(value: Double(scaleX)!) }
        if let scaleY      = scaleYTF.text, scaleY != "" { button.imageScaleY = NSNumber(value: Double(scaleY)!) }
        if let topMargin   = topMarginTF.text, topMargin != "" { button.marginTop = getNS(of: topMargin) }
        
        button.buttonState        = visibilityButton.titleLabel!.text!
        button.buttonColor        = buttonColor.titleLabel!.text!
        button.buttonShape        = buttonShape.titleLabel!.text!
        button.buttonType         = buttonType.titleLabel!.text!
        button.buttonInternalType = buttonInternalType.titleLabel!.text!

        if button.buttonType == ButtonType.irButton {
            guard button.irId != nil else { rollback(alert: "IR button needs an IR ID."); return }
        }
        DatabaseRemoteButtonController.sharedInstance.editButton(button)
        NotificationCenter.default.post(name: .ButtonUpdated, object: nil)
        dismissModal()
    }

}


// MARK: - Helper functions
extension UIViewController {
    @objc fileprivate func dismissButtonSettings() {
        DatabaseRemoteButtonController.sharedInstance.rollback()
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func getNS(of string: String) -> NSNumber {
        return NSNumber(value: Int(string)!)
    }
    
    fileprivate func getCG(of string: String) -> CGFloat {
        return CGFloat(Int(string)!)
    }
    
    fileprivate func rollback(alert: String) {
        view.makeToast(message: alert)
        DatabaseRemoteButtonController.sharedInstance.rollback()
    }
}

extension UITextField {
    fileprivate func setDisabled() {
        isEnabled       = false
        backgroundColor = .gray
    }
    
    fileprivate func setEnabled() {
        isEnabled       = true
        backgroundColor = .white
    }
}

// MARK: - View setup
extension ButtonSettingsVC {
    
    fileprivate func setupViews() {
        buttonType.addTarget(self, action: #selector(setButton), for: .touchUpInside)
        buttonInternalType.addTarget(self, action: #selector(setButtonInternalType), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(dismissButtonSettings), for: .touchUpInside)
        buttonColor.addTarget(self, action: #selector(chooseButtonColor), for: .touchUpInside)
        buttonShape.addTarget(self, action: #selector(chooseButtonShape), for: .touchUpInside)
        visibilityButton.addTarget(self, action: #selector(setButtonVisibility), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(chooseButtonImage), for: .touchUpInside)
    }
    
    @objc fileprivate func chooseButtonImage() {
        showButtonImagePickerVC(button: button)
    }
    
    @objc fileprivate func chooseButtonColor() {
        let color = button.remote!.buttonColor!
        showChooseButtonColorOrShapeVC(masterValue: color, isRemote: false)
    }
    
    @objc fileprivate func chooseButtonShape() {
        let shape = button.remote!.buttonShape!
        showChooseButtonColorOrShapeVC(masterValue: shape, isRemote: false, isForColors: false)
    }
    
    fileprivate func updateViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        backgroundView.layer.cornerRadius  = 15
        backgroundView.layer.borderColor   = Colors.AndroidGrayColor.cgColor
        backgroundView.layer.borderWidth   = 2
        backgroundView.layer.masksToBounds = true
        
        hideKeyboardWhenTappedAround()
        
        imageButton.alpha = 0
        
        nameTF.placeholder         = button.name!
        addressOneTF.placeholder   = String(describing: button.addressOne!)
        addressTwoTF.placeholder   = String(describing: button.addressTwo!)
        addressThreeTF.placeholder = String(describing: button.addressThree!)
        channelTF.placeholder      = String(describing: button.channel!)
        heightTF.placeholder       = String(describing: button.buttonHeight!)
        widthTF.placeholder        = String(describing: button.buttonWidth!)
        topMarginTF.placeholder    = String(describing: button.marginTop!)
        scaleXTF.placeholder       = String(describing: button.imageScaleX! as! Double)
        scaleYTF.placeholder       = String(describing: button.imageScaleY! as! Double)
        
        nameTF.text         = button.name!
        addressOneTF.text   = String(describing: button.addressOne!)
        addressTwoTF.text   = String(describing: button.addressTwo!)
        addressThreeTF.text = String(describing: button.addressThree!)
        channelTF.text      = String(describing: button.channel!)
        heightTF.text       = String(describing: button.buttonHeight!)
        widthTF.text        = String(describing: button.buttonWidth!)
        topMarginTF.text    = String(describing: button.marginTop!)
        scaleXTF.text       = String(describing: button.imageScaleX! as! Double)
        scaleYTF.text       = String(describing: button.imageScaleY! as! Double)
        
        addressOneTF.keyboardType   = .numberPad
        addressTwoTF.keyboardType   = .numberPad
        addressThreeTF.keyboardType = .numberPad
        channelTF.keyboardType      = .numberPad
        heightTF.keyboardType       = .numberPad
        widthTF.keyboardType        = .numberPad
        scaleYTF.keyboardType       = .decimalPad
        scaleXTF.keyboardType       = .decimalPad
        topMarginTF.keyboardType    = .numberPad

        switch button.buttonType! {
            case ButtonType.irButton    : setIRmode()
            case ButtonType.sceneButton : setSceneMode()
            case ButtonType.hexButton   : setHEXmode()
            default: break
        }
        
        switch button.buttonInternalType! {
            case ButtonInternalType.regular     : setRegularInteralType() ; imageButton.isEnabled = false
            case ButtonInternalType.image       : setImageInternalType(); imageButton.isEnabled = true
            case ButtonInternalType.imageButton : setImageButtonInternalType(); imageButton.isEnabled = true
            default: break
        }
        
        switch button.buttonState! {
            case ButtonState.visible    : visibilityButton.setTitle(ButtonState.visible, for: UIControlState())
            case ButtonState.invisible  : visibilityButton.setTitle(ButtonState.invisible, for: UIControlState())
            case ButtonState.disable    : visibilityButton.setTitle(ButtonState.disable, for: UIControlState())
            default: break
        }
        
        switch button.buttonShape! {
            case ButtonShape.circle         : buttonShape.setTitle(ButtonShape.circle, for: UIControlState())
            case ButtonShape.rectangle    : buttonShape.setTitle(ButtonShape.rectangle, for: UIControlState())
            default: break
        }
        
        buttonColor.setTitle(button.buttonColor!, for: UIControlState())
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedButtonColor(_:)), name: .ButtonColorChosen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name:.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedButtonShape(_:)), name: .ButtonShapeChosen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setButtonImage), name: .ButtonImageChosen, object: nil)
    }
    
    fileprivate func setupTextfieldDelegates() {
        nameTF.delegate         = self
        addressOneTF.delegate   = self
        addressTwoTF.delegate   = self
        addressThreeTF.delegate = self
        channelTF.delegate      = self
        buttonTypeIDTF.delegate = self
        heightTF.delegate       = self
        widthTF.delegate        = self
        scaleXTF.delegate       = self
        scaleYTF.delegate       = self
        topMarginTF.delegate    = self
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: nameTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: addressOneTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: addressTwoTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: addressThreeTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: buttonTypeIDTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: heightTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: widthTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: scaleXTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: scaleYTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        moveTextfield(textfield: topMarginTF, keyboardFrame: keyboardFrame, backView: backgroundView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
}

extension UIViewController {
    func showRemoteButtonSettings(button: RemoteButton) {
        let vc = ButtonSettingsVC()
        vc.button = button
        present(vc, animated: true, completion: nil)
    }
}
