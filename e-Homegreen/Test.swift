////
////  Test.swift
////  e-Homegreen
////
////  Created by Teodor Stevic on 3/4/16.
////  Copyright © 2016 Teodor Stevic. All rights reserved.
////
//
//import UIKit
//
//struct TestTest {
//    let defaultImage:String
//    let state:Int
//}
//
//class Test: NSObject {
//    func getNewImagesForDevice (device:Device) -> [TestTest] {
//        
//            // prvo nadji po kategoriji
//        let categoryId = device.categoryId
//        let controlType = device.controlType
//        // Importan for multisensor device (specialy motion sensor_
//        let channel = device.channel
//        //MARK: Find images if device is multi sensor
//        if controlType == ControlType.HumanInterfaceSeries && channel == 6  {
//            return [TestTest(defaultImage: "14 Security - Motion Sensor - 00", state: DeviceValue.MotionSensor.Idle),
//                TestTest(defaultImage: "14 Security - Motion Sensor - 01", state: DeviceValue.MotionSensor.Motion),
//                TestTest(defaultImage: "14 Security - Motion Sensor - 02", state: DeviceValue.MotionSensor.IdleWarning),
//                TestTest(defaultImage: "14 Security - Motion Sensor - 02", state: DeviceValue.MotionSensor.ResetTimer)]
//        }
//        //MARK: Find images for category id
//        //            CategoryId.GatewayControl = 1
//        //            CategoryId.DimmingControl = 2 *
//        //            CategoryId.RelayControl = 3 *
//        //            CategoryId.ClimateControl = 4 *
//        //            CategoryId.HumanInterface = 5
//        //            CategoryId.InputOutput = 6
//        //            CategoryId.PowerSupply = 7
//        //            CategoryId.Reserved8 = 8
//        //            CategoryId.Reserved9 = 9
//        //            CategoryId.Reserved10 = 10
//        //            CategoryId.Lighting = 11 *
//        //            CategoryId.Appliance = 12 *
//        //            CategoryId.Curtain = 13 *
//        //            CategoryId.Security = 14 *
//        //            CategoryId.Timer = 15 *
//        //            CategoryId.Flag = 16 *
//        //            CategoryId.Event = 17 *
//        //            CategoryId.Media = 18 *
//        //            CategoryId.Blind = 19 *
//        //            CategoryId.Default = 255
//        
//        if categoryId == CategoryId.DimmingControl {
//            return [TestTest(defaultImage: "11 Lighting - Bulb - 00", state: 0),
//                TestTest(defaultImage: "11 Lighting - Bulb - 01", state: 1),
//                TestTest(defaultImage: "11 Lighting - Bulb - 02", state: 2),
//                TestTest(defaultImage: "11 Lighting - Bulb - 03", state: 3),
//                TestTest(defaultImage: "11 Lighting - Bulb - 04", state: 4),
//                TestTest(defaultImage: "11 Lighting - Bulb - 05", state: 5),
//                TestTest(defaultImage: "11 Lighting - Bulb - 06", state: 6),
//                TestTest(defaultImage: "11 Lighting - Bulb - 07", state: 7),
//                TestTest(defaultImage: "11 Lighting - Bulb - 08", state: 8),
//                TestTest(defaultImage: "11 Lighting - Bulb - 09", state: 9),
//                TestTest(defaultImage: "11 Lighting - Bulb - 10", state: 10)]
//        }
//        if categoryId == CategoryId.RelayControl {
//            return [TestTest(defaultImage: "12 Appliance - Switch - 00", state: 0),
//                TestTest(defaultImage: "12 Appliance - Switch - 01", state: 1)]
//        }
//        if categoryId == CategoryId.ClimateControl {
//            return [TestTest(defaultImage: "04 Climate Control - HVAC - 00", state: 0),
//                TestTest(defaultImage: "04 Climate Control - HVAC - 01", state: 1)]
//        }
//        if categoryId == CategoryId.Lighting {
//            return [TestTest(defaultImage: "11 Lighting - Bulb - 00", state: 0),
//                TestTest(defaultImage: "11 Lighting - Bulb - 01", state: 1),
//                TestTest(defaultImage: "11 Lighting - Bulb - 02", state: 2),
//                TestTest(defaultImage: "11 Lighting - Bulb - 03", state: 3),
//                TestTest(defaultImage: "11 Lighting - Bulb - 04", state: 4),
//                TestTest(defaultImage: "11 Lighting - Bulb - 05", state: 5),
//                TestTest(defaultImage: "11 Lighting - Bulb - 06", state: 6),
//                TestTest(defaultImage: "11 Lighting - Bulb - 07", state: 7),
//                TestTest(defaultImage: "11 Lighting - Bulb - 08", state: 8),
//                TestTest(defaultImage: "11 Lighting - Bulb - 09", state: 9),
//                TestTest(defaultImage: "11 Lighting - Bulb - 10", state: 10)]
//        }
//        if categoryId == CategoryId.Appliance {
//            return [TestTest(defaultImage: "12 Appliance - Power - 00", state: 0),
//                TestTest(defaultImage: "12 Appliance - Power - 01", state: 1)]
//        }
//        if categoryId == CategoryId.Curtain {
//            return [TestTest(defaultImage: "13 Curtain - Curtain - 00", state: 0),
//                TestTest(defaultImage: "13 Curtain - Curtain - 01", state: 1),
//                TestTest(defaultImage: "13 Curtain - Curtain - 02", state: 2),
//                TestTest(defaultImage: "13 Curtain - Curtain - 03", state: 3),
//                TestTest(defaultImage: "13 Curtain - Curtain - 04", state: 4)]
//        }
//        if categoryId == CategoryId.Security {
//            return [TestTest(defaultImage: "14 Security - Lock - 00", state: 0),
//                TestTest(defaultImage: "14 Security - Lock - 01", state: 1)]
//        }
//        if categoryId == CategoryId.Timer {
//            return [TestTest(defaultImage: "15 Timer - CLock - 00", state: 0),
//                TestTest(defaultImage: "15 Timer - CLock - 01", state: 1)]
//        }
//        if categoryId == CategoryId.Flag {
//            return [TestTest(defaultImage: "16 Flag - Flag - 00", state: 0),
//                TestTest(defaultImage: "16 Flag - Flag - 01", state: 1)]
//        }
//        if categoryId == CategoryId.Event {
//            return [TestTest(defaultImage: "17 Event - Up Down - 00", state: 0),
//                TestTest(defaultImage: "17 Event - Up Down - 01", state: 1)]
//        }
//        if categoryId == CategoryId.Media {
//            return [TestTest(defaultImage: "18 Media - LCD TV - 00", state: 0),
//                TestTest(defaultImage: "18 Media - LCD TV - 01", state: 1)]
//        }
//        if categoryId == CategoryId.Blind {
//            return [TestTest(defaultImage: "19 Blind - Blind - 00", state: 0),
//                TestTest(defaultImage: "19 Blind - Blind - 01", state: 1),
//                TestTest(defaultImage: "19 Blind - Blind - 02", state: 2),
//                TestTest(defaultImage: "19 Blind - Blind - 03", state: 3),
//                TestTest(defaultImage: "19 Blind - Blind - 04", state: 4),
//                TestTest(defaultImage: "19 Blind - Blind - 05", state: 5),
//                TestTest(defaultImage: "19 Blind - Blind - 06", state: 6)]
//        }
//        if categoryId != 0 || categoryId != 1 || categoryId != 5 || categoryId != 6 || categoryId != 7 || categoryId != 8 || categoryId != 9 || categoryId != 10 {
//            
//        }
//        //MARK: Find images for control type
//        if controlType == ControlType.Dimmer {
//            return [TestTest(defaultImage: "11 Lighting - Bulb - 00", state: 0),
//                TestTest(defaultImage: "11 Lighting - Bulb - 01", state: 1),
//                TestTest(defaultImage: "11 Lighting - Bulb - 02", state: 2),
//                TestTest(defaultImage: "11 Lighting - Bulb - 03", state: 3),
//                TestTest(defaultImage: "11 Lighting - Bulb - 04", state: 4),
//                TestTest(defaultImage: "11 Lighting - Bulb - 05", state: 5),
//                TestTest(defaultImage: "11 Lighting - Bulb - 06", state: 6),
//                TestTest(defaultImage: "11 Lighting - Bulb - 07", state: 7),
//                TestTest(defaultImage: "11 Lighting - Bulb - 08", state: 8),
//                TestTest(defaultImage: "11 Lighting - Bulb - 09", state: 9),
//                TestTest(defaultImage: "11 Lighting - Bulb - 10", state: 10)]
//        }
//        if controlType == ControlType.Relay {
//            //TODO:- OVO
//        }
//        if controlType == ControlType.Appliance {
//            //TODO:- OVO
//            
//        }
//        if controlType == ControlType.Sensor {
//            //TODO:- OVO
//            
//        }
//        if controlType == ControlType.Sensor {
//            //TODO:- OVO
//            
//        }
//        if controlType == ControlType.HumanInterfaceSeries {
//            //TODO:- OVO i treba jos i gateway i LCD
//            
//        }
//        
//        
//            
//
//            
//    //        static let CurtainsRS485 = "Curtains RS485"
//    //        static let Gateway = "Gateway"
//    //        static let CurtainsRelay = "Curtains Relay"
//    //        static let PC = "PC"
//    //        static let HVAC = "HVAC"
//    //        static let Climate = "Climate"
//    //        static let Sensor = "Sensor"
//    //        static let HumanInterfaceSeries = "Intelligent Switch"
//    //        static let AnalogOutput = "Analog Output"
//    //        static let DigitalInput = "Digital Input"
//    //        static let DigitalOutput = "Digital Output"
//    //        static let AnalogInput = "Analog Input"
//    //        static let IRTransmitter = "IR Transmitter"
//    //        static let Access = "Access"
//    //        static let Curtain = "Curtain"
//            
//            //        1 - Gateway & Control
//            //        2 - Dimming Control *
//            //        3 - Relay Control *
//            //        4 - Climate Control *
//            //        5 - Human Interface
//            //        6 - Input\\/Output
//            //        7 - Power Supply
//            //        8 - Reserved 8
//            //        9 - Reserved 9
//            //        10 - Reserved 10
//            //        11 - Lighting *
//            //        12 - Appliance *
//            //        13 - Curtain *
//            //        14 - Security *
//            //        15 - Timer *
//            //        16 - Flag *
//            //        17 - Event *
//            //        18 - Media *
//            //        19 - Blind *
//            //        255 - Default
//        
//            return nil
//    //    }
//    }
//}
