//
//  DeviceCollectionView+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/3/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if devices[(indexPath as NSIndexPath).row].isEnabled.boolValue {
            if devices[(indexPath as NSIndexPath).row].controlType == ControlType.Climate {
                showClimaSettings((indexPath as NSIndexPath).row, devices: devices)
                
                // Dumb solution for the climate mode icon issue, but it'll work until we find the correct fix
                self.deviceCollectionView.reloadData()
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellSize.width, height: collectionViewCellSize.height)
    }
}

extension DevicesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func updateDeviceStatus (indexPathRow: Int) {
        for device in devices {
            if device.gateway == devices[indexPathRow].gateway && device.address == devices[indexPathRow].address {
                device.stateUpdatedAt = Date()
            }
        }
        let address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)), UInt8(Int(devices[indexPathRow].gateway.addressTwo)), UInt8(Int(devices[indexPathRow].address))]
        if devices[indexPathRow].controlType == ControlType.Dimmer {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].controlType == ControlType.Relay {

            SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].controlType == ControlType.Climate {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getACStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].controlType == ControlType.Sensor || devices[indexPathRow].controlType == ControlType.IntelligentSwitch || devices[indexPathRow].controlType == ControlType.Gateway {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getSensorState(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].controlType == ControlType.Curtain {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: devices[indexPathRow].gateway)
        }
