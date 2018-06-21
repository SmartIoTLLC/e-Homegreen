//
//  ZoneAndCategoryControlView.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/19/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let sliderHeight: CGFloat = 31
    static let pullupImageSize: CGSize = CGSize(width: 120, height: 37)
    static let backgroundHeight: CGFloat = 154
    static let segControlHeight: CGFloat = 29
    static let itemSidePadding: CGFloat = 12
    static let buttonHeight: CGFloat = 40
    static let labelHeight: CGFloat = 18.5
    static let buttonFontSize: CGFloat = 15
    static let itemTopPadding: CGFloat = 5
    
    static let buttonWidth: CGFloat = (GlobalConstants.screenSize.width - 3*itemSidePadding) / 2
}

private struct ZACCType {
    static let zone = "Zone"
    static let category = "Category"
}

private struct ZACCTypeOfControl {
    static let allowed: Int = 1
    static let confirmed: Int = 2
    static let notAllowed: Int = 3
}

class ZoneAndCategoryControlView: UIView {
    private var filterItem: FilterItem {
        get { return Filter.sharedInstance.returnFilter(forTab: .Device) }
    }
    
    // MARK: - UI components declaration
    private let pullUpImageView: UIImageView = UIImageView()
    private let backgroundView: CustomGradientBackground = CustomGradientBackground()
    private let slider: SICSlider = SICSlider()
    private let onButton: CustomGradientButton = CustomGradientButton()
    private let offButton: CustomGradientButton = CustomGradientButton()
    private let control: UISegmentedControl = UISegmentedControl()
    private let titleLabel: UILabel = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addPullUpImageView()
        addBackgroundView()
        addSlider()
        addOnButton()
        addOffButton()
        addControl()
        addTitleLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addPullUpImageView()
        addBackgroundView()
        addSlider()
        addOnButton()
        addOffButton()
        addControl()
        addTitleLabel()
        
