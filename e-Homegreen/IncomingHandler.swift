
//  ReceiveHandler.swift
//  new
//
//  Created by Teodor Stevic on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics

class IncomingHandler: NSObject {
    var byteArray:[Byte]!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var error:NSError? = nil
    var host:String = ""
    var port:UInt16 = 0
    deinit {
        print("UPRAVO SE GASIM - class IncomingHandler: NSObject")
    }
    func commonCommand(dataFrame:DataFrame) {
        
    }
    func gatewayControllerCommand(dataFrame:DataFrame) {
        
    }
    func lightingControlCommandDimmerRelayModule(dataFrame:DataFrame) {
        
    }
    func climateControlCommand(dataFrame:DataFrame) {
        
    }
    func analogDigitalInputCommand(dataFrame:DataFrame) {
        
    }
    init (byteArrayToHandle: [Byte], host:String, port:UInt16) {
        super.init()
        CLSLogv("Log awesomeness %@", getVaList(["\(byteArrayToHandle)"]))
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.Gateway.DidReceiveData, object: self, userInfo: nil)
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        self.host = host
        self.port = port
        gateways = CoreDataController.shahredInstance.fetchGatewaysForHost(host, port: port)
        
        // NEW
        guard let dataFrame = DataFrame(byteArray: byteArrayToHandle) else {
            return
        }
        switch dataFrame.CID1 {
        case .CommonComand:
            commonCommand(dataFrame)
        case .GatewayControllerCommand:
            gatewayControllerCommand(dataFrame)
        case .LightingControlCommandDimmerRelayModule:
            lightingControlCommandDimmerRelayModule(dataFrame)
        case .ClimateControlCommand:
            climateControlCommand(dataFrame)
        case .AnalogDigitalInputCommand:
            analogDigitalInputCommand(dataFrame)
        case .AnalogDigitalOutputCommand: return
        case .SwitchPanelCommand: return
        case .LCDPanelCommands: return
        case .IRCommand: return
        case .PCControllerCommand: return
        }
        //  Checks if there are any gateways
        if gateways != [] {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            self.byteArray = byteArrayToHandle
            // Check if byteArray is correct one (check byte also, which is missing)
            if self.byteArray[0] == 0xFC && self.byteArray[self.byteArray.count-1] == 0x10 {
                //  ACKNOWLEDGMENT ABOUT NEW DEVICES
                if self.byteArray[5] == 0xF1 && self.byteArray[6] == 0x01 {
                    self.acknowledgementAboutNewDevices(self.byteArray)
                }
            }
            if self.byteArray[0] == 0xAA && self.byteArray[self.byteArray.count-1] == 0x10 {
                print("Uslo je u incoming handler.")
                
                //  ACKNOWLEDGMENT ABOUT NEW DEVICES
                if self.byteArray[5] == 0xF1 && self.byteArray[6] == 0x01 {
                    self.acknowledgementAboutNewDevices(self.byteArray)
                }
                // Get device (module not by channel) Main ACK, Category, Zone, Name
                // It was named curtain in beginning, but it is standard for all modules.
                if self.byteArray[5] == 0xF1 && self.byteArray[6] == 0x0D {
                    self.acknowledgementAboutCurtainParametar(self.byteArray)
                }
                
                //  ACKNOWLEDGEMENT ABOUT CHANNEL PARAMETAR (Get Channel Parametar) IMENA
                if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x01 {
                    self.acknowledgementAboutChannelParametar (self.byteArray)
                }
                
                //  ACKNOWLEDGMENT ABOUT CHANNEL STATE (Get Channel State)
                if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x06 && self.byteArray[7] == 0xFF { // OVO NE MOZE OVAKO DA BUDE
                    self.ackonowledgementAboutChannelsState(self.byteArray)
                }
                if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x06 && self.byteArray[7] == 0xF0 { // OVO NE MOZE OVAKO DA BUDE
                    self.ackonowledgementAboutCurtainState(self.byteArray)
                }
                //                    if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x06 {
                //                        self.ackonowledgementAboutChannelState(self.byteArray)
                //                    }
                
                //            //  ACKNOWLEDGMENT ABOUT LIGHT RELAY STATUS (Get channel state (output) Lightning control action)
                //            if byteArray[5] == 0xF3 && byteArray[6] == 0x07 {
                //
                //            }
                
                //  ACKNOWLEDGMENT ABOUT RUNNING TIME (Get Channel On Time Count)
                if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x0C {
                    self.ackDimmerGetRunningTime(self.byteArray)
                }
                
                //  ACKNOWLEDGMENT ABOUT CHANNEL WARNINGS (Get Channel On Last Current Change Warning)
                if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x10 {
                    self.ackChannelWarnings(self.byteArray)
                }
                
                //  ACKNOWLEDGMENET ABOUT AC CONTROL PARAMETAR
                if self.byteArray[5] == 0xF4 && self.byteArray[6] == 0x01 {
                    self.ackACParametar(self.byteArray)
                }
                //  ACKNOWLEDGMENT ABOUT AC CONTROL STATUS
                if self.byteArray[5] == 0xF4 && self.byteArray[6] == 0x03 && self.byteArray[7] == 0xFF  {
                    self.ackACstatus(self.byteArray)
                }
                //                if byteArray[5] == 0xF4 && byteArray[6] == 0x {
                //
                //                }
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x02 {
                    self.ackADICmdGetInterfaceParametar(self.byteArray)
                }
                // - Ovo je izgleda u redu
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 && self.byteArray[7] == 0xFF { // OVO NE MOZE OVAKO DA BUDE
                    self.ackADICmdGetInterfaceStatus(self.byteArray)
                }
                //                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 { // OVO NE MOZE OVAKO DA BUDE
                //                        self.ackADICmdGetInterfaceStatus(self.byteArray)
                //                    }
                //                    if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 {
                //
                //                    }
                
                // - Ovo je izgleda u redu
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 {
                    self.securityFeedbackHandler(self.byteArray)
                }
                
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x03 {
                    self.ackInterfaceEnableStatus(self.byteArray)
                }
                
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x04 {
                    self.ackADICmdGetInterfaceName(self.byteArray)
                }
                
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x17 && self.byteArray[7] == 0xFF {
                    self.ackTimerStatus(self.byteArray)
                }
                
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x06 && self.byteArray[7] == 0xFF {
                    self.ackFlagStatus(self.byteArray)
                }
                if self.byteArray[5] == 0xF2 && self.byteArray[6] == 0x11 && self.byteArray[7] == 0x00 {
                    self.getZone(self.byteArray)
                }
                if self.byteArray[5] == 0xF2 && self.byteArray[6] == 0x13 && self.byteArray[7] == 0x00 {
                    self.getCategories(self.byteArray)
                }
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x12 {
                    self.refreshEvent(self.byteArray)
                }
                if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x19 && self.byteArray[7] == 0xFF {
                    self.parseTimerStatus(dataFrame)
                    //FIXME: Popravi me
//                    self.ackTimerStatus(self.byteArray)
                }
            }
        }
    }
    
    func refreshEvent(byteArray:[Byte]){
        let data = ["id":Int(byteArray[7]), "value":Int(byteArray[8])]
        NSNotificationCenter.defaultCenter().postNotificationName("ReportEvent", object: self, userInfo: data)
    }
    
    func parseTimerStatus(dataFrame:DataFrame) {
        fetchEntities("Timer")
        // Check if byte array has minimum requirement 0f 16 times 4 bytes which is 64 OVERALL
//        guard dataFrame.INFO.count == 74 else {
//            return
//        }
        // For loop in data frame INFO block
        for var i = 1; i <= 16; i++ {
            for item in timers {
                if  item.gateway.addressOne == Int(dataFrame.ADR1) && item.gateway.addressTwo == Int(dataFrame.ADR2) && item.address == Int(dataFrame.ADR3) && item.timerId == Int(i) {
                    let position = (i - 1)*4
                    let fourBytes = [dataFrame.INFO[1+position], dataFrame.INFO[2+position], dataFrame.INFO[3+position], dataFrame.INFO[4+position]]
                    item.count = NSNumber(unsignedInteger: UInt.convertFourBytesToUInt(fourBytes))
                    item.timerCount = UInt.convertFourBytesToUInt(fourBytes)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshTimer, object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
    }
    func refreshSecurityStatus (byteArray:[Byte]) {
        
    }
    func ackChannelWarnings (byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) {
                //                var number = Int(byteArray[6+5*Int(device.channel)])
                print("\(6+6*Int(device.channel)) - \(Int(device.channel)) - \(Int(byteArray[6+5+6*(Int(device.channel)-1)]))")
                device.warningState = Int(byteArray[6+5+6*(Int(device.channel)-1)])
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func fetchZones() -> [Zone] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "location == %@", gateways[0].location)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return []
    }
    func fetchCategories() -> [Category] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "location == %@", gateways[0].location)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return []
    }
    
    
    func ackACstatus (byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                let channel = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+13*(channel-1)])
                if let mode = DeviceInfo.setMode[Int(byteArray[9+13*(channel-1)])], let modeState = DeviceInfo.modeState[Int(byteArray[10+13*(channel-1)])], let speed = DeviceInfo.setSpeed[Int(byteArray[11+13*(channel-1)])], let speedState = DeviceInfo.speedState[Int(byteArray[12+13*(channel-1)])] {
                    devices[i].mode = mode
                    devices[i].modeState = modeState
                    devices[i].speed = speed
                    devices[i].speedState = speedState
                } else {
                    devices[i].mode = "Auto"
                    devices[i].modeState = "Off"
                    devices[i].speed = "Auto"
                    devices[i].speedState = "Off"
                }
                devices[i].coolTemperature = Int(byteArray[13+13*(channel-1)])
                devices[i].heatTemperature = Int(byteArray[14+13*(channel-1)])
                devices[i].roomTemperature = Int(byteArray[15+13*(channel-1)])
                devices[i].humidity = Int(byteArray[16+13*(channel-1)])
                print(byteArray[17+13*(channel-1)] == 0x00 ? false : true)
                devices[i].filterWarning = byteArray[17+13*(channel-1)] == 0x00 ? false : true
                devices[i].allowEnergySaving = byteArray[18+13*(channel-1)] == 0x00 ? NSNumber(bool:false) : NSNumber(bool:true)
                devices[i].current = Int(byteArray[19+13*(channel-1)]) + Int(byteArray[20+13*(channel-1)])
                let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveDataForRepeatSendingHandler, object: self, userInfo: data)
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshClimate, object: self, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func ackDimmerGetRunningTime (byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                if byteArray[7] != 0xFF && byteArray[7] != 0xF0 {
                    devices[i].runningTime = returnRunningTime([byteArray[8], byteArray[9], byteArray[10], byteArray[11]])
                } else if byteArray[7] == 0xF0 {
                    
                } else {
                    let channelNumber = Int(devices[i].channel)
                    print(Int(devices[i].channel))
                    devices[i].runningTime = returnRunningTime([byteArray[8+4*(channelNumber-1)], byteArray[9+4*(channelNumber-1)], byteArray[10+4*(channelNumber-1)], byteArray[11+4*(channelNumber-1)]])
                    print(devices[i].controlType )
                    print(devices[i].runningTime)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    
    func returnRunningTime (runningTimeByteArray:[Byte]) -> String {
        print(runningTimeByteArray)
        let x = Int(UInt.convertFourBytesToUInt(runningTimeByteArray))
        //        var z = UnsafePointer<UInt16>(runningTimeByteArray).memory
        //        var y = Int(runningTimeByteArray[0])*1*256 + Int(runningTimeByteArray[1])*1*256 + Int(runningTimeByteArray[2])*1*256 + Int(runningTimeByteArray[3])
        var seconds = x / 10
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        seconds = seconds % 60
        let secdiv = (x % 60) % 10
        return "\(returnTwoPlaces(hours)):\(returnTwoPlaces(minutes)):\(returnTwoPlaces(seconds)),\(secdiv)s"
    }
    
    func returnTwoPlaces (number:Int) -> String {
        return String(format: "%02d",number)
    }
    
    //  informacije o imenima uredjaja na MULTISENSORU
    func ackADICmdGetInterfaceName (byteArray:[Byte]) {
        print(NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName))
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            var string:String = ""
            for var j = 9; j < byteArray.count-2; j++ {
                string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
            }
            for var i = 0; i < devices.count; i++ {
                if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                    //                var channel = Int(devices[i].channel)
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDeviceName, object: self, userInfo: data)
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
    }
    func ackInterfaceEnableStatus (byteArray: [Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) && device.channel == Int(byteArray[7]) {
                if byteArray[8] >= 0x80 {
                    device.isEnabled = NSNumber(bool: true)
                } else {
                    device.isEnabled = NSNumber(bool: false)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func ackADICmdGetInterfaceParametar (byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        var counter = 0
        for device in devices {
            if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) && device.channel == Int(byteArray[7]) {
                device.zoneId = Int(byteArray[9])
                device.parentZoneId = Int(byteArray[10])
                device.categoryId = Int(byteArray[8])
                // When we change category it will reset images
                device.digitalInputMode = Int(byteArray[14])
                //                var interfaceParametar:[Byte] = []
                //                for var i = 7; i < byteArray.count-2; i++ {
                //                    interfaceParametar.append(byteArray[i])
                //                }
                //                device.interfaceParametar = interfaceParametar
                if byteArray[11] >= 0x80 {
                    device.isEnabled = NSNumber(bool: true)
                    device.isVisible = NSNumber(bool: true)
                } else {
                    device.isEnabled = NSNumber(bool: false)
                    device.isVisible = NSNumber(bool: false)
                }
                device.resetImages(appDel.managedObjectContext!)
                let data = ["sensorIndexForFoundParametar":counter]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshInterface, object: self, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindSensorParametar, object: self, userInfo: data)
                
            }
            counter = counter + 1
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func ackACParametar (byteArray:[Byte]) {
        print(NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName))
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            var string:String = ""
            for var i = 9; i < byteArray.count-2; i++ {
                string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
                print(string)
            }
            for var i = 0; i < devices.count; i++ {
                if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                    var string:String = ""
                    for var j = 42; j < byteArray.count-2; j++ {
                        string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
                    }
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    
                    // PLC doesn't send info about this, so we put TRUE as default
                    devices[i].isEnabled = NSNumber(bool: true)
                    devices[i].isVisible = NSNumber(bool: true)
                    
                    devices[i].zoneId = Int(byteArray[33])
                    devices[i].parentZoneId = Int(byteArray[34])
                    devices[i].categoryId = Int(byteArray[32])
                    //                    devices[i].enabled = ""
                    //                    if byteArray[22] == 0x01 {
                    //                        devices[i].isEnabled = NSNumber(bool: true)
                    //                    } else {
                    //                        devices[i].isEnabled = NSNumber(bool: false)
                    //                    }
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDeviceName, object: self, userInfo: data)
                    
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
    }
    
    //  informacije o parametrima (statusu) urdjaja na MULTISENSORU - MISLIM DA JE OVO U REDU
    func ackADICmdGetInterfaceStatus (byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        print(byteArray)
        for var i = 0; i < self.devices.count; i++ {
            if self.devices[i].gateway.addressOne == Int(byteArray[2]) && self.devices[i].gateway.addressTwo == Int(byteArray[3]) && self.devices[i].address == Int(byteArray[4]) {
                let channel = Int(self.devices[i].channel)
                self.devices[i].currentValue = Int(byteArray[7+channel])
            }
            
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    func acknowledgementAboutCurtainParametar (byteArray:[Byte]) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            for (i, device) in devices.enumerate() {
                if device.gateway.addressOne == Int(byteArray[2]) && device.gateway.addressTwo == Int(byteArray[3]) && device.address == Int(byteArray[4]) {
                    var string:String = ""
                    for var j = 12; j < byteArray.count-2; j++ {
                        string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
                    }
                    if string != "" {
                        device.name = string
                    } else {
                        device.name = "Unknown"
                    }
                    device.categoryId = Int(byteArray[8])
                    device.zoneId = Int(byteArray[9])
                    device.parentZoneId = Int(byteArray[10])
                    // When we change category it will reset images
                    device.resetImages(appDel.managedObjectContext!)
                    //TODO: problem with modul names and response for finding names
                    //                let data = ["deviceIndexForFoundName":i]
                    //                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDeviceName, object: self, userInfo: data)
                }
                
            }
            CoreDataController.shahredInstance.saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
    }
    //  informacije o stanjima na uredjajima
    func ackonowledgementAboutChannelState (byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                let channelNumber = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+5*(channelNumber-1)]) //  lightning state
                devices[i].current = Int(byteArray[9+5*(channelNumber-1)]) + Int(byteArray[10+5*(channelNumber-1)]) // current
                devices[i].voltage = Int(byteArray[11+5*(channelNumber-1)]) // voltage
                devices[i].temperature = Int(byteArray[12+5*(channelNumber-1)]) // temperature
            } else {
                
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    //  informacije o stanjima na uredjajima
    func ackonowledgementAboutChannelsState (byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for var i = 0; i < devices.count; i++ {
            if devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) {
                let channelNumber = Int(devices[i].channel)
                devices[i].currentValue = Int(byteArray[8+5*(channelNumber-1)]) //  lightning state
                //                let data = NSData(bytes: [byteArray[9+5*(channelNumber-1)], byteArray[10+5*(channelNumber-1)]], length: 2)
                devices[i].current = Int(UInt16(byteArray[9+5*(channelNumber-1)])*256 + UInt16(byteArray[10+5*(channelNumber-1)])) // current
                devices[i].voltage = Int(byteArray[11+5*(channelNumber-1)]) // voltage
                devices[i].temperature = Int(byteArray[12+5*(channelNumber-1)]) // temperature
                let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveDataForRepeatSendingHandler, object: self, userInfo: data)
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    //  informacije o parametrima kanala
    func acknowledgementAboutChannelParametar (byteArray:[Byte]){
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            for var i = 0; i < devices.count; i++ {
                if  devices[i].gateway.addressOne == Int(byteArray[2]) && devices[i].gateway.addressTwo == Int(byteArray[3]) && devices[i].address == Int(byteArray[4]) && devices[i].channel == Int(byteArray[7]) {
                    var string:String = ""
                    for var j = 8+47; j < byteArray.count-2; j++ {
                        string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
                    }
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    devices[i].overrideControl1 = Int(byteArray[23])
                    devices[i].overrideControl2 = Int(byteArray[24])
                    devices[i].overrideControl3 = Int(byteArray[25])
                    if Int(byteArray[10]) == 0 {
                        devices[i].zoneId = 0
                        devices[i].parentZoneId = Int(byteArray[9])
                    } else {
                        devices[i].zoneId = Int(byteArray[9])
                        devices[i].parentZoneId = Int(byteArray[10])
                    }
                    devices[i].categoryId = Int(byteArray[8])
                    // When we change category it will reset images
                    devices[i].resetImages(appDel.managedObjectContext!)
                    if byteArray[22] == 0x01 {
                        devices[i].isEnabled = NSNumber(bool: true)
                        devices[i].isVisible = NSNumber(bool: true)
                    } else {
                        devices[i].isEnabled = NSNumber(bool: false)
                        devices[i].isVisible = NSNumber(bool: false)
                    }
                    //                    devices[i].allowCurtainMode = Int(byteArray[33])
                    //                    This is for curatin COntrol Mode: 1 NC, 2 NO, 3 NC and Reset, 4 NO and Reset
                    if byteArray[28] == 0x01 {
                        devices[i].isDimmerModeAllowed = NSNumber(bool: true)
                        devices[i].controlType = ControlType.Dimmer
                    }
                    if byteArray[33] == 0x01 {
                        devices[i].isCurtainModeAllowed = NSNumber(bool: true)
                        devices[i].controlType = ControlType.Curtain
                    }
                    devices[i].curtainGroupID = Int(byteArray[34])          // CurtainGroupID defines the curtain device. Ic curtain group is the same on 2 channels then that is the same Curtain
                    devices[i].curtainControlMode = Int(byteArray[35])      // Will be used later (17.07.2016)
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidFindDeviceName, object: self, userInfo: data)
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
    }
    //  0x00 Waiting = 0
    //  0x01 Started = 1
    //  0xF0 Elapsed = 240
    //  0xEE Suspend = 238
    //  informacije o parametrima kanala
    func ackTimerStatus (byteArray:[Byte]){
        fetchEntities("Timer")
        for var i = 1; i <= 16; i++ {
            print(timers.count)
            for item in timers {
                if  item.gateway.addressOne == Int(byteArray[2]) && item.gateway.addressTwo == Int(byteArray[3]) && item.address == Int(byteArray[4]) && item.timerId == Int(i) {
                    item.timerState = NSNumber(integer: Int(byteArray[7+i]))
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshTimer, object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
    }
    //  informacije o parametrima kanala
    func ackFlagStatus (byteArray:[Byte]){
        print("AOOO 2")
        print(byteArray)
        fetchEntities("Flag")
        for var i = 1; i <= 32; i++ {
            print(flags.count)
            for item in flags {
                if  item.gateway.addressOne == Int(byteArray[2]) && item.gateway.addressTwo == Int(byteArray[3]) && item.address == Int(byteArray[4]) && item.flagId == Int(i) {
                    print("alo \(NSNumber(integer: Int(byteArray[7+i])))")
                    if Int(byteArray[7+i]) == 1 {
                        item.setState = NSNumber(bool: false)
                    } else if Int(byteArray[7+i]) == 0 {
                        item.setState = NSNumber(bool: true)
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFlag, object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        
    }
    
    // Security
    func securityFeedbackHandler (byteArray:[Byte]) {
        parseMessage(byteArray)
        fetchEntities("Security")
        //FIXME: Pucalo je security zato sto nema u svim gatewayovima security
        if securities.count != 0 {
            let address = [Byte(Int(securities[0].addressOne)), Byte(Int(securities[0].addressTwo)), Byte(Int(securities[0].addressThree))]
            if byteArray[2] == address[0] && byteArray[3] == address[1] && byteArray[4] == address[2] {
                let defaults = NSUserDefaults.standardUserDefaults()
                if byteArray[7] == 0x02 {
                    switch byteArray[8] {
                    case 0x00:
                        defaults.setValue("Disarm", forKey: UserDefaults.Security.SecurityMode)
                    case 0x01:
                        defaults.setValue("Away", forKey: UserDefaults.Security.SecurityMode)
                    case 0x02:
                        defaults.setValue("Night", forKey: UserDefaults.Security.SecurityMode)
                    case 0x03:
                        defaults.setValue("Day", forKey: UserDefaults.Security.SecurityMode)
                    case 0x04:
                        defaults.setValue("Vacation", forKey: UserDefaults.Security.SecurityMode)
                    default: break
                    }
                }
                if byteArray[7] == 0x03 {
                    switch byteArray[8] {
                    case 0x00:
                        defaults.setValue("Idle", forKey: UserDefaults.Security.AlarmState)
                    case 0x01:
                        defaults.setValue("Trouble", forKey: UserDefaults.Security.AlarmState)
                    case 0x02:
                        defaults.setValue("Alert", forKey: UserDefaults.Security.AlarmState)
                    case 0x03:
                        defaults.setValue("Alarm", forKey: UserDefaults.Security.AlarmState)
                    default: break
                    }
                }
                if byteArray[7] == 0x04 {
                    switch byteArray[8] {
                    case 0x00:
                        defaults.setBool(false, forKey: UserDefaults.Security.IsPanic)
                    case 0x01:
                        defaults.setBool(true, forKey: UserDefaults.Security.IsPanic)
                    default: break
                    }
                }
                print("EHGSecuritySeczurityMode - \(defaults.valueForKey(UserDefaults.Security.SecurityMode)) *** EHGSecurityAlarmState - \(defaults.valueForKey(UserDefaults.Security.AlarmState)) *** EHGSecurityPanic - \(defaults.boolForKey(UserDefaults.Security.IsPanic))")
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.Security.ControlModeStopBlinking, object: self, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshSecurity, object: self, userInfo: nil)
            }
        }
    }
    
    var timers:[Timer] = []
    var flags:[Flag] = []
    var securities:[Security] = []
    var events:[Event] = []
    func fetchEntities (whatToFetch:String) {
        if whatToFetch == "Flag" {
            let fetchRequest = NSFetchRequest(entityName: "Flag")
            let sortDescriptors = NSSortDescriptor(key: "flagName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Flag]
                print(results.count)
                flags = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Timer" {
            let fetchRequest = NSFetchRequest(entityName: "Timer")
            let sortDescriptors = NSSortDescriptor(key: "timerName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Timer]
                timers = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Security" {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: String(Security))
            let sortDescriptorTwo = NSSortDescriptor(key: "securityName", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorTwo]
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Security]
                securities = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
        if whatToFetch == "Event" {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Event")
            let sortDescriptorTwo = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorTwo]
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
                events = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    // MARK: - Get zones and categories
    func getZone(byteArray:[Byte]) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningForZones) {
            // Miminum is 12, but that is also doubtful...
            if byteArray.count > 12 {
                var name:String = ""
                for var j = 11; j < 11+Int(byteArray[10]); j++ {
                    name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
                }
                let id = byteArray[8]
                let level = byteArray[byteArray.count - 2 - 1]
                var description = ""
                if byteArray[11+Int(byteArray[10])+2] != 0x00 {
                    let number = 11+Int(byteArray[10])+2
                    for var j = number; j < number+Int(byteArray[number-1]); j++ {
                        description = description + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
                    }
                }

                var doesIdExist = false
                let zones = fetchZones()
                
                for zone in zones {
                    if zone.id == NSNumber(integer: Int(id)) {
                        doesIdExist = true
                        (zone.name, zone.level, zone.zoneDescription) = (name, NSNumber(integer:Int(level)), description)
                        CoreDataController.shahredInstance.saveChanges()
                        break
                    }
                }
                
                if doesIdExist {
                } else {
                    let zone = Zone(context: appDel.managedObjectContext!)
                    (zone.id, zone.name, zone.level, zone.zoneDescription, zone.location, zone.orderId, zone.allowOption) = (NSNumber(integer: Int(id)), name, NSNumber(integer:Int(level)), description, gateways[0].location, NSNumber(integer: Int(id)), 1)
                    CoreDataController.shahredInstance.saveChanges()
                }
                
                let data = ["zoneId":Int(id)]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveZoneFromGateway, object: self, userInfo: data)
            }
        }
    }
    
    func getCategories(byteArray:[Byte]) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningForCategories) {
            var name:String = ""
            for var j = 11; j < 11+Int(byteArray[10]); j++ {
                name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
            }
            let id = byteArray[8]
            var description = ""
            if byteArray[11+Int(byteArray[10])+2] != 0x00 {
                let number = 11+Int(byteArray[10])+2
                for var j = number; j < number+Int(byteArray[number-1]); j++ {
                    description = description + "\(Character(UnicodeScalar(Int(byteArray[j]))))" //  device name
                }
            }
            if id > 20 {
                var doesIdExist = false
                let categories = fetchCategories()
                
                for category in categories {
                    if category.id == NSNumber(integer: Int(id)) {
                        doesIdExist = true
                        (category.name, category.categoryDescription) = (name, description)
                        CoreDataController.shahredInstance.saveChanges()
                        break
                    }
                }
                if !doesIdExist {
                    let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                    (category.id, category.name, category.categoryDescription, category.location, category.orderId, category.allowOption) = (NSNumber(integer: Int(id)), name, description, gateways[0].location, NSNumber(integer: Int(id)), 3)
                    CoreDataController.shahredInstance.saveChanges()
                }
                
            }
            
            let data = ["categoryId":Int(id)]
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.DidReceiveCategoryFromGateway, object: self, userInfo: data)
        }
    }
    
    // Helper
    func parseMessage(byteArray: [UInt8]){
        let byteLength = byteArray.count
        let SOI = byteArray[0]
        let LEN = byteArray[1]
        let ADDR = [byteArray[2], byteArray[3], byteArray[4]]
        let CID1 = byteArray[5]
        let CID2 = byteArray[6]
        
        var INFO: [UInt8] = []
        for i in 7...byteLength-3{
            INFO = INFO + [byteArray[i]]
        }
        
        let CHK = byteArray[byteArray.count-2]
        let EOI = byteArray[byteArray.count-1]
        
        print("SOI: \(SOI)")
        print("ADDR: \(ADDR)")
        print("CID1: \(CID1)")
        print("CID2: \(CID2)")
        print("INFO: \(INFO)")
    }
}