// TODO: CHECK
        if devices[indexPathRow].controlType == ControlType.SaltoAccess {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState(address, lockId: devices[indexPathRow].channel.intValue), gateway: devices[indexPathRow].gateway)
        }
        
        CoreDataController.shahredInstance.saveChanges()
    }
    func refreshVisibleDevicesInScrollView () {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            updateDeviceStatus (indexPathRow: (indexPath as NSIndexPath).row)
        }        
    }
    
    func refreshCollectionView() {
        deviceCollectionView.reloadData()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if let collectionView = scrollView as? UICollectionView {
                let indexPaths = collectionView.indexPathsForVisibleItems
                for indexPath in indexPaths {
                    if let stateUpdatedAt = devices[(indexPath as NSIndexPath).row].stateUpdatedAt as Date? {
                        if let hourValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayHours) as? Int, let minuteValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayMinutes) as? Int {
                            let minutes = (hourValue * 60 + minuteValue) * 60
                            if Date().timeIntervalSince(stateUpdatedAt.addingTimeInterval(TimeInterval(NSNumber(value: minutes as Int)))) >= 0 {
                                updateDeviceStatus (indexPathRow: (indexPath as NSIndexPath).row)
                            }
                        }
                    } else {
                        updateDeviceStatus (indexPathRow: (indexPath as NSIndexPath).row)
                    }
                }
                
            }
            if shouldUpdate {
                shouldUpdate = false
            }
            isScrolling = false
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            let indexPaths = collectionView.indexPathsForVisibleItems
            for indexPath in indexPaths {
                if let stateUpdatedAt = devices[(indexPath as NSIndexPath).row].stateUpdatedAt as Date? {
                    if let hourValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayHours) as? Int, let minuteValue = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayMinutes) as? Int {
                        let minutes = (hourValue * 60 + minuteValue) * 60
                        if Date().timeIntervalSince(stateUpdatedAt.addingTimeInterval(TimeInterval(NSNumber(value: minutes as Int)))) >= 0 {
                            updateDeviceStatus (indexPathRow: (indexPath as NSIndexPath).row)
                        }
                    }
                } else {
                    updateDeviceStatus (indexPathRow: (indexPath as NSIndexPath).row)
                }
            }
        }
        if shouldUpdate {
            shouldUpdate = false
        }
        isScrolling = false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if devices[indexPath.row].controlType == ControlType.Dimmer {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DeviceCollectionCell
            // Set cell data
            cell.getDevice(devices[indexPath.row])
            
            cell.typeOfLight.text = devices[indexPath.row].cellTitle
            cell.typeOfLight.tag = indexPath.row
            
            cell.lightSlider.isContinuous = true
            cell.lightSlider.tag = indexPath.row
            
            let deviceValue:Double = {
                return Double(devices[indexPath.row].currentValue)///255
            }()
            
            cell.picture.image = devices[indexPath.row].returnImage(Double(devices[indexPath.row].currentValue))
            cell.lightSlider.value = Float(deviceValue)/255 // Slider accepts values 0-1
            cell.picture.isUserInteractionEnabled = true
            cell.picture.tag = indexPath.row
            
            cell.lblElectricity.text = "\(Float(devices[indexPath.row].current) * 0.01) A"
            cell.lblVoltage.text = "\(Float(devices[indexPath.row].voltage)) V"
            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            cell.labelRunningTime.text = devices[indexPath.row].runningTime
            
            if devices[indexPath.row].info {
                cell.infoView.isHidden = false
                cell.backView.isHidden = true
            }else {
                cell.infoView.isHidden = true
                cell.backView.isHidden = false
            }
            
            if devices[indexPath.row].warningState == 0 {
                cell.backView.colorTwo = Colors.MediumGray                
            } else if devices[indexPath.row].warningState == 1 {
                // Uppet state
                cell.backView.colorTwo = Colors.DirtyRedColor
                
            } else if devices[indexPath.row].warningState == 2 {
                // Lower state
                cell.backView.colorTwo = Colors.DirtyBlueColor
            }
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                cell.typeOfLight.isUserInteractionEnabled = true
                
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.cellParametarLongPress(_:)))
                longPress.minimumPressDuration = 0.5
                cell.typeOfLight.addGestureRecognizer(longPress)
                
                let oneTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap(_:)))
                oneTap.numberOfTapsRequired = 2
                cell.typeOfLight.addGestureRecognizer(oneTap)
                
                cell.lightSlider.addTarget(self, action: #selector(DevicesViewController.changeSliderValue(_:)), for: .valueChanged)
                cell.lightSlider.addTarget(self, action: #selector(DevicesViewController.changeSliderValueEnded(_:)), for:  UIControlEvents.touchUpInside)
                cell.lightSlider.addTarget(self, action: #selector(DevicesViewController.changeSliderValueStarted(_:)), for: UIControlEvents.touchDown)
                cell.lightSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.changeSliderValueOnOneTap(_:))))
                
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.oneTap(_:)))
                
                let lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.longTouch(_:)))
                lpgr.minimumPressDuration = 0.5
                lpgr.delegate = self
                
                cell.picture.addGestureRecognizer(lpgr)
                cell.picture.addGestureRecognizer(tap)
                
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap2(_:))))
                
                cell.disabledCellView.isHidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.isHidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            return cell
        }
        else if devices[indexPath.row].controlType == ControlType.Curtain {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "curtainCell", for: indexPath) as! CurtainCollectionCell
                        
            cell.curtainName.text = devices[indexPath.row].cellTitle
            cell.curtainImage.tag = indexPath.row
            cell.openButton.tag = indexPath.row
            cell.closeButton.tag = indexPath.row
            
            cell.setImageForDevice(devices[indexPath.row])
        
            cell.curtainName.isUserInteractionEnabled = true
            cell.curtainImage.isUserInteractionEnabled = true
            
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                let curtainOpenTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.openCurtain(_:)))
                let curtainCloseTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.closeCurtain(_:)))
                let curtainStopTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.stopCurtain(_:)))
                
                cell.openButton.addGestureRecognizer(curtainOpenTap)
                cell.closeButton.addGestureRecognizer(curtainCloseTap)
                cell.curtainImage.addGestureRecognizer(curtainStopTap)
                
//                let curtainNameTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap(_:)))
//                curtainNameTap.numberOfTapsRequired = 2
                cell.curtainName.tag = (indexPath as NSIndexPath).row
