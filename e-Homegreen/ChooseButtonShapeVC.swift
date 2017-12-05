//
//  ChooseButtonShapeVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/16/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class ChooseButtonShapeVC: CommonXIBTransitionVC {
    
    var pickedShape: String!
    var masterShape: String!
    
    @IBOutlet weak var dismissArea: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var useMasterButton: UIButton!
    @IBOutlet weak var rectangleButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    
    override func viewDidLoad() {
        updateViews()
        setButtons()
    }
    
    fileprivate func updateViews() {
        backgroundView.backgroundColor = Colors.AndroidGrayColor
        view.backgroundColor        = .clear
        dismissArea.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dismissArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissModal)))
    }
    
    func setButtons() {
        useMasterButton.setPickButton()
        rectangleButton.setPickButton()
        circleButton.setPickButton()
        
        useMasterButton.addTarget(self, action: #selector(pickShape(_:)), for: .touchUpInside)
        rectangleButton.addTarget(self, action: #selector(pickShape(_:)), for: .touchUpInside)
        circleButton.addTarget(self, action: #selector(pickShape(_:)), for: .touchUpInside)
    }
    
    @objc fileprivate func pickShape(_ sender: UIButton) {
        switch sender.titleLabel!.text! {
            case "Use master"               : pickedShape = masterShape
            case ButtonShape.circle         : pickedShape = ButtonShape.circle
            case ButtonShape.rectangle    : pickedShape = ButtonShape.rectangle
            default: break
        }
        
        NotificationCenter.default.post(name: .ButtonShapeChosen, object: pickedShape)
        dismissModal()
    }
    
}

extension UIViewController {
    
    @objc func showChooseButtonShape(masterShape: String) {
        let vc = ChooseButtonShapeVC()
        vc.masterShape = masterShape
        present(vc, animated: true, completion: nil)
    }
}
