//
//  SidemenuUserCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/8/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let profileImageSize: CGFloat = 44
    static let labelHeight: CGFloat = 18.5
    static let logoutButtonSize: CGFloat = 40
}

class SidemenuUserCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "SidemenuUserCollectionViewCell"
    
    private let profileImageView: UIImageView = UIImageView()
    private let adminLabel: UILabel = UILabel()
    private let userLabel: UILabel = UILabel()
    private let logoutButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addProfileImageView()
        addAdminLabel()
        addUserLabel()
        addLogoutButton()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        addProfileImageView()
        addAdminLabel()
        addUserLabel()
        addLogoutButton()
        
        setupConstraints()
    }
    
    private func addProfileImageView() {
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.masksToBounds = true
        
        addSubview(profileImageView)
    }
    
    private func addAdminLabel() {
        adminLabel.font = .tahoma(size: 15)
        adminLabel.textColor = .white
        
        addSubview(adminLabel)
    }
    
    private func addUserLabel() {
        userLabel.font = .tahoma(size: 14)
        userLabel.textColor = .white
        
        addSubview(userLabel)
    }
    
    private func addLogoutButton() {
        logoutButton.addTap {
            self.logOut()
        }
        logoutButton.setImage(#imageLiteral(resourceName: "btn_log_out"), for: UIControl.State())
        
        addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(LocalConstants.profileImageSize)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding / 2)
            make.centerY.equalToSuperview()
        }
        
        logoutButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding / 2)
            make.width.height.equalTo(LocalConstants.logoutButtonSize)
            make.centerY.equalToSuperview()
        }
        
        adminLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(GlobalConstants.sidePadding / 2)
            make.trailing.equalTo(logoutButton.snp.leading).inset(-GlobalConstants.sidePadding)
            make.height.equalTo(LocalConstants.labelHeight)
        }
        
        userLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.leading.equalTo(profileImageView.snp.trailing).offset(GlobalConstants.sidePadding / 2)
            make.trailing.equalTo(logoutButton.snp.leading).inset(-GlobalConstants.sidePadding)
            make.height.equalTo(LocalConstants.labelHeight)
        }
    }
    
    private func setup() {
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    func setCell(with user: User?) {
        
        var profileImage: UIImage = #imageLiteral(resourceName: "User")
        var adminLabelText: String! = ""
        var userLabelText: String! = "null"
        
        if let user = user {
            if let id = user.customImageId {
                if let image = DatabaseImageController.shared.getImageById(id) {
                    if let data =  image.imageData {
                        if let image = UIImage(data: data) {
                            profileImage = image
                        }
                    }
                }
            }
            
            adminLabelText = user.username
            
        } else {
            
            if let username = AdminController.shared.getAdmin()?.username {
                adminLabelText = username
            }
            
            if let user = DatabaseUserController.shared.getOtherUser() {
                if let username = user.username {
                    userLabelText = username + "'s database"
                }
            }
        }
        
        profileImageView.image = profileImage
        adminLabel.text = adminLabelText
        userLabel.text = userLabelText
    }
    
    private func logOut() {
        if let parentViewController = self.parentViewController {
            let optionMenu = UIAlertController(title: nil, message: "Are you sure to want to log out?", preferredStyle: .actionSheet)
            
            let logoutAction = UIAlertAction(title: "Log Out", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                DatabaseLocationController.shared.stopAllLocationMonitoring()
                DatabaseUserController.shared.logoutUser()
                let _ = DatabaseUserController.shared.setUser(nil)
                AdminController.shared.logoutAdmin()

                if let logIn = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LogInViewController {
                    parentViewController.present(logIn, animated: false, completion: nil)
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(logoutAction)
            optionMenu.addAction(cancelAction)
            parentViewController.present(optionMenu, animated: true, completion: nil)
        }

    }
}
