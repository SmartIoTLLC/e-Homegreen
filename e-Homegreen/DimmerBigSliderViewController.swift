//
//  DimmerBigSliderViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/18/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let holderViewHeight: CGFloat = 93
    static let sliderHeight: CGFloat = 31
    static let buttonHeight: CGFloat = 40
    static let itemPadding: CGFloat = 8
    static let buttonFontSize: CGFloat = 15
    static let buttonWidth: CGFloat = (GlobalConstants.screenSize.width - 3 * itemPadding) / 2
}

class DimmerBigSliderViewController: CommonXIBTransitionVC {
    
    private var sliderOldValue: Int?
    private var device: Device?
    
    // MARK: - UI components declaration
    private let holderView: UIView = UIView()
    private let slider: SICSlider = SICSlider()
    private let offButton: CustomGradientButton = CustomGradientButton()
    private let onButton: CustomGradientButton = CustomGradientButton()
    
    // MARK: - Init
    init(device: Device, tag: Int) {
        super.init(nibName: nil, bundle: nil)
        
        self.device = device
        
        slider.value = device.currentValue.floatValue / 255
        slider.tag = tag
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHolderView()
        addSlider()
        addOffButton()
        addOnButton()
        
        setupConstraints()
    }
    
    // MARK: - Setup views
    private func addHolderView() {
        view.addSubview(holderView)
    }
    
    private func addSlider() {
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderEnded(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderStarted(_:)), for: .touchDown)
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
        
