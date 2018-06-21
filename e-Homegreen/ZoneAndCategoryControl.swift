//
//  ZoneAndCategoryControl.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/13/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

class ZoneAndCategoryControl: NSObject {

    static let shared = ZoneAndCategoryControl()
    
//    func turnOnByZone(with filter: FilterItem) {
//        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(filter.location)
//        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandTurnOnByZone(filter.zoneId)
//        for gateway in gateways {
//            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
//        }
//    }
//
//    func turnOffByZone(with filter: FilterItem) {
//        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(filter.location)
//        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandTurnOffByZone(filter.zoneId)
//        for gateway in gateways {
//            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
//        }
//    }
//
//    func turnOnByCategory(with filter: FilterItem) {
//        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(filter.location)
//        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandTurnOnByCategory(filter.categoryId)
//        for gateway in gateways {
//            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
//        }
//    }
//
//    func turnOffByCategory(with filter: FilterItem) {
//        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(filter.location)
//        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandTurnOffByCategory(filter.categoryId)
//        for gateway in gateways {
//            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
//        }
//    }
//
//    func changeValueByZone(with filter: FilterItem, value:Int) {
//        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(filter.location)
//        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandChangeValueByZone(filter.zoneId, value: value)
//        for gateway in gateways {
//            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
//        }
//    }
//
//    func changeValueByCategory(with filter: FilterItem, value:Int) {
//        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(filter.location)
//        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandChangeValueByCategory(filter.zoneId, value: value)
//        for gateway in gateways {
//            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
//        }
//    }
    
    func turnOnByZone(_ zoneId:Int, location:String){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandTurnOnByZone(zoneId)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func turnOffByZone(_ zoneId:Int, location:String){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandTurnOffByZone(zoneId)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func turnOnByCategory(_ categoryId:Int, location:String){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandTurnOnByCategory(categoryId)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func turnOffByCategory(_ categoryId:Int, location:String){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandTurnOffByCategory(categoryId)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func changeValueByZone(_ zoneId:Int, location:String, value:Int){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandChangeValueByZone(zoneId, value:value)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
    
    func changeValueByCategory(_ zoneId:Int, location:String, value:Int){
        let gateways = DatabaseGatewayController.shared.getGatewayByLocation(location)
        let command = OutgoingHandlerForZoneAndCategory.shared.getCommandChangeValueByCategory(zoneId, value:value)
        for gateway in gateways{
            SendingHandler.sendCommand(byteArray: command, gateway: gateway)
        }
    }
}
