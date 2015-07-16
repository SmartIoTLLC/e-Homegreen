//
//  UserDefaults.swift
//  new
//
//  Created by Teodor Stevic on 7/2/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class UserDefaults: NSObject {
    let ONE_CHANEL = 1
    let TWO_CHANEL = 2
    let FOUR_CHANEL = 4
    let SIX_CHANEL = 6
    let EIGHT_CHANEL = 8
    let TEN_CHANEL = 10
    
    let CURTAINRS485 = "curtainsRS485"
    let CURTAINS_RELAY = "curtainsRelay"
    let PC = "pc"
    let DIMER = "Dimmer"
    let APPLIANCE = "appliance"
    let HVAC = "hvac"
    let SENSOR = "sensor"
    let LIGHT = "light"
    
    let temperatureProbe = "CPU.Temp"
    let digitalInputDryContact = "Dig Input 1"
    let digitalInputDryContact2 = "Dig. Input 2"
    let analogInput = "Analog Input"
    let temperatureProbe2 = "Temperature"
    let brightnessSensorLUX = "Brt. Level"
    let motionSensorPIR = "Motion Sensor"
    let IRReceiver = "IR Receiver"
    let digitalInput = "Tamper Sensor"
    let digitalInput2 = "Noise Sensor"
    
    var deviceCategory:[Int:String] = [:]
    var deviceChannel:[UInt8:DeviceChannelType] = [:]
    var inputInterface10in1:[Int:String] = [:]
    var inputInterface6in1:[Int:String] = [:]
    
    override init () {
        super.init()
        saveCategory()
        saveDeviceChannel()
        saveInterfaceType10in1()
        saveInterfaceType6in1()
    }
    func saveCategory() {
        deviceCategory = [2 : DIMER,
            4:HVAC,
            11:LIGHT,
            12:APPLIANCE,
            19:CURTAINS_RELAY,
            13:CURTAINS_RELAY,
            14:SENSOR]
    }
    func saveInterfaceType10in1 () {
        inputInterface10in1 = [1:temperatureProbe,
            2:digitalInputDryContact,
            3:digitalInputDryContact2,
            4:analogInput,
            5:temperatureProbe2,
            6:brightnessSensorLUX,
            7:motionSensorPIR,
            8:IRReceiver,
            9:digitalInput,
            10:digitalInput2]
    }
    func saveInterfaceType6in1 () {
        inputInterface6in1 = [1:temperatureProbe,
            2:digitalInputDryContact,
            3:digitalInputDryContact2,
            4:temperatureProbe2,
            5:motionSensorPIR,
            6:digitalInput]
    }
    func saveDeviceChannel () {
        deviceChannel = [0x03:DeviceChannelType(channel:ONE_CHANEL, name:CURTAINRS485), //RS232/RS485 Gateway
            0x21:DeviceChannelType(channel:FOUR_CHANEL, name:CURTAINS_RELAY), //ChangeOverRelay
            0x25:DeviceChannelType(channel:EIGHT_CHANEL, name:CURTAINS_RELAY), //ChangeOverRelay
            0x0C:DeviceChannelType(channel:ONE_CHANEL, name:PC), //PC
            0x13:DeviceChannelType(channel:FOUR_CHANEL, name:DIMER), //Dimmer Module 4CH, 1A
            0x16:DeviceChannelType(channel:EIGHT_CHANEL, name:DIMER), //Dimmer Module 8CH, 1A
            0x11:DeviceChannelType(channel:TWO_CHANEL, name:DIMER), //Dimmer Module 2CH, 2A
            0x14:DeviceChannelType(channel:FOUR_CHANEL, name:DIMER), //Dimmer Module 4CH, 2A
            0x12:DeviceChannelType(channel:ONE_CHANEL, name:DIMER), //Dimmer Module 1CH, 4A
            0x15:DeviceChannelType(channel:TWO_CHANEL, name:DIMER), //Dimmer Module 2CH, 4A
            0x22:DeviceChannelType(channel:FOUR_CHANEL, name:APPLIANCE), //Relay Module 4CH 10A
            0x26:DeviceChannelType(channel:EIGHT_CHANEL, name:APPLIANCE), //Relay Module 8CH 10A
            0x23:DeviceChannelType(channel:FOUR_CHANEL, name:APPLIANCE), //Relay Module 4CH 16A
            0x27:DeviceChannelType(channel:EIGHT_CHANEL, name:APPLIANCE), //Relay Module 8CH 16A
            0x24:DeviceChannelType(channel:TWO_CHANEL, name:APPLIANCE),//Relay Module 2CH 20A
            0x32:DeviceChannelType(channel:ONE_CHANEL, name:HVAC), //Climate Module, 1 Controller with I/O
            0x35:DeviceChannelType(channel:TWO_CHANEL, name:HVAC), //Climate Module, 2 Controllers with I/O
            0x33:DeviceChannelType(channel:ONE_CHANEL, name:HVAC), //Climate Module, 1 Controller
            0x31:DeviceChannelType(channel:TWO_CHANEL, name:HVAC), //Climate Module, 2 Controllers
            0x34:DeviceChannelType(channel:FOUR_CHANEL, name:HVAC), //Climate Module, 4 Controllers
            0x04:DeviceChannelType(channel:FOUR_CHANEL, name:HVAC), //Climate Module, 4 Controllers
            0x41:DeviceChannelType(channel:TEN_CHANEL, name:SENSOR), //10-in-1 Multisensor
            0x45:DeviceChannelType(channel:SIX_CHANEL, name:SENSOR)] //6-in-1 Multisensor
    }
//    var tuplesA:(UInt8, UInt8)
//    var deviceChannelTest:[tuplesA:DeviceChannelType]
//    func saveDeviceChannel () {
//        deviceChannelTest = [[0x01:0x02]:DeviceChannelType(channel:ONE_CHANEL, name:CURTAINRS485), //RS232/RS485 Gateway
//    }
}
class DeviceType {
    var deviceId:UInt8?
    var subId:UInt8?
    init (deviceId:UInt8, subId:UInt8) {
        self.deviceId = deviceId
        self.subId = subId
    }
}
class DeviceChannelType {
    var channel:Int?
    var name:String?
    init (channel:Int, name:String) {
        self.channel = channel
        self.name = name
        }
}
