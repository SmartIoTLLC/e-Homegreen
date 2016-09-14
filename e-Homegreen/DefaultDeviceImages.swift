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
                return blindImagesMultistate
            case CategoryId.Curtain:
                return curtainImagesMultistate
            default:
                return lightningImagesMultistate
            }
        case ControlType.Curtain:
            switch categoryId {
            case CategoryId.Blind:
                return blindImagesThreeStateNO
            default:
                return curtainImagesTwoStateNO
            }
        case ControlType.IntelligentSwitch:
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        case ControlType.Climate:
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        case ControlType.AnalogInput:
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        case ControlType.AnalogOutput:
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        case ControlType.DigitalInput:
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        case ControlType.DigitalOutput:
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        case ControlType.Sensor:
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        case ControlType.IRTransmitter:
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        default: // ControlType == Relay
            return returnImagesArrayDependingOnCategoryId(categoryId, controlMode: controlMode)
        }
    }
    
    func returnImagesArrayDependingOnCategoryId(categoryId: NSNumber, controlMode: Int?) -> [DeviceImageState]{
        switch categoryId {
        case CategoryId.GatewayControl:
            guard let controlModeTemp = controlMode else{
                return lightningImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return lightningImagesTwoStateNC
            }else{
                return lightningImagesTwoStateNO
            }
        case CategoryId.DimmingControl:
            guard let controlModeTemp = controlMode else{
                return lightningImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return lightningImagesTwoStateNC
            }else{
                return lightningImagesTwoStateNO
            }
        case CategoryId.RelayControl:
            guard let controlModeTemp = controlMode else{
                return applianceImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return applianceImagesTwoStateNC
            }else{
                return applianceImagesTwoStateNO
            }
        case CategoryId.ClimateControl:
            guard let controlModeTemp = controlMode else{
                return climateImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return climateImagesTwoStateNC
            }else{
                let k = climateImagesTwoStateNO
                return climateImagesTwoStateNO
            }
            
        case CategoryId.Lighting:
            guard let controlModeTemp = controlMode else{
                return lightningImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return lightningImagesTwoStateNC
            }else{
                return lightningImagesTwoStateNO
            }
            
        case CategoryId.Appliance:
            guard let controlModeTemp = controlMode else{
                return applianceImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return applianceImagesTwoStateNC
            }else{
                return applianceImagesTwoStateNO
            }
            
        case CategoryId.Curtain:
            guard let controlModeTemp = controlMode else{
                return curtainImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return curtainImagesTwoStateNC
            }else{
                return curtainImagesTwoStateNO
            }
        case CategoryId.Security:
            guard let controlModeTemp = controlMode else{
                return securityImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return securityImagesTwoStateNC
            }else{
                return securityImagesTwoStateNO
            }
        case CategoryId.Timer:
            guard let controlModeTemp = controlMode else{
                return timerImagesTwostateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return timerImagesTwostateNC
            }else{
                return timerImagesTwostateNO
            }
        case CategoryId.Flag:
            guard let controlModeTemp = controlMode else{
                return flagImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return flagImagesTwoStateNC
            }else{
                return flagImagesTwoStateNO
            }
        case CategoryId.Event:
            guard let controlModeTemp = controlMode else{
                return eventImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return eventImagesTwoStateNC
            }else{
                return eventImagesTwoStateNO
            }
        case CategoryId.Media:
            guard let controlModeTemp = controlMode else{
                return mediaImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return mediaImagesTwoStateNC
            }else{
                return mediaImagesTwoStateNO
            }
        case CategoryId.Blind:
            guard let controlModeTemp = controlMode else{
                return blindImagesTwoStateNO
            }
            if (DigitalInput.modeInfo[controlModeTemp] == DigitalInput.ButtonNormallyClosed.description() || DigitalInput.modeInfo[controlModeTemp] == DigitalInput.NormallyClosed.description()){
                return blindImagesTwoStateNC
            }else{
                return blindImagesTwoStateNO
            }
            
        default:
            return applianceImagesTwoStateNO
        }
    }
}
