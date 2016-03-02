//
//  IncomingHandler+Extensions.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/30/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

// Curtain
extension IncomingHandler {
    func ackonowledgementAboutCurtainState(byteArray:[Byte]) {
        fetchDevices()
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) {
                device.currentValue = Int(byteArray[8])
                let data = ["deviceDidReceiveSignalFromGateway":device]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveDataForRepeatSendingHandler, object: self, userInfo: data)
                break
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
}
// New devices
extension IncomingHandler {
    //  informacije o novim uredjajima
    func acknowledgementAboutNewDevices (byteArray:[Byte]) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDevice) {
            var deviceExists = false
            if let channel = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.channel, let name = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                if devices != [] {
                    for device in devices {
                        if device.address == Int(byteArray[4]) {deviceExists = true}
                    }
                } else {
                    deviceExists = false
                }
                if !deviceExists {
                    for var i=1 ; i<=channel ; i++ {
                        if channel == 10 && name == ControlType.Sensor && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        } else if channel == 6 && name == ControlType.Sensor && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        } else if name == ControlType.Climate {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.currentValue = 0
                            device.runningTime = "00:00:00,0s"
                            device.mode = "AUTO"
                            device.modeState = "Off"
                            device.speed = "AUTO"
                            device.speedState = "Off"
                            device.coolTemperature = 0
                            device.heatTemperature = 0
                            device.roomTemperature = 0
                            device.humidity = 0
                            device.current = 0
                            saveChanges()
                        } else if name == ControlType.Gateway || name == ControlType.Access || name == ControlType.AnalogInput || name == ControlType.AnalogOutput || name == ControlType.DigitalInput || name == ControlType.DigitalOutput || name == ControlType.IRTransmitter {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.currentValue = 0
                            device.runningTime = "00:00:00,0s"
                            device.current = 0
                            saveChanges()
                        } else if channel == 5 && name == ControlType.HumanInterfaceSeries && i > 1 {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.isVisible = false
                            device.isEnabled = false
                            saveChanges()
                        } else if name == ControlType.Curtain {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.currentValue = 0
                            device.runningTime = "00:00:00,0s"
                            device.current = 0
                            saveChanges()
                        } else if name != ControlType.Climate && name != ControlType.Sensor && name != ControlType.HumanInterfaceSeries {
                            let device = Device(context: appDel.managedObjectContext!)
                            device.name = "Unknown"
                            device.address = Int(byteArray[4])
                            device.channel = i
                            device.numberOfDevices = channel
                            device.runningTime = ""
                            device.currentValue = 0
                            device.current = 0
                            device.runningTime = "00:00:00,0s"
                            device.amp = ""
                            device.type = name
                            device.controlType = name
                            device.voltage = 0
                            device.temperature = 0
                            device.gateway = gateways[0] // OVDE BI TREBALO DA BUDE SAMO JEDAN, NIKAKO DVA ILI VISE
                            device.delay = 0
                            device.runtime = 0
                            device.skipState = 0
                            saveChanges()
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
                    }
                    let data = ["deviceAddresInGateway":Int(byteArray[4])]
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDevice, object: self, userInfo: data)
                }
            }
        }
    }
