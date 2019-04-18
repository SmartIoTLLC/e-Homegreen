//
//  EditRemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/28/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

private struct LocalConstants {
    static let buttonContainerSize: CGSize = CGSize(width: GlobalConstants.screenSize.width - 32, height: 46)
    static let buttonSize: CGSize = CGSize(width: (buttonContainerSize.width - 2 * 4 - 2 * 8) / 3, height: 30)
    static let itemSpacing: CGFloat = 8
}

class EditRemoteViewController: CommonXIBTransitionVC {
    
    var remote: Remote!
    var location: Location!
    var zoneId: Zone!
    
    private let dismissView: UIView = UIView()
    
    private let buttonContainer: UIView = UIView()
    private let cancelButton: CustomGradientButton = CustomGradientButton()
    private let deleteButton: CustomGradientButton = CustomGradientButton()
    private let copyButton: CustomGradientButton = CustomGradientButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addDismissView()
        addContainerView()
        addCancelButton()
        addDeleteButton()
        addCopyButton()
        
        setupConstraints()
    }
    
    // MARK: - Setup views
    private func addDismissView() {
        dismissView.addTap {
            self.dismiss(animated: true, completion: nil)
        }
        
        view.addSubview(dismissView)
    }
    
    private func addContainerView() {
        buttonContainer.backgroundColor     = Colors.AndroidGrayColor
        buttonContainer.setGradientBackground()
        buttonContainer.layer.cornerRadius  = 10
        buttonContainer.layer.borderColor   = Colors.MediumGray
        buttonContainer.layer.borderWidth   = 1
        buttonContainer.layer.masksToBounds = true
        
        view.addSubview(buttonContainer)
    }
    
    private func addCancelButton() {
        cancelButton.setTitle("CANCEL", for: UIControl.State())
        cancelButton.setTitleColor(.white, for: UIControl.State())
        cancelButton.addTap {
            self.dismiss(animated: true, completion: nil)
        }
        
        buttonContainer.addSubview(cancelButton)
    }
    
    private func addDeleteButton() {
        deleteButton.setTitle("DELETE", for: UIControl.State())
        deleteButton.setTitleColor(.white, for: UIControl.State())
        deleteButton.addTap {
            self.delete()
        }
        
        buttonContainer.addSubview(deleteButton)
    }
    
    private func addCopyButton() {
        copyButton.setTitle("COPY", for: UIControl.State())
        copyButton.setTitleColor(.white, for: UIControl.State())
        copyButton.addTap {
            self.clone()
        }
        
        buttonContainer.addSubview(copyButton)
    }
    
    
    private func setupConstraints() {
        dismissView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        buttonContainer.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(LocalConstants.buttonContainerSize.width)
            make.height.equalTo(LocalConstants.buttonContainerSize.height)
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.width.equalTo(LocalConstants.buttonSize.width)
            make.height.equalTo(LocalConstants.buttonSize.height)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(LocalConstants.buttonSize.width)
            make.height.equalTo(LocalConstants.buttonSize.height)
            make.trailing.equalTo(deleteButton.snp.leading).inset(-LocalConstants.itemSpacing)
            make.centerY.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints { (make) in
            make.width.equalTo(LocalConstants.buttonSize.width)
            make.height.equalTo(LocalConstants.buttonSize.height)
            make.leading.equalTo(deleteButton.snp.trailing).offset(LocalConstants.itemSpacing)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Logic
    private func delete() {
        DatabaseRemoteController.sharedInstance.deleteRemote(remote: remote, from: location)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func clone() {
        DatabaseRemoteController.sharedInstance.cloneRemote(remote: remote, on: location)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
        self.dismiss(animated: true, completion: nil)
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
