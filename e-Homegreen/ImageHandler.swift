//
//  ImageHandler.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 11/27/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ImageHandler: NSObject {
//    static func returnPictures(type:String, categoryId:Int, deviceValue:Float, motionSensor:Bool) -> UIImage? {
    static func returnPictures(categoryId:Int, deviceValue:Double, motionSensor:Bool) -> UIImage? {
    
        //        1 - Gateway & Control
        //        2 - Dimming Control *
        //        3 - Relay Control *
        //        4 - Climate Control *
        //        5 - Human Interface
        //        6 - Input\\/Output
        //        7 - Power Supply
        //        8 - Reserved 8
        //        9 - Reserved 9
        //        10 - Reserved 10
        //        11 - Lighting *
        //        12 - Appliance *
        //        13 - Curtain *
        //        14 - Security *
        //        15 - Timer *
        //        16 - Flag *
        //        17 - Event *
        //        18 - Media *
        //        19 - Blind *
        //        255 - Default
//        if type == "Dimmer" {
            if categoryId == 2 {
                if deviceValue == 0 {
                    return UIImage(named: "lightBulb")
                } else if deviceValue > 0 && deviceValue < 10{ //0.1 {
                    return UIImage(named: "lightBulb1")
                } else if deviceValue >= 0.1 && deviceValue < 20{//0.2 {
                    return UIImage(named: "lightBulb2")
                } else if deviceValue >= 0.2 && deviceValue < 30{//0.3 {
                    return UIImage(named: "lightBulb3")
                } else if deviceValue >= 0.3 && deviceValue < 40{//0.4 {
                    return UIImage(named: "lightBulb4")
                } else if deviceValue >= 0.4 && deviceValue < 50{//0.5 {
                    return UIImage(named: "lightBulb5")
                } else if deviceValue >= 0.5 && deviceValue < 60{//0.6 {
                    return UIImage(named: "lightBulb6")
                } else if deviceValue >= 0.6 && deviceValue < 70{//0.7 {
                    return UIImage(named: "lightBulb7")
                } else if deviceValue >= 0.7 && deviceValue < 80{//0.8 {
                    return UIImage(named: "lightBulb8")
                } else if deviceValue >= 0.8 && deviceValue < 90{//0.9 {
                    return UIImage(named: "lightBulb9")
                } else {
                    return UIImage(named: "lightBulb10")
                }
            } else if categoryId == 3 {
                    if deviceValue == 0 {
                        return UIImage(named: "applianceoff")!
                    } else {
                        return UIImage(named: "applianceon")!
                    }
//                return [UIImage(named: "")!, UIImage(named: "")!]
            }
            else if categoryId == 4 {
                if deviceValue == 0 {
                    return UIImage(named: "04 Climate Control - HVAC - 00")!
                } else {
                    return UIImage(named: "04 Climate Control - HVAC - 01")!
                }
//                return [UIImage(named: "04 Climate Control - HVAC - 00")!, UIImage(named: "04 Climate Control - HVAC - 01")!]
            }
            else if categoryId == 11 {
                if deviceValue == 0 {
                    return UIImage(named: "lightBulb")
                } else if deviceValue > 0 && deviceValue < 10{//0.1 {
                    return UIImage(named: "lightBulb1")
                } else if deviceValue >= 0.1 && deviceValue < 20{//0.2 {
                    return UIImage(named: "lightBulb2")
                } else if deviceValue >= 0.2 && deviceValue < 30{//0.3 {
                    return UIImage(named: "lightBulb3")
                } else if deviceValue >= 0.3 && deviceValue < 40{//0.4 {
                    return UIImage(named: "lightBulb4")
                } else if deviceValue >= 0.4 && deviceValue < 50{//0.5 {
                    return UIImage(named: "lightBulb5")
                } else if deviceValue >= 0.5 && deviceValue < 60{//0.6 {
                    return UIImage(named: "lightBulb6")
                } else if deviceValue >= 0.6 && deviceValue < 70{//0.7 {
                    return UIImage(named: "lightBulb7")
                } else if deviceValue >= 0.7 && deviceValue < 80{//0.8 {
                    return UIImage(named: "lightBulb8")
                } else if deviceValue >= 0.8 && deviceValue < 90{//0.9 {
                    return UIImage(named: "lightBulb9")
                } else {
                    return UIImage(named: "lightBulb10")
                }
//                return [UIImage(named: "11 Lighting - Bulb - 00")!, UIImage(named: "11 Lighting - Bulb - 10")!]
                //                11 Lighting - Bulb - 00
                //                11 Lighting - Bulb - 01
                //                11 Lighting - Bulb - 02
                //                11 Lighting - Bulb - 03
                //                11 Lighting - Bulb - 04
                //                11 Lighting - Bulb - 05
                //                11 Lighting - Bulb - 06
                //                11 Lighting - Bulb - 07
                //                11 Lighting - Bulb - 08
                //                11 Lighting - Bulb - 09
                //                11 Lighting - Bulb - 10
            }
            else if categoryId == 12 {
                if deviceValue == 0 {
                    return UIImage(named: "12 Appliance - Power - 00")!
                } else {
                    return UIImage(named: "12 Appliance - Power - 01")!
                }
//                return [UIImage(named: "12 Appliance - Power - 00")!, UIImage(named: "12 Appliance - Power - 01")!]
            }
            else if categoryId == 13 {
                if deviceValue == 0 {
                    return UIImage(named: "curtain0")
                } else if deviceValue <= 95 {
                    return UIImage(named: "curtain2")
                } else {
                    return UIImage(named: "curtain4")
                }
            } else if categoryId == 14 {
                if motionSensor {
//                    if devices[indexPath.row].currentValue == 1 {
//                        cell.sensorImage.image = UIImage(named: "sensor_motion")
//                    } else if devices[indexPath.row].currentValue == 0 {
//                        cell.sensorImage.image = UIImage(named: "sensor_idle")
//                    } else {
//                        cell.sensorImage.image = UIImage(named: "sensor_third")
//                    }
                    if deviceValue == 0 {
                        return UIImage(named: "14 Security - Motion Sensor - 00")!
                    } else if deviceValue == 100 { //1 {
                        return UIImage(named: "14 Security - Motion Sensor - 01")!
                    } else {
                        return UIImage(named: "14 Security - Motion Sensor - 02")!
                    }
                } else {
                    if deviceValue == 0 {
                        return UIImage(named: "14 Security - Lock - 00")!
                    } else {
                        return UIImage(named: "14 Security - Lock - 01")!
                    }
//                    return [UIImage(named: "")!, UIImage(named: "")!]// OVDE JE PROBLEM
//                    return UIImage(named: "14 Security - Lock - 00")!// OVDE JE PROBLEM
//                    return UIImage(named: "14 Security - Lock - 01")!// OVDE JE PROBLEM
                }
//                //                14 Security - Motion Sensor - 00
//                //                14 Security - Motion Sensor - 01
//                //                14 Security - Motion Sensor - 02
//                //                14 Security - Lock - 00
//                //                14 Security - Lock - 01
            }
            else if categoryId == 15 {
                if deviceValue == 0 {
                    return UIImage(named: "15 Timer - CLock - 00")!
                } else {
                    return UIImage(named: "15 Timer - CLock - 01")!
                }
//                return [UIImage(named: "15 Timer - CLock - 00")!, UIImage(named: "15 Timer - CLock - 01")!]
            }
            else if categoryId == 16 {
                if deviceValue == 0 {
                    return UIImage(named: "16 Flag - Flag - 00")!
                } else {
                    return UIImage(named: "16 Flag - Flag - 01")!
                }
//                return [UIImage(named: "16 Flag - Flag - 00")!, UIImage(named: "16 Flag - Flag - 01")!]
            }
            else if categoryId == 17 {
                if deviceValue == 0 {
                    return UIImage(named: "17 Event - Up Down - 00")!
                } else {
                    return UIImage(named: "17 Event - Up Down - 01")!
                }
//                return [UIImage(named: "17 Event - Up Down - 00")!, UIImage(named: "17 Event - Up Down - 01")!]
            }
            else if categoryId == 18 {
                if deviceValue == 0 {
                    return UIImage(named: "18 Media - LCD TV - 00")!
                } else {
                    return UIImage(named: "18 Media - LCD TV - 01")!
                }
//                return [UIImage(named: "18 Media - LCD TV - 00")!, UIImage(named: "18 Media - LCD TV - 01")!]
            }
            else if categoryId == 19 {
                if deviceValue == 0 {
                    return UIImage(named: "19 Blind - Blind - 00")
                } else if deviceValue <= 20{//{0.2 {
                    return UIImage(named: "19 Blind - Blind - 01")!
                } else if deviceValue <= 40{//{0.4 {
                    return UIImage(named: "19 Blind - Blind - 02")!
                } else if deviceValue <= 60{//{0.6 {
                    return UIImage(named: "19 Blind - Blind - 03")!
                } else if deviceValue <= 80{//{0.8 {
                    return UIImage(named: "19 Blind - Blind - 04")!
                } else if deviceValue < 100{//{1 {
                    return UIImage(named: "19 Blind - Blind - 05")!
                } else {
                    return UIImage(named: "19 Blind - Blind - 06")
                }
//                return [UIImage(named: "19 Blind - Blind - 00")!, UIImage(named: "19 Blind - Blind - 06")!]
                //                19 Blind - Blind - 00
                //                19 Blind - Blind - 01
                //                19 Blind - Blind - 02
                //                19 Blind - Blind - 03
                //                19 Blind - Blind - 04
                //                19 Blind - Blind - 05
                //                19 Blind - Blind - 06
            }
//        } else if type == "curtainsRS485" {
//            
//        } else if type == "curtainsRelay" {
//            
//        } else if type == "appliance" {
//            
//        } else if type == "hvac" {
//            
//        } else if type == "sensor" {
//            
//        }
        return nil
    }
}