        holderView.addSubview(slider)
    }
    
    private func addOffButton() {
        offButton.setAttributedTitle(
            NSAttributedString(string: "OFF", attributes: [
                NSFontAttributeName: UIFont.tahoma(size: LocalConstants.buttonFontSize),
                NSForegroundColorAttributeName: UIColor.white
                ]),
            for: UIControlState()
        )
        offButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(turnLightOff(_:))))
        
        holderView.addSubview(offButton)
    }
    
    private func addOnButton() {
        onButton.setAttributedTitle(
            NSAttributedString(string: "ON", attributes: [
                NSFontAttributeName: UIFont.tahoma(size: LocalConstants.buttonFontSize),
                NSForegroundColorAttributeName: UIColor.white
                ]),
            for: UIControlState()
        )
        onButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(turnLightOn(_:))))
        
        holderView.addSubview(onButton)
    }
    
    private func setupConstraints() {
        holderView.snp.makeConstraints { (make) in
            make.height.equalTo(LocalConstants.holderViewHeight)
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.centerY.equalToSuperview()
        }
        
        slider.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.itemPadding)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.sliderHeight)
        }
        
        offButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.width.equalTo(LocalConstants.buttonWidth)
            make.height.equalTo(LocalConstants.buttonHeight)
            make.bottom.equalToSuperview()
        }
        
        onButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.width.equalTo(LocalConstants.buttonWidth)
            make.height.equalTo(LocalConstants.buttonHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    // TODO: big slider za zavesu
    // MARK: - Logic
    @objc private func sliderValueChanged(_ sender: UISlider) {
        
        if let device = self.device {
            let row = sender.tag
            device.currentValue = NSNumber(value: Int(slider.value * 255))   // device value is Int, 0 to 255 (0x00 to 0xFF)
            
            let indexPath: IndexPath = IndexPath(row: row, section: 0)
            
            var baseDeviceCollection: UICollectionView?
            
            if let dvc = self.parent as? DevicesViewController {
                baseDeviceCollection = dvc.deviceCollectionView
            } else if let fdvc = self.parent as? FavoriteDevicesVC {
                baseDeviceCollection = fdvc.deviceCollectionView
            }
            
            if let deviceCollectionView = baseDeviceCollection {
                if let cell = deviceCollectionView.cellForItem(at: indexPath) as? BaseDeviceCollectionViewCell {
                    cell.reloadDeviceCell(at: row)
                }
            }

        }
    }
    
    @objc private func turnLightOn(_ gestureRecognizer: UIGestureRecognizer) {
        sliderSetOnOff(gestureRecognizer, turnOff: false)
    }
    
    @objc private func turnLightOff(_ gestureRecognizer: UIGestureRecognizer) {
        sliderSetOnOff(gestureRecognizer, turnOff: true)
    }
    
    private func sliderSetOnOff(_ sender: UIGestureRecognizer, turnOff: Bool) {
        if let device = self.device {
            if device.controlType == ControlType.Dimmer {
                let setDeviceValue: Byte = turnOff ? 0 : 100
                let skipLevel: Byte = turnOff ? 0 : device.skipState.byteValue
                
                if turnOff {
                    device.oldValue = device.currentValue
                }
                
                let deviceCurrentValue = device.currentValue.intValue
                device.currentValue = NSNumber(value: Int(setDeviceValue)*255/100)
                
                DispatchQueue.main.async(execute: {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: setDeviceValue),
                        oldValue: NSNumber(value: deviceCurrentValue)
                    )
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: setDeviceValue, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: skipLevel),
                        gateway: device.gateway,
                        device: device,
                        oldValue: deviceCurrentValue,
                        command: NSNumber(value: setDeviceValue)
                    )
                })
            }
        }
    }
    
    @objc private func sliderStarted(_ sender: UISlider) {
        if let device = self.device {
            sliderOldValue = device.currentValue.intValue
            self.setDeviceInControlMode(to: true)
        }
    }
    
    func sliderTapped(_ gestureRecognizer :UIGestureRecognizer) {
        if let s = gestureRecognizer.view as? UISlider {
            if s.isHighlighted { return } // tap on thumb, let slider deal with it
            
            let pt:CGPoint           = gestureRecognizer.location(in: s)
            let percentage:CGFloat   = pt.x / s.bounds.size.width
            let delta:CGFloat        = percentage * (CGFloat(s.maximumValue) - CGFloat(s.minimumValue))
            let value:CGFloat        = CGFloat(s.minimumValue) + delta
            
            s.setValue(Float(value), animated: true)
            
            sliderValueChanged(slider)
        }
        
    }
    
    @objc fileprivate func sliderEnded(_ sender: UISlider) {
        if let device = self.device {
            let valueToSet: Byte = UInt8(Int(device.currentValue.doubleValue * (100/255)))
            
            device.increaseUsageCounterValue()
            
            if let sliderOldValue = sliderOldValue {
                DispatchQueue.main.async {
                    RunnableList.sharedInstance.checkForSameDevice(
                        device: device.objectID,
                        newCommand: NSNumber(value: valueToSet),
                        oldValue: NSNumber(value: sliderOldValue)
                    )
                    
                    _ = RepeatSendingHandler(
                        byteArray: OutgoingHandler.setLightRelayStatus(device.moduleAddress, channel: device.channel.byteValue, value: valueToSet, delay: device.delay.intValue, runningTime: device.runtime.intValue, skipLevel: device.skipState.byteValue),
                        gateway: device.gateway,
                        device: device,
                        oldValue: sliderOldValue,
                        command: NSNumber(value: valueToSet)
                    )
                }
            }
            
            sliderOldValue = 0
            self.setDeviceInControlMode(to: false)
        }
    }
    
    private func setDeviceInControlMode(to state: Bool) {
        if let dvc = self.parent as? DevicesViewController {
            dvc.deviceInControlMode = state
        } else if let dvc = self.parent as? FavoriteDevicesVC {
            dvc.deviceInControlMode = state
        }
    }
}

extension UIViewController {
    func showBigSliderViewController(for device: Device, at index: Int) {
        let viewController: DimmerBigSliderViewController = DimmerBigSliderViewController(device: device, tag: index)
        viewController.modalPresentationStyle = UIModalPresentationStyle.custom
        
        self.present(viewController, animated: true, completion: nil)        
    }
}