        setupConstraints()
    }
    
    // MARK: - Setup views
    private func addPullUpImageView() {
        pullUpImageView.image = #imageLiteral(resourceName: "pullup")
        
        addSubview(pullUpImageView)
    }
    
    private func addBackgroundView() {
        addSubview(backgroundView)
    }
    
    private func addControl() {
        control.addTarget(self, action: #selector(setControlTitle(_:)), for: .valueChanged)
        
        backgroundView.addSubview(control)
    }
    
    private func addSlider() {
        slider.isContinuous = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
        
        backgroundView.addSubview(slider)
    }
    
    private func addOnButton() {
        onButton.setAttributedTitle(
            NSAttributedString(string: "ON", attributes: [
                NSFontAttributeName: UIFont.tahoma(size: LocalConstants.buttonFontSize),
                NSForegroundColorAttributeName: UIColor.white
                ]),
            for: UIControlState()
        )
        
        onButton.addTap {
            self.toggleDevices(on: true)
        }
        
        backgroundView.addSubview(onButton)
    }
    
    private func addOffButton() {
        offButton.setAttributedTitle(
            NSAttributedString(string: "OFF", attributes: [
                NSFontAttributeName: UIFont.tahoma(size: LocalConstants.buttonFontSize),
                NSForegroundColorAttributeName: UIColor.white
                ]),
            for: UIControlState()
        )
        
        offButton.addTap {
            self.toggleDevices(on: false)
        }
        
        backgroundView.addSubview(offButton)
    }
    
    private func addTitleLabel() {
        titleLabel.textColor = .white
        titleLabel.font = .tahoma(size: LocalConstants.buttonFontSize)
        titleLabel.text = "Select zone to control"
        
        backgroundView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        pullUpImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalTo(LocalConstants.pullupImageSize.width)
            make.height.equalTo(LocalConstants.pullupImageSize.height)
            make.centerX.equalToSuperview()
        }
        
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(pullUpImageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        control.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemTopPadding)
            make.leading.equalToSuperview().offset(LocalConstants.itemSidePadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemSidePadding)
            make.height.equalTo(LocalConstants.segControlHeight)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(control.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(LocalConstants.itemSidePadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemSidePadding)
            make.height.equalTo(LocalConstants.labelHeight)
        }
        
        slider.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(LocalConstants.itemSidePadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemSidePadding)
            make.height.equalTo(LocalConstants.sliderHeight)
        }
        
        offButton.snp.makeConstraints { (make) in
            make.leading.equalTo(slider.snp.leading)
            make.width.equalTo(LocalConstants.buttonWidth)
            make.height.equalTo(LocalConstants.buttonHeight)
            make.top.equalTo(slider.snp.bottom).offset(8)
        }
        
        onButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(slider.snp.trailing)
            make.width.equalTo(LocalConstants.buttonWidth)
            make.height.equalTo(LocalConstants.buttonHeight)
            make.top.equalTo(slider.snp.bottom).offset(8)
        }
    }
    
    private func toggleDevices(on turnOn: Bool, allowOption: Int, isZone: Bool) {
//        if isZone {
//            if allowOption == ZACCTypeOfControl.allowed {
//                turnOn ? ZoneAndCategoryControl.shared.turnOnByZone(with: filterItem) : ZoneAndCategoryControl.shared.turnOffByZone(with: filterItem)
//            } else if allowOption == ZACCTypeOfControl.confirmed {
//                turnOn ? showAlert { ZoneAndCategoryControl.shared.turnOnByZone(with: self.filterItem) } : showAlert { ZoneAndCategoryControl.shared.turnOffByZone(with: self.filterItem) }
//            }
//            
//        } else {
//            if allowOption == ZACCTypeOfControl.allowed {
//                turnOn ? ZoneAndCategoryControl.shared.turnOnByCategory(with: filterItem) : ZoneAndCategoryControl.shared.turnOffByCategory(with: filterItem)
//            } else if allowOption == ZACCTypeOfControl.confirmed {
//                turnOn ? showAlert { ZoneAndCategoryControl.shared.turnOnByCategory(with: self.filterItem) } : showAlert { ZoneAndCategoryControl.shared.turnOffByCategory(with: self.filterItem) }
//            }
//        }
        
        slider.value = turnOn ? 100 : 0
    }
    
    private func toggleDevices(on state: Bool) {
        if let isZone = self.isZone() {
            var allowOption: Int?
            
            if isZone {
                if let zone = FilterController.shared.getZoneByObjectId(self.filterItem.zoneObjectId) {
                    allowOption = zone.allowOption.intValue
                }
            } else {
                if let category = FilterController.shared.getCategoryByObjectId(self.filterItem.categoryObjectId) {
                    allowOption = category.allowOption.intValue
                }
            }
            
            if let allowOption = allowOption {
                self.toggleDevices(on: state, allowOption: allowOption, isZone: isZone)
            }
        }
    }
    
    @objc private func sliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        if let s = gestureRecognizer.view as? UISlider {
            if s.isHighlighted { return } // tap on thumb, let slider deal with it
            let pt:CGPoint         = gestureRecognizer.location(in: s)
            let percentage:CGFloat = pt.x / s.bounds.size.width
            let delta:CGFloat      = percentage * (CGFloat(s.maximumValue) - CGFloat(s.minimumValue))
            let value:CGFloat      = CGFloat(s.minimumValue) + delta;
            s.setValue(Float(value), animated: true)
            
            sliderValueChanged(slider)
        }
    }
    
    @objc private func sliderValueChanged(_ sender: SICSlider) {
//        if let isZone = self.isZone() {
//            let sliderValue: Int = Int(sender.value)
//
//            if isZone {
//                if let zone = FilterController.shared.getZoneByObjectId(filterItem.zoneObjectId) {
//                    switch zone.allowOption.intValue {
//                        case ZACCTypeOfControl.allowed   : ZoneAndCategoryControl.shared.changeValueByZone(with: filterItem, value: sliderValue)
//                        case ZACCTypeOfControl.confirmed : showAlert { ZoneAndCategoryControl.shared.changeValueByZone(with: self.filterItem, value: sliderValue) }
//                        default: break
//                    }
//                }
//            } else {
//                if let category = FilterController.shared.getCategoryByObjectId(filterItem.categoryObjectId) {
//                    switch category.allowOption.intValue {
//                        case ZACCTypeOfControl.allowed   : ZoneAndCategoryControl.shared.changeValueByCategory(with: filterItem, value: sliderValue)
//                        case ZACCTypeOfControl.confirmed : showAlert { ZoneAndCategoryControl.shared.changeValueByCategory(with: self.filterItem, value: sliderValue) }
//                        default: break
//                    }
//                }
//            }
//        }
    }
    
    @objc private func setControlTitle(_ sender: UISegmentedControl) {
        if let title = sender.titleForSegment(at: sender.selectedSegmentIndex) {
            switch title {
                case ZACCType.zone     : titleLabel.text = "Selected Zone: " + filterItem.zoneName
                case ZACCType.category : titleLabel.text = "Selected Category: " + filterItem.categoryName
                default: break
            }
        }
    }
    
    private func isZone() -> Bool? {
        if let title = control.titleForSegment(at: control.selectedSegmentIndex) {
            if title == ZACCType.zone, filterItem.zoneObjectId != "All" {
                return true
            } else if title == ZACCType.category, filterItem.categoryObjectId != "All" {
                return false
            }
        }
        
        return nil
    }
    
    private func showAlert(with actionHandler: @escaping () -> Void) {
        let alert: UIAlertController = UIAlertController(title: nil, message: "Are you sure you want to proceed with this control?", preferredStyle: .actionSheet)
    
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            actionHandler()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let parentViewController = self.parentViewController {
            parentViewController.present(alert, animated: true, completion: nil)
        }
    }
}
