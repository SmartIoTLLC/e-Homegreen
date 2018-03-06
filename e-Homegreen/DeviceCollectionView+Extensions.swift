//
//  DeviceCollectionView+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/3/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

// MARK: - Collection View Delegate Flow Layout & Delegate
extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellSize.width, height: collectionViewCellSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let device = devices[indexPath.row]
        
        if device.isEnabled.boolValue {
            if device.controlType == ControlType.Climate {
                showClimaSettings(indexPath.row, devices: devices)
                
                // Dumb solution for the climate mode icon issue, but it'll work until we find the correct fix
                deviceCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

// MARK: - Collection View Data Source
extension DevicesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let device      = devices[indexPath.row]
        let controlType = device.controlType
        let tag         = indexPath.row
        
        switch controlType {
            case ControlType.Dimmer : // MARK: - Device cell
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceCollectionViewCell", for: indexPath) as? DeviceCollectionViewCell {
                    
                    cell.setCell(device: device, tag: tag)
                    
                    // If device is enabled add all interactions
                    if device.isEnabled.boolValue {
                        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellParametarLongPress(_:)))
                        longPress.minimumPressDuration = 0.5
                        cell.typeOfLight.addGestureRecognizer(longPress)
                        
                        let oneTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                        oneTap.numberOfTapsRequired = 2
                        cell.typeOfLight.addGestureRecognizer(oneTap)
                        
                        cell.lightSlider.addTarget(self, action: #selector(changeSliderValue(_:)), for: .valueChanged)
                        cell.lightSlider.addTarget(self, action: #selector(changeSliderValueEnded(_:)), for: .touchUpInside)
                        cell.lightSlider.addTarget(self, action: #selector(changeSliderValueStarted(_:)), for: .touchDown)
                        cell.lightSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeSliderValueOnOneTap(_:))))
                        
                        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(longTouch(_:)))
                        lpgr.minimumPressDuration = 0.5
                        lpgr.delegate = self
                        
                        cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap2(_:))))
                        
                        cell.picture.addGestureRecognizer(lpgr)
                        cell.picture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.oneTap(_:))))
                    }
                    
                    return cell
                }
            case ControlType.Curtain: // MARK: - Curtain cell
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "curtainCollectionViewCell", for: indexPath) as? CurtainCollectionViewCell {
                    cell.setCell(device: device, tag: tag)
                    
                    // If device is enabled add all interactions
                    if device.isEnabled.boolValue {
                        
                        cell.openButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCurtain(_:))))
                        cell.closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeCurtain(_:))))
                        cell.curtainImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stopCurtain(_:))))
                        
                        let curtainNameLongPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.cellParametarLongPress(_:)))
                        curtainNameLongPress.minimumPressDuration = 0.5
                        cell.curtainName.addGestureRecognizer(curtainNameLongPress)
                        
                        cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap2(_:))))
                    }
                    
                    return cell
                }
            case ControlType.SaltoAccess: // MARK: Salto Access cell
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "saltoAccessCollectionViewCell", for: indexPath) as? SaltoAccessCollectionViewCell {
                    cell.setCell(device: device, tag: tag)
                    
                    // If device is enabled add all interactions
                    if device.isEnabled.boolValue {
                        cell.unlockButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unlockSalto(_:))))
                        cell.lockButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lockSalto(_:))))
                        cell.saltoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thirdFcnSalto(_:))))
                        
                        let curtainNameLongPress = UILongPressGestureRecognizer(target: self, action: #selector(cellParametarLongPress(_:)))
                        curtainNameLongPress.minimumPressDuration = 0.5
                        cell.saltoName.addGestureRecognizer(curtainNameLongPress)
                        cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap2(_:))))
                    }
                    
                    return cell
                }
            case ControlType.Relay, ControlType.DigitalOutput: // MARK: - Appliance cell
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "applianceCollectionViewCell", for: indexPath) as? ApplianceCollectionViewCell {
                    cell.setCell(device: device, tag: tag)
                    
                    // If device is enabled add all interactions
                    if device.isEnabled.boolValue {
                        
                        
                        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellParametarLongPress(_:)))
                        longPress.minimumPressDuration = 0.5
                        cell.name.addGestureRecognizer(longPress)
                        
                        let oneTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                        oneTap.numberOfTapsRequired = 2
                        cell.name.addGestureRecognizer(oneTap)
                        
                        cell.image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(oneTap(_:))))
                        cell.onOff.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(oneTap(_:))))
                        cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap2(_:))))
                        cell.btnRefresh.addTarget(self, action: #selector(refreshDevice(_:)), for: .touchUpInside)
                    }
                    
                    return cell
                }
            case ControlType.Climate: // MARK: - Climate cell
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "climateCollectionViewCell", for: indexPath) as? ClimateCollectionViewCell {
                    
                    cell.setCell(device: device, tag: tag)
                    
                    cell.imageOnOff.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(setACPowerStatus(_:))))
                    
                    let doublePress = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                    doublePress.numberOfTapsRequired = 2
                    cell.climateName.addGestureRecognizer(doublePress)
                    
                    cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap2(_:))))
                    
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellParametarLongPress(_:)))
                    longPress.minimumPressDuration = 0.5
                    cell.climateName.addGestureRecognizer(longPress)
                    
                    return cell
                }
            case ControlType.Sensor, ControlType.IntelligentSwitch, ControlType.Gateway, ControlType.DigitalInput: // MARK: - MultiSensor cell
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "multisensorCollectionViewCell", for: indexPath) as? MultisensorCollectionViewCell {
                    
                    cell.setCell(device: device, tag: tag)
                    
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellParametarLongPress(_:)))
                    longPress.minimumPressDuration = 0.5
                    
                    cell.sensorTitle.addGestureRecognizer(longPress)
                    cell.disabledCellView.addGestureRecognizer(longPress)
                    
                    return cell
                }
            
                default:
                    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultDeviceCollectionViewCell", for: indexPath) as? DefaultDeviceCollectionViewCell {
                        cell.defaultLabel.text = ""
                        return cell
                    }
        }
        
        return UICollectionViewCell()
    }
}

