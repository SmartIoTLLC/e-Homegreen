//
//  DeleteButtonImageVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/4/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class DeleteButtonImageVC: CommonXIBTransitionVC {

    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var cancelButton: CustomGradientButton!
    @IBOutlet weak var okButton: CustomGradientButton!

    @IBOutlet weak var deleteLabel: UILabel!
    var image: Image!
    
    override func viewDidLoad() {
        setupViews()
    }

    fileprivate func setupViews() {
        backView.setGradientBackground()
        backView.layer.cornerRadius  = 10
        backView.layer.borderColor   = Colors.MediumGray
        backView.layer.borderWidth   = 1
        backView.layer.masksToBounds = true
        
        cancelButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        okButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        
        dismissView.backgroundColor = .clear
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissModal)))
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        deleteLabel.text = "Are you sure you want to delete this image?"
        deleteLabel.textColor = .white
        cancelButton.setTitle("CANCEL", for: UIControl.State())
        cancelButton.setTitleColor(.white, for: UIControl.State())
        okButton.setTitle("OK", for: UIControl.State())
        okButton.setTitleColor(.white, for: UIControl.State())
        
        backView.bringSubviewToFront(cancelButton)
        backView.bringSubviewToFront(okButton)
        backView.bringSubviewToFront(deleteLabel)
    }
    
    @objc fileprivate func deleteImage() {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            user.removeFromImages(image)
            
            CoreDataController.sharedInstance.saveChanges()
            NotificationCenter.default.post(name: .CustomButtonImageEdited, object: nil)
            dismissModal()
        }
    }

}

extension UIViewController {
    func showDeleteButtonImageVC(image: Image) {
        let vc = DeleteButtonImageVC()
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
}
