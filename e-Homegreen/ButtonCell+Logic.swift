//
//  ButtonCell+Logic.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/4/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation

extension ButtonCell {
    
    func loadScene() {
        if let sceneId = button.sceneId as? Int, let loc = button.remote?.location {
            if let scene = DatabaseScenesController.shared.getScene(withId: sceneId, on: loc) {
                self.scene = scene
            }
        }
    }
    
    func sendSceneCommand() {
        var address: [Byte] = []
        
        // TODO: ubaciti unetu adresu umesto ove sa gatewaya
        if let scene = self.scene {
            
            if scene.isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if scene.isLocalcast.boolValue {
                address = [getByte(scene.gateway.addressOne), getByte(scene.gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(scene.gateway.addressOne), getByte(scene.gateway.addressTwo), getByte(scene.address)]
            }
            
            if let sceneId = button.sceneId as? Int {
                if sceneId >= 0 && sceneId <= 32767 { SendingHandler.sendCommand(byteArray: OutgoingHandler.setScene(address, id: sceneId), gateway: scene.gateway) }
            }
            
        }
    }
    
    func loadIRDevice() {
        if let channel = button.channel as? Int {
            if let device = DatabaseDeviceController.shared.getIRDevice(withChannelID: channel) {
                irDevice = device
            }
        }
    }
    
    func formatHexStringToByteArray(hex: String?) -> [Byte] {
        var byteArray: [Byte]     = []
        if let hex = hex {
            let stringArray: [String] = hex.split(separator: " ").map(String.init)
            for string in stringArray {
                if let byte = Int(string) { byteArray.append(UInt8(byte)) }
            }
        }        
        
        return byteArray
    }
    
    func sendHexCommand() {
        if let locationName = button.remote?.location?.name {
            let gateways = DatabaseGatewayController.shared.getGatewayByLocation(locationName)
            
            for gateway in gateways { SendingHandler.sendCommand(byteArray: hex!, gateway: gateway) }
        }
    }
    
    @objc func sendCommand() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.SendRemoteCommand), object: nil)
        
        switch button.buttonType! {
            
        case ButtonType.sceneButton : sendSceneCommand()
        case ButtonType.irButton    : break
        case ButtonType.hexButton   : sendHexCommand()
        default: break
        }
    }
    
}