//                cell.curtainName.addGestureRecognizer(curtainNameTap)
                
                let curtainNameLongPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.cellParametarLongPress(_:)))
                curtainNameLongPress.minimumPressDuration = 0.5
                cell.curtainName.addGestureRecognizer(curtainNameLongPress)
                
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap2(_:))))

                cell.disabledCellView.isHidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.isHidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            
            if devices[(indexPath as NSIndexPath).row].info {
                cell.infoView.isHidden = false
                cell.backView.isHidden = true
            }else {
                cell.infoView.isHidden = true
                cell.backView.isHidden = false
            }
            
            return cell
        }
        else if devices[(indexPath as NSIndexPath).row].controlType == ControlType.SaltoAccess {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "saltoAccessCell", for: indexPath) as! SaltoAccessCell
            cell.saltoName.text = devices[indexPath.row].cellTitle
            cell.saltoImage.tag = (indexPath as NSIndexPath).row
            cell.unlockButton.tag = (indexPath as NSIndexPath).row
            cell.lockButton.tag = (indexPath as NSIndexPath).row
            
            cell.saltoName.isUserInteractionEnabled = true
            cell.saltoImage.isUserInteractionEnabled = true
            cell.refreshDevice(devices[(indexPath).row])
            // If device is enabled add all interactions
            if devices[(indexPath as NSIndexPath).row].isEnabled.boolValue {
                let saltoOpenTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.unlockSalto(_:)))
                let saltoCloseTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.lockSalto(_:)))
                let saltoStopTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.thirdFcnSalto(_:)))
                
                cell.unlockButton.addGestureRecognizer(saltoOpenTap)
                cell.lockButton.addGestureRecognizer(saltoCloseTap)
                cell.saltoImage.addGestureRecognizer(saltoStopTap)
                
                //                let curtainNameTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap(_:)))
                //                curtainNameTap.numberOfTapsRequired = 2
                cell.saltoName.tag = (indexPath as NSIndexPath).row
                //                cell.curtainName.addGestureRecognizer(curtainNameTap)
                
                let curtainNameLongPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.cellParametarLongPress(_:)))
                curtainNameLongPress.minimumPressDuration = 0.5
                cell.saltoName.addGestureRecognizer(curtainNameLongPress)
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap2(_:))))
                
                cell.disabledCellView.isHidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.isHidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            
            if devices[(indexPath as NSIndexPath).row].info {
                cell.infoView.isHidden = false
                cell.backView.isHidden = true
            }else {
                cell.infoView.isHidden = true
                cell.backView.isHidden = false
            }
            
            return cell
        }
        else if devices[indexPath.row].controlType == ControlType.Relay || devices[indexPath.row].controlType == ControlType.DigitalOutput {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "applianceCell", for: indexPath) as! ApplianceCollectionCell
            
            cell.name.text = devices[indexPath.row].cellTitle
            cell.name.tag = indexPath.row
            
            let deviceValue:Double = {
                return Double(devices[indexPath.row].currentValue)
            }()
            
            cell.image.image = devices[indexPath.row].returnImage(Double(devices[indexPath.row].currentValue))
            
            if deviceValue == 255 {
                cell.onOff.setTitle("ON", for: UIControlState())
            } else if devices[indexPath.row].currentValue == 0 {
                cell.onOff.setTitle("OFF", for: UIControlState())
            }
            cell.onOff.tag = indexPath.row
            
            if devices[indexPath.row].info {
                cell.infoView.isHidden = false
                cell.backView.isHidden = true
            }else {
                cell.infoView.isHidden = true
                cell.backView.isHidden = false
            }
            
            cell.labelRunningTime.text = "\(devices[indexPath.row].runningTime)"
            cell.lblElectricity.text = "\(Float(devices[indexPath.row].current) * 0.01) A"
            cell.lblVoltage.text = "\(Float(devices[indexPath.row].voltage)) V"
            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            
            
            // If device is enabled add all interactions
            if devices[(indexPath as NSIndexPath).row].isEnabled.boolValue {
                cell.name.isUserInteractionEnabled = true
                
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.oneTap(_:)))
                cell.image.tag = indexPath.row
                cell.image.isUserInteractionEnabled = true
                cell.image.addGestureRecognizer(tap)
                
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.cellParametarLongPress(_:)))
                longPress.minimumPressDuration = 0.5
                cell.name.addGestureRecognizer(longPress)
                
                let oneTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap(_:)))
                oneTap.numberOfTapsRequired = 2
                cell.name.addGestureRecognizer(oneTap)
                
