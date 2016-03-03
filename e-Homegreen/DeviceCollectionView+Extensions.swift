//
//  DeviceCollectionView+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/3/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if devices[indexPath.row].isEnabled.boolValue {
            if devices[indexPath.row].controlType == ControlType.Climate {
                showClimaSettings(indexPath.row, devices: devices)
            }
            //            deviceCollectionView.reloadData()
        }
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionViewCellSize.width, height: collectionViewCellSize.height)
    }
}

extension DevicesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
            
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func updateDeviceStatus (indexPathRow indexPathRow: Int) {
        for device in devices {
            if device.gateway == devices[indexPathRow].gateway && device.address == devices[indexPathRow].address {
                device.stateUpdatedAt = NSDate()
            }
        }
        let address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)), UInt8(Int(devices[indexPathRow].gateway.addressTwo)), UInt8(Int(devices[indexPathRow].address))]
        if devices[indexPathRow].controlType == ControlType.Dimmer {
            print("\(devices[indexPathRow].channel)---\(devices[indexPathRow].name)---\(devices[indexPathRow].controlType)---\(devices[indexPathRow].stateUpdatedAt)")
            SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].controlType == ControlType.Relay {
            print("\(devices[indexPathRow].channel)---\(devices[indexPathRow].name)---\(devices[indexPathRow].controlType)---\(devices[indexPathRow].stateUpdatedAt)")
            SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].controlType == ControlType.Climate {
            print("\(devices[indexPathRow].channel)---\(devices[indexPathRow].name)---\(devices[indexPathRow].controlType)---\(devices[indexPathRow].stateUpdatedAt)")
            SendingHandler.sendCommand(byteArray: Function.getACStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].controlType == ControlType.Sensor || devices[indexPathRow].controlType == ControlType.HumanInterfaceSeries || devices[indexPathRow].controlType == ControlType.Gateway {
            print("\(devices[indexPathRow].channel)---\(devices[indexPathRow].name)---\(devices[indexPathRow].controlType)---\(devices[indexPathRow].stateUpdatedAt)")
            SendingHandler.sendCommand(byteArray: Function.getSensorState(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].controlType == ControlType.Curtain {
            SendingHandler.sendCommand(byteArray: Function.getCurtainStatus(address), gateway: devices[indexPathRow].gateway)
        }
        saveChanges()
    }
    func refreshVisibleDevicesInScrollView () {
        if let indexPaths = deviceCollectionView.indexPathsForVisibleItems() as? [NSIndexPath] {
            print(indexPaths.count)
            for indexPath in indexPaths {
                updateDeviceStatus (indexPathRow: indexPath.row)
            }
        }
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging willDecelerate \(decelerate)")
        if !decelerate {
            if let collectionView = scrollView as? UICollectionView {
                if let indexPaths = collectionView.indexPathsForVisibleItems() as? [NSIndexPath] {
                    for indexPath in indexPaths {
                        if let stateUpdatedAt = devices[indexPath.row].stateUpdatedAt as NSDate? {
                            if let hourValue = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayHours) as? Int, let minuteValue = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayMinutes) as? Int {
                                let minutes = (hourValue * 60 + minuteValue) * 60
                                if NSDate().timeIntervalSinceDate(stateUpdatedAt.dateByAddingTimeInterval(NSTimeInterval(NSNumber(integer: minutes)))) >= 0 {
                                    updateDeviceStatus (indexPathRow: indexPath.row)
                                }
                            }
                        } else {
                            updateDeviceStatus (indexPathRow: indexPath.row)
                        }
                    }
                }
            }
            if shouldUpdate {
                //            fetchDevicesInBackground()
                //            updateDeviceList()
                //                self.deviceCollectionView.reloadData()
                shouldUpdate = false
            }
            isScrolling = false
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        if let collectionView = scrollView as? UICollectionView {
            if let indexPaths = collectionView.indexPathsForVisibleItems() as? [NSIndexPath] {
                for indexPath in indexPaths {
                    if let stateUpdatedAt = devices[indexPath.row].stateUpdatedAt as NSDate? {
                        if let hourValue = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayHours) as? Int, let minuteValue = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayMinutes) as? Int {
                            let minutes = (hourValue * 60 + minuteValue) * 60
                            if NSDate().timeIntervalSinceDate(stateUpdatedAt.dateByAddingTimeInterval(NSTimeInterval(NSNumber(integer: minutes)))) >= 0 {
                                updateDeviceStatus (indexPathRow: indexPath.row)
                            }
                        }
                    } else {
                        updateDeviceStatus (indexPathRow: indexPath.row)
                    }
                }
            }
        }
        if shouldUpdate {
            //            fetchDevicesInBackground()
            //            updateDeviceList()
            //            self.deviceCollectionView.reloadData()
            shouldUpdate = false
        }
        isScrolling = false
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if devices[indexPath.row].controlType == ControlType.Dimmer {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DeviceCollectionCell
            cell.getDevice(devices[indexPath.row])
//            cell.typeOfLight.text = returnNameForDeviceAccordingToFilter(devices[indexPath.row])
//                        cell.typeOfLight.text = devices[indexPath.row].name
//            print(devices[indexPath.row].cellTitle)
            cell.typeOfLight.text = devices[indexPath.row].cellTitle
            cell.typeOfLight.tag = indexPath.row
            cell.lightSlider.continuous = true
            cell.lightSlider.tag = indexPath.row
            let deviceValue:Double = {
                if Double(devices[indexPath.row].currentValue) > 100 {
                    return Double(devices[indexPath.row].currentValue) / 255
                } else {
                    return Double(devices[indexPath.row].currentValue) / 100
                }
            }()
            if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: deviceValue, motionSensor: false) {
                cell.picture.image = image
            } else {
                if deviceValue == 0 {
                    cell.picture.image = UIImage(named: "lightBulb")
                } else if deviceValue > 0 && deviceValue < 0.1 {
                    cell.picture.image = UIImage(named: "lightBulb1")
                } else if deviceValue >= 0.1 && deviceValue < 0.2 {
                    cell.picture.image = UIImage(named: "lightBulb2")
                } else if deviceValue >= 0.2 && deviceValue < 0.3 {
                    cell.picture.image = UIImage(named: "lightBulb3")
                } else if deviceValue >= 0.3 && deviceValue < 0.4 {
                    cell.picture.image = UIImage(named: "lightBulb4")
                } else if deviceValue >= 0.4 && deviceValue < 0.5 {
                    cell.picture.image = UIImage(named: "lightBulb5")
                } else if deviceValue >= 0.5 && deviceValue < 0.6 {
                    cell.picture.image = UIImage(named: "lightBulb6")
                } else if deviceValue >= 0.6 && deviceValue < 0.7 {
                    cell.picture.image = UIImage(named: "lightBulb7")
                } else if deviceValue >= 0.7 && deviceValue < 0.8 {
                    cell.picture.image = UIImage(named: "lightBulb8")
                } else if deviceValue >= 0.8 && deviceValue < 0.9 {
                    cell.picture.image = UIImage(named: "lightBulb9")
                } else {
                    cell.picture.image = UIImage(named: "lightBulb10")
                }
            }
            cell.lightSlider.value = Float(deviceValue)
            cell.picture.userInteractionEnabled = true
            cell.picture.tag = indexPath.row
            cell.lblElectricity.text = "\(Float(devices[indexPath.row].current) * 0.01) A"
            cell.lblVoltage.text = "\(Float(devices[indexPath.row].voltage)) V"
            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            cell.labelRunningTime.text = devices[indexPath.row].runningTime
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
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
                cell.typeOfLight.userInteractionEnabled = true
                
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
                longPress.minimumPressDuration = 0.5
                cell.typeOfLight.addGestureRecognizer(longPress)
                
                let doubleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
                doubleTap.numberOfTapsRequired = 2
                cell.typeOfLight.addGestureRecognizer(doubleTap)
                
                let oneTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
                oneTap.numberOfTapsRequired = 1
                oneTap.requireGestureRecognizerToFail(doubleTap)
                cell.typeOfLight.addGestureRecognizer(oneTap)
                
                
                
                cell.lightSlider.addTarget(self, action: "changeSliderValue:", forControlEvents: .ValueChanged)
                cell.lightSlider.addTarget(self, action: "changeSliderValueEnded:", forControlEvents:  UIControlEvents.TouchUpInside)
                cell.lightSlider.addTarget(self, action: "changeSliderValueStarted:", forControlEvents: UIControlEvents.TouchDown)
                cell.lightSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "changeSliderValueOnOneTap:"))
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                let lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longTouch:")
                lpgr.minimumPressDuration = 0.5
                lpgr.delegate = self
                cell.picture.addGestureRecognizer(lpgr)
                cell.picture.addGestureRecognizer(tap)
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
                //                cell.btnRefresh.tag = indexPath.row
                ////                let tap = UITapGestureRecognizer(target: self, action: "refreshDevice:")
                //                cell.btnRefresh.userInteractionEnabled = true
                ////                cell.btnRefresh.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "refreshDevice:"))
                //                cell.btnRefresh.addTarget(self, action: "refreshDevice:", forControlEvents:  UIControlEvents.TouchUpInside)
                cell.disabledCellView.hidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.hidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            return cell
        } else if devices[indexPath.row].type == ControlType.Curtain {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("curtainCell", forIndexPath: indexPath) as! CurtainCollectionCell
//            cell.curtainName.text = returnNameForDeviceAccordingToFilter(devices[indexPath.row])
//                        cell.curtainName.text = devices[indexPath.row].name
            cell.curtainName.text = devices[indexPath.row].cellTitle
            cell.curtainImage.tag = indexPath.row
            cell.curtainSlider.tag = indexPath.row
            let deviceValue:Double = {
                if Double(devices[indexPath.row].currentValue) > 100 {
                    return Double(devices[indexPath.row].currentValue) / 255
                } else {
                    return Double(devices[indexPath.row].currentValue) / 100
                }
            }()
            print(devices[indexPath.row].categoryId)
            print(deviceValue)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                if let image = ImageHandler.returnPictures(Int(self.devices[indexPath.row].categoryId), deviceValue: deviceValue, motionSensor: false) {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.curtainImage.image = image
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        if deviceValue == 0 {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 00")
                        } else if deviceValue <= 1/3 {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 01")
                        } else if deviceValue <= 2/3 {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 02")
                        } else if deviceValue < 3/3 {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 03")
                        } else {
                            cell.curtainImage.image = UIImage(named: "13 Curtain - Curtain - 04")
                        }
                    })
                }
            })
            cell.curtainName.userInteractionEnabled = true
            cell.curtainSlider.value = Float(deviceValue)
            cell.curtainImage.userInteractionEnabled = true
            
