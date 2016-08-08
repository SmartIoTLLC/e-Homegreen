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
    let text : String?
}

struct DeviceImages {
    
}

class DefaultDeviceImages: NSObject {
    func getNewImagesForDevice (device:Device) -> [DeviceImageState] {
        
        let categoryId = device.categoryId
        let controlType = device.controlType
        let channel = device.channel
        
        switch controlType {
        case ControlType.Dimmer:
            switch categoryId {
            case CategoryId.Blind:
                return [DeviceImageState(defaultImage: "19 Blind - Blind - 00", state: 0, text: nil),
                        DeviceImageState(defaultImage: "19 Blind - Blind - 01", state: 1, text: nil),
                        DeviceImageState(defaultImage: "19 Blind - Blind - 02", state: 2, text: nil),
                        DeviceImageState(defaultImage: "19 Blind - Blind - 03", state: 3, text: nil),
                        DeviceImageState(defaultImage: "19 Blind - Blind - 04", state: 4, text: nil),
                        DeviceImageState(defaultImage: "19 Blind - Blind - 05", state: 5, text: nil),
                        DeviceImageState(defaultImage: "19 Blind - Blind - 06", state: 6, text: nil)]
            case CategoryId.Curtain:
                return [DeviceImageState(defaultImage: "13 Curtain - Curtain - 00", state: 0, text: nil),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 01", state: 1, text: nil),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 02", state: 2, text: nil),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 03", state: 3, text: nil),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 04", state: 4, text: nil)]
            default:
            return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 01", state: 1, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 02", state: 2, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 03", state: 3, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 04", state: 4, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 05", state: 5, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 06", state: 6, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 07", state: 7, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 08", state: 8, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 09", state: 9, text: nil),
                    DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 10, text: nil)]
            }
        case ControlType.Curtain:
            switch categoryId {
            case CategoryId.Blind:
                return [DeviceImageState(defaultImage: "19 Blind - Blind - 00", state: 0, text: nil),
                        DeviceImageState(defaultImage: "19 Blind - Blind - 06", state: 1, text: nil)]
            default:
                return [DeviceImageState(defaultImage: "13 Curtain - Curtain - 00", state: 0, text: nil),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 02", state: 1, text: nil),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 04", state: 2, text: nil)]

            }
            
        default:
            switch categoryId {
                
            case CategoryId.DimmingControl:
                return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 1, text: "On")]

            case CategoryId.RelayControl:
                return [DeviceImageState(defaultImage: "12 Appliance - Switch - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "12 Appliance - Switch - 01", state: 1, text: "On")]

            case CategoryId.ClimateControl:
                return [DeviceImageState(defaultImage: "04 Climate Control - HVAC - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "04 Climate Control - HVAC - 01", state: 1, text: "On")]

            case CategoryId.Lighting:
                return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 1, text: "On")]

            case CategoryId.Appliance:
                return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1, text: "On")]

            case CategoryId.Curtain:
                
                return [DeviceImageState(defaultImage: "13 Curtain - Curtain - 00", state: 0, text: "Close"),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 04", state: 1, text: "Open")]

            case CategoryId.Security:
                return [DeviceImageState(defaultImage: "14 Security - Lock - 00", state: 0, text: "Locked"),
                        DeviceImageState(defaultImage: "14 Security - Lock - 01", state: 1, text: "Unlocked")]

            case CategoryId.Timer:
                return [DeviceImageState(defaultImage: "15 Timer - CLock - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "15 Timer - CLock - 01", state: 1, text: "On")]

            case CategoryId.Flag:
                return [DeviceImageState(defaultImage: "16 Flag - Flag - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "16 Flag - Flag - 01", state: 1, text: "On")]

            case CategoryId.Event:
                return [DeviceImageState(defaultImage: "17 Event - Up Down - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "17 Event - Up Down - 01", state: 1, text: "On")]

            case CategoryId.Media:
                return [DeviceImageState(defaultImage: "18 Media - LCD TV - 00", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "18 Media - LCD TV - 01", state: 1, text: "On")]

            case CategoryId.Blind:
                return [DeviceImageState(defaultImage: "19 Blind - Blind - 01", state: 0, text: "Off"),
                        DeviceImageState(defaultImage: "19 Blind - Blind - 06", state: 1, text: "On")]

            default:
                return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0, text: nil),
                        DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1, text: nil)]

            }
        }
    }
}