//                cell.name.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap(_:))))
                
                let tap1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.oneTap(_:)))
                cell.onOff.isUserInteractionEnabled = true
                cell.onOff.addGestureRecognizer(tap1)
                
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap2(_:))))
                
                cell.btnRefresh.tag = indexPath.row
                cell.btnRefresh.addTarget(self, action: #selector(DevicesViewController.refreshDevice(_:)), for:  UIControlEvents.touchUpInside)
                
                cell.disabledCellView.isHidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.isHidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            
            return cell
            
        }
        else if devices[indexPath.row].controlType == ControlType.Climate {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "climaCell", for: indexPath) as! ClimateCell
            
            cell.energySavingImage.isHidden = devices[indexPath.row].allowEnergySaving == NSNumber(value: true) ? false : true
            
            cell.climateName.text = devices[indexPath.row].cellTitle
            cell.climateName.tag = (indexPath as NSIndexPath).row
            
            cell.temperature.font = UIFont(name: "Tahoma", size: 17)
            cell.temperature.text = "\(devices[indexPath.row].roomTemperature) \u{00B0}c"
            
            cell.temperatureSetPoint.font = UIFont(name: "Tahoma", size: 17)
            cell.temperatureSetPoint.text = "00 \u{00B0}c"
            
            cell.climateMode.text = devices[indexPath.row].mode
            cell.climateSpeed.text = devices[indexPath.row].speed
            
            var fanSpeed = 0.0
            let speedState = devices[indexPath.row].speedState
            
            if devices[indexPath.row].filterWarning {
                cell.backView.colorTwo = Colors.DirtyRedColor
            } else {
                cell.backView.colorTwo = Colors.MediumGray
            }
            
            if devices[indexPath.row].currentValue == 255 {
                switch speedState {
                case "Low":
                    cell.fanSpeedImage.image = UIImage(named: "fanlow")
                    fanSpeed = 1
                case "Med" :
                    cell.fanSpeedImage.image = UIImage(named: "fanmedium")
                    fanSpeed = 0.3
                case "High":
                    cell.fanSpeedImage.image = UIImage(named: "fanhigh")
                    fanSpeed = 0.1
                default:
                    cell.fanSpeedImage.image = UIImage(named: "fanoff")
                    fanSpeed = 0.0
                }
                
                let animationImages:[UIImage] = [UIImage(named: "h1")!, UIImage(named: "h2")!, UIImage(named: "h3")!, UIImage(named: "h4")!, UIImage(named: "h5")!, UIImage(named: "h6")!, UIImage(named: "h7")!, UIImage(named: "h8")!]
                
                let modeState = devices[indexPath.row].modeState
                
                cell.temperatureSetPoint.font = UIFont(name: "Tahoma", size: 17)
                cell.temperatureSetPoint.text = "00 \u{00B0}c"
                
                switch modeState {
                case "Cool":
                    cell.modeImage.stopAnimating()
                    cell.modeImage.image = UIImage(named: "cool")
                    cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) \u{00B0}c"
                case "Heat":
                    cell.modeImage.stopAnimating()
                    cell.modeImage.image = UIImage(named: "heat")
                    cell.temperatureSetPoint.text = "\(devices[indexPath.row].heatTemperature) \u{00B0}c"
                case "Fan":
                    cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) \u{00B0}c"
                    if fanSpeed == 0 {
                        cell.modeImage.image = UIImage(named: "fanauto")
                        cell.modeImage.stopAnimating()
                    } else {
                        //
                        cell.modeImage.image = animationImages.first
                        //
                        cell.modeImage.animationImages = animationImages
                        cell.modeImage.animationDuration = TimeInterval(fanSpeed)
                        cell.modeImage.animationRepeatCount = 0
                        cell.modeImage.startAnimating()
                    }
                default:
                    cell.modeImage.stopAnimating()
                    cell.modeImage.image = nil
                    let mode = devices[(indexPath as NSIndexPath).row].mode
                    switch mode {
                    case "Cool":
                        cell.temperatureSetPoint.text = "\(devices[(indexPath as NSIndexPath).row].coolTemperature) \u{00B0}c"
                    case "Heat":
                        cell.temperatureSetPoint.text = "\(devices[(indexPath as NSIndexPath).row].heatTemperature) \u{00B0}c"
                    case "Fan":
                        cell.temperatureSetPoint.text = "\(devices[(indexPath as NSIndexPath).row].coolTemperature) \u{00B0}c"
                    default:
                        //  Hoce i tu da zezne
                        cell.temperatureSetPoint.text = "\(devices[(indexPath as NSIndexPath).row].coolTemperature) \u{00B0}c"
                    }
                }
            } else {
                cell.fanSpeedImage.image = UIImage(named: "fanoff")
                cell.modeImage.stopAnimating()
            }
            if devices[(indexPath as NSIndexPath).row].currentValue == 0 {
                cell.imageOnOff.image = UIImage(named: "poweroff")
                cell.modeImage.image = nil
            } else {
                cell.imageOnOff.image = UIImage(named: "poweron")
            }
            
            if devices[indexPath.row].info {
                cell.infoView.isHidden = false
                cell.backView.isHidden = true
            }else {
                cell.infoView.isHidden = true
                cell.backView.isHidden = false
            }
            cell.imageOnOff.tag = indexPath.row
            
            cell.imageOnOff.isUserInteractionEnabled = true
            cell.imageOnOff.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(DevicesViewController.setACPowerStatus(_:))))
            cell.climateName.isUserInteractionEnabled = true
            
            let doublePress = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap(_:)))
            doublePress.numberOfTapsRequired = 2
            cell.climateName.addGestureRecognizer(doublePress)
            
            cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap2(_:))))
            
            let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.cellParametarLongPress(_:)))
            longPress.minimumPressDuration = 0.5
            cell.climateName.addGestureRecognizer(longPress)
            
            // If device is enabled add all interactions
            if devices[(indexPath as NSIndexPath).row].isEnabled.boolValue {
                cell.disabledCellView.isHidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.isHidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            return cell
        }
        else if devices[indexPath.row].controlType == ControlType.Sensor || devices[indexPath.row].controlType == ControlType.IntelligentSwitch || devices[indexPath.row].controlType == ControlType.Gateway || devices[indexPath.row].controlType == ControlType.DigitalInput {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "multiSensorCell", for: indexPath) as! MultiSensorCell
            
            cell.populateCellWithData(devices[indexPath.row], tag: indexPath.row)
            
            // If device is enabled add all interactions
            let longPressOne:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.cellParametarLongPress(_:)))
            longPressOne.minimumPressDuration = 0.5
            
            let longPressTwo:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DevicesViewController.cellParametarLongPress(_:)))
            longPressTwo.minimumPressDuration = 0.5
            cell.disabledCellView.tag = indexPath.row
            
//            let doublePress = UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap(_:)))
//            doublePress.numberOfTapsRequired = 2
//            cell.sensorTitle.addGestureRecognizer(doublePress)
            
            cell.sensorTitle.addGestureRecognizer(longPressOne)
            cell.disabledCellView.addGestureRecognizer(longPressTwo)
            
//            cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DevicesViewController.handleTap2(_:))))
            if devices[indexPath.row].isEnabled.boolValue {
                cell.disabledCellView.isHidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.isHidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dafaultCell", for: indexPath) as! DefaultCell
            cell.defaultLabel.text = ""
            return cell
        }
    }
}
