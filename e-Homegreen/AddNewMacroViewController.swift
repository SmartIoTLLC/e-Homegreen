//
//  AddNewMacroViewController.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/22/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import UIKit

protocol SuccessfullyAddedMacroDelegate {
    func refreshMacroVC()
}

class AddNewMacroViewController: PopoverVC {
    
    @IBOutlet weak var popUpView: CustomGradientBackground!
    
    var nameLabel: UILabel!
    var nameTextField: MacroTextField!
    var typeLabel: UILabel!
    var typeDropDown: CustomGradientButton!
    
    var leftImageButton: UIButton!
    var leftImageString: String = "library_event_movie_00" //default image
    var rightImageButton: UIButton!
    var rightImageString: String = "library_event_movie_01" //default image
    
    var cancelButton: CustomGradientButton!
    var submitButton: CustomGradientButton!
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var popUpWidth: CGFloat!
    var popUpHeight: CGFloat!
    
    var macroType: String = "block" //default macro type
    var macroDelegate: SuccessfullyAddedMacroDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidth = UIScreen.main.bounds.width
        screenHeight = UIScreen.main.bounds.height
        setUpPopUpView()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpPopUpView() {
        
        popUpView.frame = CGRect(x: 6, y: 0, width: screenWidth - 12, height: 260) //3
        popUpView.center.y = self.view.center.y
        popUpView.center.x = self.view.center.x
        popUpView.layer.cornerRadius = 9
        popUpView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        popUpView.layer.cornerRadius = 5
        
        popUpHeight = popUpView.frame.height
        popUpWidth = popUpView.frame.width
        
        setUpElementsInsidePopUp()
    }
    
    private func setUpElementsInsidePopUp() {
        
        nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 8, y: 15, width: 50, height: 21)
        nameLabel.text = "Name:"
        nameLabel.font = .tahoma(size: 15)
        nameLabel.textColor = .white
        
        nameTextField = MacroTextField()
        nameTextField.frame = CGRect(x: nameLabel.frame.maxX + 10, y: 10, width: popUpWidth - nameLabel.frame.width - 10 - 8 - 8, height: 35)
        nameTextField.placeholder = "Name"
        
        typeLabel = UILabel()
        typeLabel.frame = CGRect(x: 8, y: nameTextField.frame.maxY + 12 , width: 50, height: 21)
        typeLabel.text = "Type:"
        typeLabel.font = .tahoma(size: 15)
        typeLabel.textColor = .white
        
        typeDropDown = CustomGradientButton()
        typeDropDown.frame = CGRect(x: typeLabel.frame.maxX + 10, y: nameTextField.frame.maxY + 7, width: popUpWidth - typeLabel.frame.width - 10 - 8 - 8, height: 35)
        typeDropDown.setTitle("Select macro type", for: UIControlState())
        typeDropDown.titleLabel?.font = UIFont(name: "Tahoma", size: 14)
        typeDropDown.addTarget(self, action: #selector(openMacroDropDown(_:)), for: .touchUpInside)
        
        leftImageButton = UIButton()
        leftImageButton.frame = CGRect(x: typeDropDown.frame.minX, y: typeDropDown.frame.maxY + 20, width: popUpWidth/3, height: 90)
        leftImageButton.setImage(UIImage(named:"library_event_movie_00"), for: UIControlState())
        leftImageButton.addTarget(self, action: #selector(editImageLeft(_:)), for: .touchUpInside)
        leftImageButton.imageView?.contentMode = .scaleAspectFit

        rightImageButton = UIButton()
        rightImageButton.frame = CGRect(x: leftImageButton.frame.maxX + 30, y: typeDropDown.frame.maxY + 20, width: popUpWidth/3, height: 90)
        rightImageButton.setImage(UIImage(named:"library_event_movie_01"), for: UIControlState())
        rightImageButton.addTarget(self, action: #selector(editImageRight(_:)), for: .touchUpInside)
        rightImageButton.imageView?.contentMode = .scaleAspectFit
        
        cancelButton = CustomGradientButton()
        cancelButton.frame = CGRect(x: 8, y: popUpHeight - 31 - 10, width: (popUpWidth/2) - 8 - 4, height: 35)
        cancelButton.setTitle("CANCEL", for: UIControlState())
        cancelButton.titleLabel?.font = UIFont(name: "Tahoma", size: 14)
        cancelButton.addTarget(self, action: #selector(cancelButton(_:)), for: .touchUpInside)
        
        submitButton = CustomGradientButton()
        submitButton.frame = CGRect(x: cancelButton.frame.maxX + 8, y: popUpHeight - 31 - 10, width: (popUpWidth/2) - 8 - 4, height: 35)
        submitButton.setTitle("CREATE NEW MACRO", for: UIControlState())
        submitButton.titleLabel?.font = UIFont(name: "Tahoma", size: 14)
        submitButton.addTarget(self, action: #selector(submitButton(_:)), for: .touchUpInside)
        
        
        //add to pop up view
        popUpView.addSubview(nameLabel)
        popUpView.addSubview(nameTextField)
        popUpView.addSubview(typeLabel)
        popUpView.addSubview(typeDropDown)
        popUpView.addSubview(leftImageButton)
        popUpView.addSubview(rightImageButton)
        popUpView.addSubview(cancelButton)
        popUpView.addSubview(submitButton)
    }
    
    @objc func openMacroDropDown(_ sender: UIButton) {
        var popOverList: [PopOverItem] = []
        
        popOverList.append(PopOverItem(name: "Block", id: "Block"))
        popOverList.append(PopOverItem(name: "Restart", id: "Restart"))
        popOverList.append(PopOverItem(name: "Queue", id: "Queue"))
        
        if let vc = popUpView.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList: popOverList) } else { print ("unable to present pop up in AddNewMacroVC") }
    }
    
    //return name and id of item selected in dropdown
    override func nameAndId(_ name: String, id: String) {
        typeDropDown.setTitle(name, for: UIControlState())
        switch name {
        case "Block":
            macroType = MacroTypes.block
        case "Restart":
            macroType = MacroTypes.restart
        case "Queue":
            macroType = MacroTypes.queue
        default:
            macroType = MacroTypes.block
        }
    }
    
    @objc func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func submitButton(_ sender: UIButton) {
        let result = DatabaseMacrosController.sharedInstance.saveMacroToCD(name: nameTextField.text!, type: macroType, leftImage: leftImageString, rightImage: rightImageString)
        switch result {
        case true:
            self.dismiss(animated: true) { self.macroDelegate?.refreshMacroVC() }
        case false:
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func editImageLeft(_ sender: UIButton) {
        showGallery(1, user: nil).delegate = self
    }
    
    @objc func editImageRight(_ sender: UIButton) {
        showGallery(2, user: nil).delegate = self
    }
    
}
extension AddNewMacroViewController : SceneGalleryDelegate {
    
    func backImageFromGallery(_ data: Data, imageIndex: Int) {
        
    }
    
    func backString(_ strText: String, imageIndex: Int) {
        if imageIndex == 1 {
            leftImageString = strText
            leftImageButton.setImage(UIImage(named: strText), for: UIControlState())
        } else if imageIndex == 2 {
            rightImageString = strText
            rightImageButton.setImage(UIImage(named: strText), for: UIControlState())
        }
    }
    
    func backImage(_ image: Image, imageIndex: Int) {
        
    }
    
}

class MacroTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateTextField()
    }
    
    func updateTextField(){
        self.tintColor = UIColor.black
        self.textColor = UIColor.black
        self.font = .tahoma(size: 13)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.backgroundColor = UIColor.white
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}





























