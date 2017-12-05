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
        if devices[indexPath.row].isEnabled.boolValue {
            if devices[indexPath.row].controlType == ControlType.Climate {
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
        if devices[indexPath.row].controlType == ControlType.Dimmer {
            
            // MARK: - Device cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DeviceCollectionCell {
                
                cell.setCell(device: devices[indexPath.row], tag: indexPath.row)
                
                // If device is enabled add all interactions
                if devices[indexPath.row].isEnabled.boolValue {
                    
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
                    
                    cell.picture.addGestureRecognizer(lpgr)
                    cell.picture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.oneTap(_:))))
                }
                
                return cell
            }

            return UICollectionViewCell()
        }
            
        else if devices[indexPath.row].controlType == ControlType.Curtain {
            
            // MARK: - Curtain cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "curtainCell", for: indexPath) as? CurtainCollectionCell {
                cell.setCell(device: devices[indexPath.row], tag: indexPath.row)
                
                // If device is enabled add all interactions
                if devices[indexPath.row].isEnabled.boolValue {
                    
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
                        
            return UICollectionViewCell()
        }
            
        else if devices[indexPath.row].controlType == ControlType.SaltoAccess {
            
            // MARK: Salto Access cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "saltoAccessCell", for: indexPath) as? SaltoAccessCell {
                
                cell.setCell(device: devices[indexPath.row], tag: indexPath.row)
                
                // If device is enabled add all interactions
                if devices[indexPath.row].isEnabled.boolValue {
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
            
            return UICollectionViewCell()
        }
            
        else if devices[indexPath.row].controlType == ControlType.Relay || devices[indexPath.row].controlType == ControlType.DigitalOutput {
            
            // MARK: - Appliance cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "applianceCell", for: indexPath) as? ApplianceCollectionCell {
                cell.setCell(device: devices[indexPath.row], tag: indexPath.row)
                
                // If device is enabled add all interactions
                if devices[indexPath.row].isEnabled.boolValue {
                    
                    
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
            
            return UICollectionViewCell()
        }
            
        else if devices[indexPath.row].controlType == ControlType.Climate {
            
            // MARK: - Climate cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "climaCell", for: indexPath) as? ClimateCell {
                
                cell.setCell(device: devices[indexPath.row], tag: indexPath.row)
                
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
            
            return UICollectionViewCell()
        }
            
        else if devices[indexPath.row].controlType == ControlType.Sensor || devices[indexPath.row].controlType == ControlType.IntelligentSwitch || devices[indexPath.row].controlType == ControlType.Gateway || devices[indexPath.row].controlType == ControlType.DigitalInput {
            
            // MARK: - MultiSensor cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "multiSensorCell", for: indexPath) as? MultiSensorCell {
                
                cell.setCell(device: devices[indexPath.row], tag: indexPath.row)
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellParametarLongPress(_:)))
                longPress.minimumPressDuration = 0.5
                
                cell.sensorTitle.addGestureRecognizer(longPress)
                cell.disabledCellView.addGestureRecognizer(longPress)
                
                return cell
            }
            
            return UICollectionViewCell()
        }
        else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dafaultCell", for: indexPath) as? DefaultCell {
                cell.defaultLabel.text = ""
                return cell
            }
            
            return UICollectionViewCell()
        }
    }
}

// MARK: - Logic
extension DevicesViewController {
    func updateDeviceStatus (indexPathRow: Int) {
        for device in devices { if device.gateway == devices[indexPathRow].gateway && device.address == devices[indexPathRow].address { device.stateUpdatedAt = Date() } }
        
        let address = [getByte(devices[indexPathRow].gateway.addressOne), getByte(devices[indexPathRow].gateway.addressTwo), getByte(devices[indexPathRow].address)]
        
        if devices[indexPathRow].controlType == ControlType.Dimmer { SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway) }
        if devices[indexPathRow].controlType == ControlType.Relay { SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway) }
        if devices[indexPathRow].controlType == ControlType.Climate { SendingHandler.sendCommand(byteArray: OutgoingHandler.getACStatus(address), gateway: devices[indexPathRow].gateway) }
        
        if devices[indexPathRow].controlType == ControlType.Sensor || devices[indexPathRow].controlType == ControlType.IntelligentSwitch || devices[indexPathRow].controlType == ControlType.Gateway {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getSensorState(address), gateway: devices[indexPathRow].gateway)
        }
        
        if devices[indexPathRow].controlType == ControlType.Curtain { SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: devices[indexPathRow].gateway) }
        if devices[indexPathRow].controlType == ControlType.SaltoAccess { SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState(address, lockId: devices[indexPathRow].channel.intValue), gateway: devices[indexPathRow].gateway) } // TODO: CHECK
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func refreshVisibleDevicesInScrollView () {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths { updateDeviceStatus (indexPathRow: indexPath.row) }
    }
    
    func refreshCollectionView() {
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
                            if Date().timeIntervalSince(stateUpdatedAt.addingTimeInterval(TimeInterval(NSNumber(value: minutes as Int)))) >= 0 { updateDeviceStatus (indexPathRow: indexPath.row) }
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
                        if Date().timeIntervalSince(stateUpdatedAt.addingTimeInterval(TimeInterval(NSNumber(value: minutes as Int)))) >= 0 { updateDeviceStatus (indexPathRow: indexPath.row) }
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
