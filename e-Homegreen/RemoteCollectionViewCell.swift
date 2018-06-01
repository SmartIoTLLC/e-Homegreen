//
//  RemoteCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 5/31/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

private struct LocalConstants {
    static let labelHeight: CGFloat = 17
    static let verticalPadding: CGFloat = 8
    static let bottomPadding: CGFloat = 30
}

class RemoteCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "RemoteCollectionViewCell"
    
    private let titleLabel: UILabel = UILabel()
    private let remoteImageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTitleLabel()
        addRemoteImageView()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTitleLabel()
        addRemoteImageView()
        
        setupConstraints()
    }
    
    private func addTitleLabel() {
        titleLabel.textColor     = .white
        titleLabel.font          = .tahoma(size: 14)
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
    }
    
    private func addRemoteImageView() {
        remoteImageView.image       = #imageLiteral(resourceName: "Remote")
        remoteImageView.contentMode = .scaleAspectFit
        
        addSubview(remoteImageView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.labelHeight)
        }
        
        remoteImageView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(LocalConstants.verticalPadding)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(LocalConstants.bottomPadding)
        }
    }
    
    func setCell(with remote: Remote) {
        titleLabel.text = remote.name
        
        remoteImageView.addLongPress(minimumPressDuration: 0.5) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            if let parentViewController = self.parentViewController as? RemoteViewController {
                if let location = parentViewController.pickedLocation {
                    parentViewController.showEditRemoteVC(remote: remote, location: location)
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        UIColor.lightGray.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).withAlphaComponent(0.95).cgColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).withAlphaComponent(1.0).cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: self.bounds.height)
        
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
    
}
