//
//  DeviceInfo.swift
//  new
//
//  Created by Teodor Stevic on 7/2/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
enum setMode:Int {
    case Auto = 0
    case Cool
    case Heat
    case Fan
}
enum modeState:Int {
    case Off = 0
    case Cool
    case Heat
    case Fan
}
enum setSpeed:Int {
    case Auto = 0
    case Low
    case Med
    case High
}
enum speedState:Int {
    case Off = 0
    case Low
    case Med
    case High
}
class DeviceInfo: NSObject {
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
    
//    "Dimming Control"
//    "Relay Control"
//    "Climate Control"
//    "Human Interface"
//    "Input\/Output"
//"Power Supply"
//"Reserved 8"
//"Reserved 9"
//    "Reserved 10"
//"Lighting"
//"Appliance"
//"Curtain"
//"Security"
//"Timer"
//"Flag"
//"Event"
//"Media"
//"Blind"
    
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
    
    var setMode:[Int:String] = [:]
    var modeState:[Int:String] = [:]
    var setSpeed:[Int:String] = [:]
    var speedState:[Int:String] = [:]
    var categoryList:[Int:String] = [:]
    
    override init () {
        super.init()
        saveCategory()
        saveDeviceChannel()
        saveInterfaceType10in1()
        saveInterfaceType6in1()
        saveDeviceChannel1()
        getCategroyList()
        setMode = [0 : "Auto",
            1:"Cool",
            2:"Heat",
            3:"Fan"]
        modeState = [0 : "Off",
            1:"Cool",
            2:"Heat",
            3:"Fan"]
        setSpeed = [0 : "Auto",
            1:"Low",
            2:"Med",
            3:"High"]
        speedState = [0 : "Off",
            1:"Low",
            2:"Med",
            3:"High"]
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
    func getCategroyList () {
        categoryList = [0:"",
            1:"Gateway & Control",
            2:"Dimming Control",
            3:"Relay Control",
            4:"Climate Control",
            5:"Human Interface",
            6:"I/O",
            7:"Power Suply",
            8:"Reserve (7\" Touch Screen Panel)",
            9:"Reserve (Remote Control)",
            10:"Reserve (Telphone Control)",
            11:"Lighting",
            12:"Appliance",
            13:"Curtain",
            14:"Security",
            15:"Timer",
            16:"Flag",
            17:"Event"]
    }
    func saveDeviceChannel () {
        deviceChannel = [0x03 :DeviceChannelType(channel:ONE_CHANEL, name:CURTAINRS485), //RS232/RS485 Gateway
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
    var deviceType: [DeviceType:DeviceTypeCode] = [:]
    func saveDeviceChannel1 () {
        
        // Gateway & Control series
        // ...
        deviceType[DeviceType(deviceId: 0x03, subId: 0x00)] = DeviceTypeCode(channel:ONE_CHANEL, name:CURTAINRS485, MPN: "RSGW2SP") // RS232/RS485 Gateway
        deviceType[DeviceType(deviceId: 0x03, subId: 0x01)] = DeviceTypeCode(channel:ONE_CHANEL, name:CURTAINRS485, MPN: "RSGW2SD") // RS232/RS485 Gateway, DIN rail
        deviceType[DeviceType(deviceId: 0x03, subId: 0x02)] = DeviceTypeCode(channel:ONE_CHANEL, name:CURTAINRS485, MPN: "ICM05XX") // Intelligent Curtain Module
        // ...
        deviceType[DeviceType(deviceId: 0x04, subId: 0x01)] = DeviceTypeCode(channel:ONE_CHANEL, name:HVAC, MPN: "CM051CG") // Climate Module, 1 Controllers
        deviceType[DeviceType(deviceId: 0x04, subId: 0x02)] = DeviceTypeCode(channel:TWO_CHANEL, name:HVAC, MPN: "CM102CG") // Climate Module, 2 Controllers
        // *** This one didn't existed, but it was put here so all combination would be covered ***
//        deviceType[DeviceType(deviceId: 0x04, subId: 0x03)] = DeviceTypeCode(channel:FOUR_CHANEL, name:HVAC, MPN: "") // Climate Module, 4 Controllers
        // ****************************************************************************************
        deviceType[DeviceType(deviceId: 0x04, subId: 0x04)] = DeviceTypeCode(channel:FOUR_CHANEL, name:HVAC, MPN: "CM204CG") // Climate Module, 4 Controllers
        // ...
        
        // Dimming Control Series
        deviceType[DeviceType(deviceId: 0x13, subId: 0x00)] = DeviceTypeCode(channel:FOUR_CHANEL, name:DIMER, MPN: "DM0401A") // Dimmer Module 4CH, 1A
        deviceType[DeviceType(deviceId: 0x13, subId: 0x01)] = DeviceTypeCode(channel:FOUR_CHANEL, name:DIMER, MPN: "DM0415A") // Dimmer Module 4CH, 1.5A
        deviceType[DeviceType(deviceId: 0x13, subId: 0x02)] = DeviceTypeCode(channel:TWO_CHANEL, name:DIMER, MPN: "DM0215W") // Dimmer Module 2CH, 150W
        deviceType[DeviceType(deviceId: 0x13, subId: 0x03)] = DeviceTypeCode(channel:FOUR_CHANEL, name:DIMER, MPN: "DM0415W") // Dimmer Module 4CH 150W
        
        deviceType[DeviceType(deviceId: 0x16, subId: 0x00)] = DeviceTypeCode(channel:EIGHT_CHANEL, name:DIMER, MPN: "DM0801A") // Dimmer Module 8CH, 1A
        deviceType[DeviceType(deviceId: 0x16, subId: 0x01)] = DeviceTypeCode(channel:EIGHT_CHANEL, name:DIMER, MPN: "DM0815A") // Dimmer Module 8CH, 1.5A
        deviceType[DeviceType(deviceId: 0x16, subId: 0x02)] = DeviceTypeCode(channel:EIGHT_CHANEL, name:DIMER, MPN: "DM0815W") // Dimmer Module
        
        deviceType[DeviceType(deviceId: 0x11, subId: 0x00)] = DeviceTypeCode(channel:TWO_CHANEL, name:DIMER, MPN: "DM0202A") // Dimmer Module
        deviceType[DeviceType(deviceId: 0x11, subId: 0x01)] = DeviceTypeCode(channel:TWO_CHANEL, name:DIMER, MPN: "DM0203A") // Dimmer Module
        
        deviceType[DeviceType(deviceId: 0x14, subId: 0x00)] = DeviceTypeCode(channel:FOUR_CHANEL, name:DIMER, MPN: "DM0402A") // Dimmer Module
        deviceType[DeviceType(deviceId: 0x14, subId: 0x01)] = DeviceTypeCode(channel:FOUR_CHANEL, name:DIMER, MPN: "DM0403A") // Dimmer Module
        
        deviceType[DeviceType(deviceId: 0x12, subId: 0x00)] = DeviceTypeCode(channel:ONE_CHANEL, name:DIMER, MPN: "DM0104A") // Dimmer Module
        deviceType[DeviceType(deviceId: 0x12, subId: 0x01)] = DeviceTypeCode(channel:ONE_CHANEL, name:DIMER, MPN: "DM0105A") // Dimmer Module
        deviceType[DeviceType(deviceId: 0x12, subId: 0x02)] = DeviceTypeCode(channel:ONE_CHANEL, name:DIMER, MPN: "DM0145W") // Dimmer Module
        
        deviceType[DeviceType(deviceId: 0x15, subId: 0x01)] = DeviceTypeCode(channel:TWO_CHANEL, name:DIMER, MPN: "DM0204A") // Dimmer Module
        deviceType[DeviceType(deviceId: 0x15, subId: 0x02)] = DeviceTypeCode(channel:TWO_CHANEL, name:DIMER, MPN: "DM0205A") // Dimmer Module
        deviceType[DeviceType(deviceId: 0x15, subId: 0x03)] = DeviceTypeCode(channel:TWO_CHANEL, name:DIMER, MPN: "DM0245W") // Dimmer Module
        
        // Relay Control Series
        deviceType[DeviceType(deviceId: 0x21, subId: 0x00)] = DeviceTypeCode(channel:FOUR_CHANEL, name:CURTAINS_RELAY, MPN: "RM0405A") // Change Over Module 4CH, 5A
        deviceType[DeviceType(deviceId: 0x22, subId: 0x00)] = DeviceTypeCode(channel:FOUR_CHANEL, name:APPLIANCE, MPN: "RM0410A") // Relay Module 4CH 10A
        deviceType[DeviceType(deviceId: 0x23, subId: 0x00)] = DeviceTypeCode(channel:FOUR_CHANEL, name:APPLIANCE, MPN: "RM0416A") // Relay Module 4CH 16A
        deviceType[DeviceType(deviceId: 0x24, subId: 0x00)] = DeviceTypeCode(channel:TWO_CHANEL, name:APPLIANCE, MPN: "RM0220A") // Relay Module 2CH 20A
        deviceType[DeviceType(deviceId: 0x25, subId: 0x00)] = DeviceTypeCode(channel:EIGHT_CHANEL, name:CURTAINS_RELAY, MPN: "RM0805A") // Change Over Module 8CH, 5A
        deviceType[DeviceType(deviceId: 0x26, subId: 0x00)] = DeviceTypeCode(channel:EIGHT_CHANEL, name:APPLIANCE, MPN: "RM0810A") // Relay Module 8CH 10A
        deviceType[DeviceType(deviceId: 0x27, subId: 0x00)] = DeviceTypeCode(channel:EIGHT_CHANEL, name:APPLIANCE, MPN: "RM0816A") // Relay Module 8CH 16A
        
        // Climate Control Series
        deviceType[DeviceType(deviceId: 0x31, subId: 0x00)] = DeviceTypeCode(channel:TWO_CHANEL, name:HVAC, MPN: "CM1002S") // Climate Module, 2 Controllers
        deviceType[DeviceType(deviceId: 0x32, subId: 0x00)] = DeviceTypeCode(channel:ONE_CHANEL, name:HVAC, MPN: "CM0604I") // Climate Module, 1 Controllers with I/O
        deviceType[DeviceType(deviceId: 0x33, subId: 0x00)] = DeviceTypeCode(channel:ONE_CHANEL, name:HVAC, MPN: "CM0501S") // Climate Module, 1 Controllers
        deviceType[DeviceType(deviceId: 0x34, subId: 0x00)] = DeviceTypeCode(channel:FOUR_CHANEL, name:HVAC, MPN: "CM2004S") // Climate Module, 4 Controllers
        deviceType[DeviceType(deviceId: 0x35, subId: 0x00)] = DeviceTypeCode(channel:TWO_CHANEL, name:HVAC, MPN: "CM1208I") // Climate Module, 2 Controllers with I/O
//        deviceType[DeviceType(deviceId: 0x04, subId: 0x01)] = DeviceTypeCode(channel:ONE_CHANEL, name:HVAC, MPN: "CM051CG") // Climate Module, 1 Controllers Gateway
//        deviceType[DeviceType(deviceId: 0x04, subId: 0x02)] = DeviceTypeCode(channel:TWO_CHANEL, name:HVAC, MPN: "CM102CG") // Climate Module, 2 Controllers Gateway
//        deviceType[DeviceType(deviceId: 0x04, subId: 0x04)] = DeviceTypeCode(channel:FOUR_CHANEL, name:HVAC, MPN: "CM204CG") // Climate Module, 4 Controllers Gateway
        
        // Human Interface Series
        // ...
        
        // I/O Series
        deviceType[DeviceType(deviceId: 0x41, subId: 0x00)] = DeviceTypeCode(channel:TEN_CHANEL, name:SENSOR, MPN: "MSIX08C") // 10-in-1 Multisensor, Indoor Ceiling Mount
        deviceType[DeviceType(deviceId: 0x45, subId: 0x00)] = DeviceTypeCode(channel:SIX_CHANEL, name:SENSOR, MPN: "MSI605C") // 6-in-1 Multisensor, Indoor Ceiling Mount
        deviceType[DeviceType(deviceId: 0x45, subId: 0x01)] = DeviceTypeCode(channel:SIX_CHANEL, name:SENSOR, MPN: "MSI605W") // 6-in-1 Multisensor, Indoor Wall Mount
        deviceType[DeviceType(deviceId: 0x0C, subId: 0x00)] = DeviceTypeCode(channel:ONE_CHANEL, name:PC, MPN: "PC0000S") // e-Homegreen PC Controller ????????????????????? Channel number is wrong
        
        deviceType[DeviceType(deviceId: 0x43, subId: 0x00)] = DeviceTypeCode(channel:ONE_CHANEL, name:PC, MPN: "DI04GPC") // Digital Input Module, 4CH ????????????????????? Channel number is wrong
        // ...
    }
}
struct DeviceChannelType {
    let channel:Int
    let name:String
    init (channel:Int, name:String) {
        self.channel = channel
        self.name = name
    }
}
struct DeviceTypeCode {
    let channel:Int
    let name:String
    let MPN:String
    init (channel:Int, name:String, MPN:String) {
        self.channel = channel
        self.name = name
        self.MPN = MPN
    }
}
//func saveDeviceChannel1 () {
//    
//    // Gateway & Control series
//    // ...
//    deviceType[DeviceType(deviceId: 0x03, subId: 0x00)] = DeviceChannelType(channel:ONE_CHANEL, name:CURTAINRS485) // RS232/RS485 Gateway
//    deviceType[DeviceType(deviceId: 0x03, subId: 0x01)] = DeviceChannelType(channel:ONE_CHANEL, name:CURTAINRS485) // RS232/RS485 Gateway, DIN rail
//    deviceType[DeviceType(deviceId: 0x03, subId: 0x02)] = DeviceChannelType(channel:ONE_CHANEL, name:CURTAINRS485) // Intelligent Curtain Module
//    // ...
//    deviceType[DeviceType(deviceId: 0x04, subId: 0x01)] = DeviceChannelType(channel:ONE_CHANEL, name:HVAC) // Climate Module, 1 Controllers
//    deviceType[DeviceType(deviceId: 0x04, subId: 0x02)] = DeviceChannelType(channel:TWO_CHANEL, name:HVAC) // Climate Module, 2 Controllers
//    // *** This one didn't existed, but it was put here so all combination would be covered ***
//    deviceType[DeviceType(deviceId: 0x04, subId: 0x03)] = DeviceChannelType(channel:FOUR_CHANEL, name:HVAC) // Climate Module, 4 Controllers
//    // ****************************************************************************************
//    deviceType[DeviceType(deviceId: 0x04, subId: 0x04)] = DeviceChannelType(channel:FOUR_CHANEL, name:HVAC) // Climate Module, 4 Controllers
//    // ...
//    
//    // Dimming Control Series
//    deviceType[DeviceType(deviceId: 0x13, subId: 0x00)] = DeviceChannelType(channel:FOUR_CHANEL, name:DIMER) // Dimmer Module 4CH, 1A
//    deviceType[DeviceType(deviceId: 0x13, subId: 0x01)] = DeviceChannelType(channel:FOUR_CHANEL, name:DIMER) // Dimmer Module 4CH, 1.5A
//    deviceType[DeviceType(deviceId: 0x13, subId: 0x02)] = DeviceChannelType(channel:TWO_CHANEL, name:DIMER) // Dimmer Module 2CH, 150W
//    deviceType[DeviceType(deviceId: 0x13, subId: 0x03)] = DeviceChannelType(channel:FOUR_CHANEL, name:DIMER) // Dimmer Module 4CH 150W
//    
//    deviceType[DeviceType(deviceId: 0x16, subId: 0x00)] = DeviceChannelType(channel:EIGHT_CHANEL, name:DIMER) // Dimmer Module 8CH, 1A
//    deviceType[DeviceType(deviceId: 0x16, subId: 0x01)] = DeviceChannelType(channel:EIGHT_CHANEL, name:DIMER) // Dimmer Module 8CH, 1.5A
//    deviceType[DeviceType(deviceId: 0x16, subId: 0x02)] = DeviceChannelType(channel:EIGHT_CHANEL, name:DIMER) // Dimmer Module
//    
//    deviceType[DeviceType(deviceId: 0x11, subId: 0x00)] = DeviceChannelType(channel:TWO_CHANEL, name:DIMER) // Dimmer Module
//    deviceType[DeviceType(deviceId: 0x11, subId: 0x01)] = DeviceChannelType(channel:TWO_CHANEL, name:DIMER) // Dimmer Module
//    
//    deviceType[DeviceType(deviceId: 0x14, subId: 0x00)] = DeviceChannelType(channel:FOUR_CHANEL, name:DIMER) // Dimmer Module
//    deviceType[DeviceType(deviceId: 0x14, subId: 0x01)] = DeviceChannelType(channel:FOUR_CHANEL, name:DIMER) // Dimmer Module
//    
//    deviceType[DeviceType(deviceId: 0x12, subId: 0x00)] = DeviceChannelType(channel:ONE_CHANEL, name:DIMER) // Dimmer Module
//    deviceType[DeviceType(deviceId: 0x12, subId: 0x01)] = DeviceChannelType(channel:ONE_CHANEL, name:DIMER) // Dimmer Module
//    deviceType[DeviceType(deviceId: 0x12, subId: 0x02)] = DeviceChannelType(channel:ONE_CHANEL, name:DIMER) // Dimmer Module
//    
//    deviceType[DeviceType(deviceId: 0x15, subId: 0x01)] = DeviceChannelType(channel:TWO_CHANEL, name:DIMER) // Dimmer Module
//    deviceType[DeviceType(deviceId: 0x15, subId: 0x02)] = DeviceChannelType(channel:TWO_CHANEL, name:DIMER) // Dimmer Module
//    deviceType[DeviceType(deviceId: 0x15, subId: 0x03)] = DeviceChannelType(channel:TWO_CHANEL, name:DIMER) // Dimmer Module
//    
//    // Relay Control Series
//    deviceType[DeviceType(deviceId: 0x21, subId: 0x00)] = DeviceChannelType(channel:FOUR_CHANEL, name:CURTAINS_RELAY) // Change Over Module 4CH, 5A
//    deviceType[DeviceType(deviceId: 0x22, subId: 0x00)] = DeviceChannelType(channel:FOUR_CHANEL, name:APPLIANCE) // Relay Module 4CH 10A
//    deviceType[DeviceType(deviceId: 0x23, subId: 0x00)] = DeviceChannelType(channel:FOUR_CHANEL, name:APPLIANCE) // Relay Module 4CH 16A
//    deviceType[DeviceType(deviceId: 0x24, subId: 0x00)] = DeviceChannelType(channel:TWO_CHANEL, name:APPLIANCE) // Relay Module 2CH 20A
//    deviceType[DeviceType(deviceId: 0x25, subId: 0x00)] = DeviceChannelType(channel:EIGHT_CHANEL, name:CURTAINS_RELAY) // Change Over Module 8CH, 5A
//    deviceType[DeviceType(deviceId: 0x26, subId: 0x00)] = DeviceChannelType(channel:EIGHT_CHANEL, name:APPLIANCE) // Relay Module 8CH 10A
//    deviceType[DeviceType(deviceId: 0x27, subId: 0x00)] = DeviceChannelType(channel:EIGHT_CHANEL, name:APPLIANCE) // Relay Module 8CH 16A
//    
//    // Climate Control Series
//    deviceType[DeviceType(deviceId: 0x31, subId: 0x00)] = DeviceChannelType(channel:TWO_CHANEL, name:HVAC) // Climate Module, 2 Controllers
//    deviceType[DeviceType(deviceId: 0x32, subId: 0x00)] = DeviceChannelType(channel:ONE_CHANEL, name:HVAC) // Climate Module, 1 Controllers with I/O
//    deviceType[DeviceType(deviceId: 0x33, subId: 0x00)] = DeviceChannelType(channel:ONE_CHANEL, name:HVAC) // Climate Module, 1 Controllers
//    deviceType[DeviceType(deviceId: 0x34, subId: 0x00)] = DeviceChannelType(channel:FOUR_CHANEL, name:HVAC) // Climate Module, 4 Controllers
//    deviceType[DeviceType(deviceId: 0x35, subId: 0x00)] = DeviceChannelType(channel:TWO_CHANEL, name:HVAC) // Climate Module, 2 Controllers with I/O
//    //        deviceType[DeviceType(deviceId: 0x04, subId: 0x01)] = DeviceChannelType(channel:ONE_CHANEL, name:HVAC) // Climate Module, 1 Controllers Gateway
//    //        deviceType[DeviceType(deviceId: 0x04, subId: 0x02)] = DeviceChannelType(channel:TWO_CHANEL, name:HVAC) // Climate Module, 2 Controllers Gateway
//    //        deviceType[DeviceType(deviceId: 0x04, subId: 0x04)] = DeviceChannelType(channel:FOUR_CHANEL, name:HVAC) // Climate Module, 4 Controllers Gateway
//    
//    // Human Interface Series
//    // ...
//    
//    // I/O Series
//    deviceType[DeviceType(deviceId: 0x41, subId: 0x00)] = DeviceChannelType(channel:TEN_CHANEL, name:SENSOR) // 10-in-1 Multisensor, Indoor Ceiling Mount
//    deviceType[DeviceType(deviceId: 0x45, subId: 0x00)] = DeviceChannelType(channel:SIX_CHANEL, name:SENSOR) // 6-in-1 Multisensor, Indoor Ceiling Mount
//    deviceType[DeviceType(deviceId: 0x45, subId: 0x01)] = DeviceChannelType(channel:SIX_CHANEL, name:SENSOR) // 6-in-1 Multisensor, Indoor Wall Mount
//    deviceType[DeviceType(deviceId: 0x0C, subId: 0x00)] = DeviceChannelType(channel:ONE_CHANEL, name:PC) // e-Homegreen PC Controller
//    
//    deviceType[DeviceType(deviceId: 0x43, subId: 0x00)] = DeviceChannelType(channel:ONE_CHANEL, name:PC) // Digital Input Module, 4CH
//    // ...
//}
