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
struct Channel {
    static let One = 1
    static let Two = 2
    static let Four = 4
    static let Six = 6
    static let Eight = 8
    static let Ten = 10
    static let Twelve = 12
}
struct ControlType {
    // Dimmer
    // Appliance, Relay i ChangeOverRelay
    // HVAC
    // Sensor
    // Curtains
    // DigitalInput
    // DigitalOutput
    // AnalogInput
    // AnalogOutput
    // SaltoAccess
    static let CurtainsRS485 = "curtainsRS485"
    static let CurtainsRelay = "curtainsRelay"
    static let PC = "PC"
    static let Dimmer = "Dimmer"
    static let Appliance = "Appliance"
    static let HVAC = "HVAC"
    static let Sensor = "Sensor"
    static let Light = "Light"
    static let HumanInterfaceSeries = "Intelligent Switch"
    static let AnalogOutput = "Analog Output"
    static let DigitalInput = "Digital Input"
    static let DigitalOutput = "Digital Output"
    static let AnalogInput = "Analog Input"
    static let IRTransmitter = "IR Transmitter"
    static let SaltoAccess = "Salto Access"
}
struct Interface {
    static let TemperatureProbe = "CPU.Temp"
    static let DigitalInputDryContact = "Dig Input 1"
    static let DigitalInputDryContact2 = "Dig. Input 2"
    static let AnalogInput = "Analog Input"
    static let TemperatureProbe2 = "Temperature"
    static let BrightnessSensorLUX = "Brt. Level"
    static let MotionSensorPIR = "Motion Sensor"
    static let IRReceiver = "IR Receiver"
    static let DigitalInput = "Tamper Sensor"
    static let DigitalInput2 = "Noise Sensor"
}
struct DeviceInfo {
    
    static let setMode:[Int:String] = [0 : "Auto",
        1:"Cool",
        2:"Heat",
        3:"Fan"]
    static let modeState:[Int:String] = [0 : "Off",
        1:"Cool",
        2:"Heat",
        3:"Fan"]
    static let setSpeed:[Int:String] = [0 : "Auto",
        1:"Low",
        2:"Med",
        3:"High"]
    static let speedState:[Int:String] = [0 : "Off",
        1:"Low",
        2:"Med",
        3:"High"]

    static let deviceCategory:[Int:String] = [2 : ControlType.Dimmer,
        4:ControlType.HVAC,
        11:ControlType.Light,
        12:ControlType.Appliance,
        19:ControlType.CurtainsRelay,
        13:ControlType.CurtainsRelay,
        14:ControlType.Sensor]
    static let inputInterface10in1:[Int:String] = [1:Interface.TemperatureProbe,
        2:Interface.DigitalInputDryContact,
        3:Interface.DigitalInputDryContact2,
        4:Interface.AnalogInput,
        5:Interface.TemperatureProbe2,
        6:Interface.BrightnessSensorLUX,
        7:Interface.MotionSensorPIR,
        8:Interface.IRReceiver,
        9:Interface.DigitalInput,
        10:Interface.DigitalInput2]
    static let inputInterface6in1:[Int:String] = [1:Interface.TemperatureProbe,
        2:Interface.DigitalInputDryContact,
        3:Interface.DigitalInputDryContact2,
        4:Interface.TemperatureProbe2,
        5:Interface.MotionSensorPIR,
        6:Interface.DigitalInput]
    static let categoryList:[Int:String] = [0:"",
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
        12:"ControlType.Appliance",
        13:"Curtain",
        14:"Security",
        15:"Timer",
        16:"Flag",
        17:"Event"]
    
