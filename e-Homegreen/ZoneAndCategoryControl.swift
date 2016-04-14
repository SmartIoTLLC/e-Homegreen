//
//  ZoneAndCategoryControl.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/13/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

class ZoneAndCategoryControl: NSObject {

    static let shared = ZoneAndCategoryControl()
    
    func turnOnByZone(zoneId:Int, location:String){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = ZoneAndCategoryFunction.shared.getCommandTurnOnByZone(zoneId)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func turnOffByZone(zoneId:Int, location:String){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = ZoneAndCategoryFunction.shared.getCommandTurnOffByZone(zoneId)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func turnOnByCategory(categoryId:Int, location:String){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = ZoneAndCategoryFunction.shared.getCommandTurnOnByCategory(categoryId)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func turnOffByCategory(categoryId:Int, location:String){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = ZoneAndCategoryFunction.shared.getCommandTurnOffByCategory(categoryId)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func changeValueByZone(zoneId:Int, location:String, value:Int){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = ZoneAndCategoryFunction.shared.getCommandChangeValueByZone(zoneId, value:value)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func changeValueByCategory(zoneId:Int, location:String, value:Int){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = ZoneAndCategoryFunction.shared.getCommandChangeValueByCategory(zoneId, value:value)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
}
