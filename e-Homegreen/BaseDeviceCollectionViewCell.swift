//
//  BaseDeviceCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let flipAnimationDuration: Double = 0.5
    static let cornerRadius: CGFloat = 5
    static let borderWidth: CGFloat = 1
}

class BaseDeviceCollectionViewCell: UICollectionViewCell {
    
    // MARK: UI components declaration
    let disabledCellView: UIView = UIView()
    let backView: CustomGradientBackground = CustomGradientBackground()
    let infoView: CustomGradientBackground = CustomGradientBackground()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addDisabledCellView()
        addInfoView()
        addBackView()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        addDisabledCellView()
        addInfoView()
        addBackView()
        
        setupConstraints()
    }
    
    // MARK: - Setup views
    private func setup() {
        layer.borderColor   = Colors.AndroidGrayColor.cgColor
        layer.borderWidth   = LocalConstants.borderWidth
        layer.cornerRadius  = LocalConstants.cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    private func addDisabledCellView() {
        addSubview(disabledCellView)
    }
    
    private func addInfoView() {
        infoView.addTap(numberOfTapsRequired: 2) {
            UIView.transition(
                from: self.infoView,
                to: self.backView,
                duration: LocalConstants.flipAnimationDuration,
                options: [.transitionFlipFromBottom, .showHideTransitionViews],
                completion: nil
            )
            
            if let device = self.getDevice(from: self.infoView) {
                device.info = false
            }
        }
        
        addSubview(infoView)
        
    }
    
    private func addBackView() {
        backView.addTap(numberOfTapsRequired: 2) {
            UIView.transition(
                from: self.backView,
                to: self.infoView,
                duration: LocalConstants.flipAnimationDuration,
                options: [.transitionFlipFromBottom, .showHideTransitionViews],
                completion: nil
            )
            
            if let device = self.getDevice(from: self.backView) {
                device.info = true
            }
        }
        
        addSubview(backView)
    }
    
    private func setupConstraints() {
        disabledCellView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        infoView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        backView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    func setCell(with device: Device, tag: Int) {
        infoView.tag = tag
        backView.tag = tag
        
        infoView.isHidden = device.info ? false : true
        backView.isHidden = device.info ? true : false
        disabledCellView.isHidden = device.isEnabled.boolValue ? true : false
        
        device.isEnabled.boolValue ? sendSubview(toBack: disabledCellView) : bringSubview(toFront: disabledCellView)
    }
    
    func getDevice(from sender: UIView) -> Device? {
        if let dvc = self.parentViewController as? DevicesViewController {
            let index = sender.tag
            let device = dvc.devices[index]
            
            return device
        } else if let dvc = self.parentViewController as? FavoriteDevicesVC {
            let index = sender.tag
            let device = dvc.devices[index]
            
            return device
        }
        
        return nil
    }
    
    func getDeviceFromGesture(_ gestureRecognizer: UIGestureRecognizer) -> Device? {
        if let index = gestureRecognizer.view?.tag {
            if let dvc = self.parentViewController as? DevicesViewController {
                let device = dvc.devices[index]
                    
                return device
            } else if let dvc = self.parentViewController as? FavoriteDevicesVC {
                let device = dvc.devices[index]
                    
                return device
            }
        }
        
        return nil
    }
    
    func setDeviceInControlMode(to state: Bool) {
        if let dvc = self.parentViewController as? DevicesViewController {
            dvc.deviceInControlMode = state
        } else if let dvc = self.parentViewController as? FavoriteDevicesVC {
            dvc.deviceInControlMode = state
        }
    }
    
    func reloadDeviceCell(via gestureRecognizer: UIGestureRecognizer) {
        
        if let row = gestureRecognizer.view?.tag {
            if let dvc = self.parentViewController as? DevicesViewController {
                dvc.deviceCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
            } else if let dvc = self.parentViewController as? FavoriteDevicesVC {
                dvc.deviceCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
            }
        }

    }
    
    func reloadDeviceCell(at row: Int) {
        if let dvc = self.parentViewController as? DevicesViewController {
            dvc.deviceCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
        } else if let dvc = self.parentViewController as? FavoriteDevicesVC {
            dvc.deviceCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
        }
    }
    
}

