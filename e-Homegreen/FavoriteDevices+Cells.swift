//
//  FavoriteDevices+Cells.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 2/26/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation

extension FavoriteDevicesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let device      = devices[indexPath.row]
        let controlType = device.controlType
        let tag         = indexPath.row
        
        switch controlType {
        case ControlType.Dimmer : // MARK: - Device cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceCell", for: indexPath) as? DeviceCollectionCell {
                
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
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "curtainCell", for: indexPath) as? CurtainCollectionCell {
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
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "saltoAccessCell", for: indexPath) as? SaltoAccessCell {
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
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "applianceCell", for: indexPath) as? ApplianceCollectionCell {
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
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "climaCell", for: indexPath) as? ClimateCell {
                
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
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "multiSensorCell", for: indexPath) as? MultiSensorCell {
                
                cell.setCell(device: device, tag: tag)
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cellParametarLongPress(_:)))
                longPress.minimumPressDuration = 0.5
                
                cell.sensorTitle.addGestureRecognizer(longPress)
                cell.disabledCellView.addGestureRecognizer(longPress)
                
                return cell
            }
            
        default:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dafaultCell", for: indexPath) as? DefaultCell {
                cell.defaultLabel.text = ""
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
}

extension FavoriteDevicesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellSize.width, height: collectionViewCellSize.height)
    }
}
