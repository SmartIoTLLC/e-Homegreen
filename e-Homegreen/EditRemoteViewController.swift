//
//  EditRemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/28/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class EditRemoteViewController: CommonXIBTransitionVC {
    
    //var remote: RemoteDummy?
    var remote: Remote!
    var location: Location!
    var zoneId: Zone!
    
    @IBOutlet weak var dismissView: UIView!

    @IBOutlet weak var cancelButton: CustomGradientButton!
    @IBOutlet weak var deleteButton: CustomGradientButton!
    @IBOutlet weak var copyButton: CustomGradientButton!
    
    @IBAction func cancelButton(_ sender: Any) {
        dismissVC()
    }
    @IBAction func deleteButton(_ sender: Any) {
        delete()
    }
    @IBAction func copyButton(_ sender: Any) {
        clone()
    }
    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        updateViews()
    }

}

// MARK: - View setup
extension EditRemoteViewController {
    fileprivate func updateViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        
        dismissView.backgroundColor  = .clear
        backView.backgroundColor     = Colors.AndroidGrayColor
        backView.setGradientBackground()
        backView.layer.cornerRadius  = 10
        backView.layer.borderColor   = Colors.MediumGray
        backView.layer.borderWidth   = 1
        backView.layer.masksToBounds = true
        backView.bringSubview(toFront: cancelButton)
        backView.bringSubview(toFront: deleteButton)
        backView.bringSubview(toFront: copyButton)
    }
    
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}
// MARK: - Logic
extension EditRemoteViewController {
    fileprivate func delete() {
        DatabaseRemoteController.sharedInstance.deleteRemote(remote: remote, from: location)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
        dismissVC()
    }
    
    fileprivate func clone() {
        DatabaseRemoteController.sharedInstance.cloneRemote(remote: remote, on: location)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
        dismissVC()
    }
}

extension UIViewController {
    func showEditRemoteVC(remote: Remote, location: Location) {
        let vc = EditRemoteViewController()
        vc.remote = remote
        vc.location = location
        present(vc, animated: true, completion: nil)
    }
}