    static let deviceChannel:[UInt8:DeviceChannelType] = [0x03 :DeviceChannelType(channel:Channel.One, name:ControlType.CurtainsRS485), //RS232/RS485 Gateway
        0x21:DeviceChannelType(channel:Channel.Four, name:ControlType.CurtainsRelay), //ChangeOverRelay
        0x25:DeviceChannelType(channel:Channel.Eight, name:ControlType.CurtainsRelay), //ChangeOverRelay
        0x0C:DeviceChannelType(channel:Channel.One, name:ControlType.PC), //ControlType.PC
        0x13:DeviceChannelType(channel:Channel.Four, name:ControlType.Dimmer), //Dimmer Module 4CH, 1A
        0x16:DeviceChannelType(channel:Channel.Eight, name:ControlType.Dimmer), //Dimmer Module 8CH, 1A
        0x11:DeviceChannelType(channel:Channel.Two, name:ControlType.Dimmer), //Dimmer Module 2CH, 2A
        0x14:DeviceChannelType(channel:Channel.Four, name:ControlType.Dimmer), //Dimmer Module 4CH, 2A
        0x12:DeviceChannelType(channel:Channel.One, name:ControlType.Dimmer), //Dimmer Module 1CH, 4A
        0x15:DeviceChannelType(channel:Channel.Two, name:ControlType.Dimmer), //Dimmer Module 2CH, 4A
        0x22:DeviceChannelType(channel:Channel.Four, name:ControlType.Appliance), //Relay Module 4CH 10A
        0x26:DeviceChannelType(channel:Channel.Eight, name:ControlType.Appliance), //Relay Module 8CH 10A
        0x23:DeviceChannelType(channel:Channel.Four, name:ControlType.Appliance), //Relay Module 4CH 16A
        0x27:DeviceChannelType(channel:Channel.Eight, name:ControlType.Appliance), //Relay Module 8CH 16A
        0x24:DeviceChannelType(channel:Channel.Two, name:ControlType.Appliance),//Relay Module 2CH 20A
        0x32:DeviceChannelType(channel:Channel.One, name:ControlType.HVAC), //Climate Module, 1 Controller with I/O
        0x35:DeviceChannelType(channel:Channel.Two, name:ControlType.HVAC), //Climate Module, 2 Controllers with I/O
        0x33:DeviceChannelType(channel:Channel.One, name:ControlType.HVAC), //Climate Module, 1 Controller
        0x31:DeviceChannelType(channel:Channel.Two, name:ControlType.HVAC), //Climate Module, 2 Controllers
        0x34:DeviceChannelType(channel:Channel.Four, name:ControlType.HVAC), //Climate Module, 4 Controllers
        0x04:DeviceChannelType(channel:Channel.Four, name:ControlType.HVAC), //Climate Module, 4 Controllers
        0x41:DeviceChannelType(channel:Channel.Ten, name:ControlType.Sensor), //10-in-1 Multisensor
        0x45:DeviceChannelType(channel:Channel.Six, name:ControlType.Sensor)] //6-in-1 Multisensor
    
//    static let deviceType: [DeviceType:DeviceTypeCode] = [:]