//    func getImagesForDevice () -> [DeviceImage] {
//        // prvo nadji po kategoriji
//        // ako ne nadje nista vrati defaultno
//        
//    }
//    static func returnPictures(type:String, categoryId:Int, motionSensor:Bool) -> [DeviceImageInfo] {
//        // climate nema nista
//        if motionSensor {
//            return [DeviceImageInfo(defaultImage: "14 Security - Motion Sensor - 00", state: 1), DeviceImageInfo(defaultImage: "14 Security - Motion Sensor - 01", state: 2), DeviceImageInfo(defaultImage: "14 Security - Motion Sensor - 02", state: 3)]
//        }
//        if categoryId != 0 || categoryId != 1 || categoryId != 5 || categoryId != 6 || categoryId != 7 || categoryId != 8 || categoryId != 9 || categoryId != 10 {
//            
//        }
////        static let CurtainsRS485 = "Curtains RS485"
////        static let Gateway = "Gateway"
////        static let CurtainsRelay = "Curtains Relay"
////        static let PC = "PC"
////        static let HVAC = "HVAC"
////        static let Climate = "Climate"
////        static let Sensor = "Sensor"
////        static let HumanInterfaceSeries = "Intelligent Switch"
////        static let AnalogOutput = "Analog Output"
////        static let DigitalInput = "Digital Input"
////        static let DigitalOutput = "Digital Output"
////        static let AnalogInput = "Analog Input"
////        static let IRTransmitter = "IR Transmitter"
////        static let Access = "Access"
////        static let Curtain = "Curtain"
//        if type == ControlType.Dimmer {
//            
//        }
//        if type == ControlType.Relay {
//            
//        }
//        if type == ControlType.Appliance {
//            
//        }
//        if type == ControlType.Sensor {
//            
//        }
//        if type == ControlType.Sensor {
//            
//        }
//        if type == ControlType.HumanInterfaceSeries {
//            
//        }
//        //        1 - Gateway & Control
//        //        2 - Dimming Control *
//        //        3 - Relay Control *
//        //        4 - Climate Control *
//        //        5 - Human Interface
//        //        6 - Input\\/Output
//        //        7 - Power Supply
//        //        8 - Reserved 8
//        //        9 - Reserved 9
//        //        10 - Reserved 10
//        //        11 - Lighting *
//        //        12 - Appliance *
//        //        13 - Curtain *
//        //        14 - Security *
//        //        15 - Timer *
//        //        16 - Flag *
//        //        17 - Event *
//        //        18 - Media *
//        //        19 - Blind *
//        //        255 - Default
//        //        if type == "Dimmer" {
//        if categoryId == 2 {
//            if deviceValue == 0 {
//                return UIImage(named: "lightBulb")
//            } else if deviceValue > 0 && deviceValue < 0.1 {
//                return UIImage(named: "lightBulb1")
//            } else if deviceValue >= 0.1 && deviceValue < 0.2 {
//                return UIImage(named: "lightBulb2")
//            } else if deviceValue >= 0.2 && deviceValue < 0.3 {
//                return UIImage(named: "lightBulb3")
//            } else if deviceValue >= 0.3 && deviceValue < 0.4 {
//                return UIImage(named: "lightBulb4")
//            } else if deviceValue >= 0.4 && deviceValue < 0.5 {
//                return UIImage(named: "lightBulb5")
//            } else if deviceValue >= 0.5 && deviceValue < 0.6 {
//                return UIImage(named: "lightBulb6")
//            } else if deviceValue >= 0.6 && deviceValue < 0.7 {
//                return UIImage(named: "lightBulb7")
//            } else if deviceValue >= 0.7 && deviceValue < 0.8 {
//                return UIImage(named: "lightBulb8")
//            } else if deviceValue >= 0.8 && deviceValue < 0.9 {
//                return UIImage(named: "lightBulb9")
//            } else {
//                return UIImage(named: "lightBulb10")
//            }
//        } else if categoryId == 3 {
//            if deviceValue == 0 {
//                return UIImage(named: "applianceoff")!
//            } else {
//                return UIImage(named: "applianceon")!
//            }
//            //                return [UIImage(named: "")!, UIImage(named: "")!]
//        } else if categoryId == 4 {
//            if deviceValue == 0 {
//                return UIImage(named: "04 Climate Control - HVAC - 00")!
//            } else {
//                return UIImage(named: "04 Climate Control - HVAC - 01")!
//            }
//            //                return [UIImage(named: "04 Climate Control - HVAC - 00")!, UIImage(named: "04 Climate Control - HVAC - 01")!]
//        } else if categoryId == 11 {
//            if deviceValue == 0 {
//                return UIImage(named: "lightBulb")
//            } else if deviceValue > 0 && deviceValue < 0.1 {
//                return UIImage(named: "lightBulb1")
//            } else if deviceValue >= 0.1 && deviceValue < 0.2 {
//                return UIImage(named: "lightBulb2")
//            } else if deviceValue >= 0.2 && deviceValue < 0.3 {
//                return UIImage(named: "lightBulb3")
//            } else if deviceValue >= 0.3 && deviceValue < 0.4 {
//                return UIImage(named: "lightBulb4")
//            } else if deviceValue >= 0.4 && deviceValue < 0.5 {
//                return UIImage(named: "lightBulb5")
//            } else if deviceValue >= 0.5 && deviceValue < 0.6 {
//                return UIImage(named: "lightBulb6")
//            } else if deviceValue >= 0.6 && deviceValue < 0.7 {
//                return UIImage(named: "lightBulb7")
//            } else if deviceValue >= 0.7 && deviceValue < 0.8 {
//                return UIImage(named: "lightBulb8")
//            } else if deviceValue >= 0.8 && deviceValue < 0.9 {
//                return UIImage(named: "lightBulb9")
//            } else {
//                return UIImage(named: "lightBulb10")
//            }
//            //                return [UIImage(named: "11 Lighting - Bulb - 00")!, UIImage(named: "11 Lighting - Bulb - 10")!]
//            //                11 Lighting - Bulb - 00
//            //                11 Lighting - Bulb - 01
//            //                11 Lighting - Bulb - 02
//            //                11 Lighting - Bulb - 03
//            //                11 Lighting - Bulb - 04
//            //                11 Lighting - Bulb - 05
//            //                11 Lighting - Bulb - 06
//            //                11 Lighting - Bulb - 07
//            //                11 Lighting - Bulb - 08
//            //                11 Lighting - Bulb - 09
//            //                11 Lighting - Bulb - 10
//        } else if categoryId == 12 {
//            if deviceValue == 0 {
//                return UIImage(named: "12 Appliance - Power - 00")!
//            } else {
//                return UIImage(named: "12 Appliance - Power - 01")!
//            }
//            //                return [UIImage(named: "12 Appliance - Power - 00")!, UIImage(named: "12 Appliance - Power - 01")!]
//        } else if categoryId == 13 {
//            //                return [UIImage(named: "13 Curtain - Curtain - 00")!, UIImage(named: "13 Curtain - Curtain - 04")!]
//            if deviceValue == 0 {
//                return UIImage(named: "13 Curtain - Curtain - 00")
//            } else if deviceValue <= 1/3 {
//                return UIImage(named: "13 Curtain - Curtain - 01")
//            } else if deviceValue <= 2/3 {
//                return UIImage(named: "13 Curtain - Curtain - 02")
//            } else if deviceValue < 3/3 {
//                return UIImage(named: "13 Curtain - Curtain - 03")
//            } else {
//                return UIImage(named: "13 Curtain - Curtain - 04")
//            }
//            //                13 Curtain - Curtain - 00
//            //                13 Curtain - Curtain - 01
//            //                13 Curtain - Curtain - 02
//            //                13 Curtain - Curtain - 03
//            //                13 Curtain - Curtain - 04
//        } else if categoryId == 14 {
//            if motionSensor {
//                //                    if devices[indexPath.row].currentValue == 1 {
//                //                        cell.sensorImage.image = UIImage(named: "sensor_motion")
//                //                    } else if devices[indexPath.row].currentValue == 0 {
//                //                        cell.sensorImage.image = UIImage(named: "sensor_idle")
//                //                    } else {
//                //                        cell.sensorImage.image = UIImage(named: "sensor_third")
//                //                    }
//                if deviceValue == 0 {
//                    return UIImage(named: "14 Security - Motion Sensor - 00")!
//                } else if deviceValue == 1 {
//                    return UIImage(named: "14 Security - Motion Sensor - 01")!
//                } else {
//                    return UIImage(named: "14 Security - Motion Sensor - 02")!
//                }
//            } else {
//                if deviceValue == 0 {
//                    return UIImage(named: "14 Security - Lock - 00")!
//                } else {
//                    return UIImage(named: "14 Security - Lock - 01")!
//                }
//                //                    return [UIImage(named: "")!, UIImage(named: "")!]// OVDE JE PROBLEM
//                //                    return UIImage(named: "14 Security - Lock - 00")!// OVDE JE PROBLEM
//                //                    return UIImage(named: "14 Security - Lock - 01")!// OVDE JE PROBLEM
//            }
//            //                //                14 Security - Motion Sensor - 00
//            //                //                14 Security - Motion Sensor - 01
//            //                //                14 Security - Motion Sensor - 02
//            //                //                14 Security - Lock - 00
//            //                //                14 Security - Lock - 01
//        } else if categoryId == 15 {
//            if deviceValue == 0 {
//                return UIImage(named: "15 Timer - CLock - 00")!
//            } else {
//                return UIImage(named: "15 Timer - CLock - 01")!
//            }
//            //                return [UIImage(named: "15 Timer - CLock - 00")!, UIImage(named: "15 Timer - CLock - 01")!]
//        } else if categoryId == 16 {
//            if deviceValue == 0 {
//                return UIImage(named: "16 Flag - Flag - 00")!
//            } else {
//                return UIImage(named: "16 Flag - Flag - 01")!
//            }
//            //                return [UIImage(named: "16 Flag - Flag - 00")!, UIImage(named: "16 Flag - Flag - 01")!]
//        } else if categoryId == 17 {
//            if deviceValue == 0 {
//                return UIImage(named: "17 Event - Up Down - 00")!
//            } else {
//                return UIImage(named: "17 Event - Up Down - 01")!
//            }
//            //                return [UIImage(named: "17 Event - Up Down - 00")!, UIImage(named: "17 Event - Up Down - 01")!]
//        } else if categoryId == 18 {
//            if deviceValue == 0 {
//                return UIImage(named: "18 Media - LCD TV - 00")!
//            } else {
//                return UIImage(named: "18 Media - LCD TV - 01")!
//            }
//            //                return [UIImage(named: "18 Media - LCD TV - 00")!, UIImage(named: "18 Media - LCD TV - 01")!]
//        } else if categoryId == 19 {
//            if deviceValue == 0 {
//                return UIImage(named: "19 Blind - Blind - 00")
//            } else if deviceValue <= 0.2 {
//                return UIImage(named: "19 Blind - Blind - 01")!
//            } else if deviceValue <= 0.4 {
//                return UIImage(named: "19 Blind - Blind - 02")!
//            } else if deviceValue <= 0.6 {
//                return UIImage(named: "19 Blind - Blind - 03")!
//            } else if deviceValue <= 0.8 {
//                return UIImage(named: "19 Blind - Blind - 04")!
//            } else if deviceValue < 1 {
//                return UIImage(named: "19 Blind - Blind - 05")!
//            } else {
//                return UIImage(named: "19 Blind - Blind - 06")
//            }
//            //                return [UIImage(named: "19 Blind - Blind - 00")!, UIImage(named: "19 Blind - Blind - 06")!]
//            //                19 Blind - Blind - 00
//            //                19 Blind - Blind - 01
//            //                19 Blind - Blind - 02
//            //                19 Blind - Blind - 03
//            //                19 Blind - Blind - 04
//            //                19 Blind - Blind - 05
//            //                19 Blind - Blind - 06
//        }
//        //        } else if type == "curtainsRS485" {
//        //
//        //        } else if type == "curtainsRelay" {
//        //
//        //        } else if type == "appliance" {
//        //
//        //        } else if type == "hvac" {
//        //
//        //        } else if type == "sensor" {
//        //
//        //        }
//        return nil
////    }
//}
//struct DeviceImageInfo {
//    let defaultImage:String
//    let state:Int
}