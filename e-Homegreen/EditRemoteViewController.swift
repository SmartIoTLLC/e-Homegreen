//
//  EditRemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/28/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class EditRemoteViewController: CommonXIBTransitionVC {
    
    var remote: RemoteDummy?
    var realRemote: Remote!
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
        DatabaseRemoteController.sharedInstance.deleteRemote(realRemote)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
    }
    
    @IBAction func copyButton(_ sender: Any) {
        cloneRemote(remote: realRemote)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
    }
    
    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))

        updateViews()
    }
    

    func updateViews() {
        dismissView.backgroundColor = .clear
        backView.backgroundColor = Colors.AndroidGrayColor
        backView.setGradientBackground()
        backView.layer.cornerRadius = 10
        backView.layer.borderColor = Colors.MediumGray
        backView.layer.borderWidth = 1
        backView.layer.masksToBounds = true
        backView.bringSubview(toFront: cancelButton)
        backView.bringSubview(toFront: deleteButton)
        backView.bringSubview(toFront: copyButton)
    }
    
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    func cloneRemote(remote: Remote) {
        DatabaseRemoteController.sharedInstance.createRemote(name: remote.name!, columns: remote.columns!, rows: remote.rows!, location: location, level: 0, zone: zoneId, addressOne: remote.addressOne!, addressTwo: remote.addressTwo!, addressThree: remote.addressThree!, channel: remote.channel!, buttonHeight: remote.buttonHeight!, buttonWidth: remote.buttonWidth!, marginTop: remote.marginTop!, marginBottom: remote.marginBottom!, buttonColor: remote.buttonColor!, buttonShape: remote.buttonShape!)
    }
    

}

extension UIViewController {
    func showEditRemoteVC(remote: RemoteDummy) {
        let vc = EditRemoteViewController()
        vc.remote = remote
        self.present(vc, animated: true, completion: nil)
    }
}
