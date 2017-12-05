//
//  ChooseButtonColorVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/16/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class ChooseButtonColorVC: CommonXIBTransitionVC {
    
    var pickedColor: String!
    var masterColor: String!
    
    @IBOutlet weak var dismissArea: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var useMasterButton: UIButton!
    @IBOutlet weak var grayButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    override func viewDidLoad() {
        updateViews()
        setButtons()
    }
    
    fileprivate func updateViews() {
        view.backgroundColor = .clear
        backgroundView.backgroundColor = Colors.AndroidGrayColor
        dismissArea.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dismissArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissModal)))
    }
    
    fileprivate func setButtons() {
        useMasterButton.setPickButton()
        grayButton.setPickButton()
        redButton.setPickButton()
        greenButton.setPickButton()
        blueButton.setPickButton()
        
        useMasterButton.addTarget(self, action: #selector(pickColor(_:)), for: .touchUpInside)
        grayButton.addTarget(self, action: #selector(pickColor(_:)), for: .touchUpInside)
        redButton.addTarget(self, action: #selector(pickColor(_:)), for: .touchUpInside)
        greenButton.addTarget(self, action: #selector(pickColor(_:)), for: .touchUpInside)
        blueButton.addTarget(self, action: #selector(pickColor(_:)), for: .touchUpInside)
    }
    
    @objc fileprivate func pickColor(_ sender: UIButton) {
        switch sender.titleLabel!.text! {
            case "Use master"       : pickedColor = masterColor
            case ButtonColor.gray   : pickedColor = ButtonColor.gray
            case ButtonColor.red    : pickedColor = ButtonColor.red
            case ButtonColor.green  : pickedColor = ButtonColor.green
            case ButtonColor.blue   : pickedColor = ButtonColor.blue
            default: break
        }
        NotificationCenter.default.post(name: .ButtonColorChosen, object: pickedColor)
        dismissModal()
    }    

}

extension UIButton {
    func setPickButton() {
        //titleLabel?.textAlignment = .left
        contentHorizontalAlignment = .left
        contentEdgeInsets.left = 8
        setTitleColor(.white, for: UIControlState())
        titleLabel?.font = .tahoma(size: 17)
    }
}

extension UIViewController {
    @objc func showChooseButtonColorVC(color: String) {
        let vc = ChooseButtonColorVC()
        vc.masterColor = color
        present(vc, animated: true, completion: nil)
    }
}
