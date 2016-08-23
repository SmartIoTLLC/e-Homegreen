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
        let controlMode = device.digitalInputMode?.integerValue
        
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
                return [DeviceImageState(defaultImage: "13 Curtain - Curtain - 00", state: 0, text: "Closed"),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 02", state: 1, text: "Stop"),
                        DeviceImageState(defaultImage: "13 Curtain - Curtain - 04", state: 2, text: "Open")]

            }
            
        default:
            switch categoryId {
            case CategoryId.GatewayControl:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 1, text: "On")]
                }
            case CategoryId.DimmingControl:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 1, text: "On")]
                }
            case CategoryId.RelayControl:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "12 Appliance - Switch - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "12 Appliance - Switch - 01", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "12 Appliance - Switch - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "12 Appliance - Switch - 01", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "12 Appliance - Switch - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "12 Appliance - Switch - 01", state: 1, text: "On")]
                }
            case CategoryId.ClimateControl:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "04 Climate Control - HVAC - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "04 Climate Control - HVAC - 01", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "04 Climate Control - HVAC - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "04 Climate Control - HVAC - 01", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "04 Climate Control - HVAC - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "04 Climate Control - HVAC - 01", state: 1, text: "On")]
                }

            case CategoryId.Lighting:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "11 Lighting - Bulb - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "11 Lighting - Bulb - 10", state: 1, text: "On")]
                }

            case CategoryId.Appliance:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "12 Appliance - Switch - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "12 Appliance - Switch - 01", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1, text: "On")]
                }
                

            case CategoryId.Curtain:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "13 Curtain - Curtain - 00", state: 0, text: "Closed"),
                            DeviceImageState(defaultImage: "13 Curtain - Curtain - 02", state: 1, text: "Stop"),
                            DeviceImageState(defaultImage: "13 Curtain - Curtain - 04", state: 2, text: "Open")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "13 Curtain - Curtain - 00", state: 0, text: "Closed"),
                            DeviceImageState(defaultImage: "13 Curtain - Curtain - 02", state: 1, text: "Stop"),
                            DeviceImageState(defaultImage: "13 Curtain - Curtain - 04", state: 2, text: "Open")]
                }else{
                    return [DeviceImageState(defaultImage: "13 Curtain - Curtain - 00", state: 0, text: "Closed"),
                            DeviceImageState(defaultImage: "13 Curtain - Curtain - 02", state: 1, text: "Stop"),
                            DeviceImageState(defaultImage: "13 Curtain - Curtain - 04", state: 2, text: "Open")]
                }
            case CategoryId.Security:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "14 Security - Lock - 00", state: 0, text: "Locked"),
                            DeviceImageState(defaultImage: "14 Security - Lock - 01", state: 1, text: "Unlocked")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "14 Security - Lock - 00", state: 1, text: "Unlocked"),
                            DeviceImageState(defaultImage: "14 Security - Lock - 01", state: 0, text: "Locked")]
                }else{
                    return [DeviceImageState(defaultImage: "14 Security - Lock - 00", state: 0, text: "Locked"),
                            DeviceImageState(defaultImage: "14 Security - Lock - 01", state: 1, text: "Unlocked")]
                }
            case CategoryId.Timer:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "15 Timer - CLock - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "15 Timer - CLock - 01", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "15 Timer - CLock - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "15 Timer - CLock - 01", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "15 Timer - CLock - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "15 Timer - CLock - 01", state: 1, text: "On")]
                }
            case CategoryId.Flag:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "16 Flag - Flag - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "16 Flag - Flag - 01", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "16 Flag - Flag - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "16 Flag - Flag - 01", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "16 Flag - Flag - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "16 Flag - Flag - 01", state: 1, text: "On")]
                }
            case CategoryId.Event:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "17 Event - Up Down - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "17 Event - Up Down - 01", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "17 Event - Up Down - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "17 Event - Up Down - 01", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "17 Event - Up Down - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "17 Event - Up Down - 01", state: 1, text: "On")]
                }
            case CategoryId.Media:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "18 Media - LCD TV - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "18 Media - LCD TV - 01", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "18 Media - LCD TV - 00", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "18 Media - LCD TV - 01", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "18 Media - LCD TV - 00", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "18 Media - LCD TV - 01", state: 1, text: "On")]
                }
            case CategoryId.Blind:
                guard let controlModeTemp = controlMode else{
                    return [DeviceImageState(defaultImage: "19 Blind - Blind - 01", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "19 Blind - Blind - 06", state: 1, text: "On")]
                }
                if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                    return [DeviceImageState(defaultImage: "19 Blind - Blind - 01", state: 1, text: "On"),
                            DeviceImageState(defaultImage: "19 Blind - Blind - 06", state: 0, text: "Off")]
                }else{
                    return [DeviceImageState(defaultImage: "19 Blind - Blind - 01", state: 0, text: "Off"),
                            DeviceImageState(defaultImage: "19 Blind - Blind - 06", state: 1, text: "On")]
                }

            default:
                return [DeviceImageState(defaultImage: "12 Appliance - Power - 00", state: 0, text: nil),
                        DeviceImageState(defaultImage: "12 Appliance - Power - 01", state: 1, text: nil)]

            }
        }
    }
}