//            cell.labelRunningTime.text = "\(devices[indexPath.row].runningTime)"
//            cell.lblElectricity.text = "\(Float(devices[indexPath.row].current) * 0.01) A"
//            cell.lblVoltage.text = "\(Float(devices[indexPath.row].voltage)) V"
//            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            cell.lblAddress.text = "\(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].address)))"
            cell.lblLevel.text = "\(DatabaseHandler.returnZoneWithId(Int(devices[indexPath.row].parentZoneId), gateway: devices[indexPath.row].gateway))"
            cell.lblZone.text = "\(DatabaseHandler.returnZoneWithId(Int(devices[indexPath.row].zoneId), gateway: devices[indexPath.row].gateway))"
            cell.lblCategory.text = "\(DatabaseHandler.returnCategoryWithId(Int(devices[indexPath.row].categoryId), gateway: devices[indexPath.row].gateway))"

            
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                cell.curtainSlider.addTarget(self, action: "changeSliderValue:", forControlEvents: .ValueChanged)
                cell.curtainSlider.addTarget(self, action: "changeSliderValueStarted:", forControlEvents: UIControlEvents.TouchDown)
                cell.curtainSlider.addTarget(self, action: "changeSliderValueEnded:", forControlEvents:  UIControlEvents.TouchUpInside)
                cell.curtainSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "changeSliderValueOnOneTap:"))
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                let lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longTouch:")
                lpgr.minimumPressDuration = 0.5
                lpgr.delegate = self
                cell.curtainImage.addGestureRecognizer(lpgr)
                cell.curtainImage.addGestureRecognizer(tap)
                cell.curtainName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
                longPress.minimumPressDuration = 0.5
                cell.curtainName.addGestureRecognizer(longPress)
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
//                cell.btnRefresh.tag = indexPath.row
                //                cell.btnRefresh.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "refreshDevice:"))
