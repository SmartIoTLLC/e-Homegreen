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
        var byteArray: [Byte] = []
        if let hex = hex {
            let stringArray: [String] = hex.split(separator: " ").map(String.init)
            for string in stringArray {
                if let byte = Int(string) { byteArray.append(UInt8(byte)) }
            }
        }        
        
        return byteArray
    }
    func loadHexByteArray() {
        hex = formatHexStringToByteArray(hex: button.hexString)
    }
    
    func sendHexCommand() {
        if let locationName = button.remote?.location?.name {
            if let sockets = (UIApplication.shared.delegate as? AppDelegate)?.inOutSockets {
                sockets.forEach({ (socket) in
                    socket.send("")
                })
            }
            let gateways = DatabaseGatewayController.shared.getGatewayByLocation(locationName)
            var chosenGateway: Gateway?
            gateways.forEach({ (gateway) in
                if let hex = hex {
                    if hex[2] == getByte(gateway.addressOne) && hex[3] == getByte(gateway.addressTwo) { chosenGateway = gateway }
                }
            })
            
            if let chosenGateway = chosenGateway {
                SendingHandler.sendCommand(byteArray: hex!, gateway: chosenGateway)
            }
            
            for gateway in gateways { SendingHandler.sendCommand(byteArray: hex!, gateway: gateway) }
        }
    }
    
    func sendIRCommand() {
        if let device = irDevice {
            
//            let gateway = device.gateway
//            let address = [getByte(gateway.addressOne), getByte(gateway.addressTwo), getByte(device.address)]
           // SendingHandler.sendCommand(byteArray: OutgoingHandler.ir, gateway: <#T##Gateway#>)
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
