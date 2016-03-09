//
//  DefaultDeviceImages.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 3/4/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

//MARK:- Result type
struct DeviceImageState {
    let defaultImage:String
    let state:Int
}

class DefaultDeviceImages: NSObject {
    func getNewImagesForDevice (device:Device) -> [DeviceImageState] {
        
        let categoryId = device.categoryId
        let controlType = device.controlType
        let channel = device.channel
        
        //MARK: Multisensor
        // If multisensor (motion sensor with id 6 in both 10 in 1 and 6 in 1) then return this by default
        if controlType == ControlType.HumanInterfaceSeries && channel == 6  {
            return [DeviceImageState(defaultImage: "14 Security - Motion Sensor - 00", state: DeviceValue.MotionSensor.Idle),
                DeviceImageState(defaultImage: "14 Security - Motion Sensor - 01", state: DeviceValue.MotionSensor.Motion),
                DeviceImageState(defaultImage: "14 Security - Motion Sensor - 02", state: DeviceValue.MotionSensor.IdleWarning),
                DeviceImageState(defaultImage: "14 Security - Motion Sensor - 02", state: DeviceValue.MotionSensor.ResetTimer)]
        }
        
        // MARK: Search by category id
        // First search by caterogy Id (If there is any)
        if categoryId == CategoryId.DimmingControl {
            return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 01", state: 1),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 02", state: 2),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 03", state: 3),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 04", state: 4),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 05", state: 5),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 06", state: 6),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 07", state: 7),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 08", state: 8),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 09", state: 9),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 10)]
        }
        if categoryId == CategoryId.RelayControl {
            return [DeviceImageState(defaultImage: "12 Appliance - Switch - 00", state: 0),
                DeviceImageState(defaultImage: "12 Appliance - Switch - 01", state: 1)]
        }
        if categoryId == CategoryId.ClimateControl {
            return [DeviceImageState(defaultImage: "04 Climate Control - HVAC - 00", state: 0),
                DeviceImageState(defaultImage: "04 Climate Control - HVAC - 01", state: 1)]
        }
        if categoryId == CategoryId.Lighting {
            return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 01", state: 1),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 02", state: 2),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 03", state: 3),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 04", state: 4),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 05", state: 5),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 06", state: 6),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 07", state: 7),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 08", state: 8),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 09", state: 9),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 10)]
        }
        if categoryId == CategoryId.Appliance {
            return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0),
                DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1)]
        }
        if categoryId == CategoryId.Curtain {
            return [DeviceImageState(defaultImage: "13 Curtain - Curtain - 00", state: 0),
                DeviceImageState(defaultImage: "13 Curtain - Curtain - 01", state: 1),
                DeviceImageState(defaultImage: "13 Curtain - Curtain - 02", state: 2),
                DeviceImageState(defaultImage: "13 Curtain - Curtain - 03", state: 3),
                DeviceImageState(defaultImage: "13 Curtain - Curtain - 04", state: 4)]
        }
        if categoryId == CategoryId.Security {
            return [DeviceImageState(defaultImage: "14 Security - Lock - 00", state: 0),
                DeviceImageState(defaultImage: "14 Security - Lock - 01", state: 1)]
        }
        if categoryId == CategoryId.Timer {
            return [DeviceImageState(defaultImage: "15 Timer - CLock - 00", state: 0),
                DeviceImageState(defaultImage: "15 Timer - CLock - 01", state: 1)]
        }
        if categoryId == CategoryId.Flag {
            return [DeviceImageState(defaultImage: "16 Flag - Flag - 00", state: 0),
                DeviceImageState(defaultImage: "16 Flag - Flag - 01", state: 1)]
        }
        if categoryId == CategoryId.Event {
            return [DeviceImageState(defaultImage: "17 Event - Up Down - 00", state: 0),
                DeviceImageState(defaultImage: "17 Event - Up Down - 01", state: 1)]
        }
        if categoryId == CategoryId.Media {
            return [DeviceImageState(defaultImage: "18 Media - LCD TV - 00", state: 0),
                DeviceImageState(defaultImage: "18 Media - LCD TV - 01", state: 1)]
        }
        if categoryId == CategoryId.Blind {
            return [DeviceImageState(defaultImage: "19 Blind - Blind - 00", state: 0),
                DeviceImageState(defaultImage: "19 Blind - Blind - 01", state: 1),
                DeviceImageState(defaultImage: "19 Blind - Blind - 02", state: 2),
                DeviceImageState(defaultImage: "19 Blind - Blind - 03", state: 3),
                DeviceImageState(defaultImage: "19 Blind - Blind - 04", state: 4),
                DeviceImageState(defaultImage: "19 Blind - Blind - 05", state: 5),
                DeviceImageState(defaultImage: "19 Blind - Blind - 06", state: 6)]
        }
        
        // MARK: Search by control type
        // If device has no category id (if device was not scanned for parametars or if gateway returned other) then it should return images and states by control type
        if controlType == ControlType.Dimmer {
            return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 01", state: 1),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 02", state: 2),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 03", state: 3),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 04", state: 4),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 05", state: 5),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 06", state: 6),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 07", state: 7),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 08", state: 8),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 09", state: 9),
                DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 10)]
        }
        if controlType == ControlType.Relay {
            return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0),
                DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1)]
        }
        if controlType == ControlType.Appliance {
            return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0),
                DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1)]
        }
        // For case when sensor is 10 in 1 and when sensor id 6 in 1
        if controlType == ControlType.Sensor {
            return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0),
                DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1)]
        }
        if controlType == ControlType.Gateway {
            return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0),
                DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1)]
        }
        if controlType == ControlType.HumanInterfaceSeries {
            return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0),
                DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1)]
        }
        
        // MARK: If none of above were fulfilled
        // If none of above is fulfilled then return default
        return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0),
            DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1)]
    }
}