// MARK: - Logic
extension DevicesViewController {
    func updateDeviceStatus (indexPathRow: Int) {
        let device      = devices[indexPathRow]
        let controlType = device.controlType
        let gateway     = device.gateway
        let channel     = device.channel.intValue
        
        for d in devices { if d.gateway == device.gateway && d.address == device.address { d.stateUpdatedAt = Date() } }
        
        let address = device.getAddress()
        switch controlType {
            case ControlType.Dimmer,
                 ControlType.Relay       : SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
            case ControlType.Climate     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getACStatus(address), gateway: gateway)
            case ControlType.Sensor,
                 ControlType.IntelligentSwitch,
                 ControlType.Gateway     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getSensorState(address), gateway: gateway)
            case ControlType.Curtain     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: gateway)
            case ControlType.SaltoAccess : SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState(address, lockId: channel), gateway: gateway)
            default: break
        }
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    @objc func refreshVisibleDevicesInScrollView () {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths { updateDeviceStatus (indexPathRow: indexPath.row) }
    }
    
    @objc func refreshCollectionView() {
        deviceCollectionView.reloadData()
    }
}

// MARK: - Scroll View Delegate
extension DevicesViewController {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if let collectionView = scrollView as? UICollectionView {
                let indexPaths = collectionView.indexPathsForVisibleItems
                for indexPath in indexPaths {
                    if let stateUpdatedAt = devices[indexPath.row].stateUpdatedAt as Date? {
                        if let hourValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayHours) as? Int, let minuteValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayMinutes) as? Int {
                            let minutes = (hourValue * 60 + minuteValue) * 60
                            if Date().timeIntervalSince(stateUpdatedAt.addingTimeInterval(TimeInterval(truncating: NSNumber(value: minutes as Int)))) >= 0 { updateDeviceStatus (indexPathRow: indexPath.row) }
                        }
                    } else { updateDeviceStatus (indexPathRow: indexPath.row) }
                }
            }
            
            if shouldUpdate { shouldUpdate = false }
            isScrolling = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            let indexPaths = collectionView.indexPathsForVisibleItems
            for indexPath in indexPaths {
                if let stateUpdatedAt = devices[indexPath.row].stateUpdatedAt as Date? {
                    if let hourValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayHours) as? Int, let minuteValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayMinutes) as? Int {
                        let minutes = (hourValue * 60 + minuteValue) * 60
                        if Date().timeIntervalSince(stateUpdatedAt.addingTimeInterval(TimeInterval(truncating: NSNumber(value: minutes as Int)))) >= 0 { updateDeviceStatus (indexPathRow: indexPath.row) }
                    }
                } else { updateDeviceStatus (indexPathRow: indexPath.row) }
            }
        }
        if shouldUpdate { shouldUpdate = false }
        isScrolling = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrolling = true
    }
}