    // stojao je i class
    static let deviceType:[DeviceType:DeviceTypeCode] = [
        // Gateway & Control series
//        DeviceType(deviceId: 0x01, subId: 0x00):DeviceTypeCode(channel: Channel.One, name:ControlType.CurtainsRS485, MPN: "IPGC256"), // RS232/RS485 Gateway
//        DeviceType(deviceId: 0x01, subId: 0x01):DeviceTypeCode(channel:Channel.One, name:ControlType.CurtainsRS485, MPN: "IPGCW02"), // RS232/RS485 Gateway, DIN rail
//        DeviceType(deviceId: 0x03, subId: 0x00):DeviceTypeCode(channel: Channel.One, name:ControlType.CurtainsRS485, MPN: "RSGW2SP"), // RS232/RS485 Gateway
//        DeviceType(deviceId: 0x03, subId: 0x01):DeviceTypeCode(channel:Channel.One, name:ControlType.CurtainsRS485, MPN: "RSGW2SD"), // RS232/RS485 Gateway, DIN rail
//        DeviceType(deviceId: 0x03, subId: 0x02):DeviceTypeCode(channel:Channel.One, name:ControlType.IntelligentCurtainModule, MPN: "ICM05XX"), // Intelligent Curtain Module
//        DeviceType(deviceId: 0x03, subId: 0x03):DeviceTypeCode(channel: Channel.One, name:ControlType.SaltoAccess, MPN: "S04HOST"), // RS232/RS485 Gateway
//        DeviceType(deviceId: 0x03, subId: 0x04):DeviceTypeCode(channel:Channel.One, name:ControlType.SaltoAccess, MPN: "S08HOST"), // RS232/RS485 Gateway, DIN rail
//        DeviceType(deviceId: 0x03, subId: 0x05):DeviceTypeCode(channel: Channel.One, name:ControlType.SaltoAccess, MPN: "S16HOST"), // RS232/RS485 Gateway
        
        // Dimming Control Series
        DeviceType(deviceId: 0x13, subId: 0x00):DeviceTypeCode(channel:Channel.Four, name:ControlType.Dimmer, MPN: "DM0401A"), // Dimmer Module 4CH, 1A
        DeviceType(deviceId: 0x13, subId: 0x01):DeviceTypeCode(channel:Channel.Four, name:ControlType.Dimmer, MPN: "DM0415A"), // Dimmer Module 4CH, 1.5A
        DeviceType(deviceId: 0x13, subId: 0x02):DeviceTypeCode(channel:Channel.Two, name:ControlType.Dimmer, MPN: "DM0215W"), // Dimmer Module 2CH, 150W
        DeviceType(deviceId: 0x13, subId: 0x03):DeviceTypeCode(channel:Channel.Four, name:ControlType.Dimmer, MPN: "DM0415W"), // Dimmer Module 4CH 150W
        
        DeviceType(deviceId: 0x16, subId: 0x00):DeviceTypeCode(channel:Channel.Eight, name:ControlType.Dimmer, MPN: "DM0801A"), // Dimmer Module 8CH, 1A
        DeviceType(deviceId: 0x16, subId: 0x01):DeviceTypeCode(channel:Channel.Eight, name:ControlType.Dimmer, MPN: "DM0815A"), // Dimmer Module 8CH, 1.5A
        DeviceType(deviceId: 0x16, subId: 0x02):DeviceTypeCode(channel:Channel.Eight, name:ControlType.Dimmer, MPN: "DM0815W"), // Dimmer Module 8CH, 150W
        
        DeviceType(deviceId: 0x11, subId: 0x00):DeviceTypeCode(channel:Channel.Two, name:ControlType.Dimmer, MPN: "DM0202A"), // Dimmer Module 2CH, 2A
        DeviceType(deviceId: 0x11, subId: 0x01):DeviceTypeCode(channel:Channel.Two, name:ControlType.Dimmer, MPN: "DM0203A"), // Dimmer Module 2CH, 3A
        
        DeviceType(deviceId: 0x14, subId: 0x00):DeviceTypeCode(channel:Channel.Four, name:ControlType.Dimmer, MPN: "DM0402A"), // Dimmer Module 4CH, 2A
        DeviceType(deviceId: 0x14, subId: 0x01):DeviceTypeCode(channel:Channel.Four, name:ControlType.Dimmer, MPN: "DM0403A"), // Dimmer Module 4CH, 3A
        
        DeviceType(deviceId: 0x12, subId: 0x00):DeviceTypeCode(channel:Channel.One, name:ControlType.Dimmer, MPN: "DM0104A"), // Dimmer Module 1CH, 4A
        DeviceType(deviceId: 0x12, subId: 0x01):DeviceTypeCode(channel:Channel.One, name:ControlType.Dimmer, MPN: "DM0105A"), // Dimmer Module 1CH, 5A
        DeviceType(deviceId: 0x12, subId: 0x02):DeviceTypeCode(channel:Channel.One, name:ControlType.Dimmer, MPN: "DM0145W"), // Dimmer Module 1CH, 450W
        
        DeviceType(deviceId: 0x15, subId: 0x01):DeviceTypeCode(channel:Channel.Two, name:ControlType.Dimmer, MPN: "DM0204A"), // Dimmer Module 2CH, 4A
        DeviceType(deviceId: 0x15, subId: 0x02):DeviceTypeCode(channel:Channel.Two, name:ControlType.Dimmer, MPN: "DM0205A"), // Dimmer Module 2CH, 5A
        DeviceType(deviceId: 0x15, subId: 0x03):DeviceTypeCode(channel:Channel.Two, name:ControlType.Dimmer, MPN: "DM0245W"), // Dimmer Module 2CH, 450W
        
        // Relay Control Series
        DeviceType(deviceId: 0x21, subId: 0x00):DeviceTypeCode(channel:Channel.Four, name:ControlType.CurtainsRelay, MPN: "RM0405A"), // Change Over Module 4CH, 5A
        DeviceType(deviceId: 0x22, subId: 0x00):DeviceTypeCode(channel:Channel.Four, name:ControlType.Appliance, MPN: "RM0410A"), // Relay Module 4CH 10A
        DeviceType(deviceId: 0x23, subId: 0x00):DeviceTypeCode(channel:Channel.Four, name:ControlType.Appliance, MPN: "RM0416A"), // Relay Module 4CH 16A
        DeviceType(deviceId: 0x24, subId: 0x00):DeviceTypeCode(channel:Channel.Two, name:ControlType.Appliance, MPN: "RM0220A"), // Relay Module 2CH 20A
        DeviceType(deviceId: 0x25, subId: 0x00):DeviceTypeCode(channel:Channel.Eight, name:ControlType.CurtainsRelay, MPN: "RM0805A"), // Change Over Module 8CH, 5A
        DeviceType(deviceId: 0x26, subId: 0x00):DeviceTypeCode(channel:Channel.Eight, name:ControlType.Appliance, MPN: "RM0810A"), // Relay Module 8CH 10A
        DeviceType(deviceId: 0x27, subId: 0x00):DeviceTypeCode(channel:Channel.Eight, name:ControlType.Appliance, MPN: "RM0816A"), // Relay Module 8CH 16A
        
        // Climate Control Series
        DeviceType(deviceId: 0x31, subId: 0x00):DeviceTypeCode(channel:Channel.Two, name:ControlType.HVAC, MPN: "CM1002S"), // Climate Module, 2 Controllers
        DeviceType(deviceId: 0x32, subId: 0x00):DeviceTypeCode(channel:Channel.One, name:ControlType.HVAC, MPN: "CM0604I"), // Climate Module, 1 Controller with I/O
        DeviceType(deviceId: 0x33, subId: 0x00):DeviceTypeCode(channel:Channel.One, name:ControlType.HVAC, MPN: "CM0501S"), // Climate Module, 1 Controller
        DeviceType(deviceId: 0x34, subId: 0x00):DeviceTypeCode(channel:Channel.Four, name:ControlType.HVAC, MPN: "CM2004S"), // Climate Module, 4 Controllers
        DeviceType(deviceId: 0x35, subId: 0x00):DeviceTypeCode(channel:Channel.Two, name:ControlType.HVAC, MPN: "CM1208I"), // Climate Module, 2 Controllers with I/O
        DeviceType(deviceId: 0x04, subId: 0x01):DeviceTypeCode(channel:Channel.One, name: ControlType.HVAC, MPN: "CM051CG"), // Climate Module, 1 Controller Gateway
        DeviceType(deviceId: 0x04, subId: 0x02):DeviceTypeCode(channel: Channel.Two, name:ControlType.HVAC, MPN: "CM102CG"), // Climate Module, 2 Controllers Gateway
        DeviceType(deviceId: 0x04, subId: 0x04):DeviceTypeCode(channel: Channel.Four, name:ControlType.HVAC, MPN: "CM204CG"), // Climate Module, 4 Controllers Gateway
        
        // Human Interface Series
//        DeviceType(deviceId: 0x54, subId: 0x00):DeviceTypeCode(channel: Channel.Twelve, name:ControlType.HumanInterfaceSeries, MPN: "HS04xxx"), // Intelligent Switch, 4 Buttons
//        DeviceType(deviceId: 0x54, subId: 0x00):DeviceTypeCode(channel: Channel.Twelve, name:ControlType.HumanInterfaceSeries, MPN: "HS08xxx"), // Intelligent Switch, 8 Buttons
//        DeviceType(deviceId: 0x72, subId: 0x00):DeviceTypeCode(channel: Channel.Twelve, name:ControlType.HumanInterfaceSeries, MPN: "HS12xxx"), // Intelligent LCD Switch, 12 Buttons
        
        // I/O Series
//        DeviceType(deviceId: 0x42, subId: 0x00):DeviceTypeCode(channel:Channel.Four, name:ControlType.AnalogOutput, MPN: "AO4010V"), // Analog Output Module, 4CH 0-10V
//        DeviceType(deviceId: 0x43, subId: 0x01):DeviceTypeCode(channel:Channel.Four, name:ControlType.DigitalInput, MPN: "DI04GPC"), // Digital Input Module, 4CH
//        DeviceType(deviceId: 0x2A, subId: 0x00):DeviceTypeCode(channel:Channel.Two, name:ControlType.DigitalOutput, MPN: "DO02GPC"), // Digital Output Module, 2CH
//        DeviceType(deviceId: 0x41, subId: 0x00):DeviceTypeCode(channel:Channel.Four, name:ControlType.AnalogInput, MPN: "AI0402S"), // Analog Input Module, 4CH 0-10V/0-20mA
        DeviceType(deviceId: 0x45, subId: 0x00):DeviceTypeCode(channel:Channel.Ten, name:ControlType.Sensor, MPN: "MSIX08C"), // 10-in-1 Multisensor, Indoor Ceiling Mount
        DeviceType(deviceId: 0x45, subId: 0x01):DeviceTypeCode(channel:Channel.Six, name:ControlType.Sensor, MPN: "MSI605C"), // 6-in-1 Multisensor, Indoor Ceiling Mount
        DeviceType(deviceId: 0x44, subId: 0x00):DeviceTypeCode(channel:Channel.Six, name:ControlType.Sensor, MPN: "MSI605W"), // 6-in-1 Multisensor, Indoor Wall Mount number
//        DeviceType(deviceId: 0x47, subId: 0x00):DeviceTypeCode(channel:Channel.Two, name:ControlType.IRTransmitter, MPN: "MS0502S"), // IR Transmitter, 2CH with 2 AI
    ]
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