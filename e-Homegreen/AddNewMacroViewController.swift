//
//  AddNewMacroViewController.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/22/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import UIKit

class AddNewMacroViewController: PopoverVC {
    
    @IBOutlet weak var popUpView: UIView!
    
    var nameLabel: UILabel!
    var nameTextField: EditTextField!
    var typeLabel: UILabel!
    var typeDropDown: CustomGradientButton!
    //TODO add two image views and two labels here
    var cancelButton: CustomGradientButton!
    var submitButton: CustomGradientButton!
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var popUpWidth: CGFloat!
    var popUpHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidth = self.view.frame.size.width
        screenHeight = self.view.frame.size.height
        setUpPopUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpPopUpView() {
        
        popUpView.frame = CGRect(x: 6, y: 0, width: screenWidth - 12, height: screenHeight/3)
        popUpView.center.y = self.view.center.y
        popUpView.layer.cornerRadius = 9
        popUpView.backgroundColor = UIColor.lightGray
        
        popUpHeight = popUpView.frame.height
        popUpWidth = popUpView.frame.width
        
        setUpElementsInsidePopUp()
    }
    
    private func setUpElementsInsidePopUp() {
        
        nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 8, y: 15, width: 50, height: 16)
        nameLabel.text = "Name:"
        nameLabel.font = .tahoma(size: 15)
        nameLabel.textColor = .white
        
        nameTextField = EditTextField()
        nameTextField.frame = CGRect(x: nameLabel.frame.maxX + 10, y: 10, width: popUpWidth - nameLabel.frame.width - 10 - 8 - 8, height: 30)
        nameTextField.placeholder = "Name"
        
        typeLabel = UILabel()
        typeLabel.frame = CGRect(x: 8, y: nameTextField.frame.maxY + 8 , width: 50, height: 16)
        typeLabel.text = "Type:"
        typeLabel.font = .tahoma(size: 15)
        typeLabel.textColor = .white
        
        typeDropDown = CustomGradientButton()
        typeDropDown.frame = CGRect(x: typeLabel.frame.maxX + 10, y: nameTextField.frame.maxY + 3, width: popUpWidth - typeLabel.frame.width - 10 - 8 - 8, height: 30)
        typeDropDown.setTitle("Select macro type", for: UIControlState())
        typeDropDown.addTarget(self, action: #selector(openMacroDropDown(_:)), for: .touchUpInside)
        
        cancelButton = CustomGradientButton()
        cancelButton.frame = CGRect(x: 8, y: popUpHeight - 31 - 6, width: (popUpWidth/2) - 8 - 4, height: 31)
        cancelButton.setTitle("CANCEL", for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancelButton(_:)), for: .touchUpInside)
        
        submitButton = CustomGradientButton()
        submitButton.frame = CGRect(x: cancelButton.frame.maxX + 8, y: popUpHeight - 31 - 6, width: (popUpWidth/2) - 8 - 4, height: 31)
        submitButton.setTitle("CREATE NEW MACRO", for: UIControlState())
        submitButton.addTarget(self, action: #selector(submitButton(_:)), for: .touchUpInside)

        
        //add to pop up view
        popUpView.addSubview(nameLabel)
        popUpView.addSubview(nameTextField)
        popUpView.addSubview(typeLabel)
        popUpView.addSubview(typeDropDown)
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
    
    @objc func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func submitButton(_ sender: UIButton) {
        
    }
    
    
}

























