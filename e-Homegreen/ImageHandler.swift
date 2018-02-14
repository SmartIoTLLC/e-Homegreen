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
    static func returnPictures(_ categoryId:Int, deviceValue:Double, motionSensor:Bool) -> UIImage? {
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
        switch categoryId {
            case 2:
                if deviceValue == 0 { return UIImage(named: "lightBulb") }
                else if deviceValue > 0 && deviceValue < 0.1*255{ return UIImage(named: "lightBulb1") } // 0.1
                else if deviceValue >= 0.1*255 && deviceValue < 0.2*255 { return UIImage(named: "lightBulb2") } // 0.2
                else if deviceValue >= 0.2*255 && deviceValue < 0.3*255 { return UIImage(named: "lightBulb3") } // 0.3
                else if deviceValue >= 0.3*255 && deviceValue < 0.4*255 { return UIImage(named: "lightBulb4") } // 0.4
                else if deviceValue >= 0.4*255 && deviceValue < 0.5*255 { return UIImage(named: "lightBulb5") } // 0.5
                else if deviceValue >= 0.5*255 && deviceValue < 0.6*255 { return UIImage(named: "lightBulb6") } // 0.6
                else if deviceValue >= 0.6*255 && deviceValue < 0.7*255 { return UIImage(named: "lightBulb7") } // 0.7
                else if deviceValue >= 0.7*255 && deviceValue < 0.8*255 { return UIImage(named: "lightBulb8") } // 0.8
                else if deviceValue >= 0.8*255 && deviceValue < 0.9*255 { return UIImage(named: "lightBulb9") } // 0.9
                else { return UIImage(named: "lightBulb10") }
            
            case 3:
                if deviceValue == 0 { return UIImage(named: "applianceoff")! } else { return UIImage(named: "applianceon")! }
            
            case 4:
                if deviceValue == 0 { return UIImage(named: "04 Climate Control - HVAC - 00")! } else { return UIImage(named: "04 Climate Control - HVAC - 01")! }
            
            case 11:
                if deviceValue == 0 { return UIImage(named: "lightBulb") }
                else if deviceValue > 0 && deviceValue < 0.1*255 { return UIImage(named: "lightBulb1") } // 0.1
                else if deviceValue >= 0.1*255 && deviceValue < 0.2*255 { return UIImage(named: "lightBulb2") } // 0.2
                else if deviceValue >= 0.2*255 && deviceValue < 0.3*255 { return UIImage(named: "lightBulb3") } // 0.3
                else if deviceValue >= 0.3*255 && deviceValue < 0.4*255 { return UIImage(named: "lightBulb4") } // 0.4
                else if deviceValue >= 0.4*255 && deviceValue < 0.5*255 { return UIImage(named: "lightBulb5") } // 0.5
                else if deviceValue >= 0.5*255 && deviceValue < 0.6*255 { return UIImage(named: "lightBulb6") } // 0.6
                else if deviceValue >= 0.6*255 && deviceValue < 0.7*255 { return UIImage(named: "lightBulb7") } // 0.7
                else if deviceValue >= 0.7*255 && deviceValue < 0.8*255 { return UIImage(named: "lightBulb8") } // 0.8
                else if deviceValue >= 0.8*255 && deviceValue < 0.9*255 { return UIImage(named: "lightBulb9") } // 0.9
                else { return UIImage(named: "lightBulb10") }
            
            case 12:
                if deviceValue == 0 { return UIImage(named: "12 Appliance - Power - 00")! } else { return UIImage(named: "12 Appliance - Power - 01")! }
            
            case 13:
                if deviceValue == 0 { return UIImage(named: "curtain0") }
                else if deviceValue <= 0.95*255 { return UIImage(named: "curtain2") }
                else { return UIImage(named: "curtain4") }
            
            case 14:
                if motionSensor {
                    if deviceValue == 0 { return UIImage(named: "14 Security - Motion Sensor - 00")! }
                    else if deviceValue == 255 { return UIImage(named: "14 Security - Motion Sensor - 01")! }  // 1
                    else { return UIImage(named: "14 Security - Motion Sensor - 02")! }
                } else {
                    if deviceValue == 0 { return UIImage(named: "14 Security - Lock - 00")! } else { return UIImage(named: "14 Security - Lock - 01")! }
                }
            
            case 15:
                if deviceValue == 0 { return UIImage(named: "15 Timer - CLock - 00")! } else { return UIImage(named: "15 Timer - CLock - 01")! }
            
            case 16:
                if deviceValue == 0 { return UIImage(named: "16 Flag - Flag - 00")! } else { return UIImage(named: "16 Flag - Flag - 01")! }
            
            case 17:
                if deviceValue == 0 { return UIImage(named: "17 Event - Up Down - 00")! } else { return UIImage(named: "17 Event - Up Down - 01")! }
            
            case 18:
                if deviceValue == 0 { return UIImage(named: "18 Media - LCD TV - 00")! } else { return UIImage(named: "18 Media - LCD TV - 01")! }
            
            case 19:
                if deviceValue == 0 { return UIImage(named: "19 Blind - Blind - 00") }
                else if deviceValue <= 0.2*255 { return UIImage(named: "19 Blind - Blind - 01")! }  // 0.2
                else if deviceValue <= 0.4*255 { return UIImage(named: "19 Blind - Blind - 02")! } // 0.4
                else if deviceValue <= 0.6*255 { return UIImage(named: "19 Blind - Blind - 03")! } // 0.6
                else if deviceValue <= 0.8*255 { return UIImage(named: "19 Blind - Blind - 04")! } // 0.8
                else if deviceValue < 1*255 { return UIImage(named: "19 Blind - Blind - 05")! } // 1
                else { return UIImage(named: "19 Blind - Blind - 06") }
            
            default: return nil
        }

    }
}