//                cell.btnRefresh.addTarget(self, action: "refreshDevice:", forControlEvents:  UIControlEvents.TouchUpInside)
                cell.disabledCellView.hidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.hidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
            }
            
            return cell
        } else if devices[indexPath.row].controlType == ControlType.Relay || devices[indexPath.row].controlType == ControlType.Curtain {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("applianceCell", forIndexPath: indexPath) as! ApplianceCollectionCell
//            cell.name.text = returnNameForDeviceAccordingToFilter(devices[indexPath.row])
//                        cell.name.text = devices[indexPath.row].name
                        cell.name.text = devices[indexPath.row].cellTitle
            cell.name.tag = indexPath.row
            let deviceValue:Double = {
                if Double(devices[indexPath.row].currentValue) == 100 {
                    return Double(devices[indexPath.row].currentValue)/100
                } else {
                    return Double(devices[indexPath.row].currentValue)/255
                }
            }()
            if let image = ImageHandler.returnPictures(Int(devices[indexPath.row].categoryId), deviceValue: deviceValue, motionSensor: false) {
                cell.image.image = image
            } else {
                if devices[indexPath.row].currentValue == 255 {
                    cell.image.image = UIImage(named: "applianceon")
                }
                if devices[indexPath.row].currentValue == 0{
                    cell.image.image = UIImage(named: "applianceoff")
                }
            }
            if deviceValue == 1 {
                cell.onOff.setTitle("ON", forState: .Normal)
            } else if devices[indexPath.row].currentValue == 0 {
                cell.onOff.setTitle("OFF", forState: .Normal)
            }
            cell.onOff.tag = indexPath.row
            
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
            }
            
            cell.labelRunningTime.text = "\(devices[indexPath.row].runningTime)"
            cell.lblElectricity.text = "\(Float(devices[indexPath.row].current) * 0.01) A"
            cell.lblVoltage.text = "\(Float(devices[indexPath.row].voltage)) V"
            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            
            
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                cell.name.userInteractionEnabled = true
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                cell.image.tag = indexPath.row
                cell.image.userInteractionEnabled = true
                cell.image.addGestureRecognizer(tap)
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
                longPress.minimumPressDuration = 0.5
                cell.name.addGestureRecognizer(longPress)
                cell.name.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                let tap1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                cell.onOff.userInteractionEnabled = true
                cell.onOff.addGestureRecognizer(tap1)
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
                cell.btnRefresh.tag = indexPath.row
                //                cell.btnRefresh.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "refreshDevice:"))
                cell.btnRefresh.addTarget(self, action: "refreshDevice:", forControlEvents:  UIControlEvents.TouchUpInside)
                cell.disabledCellView.hidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.hidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            
            return cell
            
        } else if devices[indexPath.row].controlType == ControlType.Climate {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("climaCell", forIndexPath: indexPath) as! ClimateCell
            cell.energySavingImage.hidden = devices[indexPath.row].allowEnergySaving == NSNumber(bool: true) ? false : true
//            cell.climateName.text = returnNameForDeviceAccordingToFilter(devices[indexPath.row])
//                        cell.climateName.text = devices[indexPath.row].name
            cell.climateName.text = devices[indexPath.row].cellTitle
            cell.climateName.tag = indexPath.row
            cell.temperature.font = UIFont(name: "DBLCDTempBlack", size: 16)
            cell.temperature.text = "\(devices[indexPath.row].roomTemperature) \u{00B0}c"
            cell.temperatureSetPoint.font = UIFont(name: "DBLCDTempBlack", size: 16)
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
                cell.temperatureSetPoint.font = UIFont(name: "DBLCDTempBlack", size: 16)
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
                        cell.modeImage.animationImages = animationImages
                        cell.modeImage.animationDuration = NSTimeInterval(fanSpeed)
                        cell.modeImage.animationRepeatCount = 0
                        cell.modeImage.startAnimating()
                    }
                default:
                    cell.modeImage.stopAnimating()
                    cell.modeImage.image = nil
                    let mode = devices[indexPath.row].mode
                    switch mode {
                    case "Cool":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) \u{00B0}c"
                    case "Heat":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].heatTemperature) \u{00B0}c"
                    case "Fan":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) \u{00B0}c"
                    default:
                        //  Hoce i tu da zezne
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) \u{00B0}c"
                    }
                }
            } else {
                cell.fanSpeedImage.image = UIImage(named: "fanoff")
                cell.modeImage.stopAnimating()
            }
            if devices[indexPath.row].currentValue == 0 {
                cell.imageOnOff.image = UIImage(named: "poweroff")
                cell.modeImage.image = nil
            } else {
                cell.imageOnOff.image = UIImage(named: "poweron")
            }
            
            
            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
            }
            cell.imageOnOff.tag = indexPath.row
            cell.imageOnOff.userInteractionEnabled = true
            cell.imageOnOff.addGestureRecognizer(UITapGestureRecognizer(target:self, action:"setACPowerStatus:"))
            cell.climateName.userInteractionEnabled = true
            cell.climateName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
            cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
            
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                cell.disabledCellView.hidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.hidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            return cell
        } else if devices[indexPath.row].controlType == ControlType.Sensor || devices[indexPath.row].controlType == ControlType.HumanInterfaceSeries || devices[indexPath.row].controlType == ControlType.Gateway {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("multiSensorCell", forIndexPath: indexPath) as! MultiSensorCell
            cell.populateCellWithData(devices[indexPath.row], tag: indexPath.row)
            // If device is enabled add all interactions
            let longPressOne:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
            longPressOne.minimumPressDuration = 0.5
            let longPressTwo:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
            longPressTwo.minimumPressDuration = 0.5
            cell.disabledCellView.tag = indexPath.row
            cell.sensorTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
            cell.sensorTitle.addGestureRecognizer(longPressOne)
            cell.disabledCellView.addGestureRecognizer(longPressTwo)
            cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
            if devices[indexPath.row].isEnabled.boolValue {
                cell.disabledCellView.hidden = true
                cell.disabledCellView.layer.cornerRadius = 5
            } else {
                cell.disabledCellView.hidden = false
                cell.disabledCellView.layer.cornerRadius = 5
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("dafaultCell", forIndexPath: indexPath) as! DefaultCell
            NSLog("Device:\nGateway name:\(devices[indexPath.row].gateway.name) \n")
            NSLog("Device address:\(devices[indexPath.row].address)")
            NSLog("Device channel:\(devices[indexPath.row].channel) \n")
            NSLog("Device number of devices:\(devices[indexPath.row].numberOfDevices) \n")
            NSLog("Device type:\(devices[indexPath.row].type)")
            NSLog("Device controlType:\(devices[indexPath.row].controlType)")
            cell.defaultLabel.text = "\(devices[indexPath.row].name) "
//            if let a1 = devices[indexPath.row].gateway.name, a2 = devices[indexPath.row].address, a3 = devices[indexPath.row].channel, a4 = devices[indexPath.row].numberOfDevices, a5 = devices[indexPath.row].type, a6 = devices[indexPath.row].controlType {
//                cell.defaultLabel.text = "Device:\nGateway name:\(devices[indexPath.row].gateway.name) \nAddress:\(devices[indexPath.row].address) Channel:\(devices[indexPath.row].channel) \nNumber of devices:\(devices[indexPath.row].numberOfDevices) \nType:\(devices[indexPath.row].type) \nControl type:\(devices[indexPath.row].controlType)"
//                NSLog("Device:\nGateway name:\(devices[indexPath.row].gateway.name) \nDevice address:\(devices[indexPath.row].address) Device channel:\(devices[indexPath.row].channel) \nDevice number of devices:\(devices[indexPath.row].numberOfDevices) \nDevice type:\(devices[indexPath.row].type) Device controlType:\(devices[indexPath.row].controlType)")
//            }
//            NSLog("%@ %@", indexPath.row, devices[indexPath.row])
            return cell
        }
    }
}