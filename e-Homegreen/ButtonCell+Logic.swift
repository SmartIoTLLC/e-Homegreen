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
        if let scene = self.scene {
            
            if button.addressOne != nil && button.addressTwo != nil && button.addressThree != nil {
                address = [getByte(button.addressOne!), getByte(button.addressTwo!), getByte(button.addressThree!)]
            } else {
                if scene.isBroadcast.boolValue {
                    address = [0xFF, 0xFF, 0xFF]
                } else if scene.isLocalcast.boolValue {
                    address = [getByte(scene.gateway.addressOne), getByte(scene.gateway.addressTwo), 0xFF]
                } else {
                    address = [getByte(scene.gateway.addressOne), getByte(scene.gateway.addressTwo), getByte(scene.address)]
                }
            }

            if let sceneId = button.sceneId as? Int {
                if sceneId >= 0 && sceneId <= 32767 { SendingHandler.sendCommand(byteArray: OutgoingHandler.setScene(address, id: sceneId), gateway: scene.gateway) }
            }
            
        } else { makeToast(message: "Scene not found.") }
    }
    
    func loadIRDevice() {
        if let channel = button.channel as? Int {
            if let device = DatabaseDeviceController.shared.getIRDevice(withChannelID: channel) {
                irDevice = device
            }
        }
    }
    
    func formatHexStringToByteArray(hex: String?) -> [Byte] {
        var byteArray: [Byte] = []
        if let hex = hex?.replacingOccurrences(of: " ", with: "") { byteArray = hex.hexa2Bytes }
        
        return byteArray
    }
    func loadHexByteArray() {
        hex = formatHexStringToByteArray(hex: button.hexString)
    }
    
    func sendHexCommand() {
        if let locationName = button.remote?.location?.name {

            let gateways = DatabaseGatewayController.shared.getGatewayByLocation(locationName)
            var chosenGateway: Gateway?
            gateways.forEach({ (gateway) in
                if let hex = hex {
                    if hex.count > 3 {
                        if hex[2] == getByte(gateway.addressOne) && hex[3] == getByte(gateway.addressTwo) && hex[4] == getByte(gateway.addressThree) { chosenGateway = gateway }
                    }
                }
            })
            
            if let chosenGateway = chosenGateway {
                SendingHandler.sendCommand(byteArray: hex!, gateway: chosenGateway)
            } else { makeToast(message: "Entered gateway not found.") }
        }
    }
    
    func sendIRCommand() {
        if let device = irDevice {
            let gateway  = device.gateway
            let address  = [getByte(gateway.addressOne), getByte(gateway.addressTwo), getByte(device.address)]
            let channel  = getByte(device.channel)
            let id       = getByte(button.irId!)
            // TODO: na settings ekranu staviti da je ID obavezan
            SendingHandler.sendCommand(byteArray: OutgoingHandler.sendIRLibrary(address, channel: channel, ir_id: id), gateway: gateway)
        }
    }
    
    @objc func sendCommand() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.SendRemoteCommand), object: nil)
        
        switch button.buttonType! {
            case ButtonType.sceneButton : sendSceneCommand()
            case ButtonType.irButton    : sendIRCommand()
            case ButtonType.hexButton   : sendHexCommand()
            default: break
        }
    }
    
}

extension String {
    
    var hexa2Bytes: [UInt8] {
        let hexa = Array(self)
        return stride(from: 0, to: count, by: 2).flatMap { UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16) }
    }
}
