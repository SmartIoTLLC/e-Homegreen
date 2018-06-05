//
//  PhoneInstructionsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/5/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let sidePadding: CGFloat = GlobalConstants.sidePadding / 2
    static let labelSide: CGFloat = 250
    static let borderWidth: CGFloat = 1
    static let cornerRadius: CGFloat = 3
}

class PhoneInstructionsViewController: UIViewController {
    
    private let dismissArea: UIView = UIView()
    private let backgroundView: UIView = UIView()
    private let descriptionLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDismissArea()
        addBackgroundView()
        addDescriptionLabel()
        
        setupConstraints()
    }
    
    private func addDismissArea() {
        dismissArea.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dismissArea.addTap {
            self.dismiss(animated: true, completion: nil)
        }
        
        view.addSubview(dismissArea)
    }
    
    private func addBackgroundView() {
        backgroundView.backgroundColor   = Colors.AndroidGrayColor
        backgroundView.layer.borderColor = Colors.DarkGray
        backgroundView.layer.borderWidth = LocalConstants.borderWidth
        backgroundView.layer.cornerRadius = LocalConstants.cornerRadius
        backgroundView.layer.masksToBounds = true
        
        view.addSubview(backgroundView)
    }
    
    private func addDescriptionLabel() {
        descriptionLabel.font = .tahoma(size: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        
        descriptionLabel.text = "To call someone, simply short-tap the 'Make a call' button and utter the name of the person you want to call loud and clear.\n\nTo use this feature, you'll need to give us access to your contacts and microphone.\nAdditionally, you'll need an active internet connection for voice recognition to work."
        
        backgroundView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        dismissArea.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        backgroundView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(LocalConstants.labelSide)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.sidePadding)
            make.leading.equalToSuperview().offset(LocalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(LocalConstants.sidePadding)
            make.bottom.equalToSuperview().inset(LocalConstants.sidePadding)
        }
    }
}
