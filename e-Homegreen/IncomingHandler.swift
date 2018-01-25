
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
    
    init (byteArrayToHandle: [Byte], host:String, port:UInt16) {
        super.init()
        CLSLogv("Log awesomeness %@", getVaList(["\(byteArrayToHandle)"]))
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.Gateway.DidReceiveData), object: self, userInfo: nil)
        appDel = UIApplication.shared.delegate as! AppDelegate
        self.host = host
        self.port = port
        gateways = CoreDataController.sharedInstance.fetchGatewaysForHost(host, port: port)
        
        guard let dataFrame = DataFrame(byteArray: byteArrayToHandle) else {            
            print("Invalid data frame"); parseMessageAndPrint(byteArrayToHandle)
            return
        }
        
        //  Checks if there are any gateways
        if gateways.count > 0 {
            devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
            byteArray = byteArrayToHandle
            if messageIsValid() {
                
                if messageIsNewDeviceSalto() { parseMessageNewDevicSalto(byteArray)
                } else if messageIsNewDevice() { parseMessageNewDevice(byteArray) }
                
                else if messageIsNewDeviceParameters() { parseMessageNewDeviceParameter(byteArray) }
            
                // MARK: - Channel Parameter | ACKNOWLEDGEMENT ABOUT CHANNEL PARAMETAR (Get Channel Parametar) IMENA
                else if messageIsChannelParameter() { parseMessageChannelParameter(byteArray) }
                else if messageIsChannelState() { parseMessageChannelsState(byteArray) }
                // MARK: - Channel Warnings | ACKNOWLEDGMENT ABOUT CHANNEL WARNINGS (Get Channel On Last Current Change Warning)
                else if messageIsChannelWarning() { parseMessageChannelWarnings(byteArray) }
                // MARK: - Curtains
                else if messageIsCurtainState() { parseMessageCurtainState(byteArray) }
                // MARK: - Running time | ACKNOWLEDGMENT ABOUT RUNNING TIME (Get Channel On Time Count)
                else if messageIsRunningTime() { parseMessageDimmerGetRunningTime(byteArray) }
                // MARK: - Air Condition
                else if messageIsAcParameter() { parseMessageACParametar(byteArray) }
                else if messageIsAcControlStatus() { parseMessageACstatus(byteArray) }
                else if messageIsSingleACControlStatus() { parseMessageSingleACStatus(byteArray) }
                // MARK: - Interface
                else if messageIsInterfaceParameter() { parseMessageInterfaceParametar(byteArray) }
                else if messageIsInterfaceStatus() { parseMessageInterfaceStatus(byteArray) } /* OVO NE MOZE OVAKO DA BUDE */
                else if messageIsInterfaceEnableStatus() { parseMessageInterfaceEnableStatus(byteArray) }
                else if messageIsInterfaceName() { parseMessageInterfaceName(byteArray) }
                // MARK: - Security
                else if messageIsSecurityFeedbackHandler() { parseMessageSecurityFeedbackHandler(byteArray) }
                // MARK: - Timer
                else if messageIsTimerStatus() { parseMessageTimerStatus(byteArray) }
                else if messageIsTimerStatusData() { parseTimerStatus(dataFrame) }
                else if messageIsTimerName() { parseMessageTimerName(byteArray) }
                else if messageIsTimerParameters() { parseMessageTimerParameters(byteArray) }
                // MARK: - Flags
                else if messageIsFlagStatus() { parseMessageFlagStatus(byteArray) }
                else if messageIsNewFlag() { parseMessageFlagName(byteArray) }
                else if messageIsNewFlagParameter() { parseMessageFlagParameters(byteArray) }
                // MARK: - Zone & Category
                else if messageIsNewZone() { parseMessageNewZone(byteArray) }
                else if messageIsNewCategory() { parseMessageNewCategory(byteArray) }
                // MARK: - Events
                else if messageIsEventStatus() { parseMessageRefreshEvent(byteArray) }
                else if messageIsNewEvent() { parseMessageNewEvent(byteArray) }
                // MARK: - Scenes
                else if messageIsNewScene(){ parseMessageNewScene(byteArray) }
                // MARK: - Sequences
                else if messageIsNewSequence() { parseMessageNewSequence(byteArray) }
                // MARK: - Cards
                else if messageIsNewCardName() { parseMessageCardName(byteArray) }
                else if messageIsNewCardParameter() { parseMessageCardParameters(byteArray) }
                // MARK: - Salto
                else if messageIsNewDeviceSaltoParameter() { parseMessageSaltoParameters(byteArray) }
                else if messageIsSaltoStatus() { parseMessageSaltoStatus(byteArray) }
                // MARK: - PC
                else if messageIsPCStatus(){ parsePCStatus(byteArray) }
                else if messageIsIRCode() { parseMessageIRCode(byteArray) }
                else if messageIsSingleIRCode() { parseMessageSingleIRCode(byteArray) }
                else if messageIsIRLearningState() { parseMessageIRLearningState(byteArray) }
                else if messageIsIRSerialLibrary() { parseMessageIRSerialLibrary(byteArray) }
                else if messageIsIRSerialLibraryName() { parseMessageIRSerialLibraryName(byteArray) }
                else {
                    print("NO IMPLEMENTATION FOR THIS")
                    parseMessageAndPrint(byteArray)
                }
                
            } else {
                print("INVALID MESSAGE")
                parseMessageAndPrint(byteArray)
            }
        }
    }
    
    // MARK: - Timers functions
    func parseMessageTimerName(_ byteArray: [Byte]) {
        print("TIMER NAME")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningTimerNames) {
            var timerId = Int(byteArray[7])
            // Miminum is 12b
            if Int(byteArray[8]) != 0 {
                let name          = getName(count: 9, baCount: 9 + Int(byteArray[8]), byteArray: byteArray) /* timer name */
                timerId           = Int(byteArray[7])
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 { DatabaseTimersController.shared.addTimer(timerId, timerName: name, moduleAddress: moduleAddress, gateway: gateways.first!, type: nil, levelId: nil, selectedZoneId: nil, categoryId: nil) } else { return }
            }
            let data = ["timerId":timerId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveTimerFromGateway), object: self, userInfo: data)
        }
    }
    func parseMessageTimerParameters(_ byteArray: [Byte]) {
        print("TIMER PARAMETERS")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningTimerParameters) {
            var timerId = Int(byteArray[7])
            // Miminum is 14b
            if byteArray.count > 14 {
                timerId             = Int(byteArray[7])
                let timerCategoryId = byteArray[8]
                let timerZoneId     = byteArray[9]
                let timerLevelId    = byteArray[10]
                let timerType       = byteArray[12]
                
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 { DatabaseTimersController.shared.addTimer(timerId, timerName: nil, moduleAddress: moduleAddress, gateway: gateways.first!, type: Int(timerType), levelId: Int(timerLevelId), selectedZoneId: Int(timerZoneId), categoryId: Int(timerCategoryId)) } else { return }
            }
            let data = ["timerId":timerId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveTimerParameterFromGateway), object: self, userInfo: data)
        }
    }
    func parseTimerStatus(_ dataFrame:DataFrame) {
        print("TIMER STATUS")
        parseMessageAndPrint(byteArray)
        
        let sortDescriptor = NSSortDescriptor(key: "timerName", ascending: true)
        let timers         = DatabaseTimersController.shared.getAllTimersSortedBy(sortDescriptor)
        
        // For loop in data frame INFO block
        for i in 1...16 {
            for item in timers {
                if  Int(item.gateway.addressOne) == Int(dataFrame.ADR1) &&
                    Int(item.gateway.addressTwo) == Int(dataFrame.ADR2) &&
                    Int(item.address) == Int(dataFrame.ADR3) &&
                    Int(item.timerId) == Int(i) {
                    
                    let position = (i - 1)*4
                    let fourBytes = [dataFrame.INFO[1+position], dataFrame.INFO[2+position], dataFrame.INFO[3+position], dataFrame.INFO[4+position]]
                    item.count = NSNumber(value: UInt.convertFourBytesToUInt(fourBytes) as UInt)
                    item.timerCount = UInt.convertFourBytesToUInt(fourBytes)
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshTimer), object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func parseMessageTimerStatus (_ byteArray:[Byte]) {
        print("TIMER STATUS")
        parseMessageAndPrint(byteArray)
        
        //  0x00 Waiting = 0
        //  0x01 Started = 1
        //  0xF0 Elapsed = 240
        //  0xEE Suspend = 238
        //  informacije o parametrima kanala
        let sortDescriptor = NSSortDescriptor(key: "timerName", ascending: true)
        let timers         = DatabaseTimersController.shared.getAllTimersSortedBy(sortDescriptor)
        for i in 1...16 {
            for item in timers {
                if isCorrectTimerAddress(i: i, timer: item, byteArray: byteArray) {
                    item.timerState = getNSNumber(for: byteArray[7+i])
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshTimer), object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.sharedInstance.saveChanges()
    }
    
    // MARK: - Scenes functions
    func parseMessageNewScene(_ byteArray: [Byte]) {
        print("NEW SCENE")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningSceneNameAndParameters) {
            var sceneId = Int(byteArray[7])
            // Miminum is 80b
            if byteArray.count > 80 {
                sceneId             = Int(byteArray[7])
                let sceneZoneId     = Int(byteArray[74])
                let sceneLevelId    = Int(byteArray[75])
                let sceneCategoryId = Int(byteArray[76])
                
                let name: String    = getName(count: 78, baCount: 78 + Int(byteArray[77]), byteArray: byteArray) //  scene name
                
                let moduleAddress   = Int(byteArray[4])
                
                if gateways.count > 0 { DatabaseScenesController.shared.createScene(sceneId, sceneName: name, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: sceneLevelId, zoneId: sceneZoneId, categoryId: sceneCategoryId) } else { return }
            }
            let data = ["sceneId":sceneId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveSceneFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK: - Sequences functions
    func parseMessageNewSequence(_ byteArray: [Byte]) {
        print("NEW SEQUENCE")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningSequencesNameAndParameters) {
            var sequenceId = Int(byteArray[7])
            // Miminum is 82b
            if byteArray.count > 82 {
                
                let bytes:[UInt8] = [byteArray[9], byteArray[8]]
                
                let id = UnsafePointer(bytes).withMemoryRebound(to: UInt16.self, capacity: 1) { $0.pointee }
                
                sequenceId             = Int(byteArray[7])
                let sequenceZoneId     = Int(byteArray[76])
                let sequenceLevelId    = Int(byteArray[77])
                let sequenceCategoryId = Int(byteArray[78])
                
                let name: String       = getName(count: 80, baCount: 80 + Int(byteArray[79]), byteArray: byteArray) //  sequences name
                
                let moduleAddress      = Int(byteArray[4])
                
                if gateways.count > 0 { DatabaseSequencesController.shared.createSequence(Int(id), sequenceName: name, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: sequenceLevelId, zoneId: sequenceZoneId, categoryId: sequenceCategoryId) } else { return }
                
            }
            let data = ["sequenceId":sequenceId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveSequenceFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK: - Event functions
    func parseMessageNewEvent(_ byteArray: [Byte]) {
        print("NEW EVENT")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningEventsNameAndParameters) {
            var eventId = Int(byteArray[7])
            // Miminum is 14b
            if byteArray.count > 14 {
                eventId             = Int(byteArray[7])
                let eventZoneId     = Int(byteArray[10])
                let eventLevelId    = Int(byteArray[11])
                let eventCategoryId = Int(byteArray[9])
                
                let name: String    = getName(count: 13, baCount: 13 + Int(byteArray[12]), byteArray: byteArray) // event name
                
                if name.trimmingCharacters(in: CharacterSet(charactersIn: "")) != "" {
                    let moduleAddress = Int(byteArray[4])
                    
                    if gateways.count > 0 { DatabaseEventsController.shared.createEvent(eventId, eventName: name, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: eventLevelId, zoneId: eventZoneId, categoryId: eventCategoryId) } else { return }
                }
            }
            let data = ["eventId":eventId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveEventFromGateway), object: self, userInfo: data)
        }
    }
    
    func parseMessageRefreshEvent(_ byteArray:[Byte]) {
        print("REFRESH EVENT")
        parseMessageAndPrint(byteArray)
        
        let data = ["id":Int(byteArray[7]), "value":Int(byteArray[8])]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReportEvent"), object: self, userInfo: data)
    }
    
    // MARK: - Flags
    func parseMessageFlagName(_ byteArray: [Byte]) {
        print("FLAG NAME")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningFlagNames) {
            var flagId = Int(byteArray[7]) - 100
            // Miminum is 12b
            if Int(byteArray[8]) != 0 {
                let name: String = getName(count: 9, baCount: 9 + Int(byteArray[8]), byteArray: byteArray) //  timer name
                
                flagId            = Int(byteArray[7]) - 100
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 { DatabaseFlagsController.shared.createFlag(flagId, flagName: name, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: nil, selectedZoneId: nil, categoryId: nil) } else { return }
            }
            
            let data = ["flagId":flagId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveFlagFromGateway), object: self, userInfo: data)
        }
    }
    func parseMessageFlagParameters(_ byteArray: [Byte]) {
        print("FLAG PARAMETERS")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningFlagParameters) {
            var flagId = Int(byteArray[7]) - 100
            // Miminum is 14b
            if byteArray.count > 14 {
                flagId             = Int(byteArray[7]) - 100
                let flagCategoryId = Int(byteArray[8])
                let flagZoneId     = Int(byteArray[9])
                let flagLevelId    = Int(byteArray[10])
                
                let moduleAddress  = Int(byteArray[4])
                
                if gateways.count > 0 { DatabaseFlagsController.shared.createFlag(flagId, flagName: nil, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: flagLevelId, selectedZoneId: flagZoneId, categoryId: flagCategoryId) } else { return }
            }
            
            let data = ["flagId":flagId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveFlagParameterFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK: - Cards functions
    func parseMessageCardName(_ byteArray: [Byte]) {
        print("CARD NAME")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningCardNames) {
            let id = Int(byteArray[8])
            // Miminum is 12b
            if id != 0 {
                var name:String = ""
                if Int(byteArray[9]) > 0 && Int(byteArray[9]) != 255 {
                    name = getName(count: 10, baCount: 10 + Int(byteArray[9]), byteArray: byteArray) // timer name
                    let moduleAddress = Int(byteArray[4])
                    
                    if gateways.count > 0 { DatabaseCardsController.shared.createCard(id, cardId: nil, cardName: name, moduleAddress: moduleAddress, gateway: gateways.first!) } else { return }
                }
            }
            let data = ["cardId":id]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveCardFromGateway), object: self, userInfo: data)
        }
    }
    func parseMessageCardParameters(_ byteArray: [Byte]) {
        print("CARD PARAMETERS")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningCardParameters) {
            let id = Int(byteArray[8])
            // Miminum is 14b
            if id != 0 {
                
                let moduleAddress = Int(byteArray[4])
                
                var isEnabled:Bool = true
                if byteArray[9] == 0x00 { isEnabled = false }
                
                let cardId = NSString(format: "%02X %02X %02X %02X %02X %02X %02X", byteArray[10], byteArray[11], byteArray[12], byteArray[13], byteArray[14], byteArray[15], byteArray[16])
                
                let timerAddress:Int = Int(byteArray[53])
                let timerId          = Int(byteArray[54])
                
                if gateways.count > 0 { DatabaseCardsController.shared.createCard(id, cardId: cardId as String, cardName: nil, moduleAddress: moduleAddress, gateway: gateways.first!, isEnabled: isEnabled, timerAddress: timerAddress, timerId: timerId) } else { return }
            }
            let data = ["cardId":id]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveCardParameterFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK: - New devices
    func parseMessageNewDevice (_ byteArray:[Byte]) {
        print("NEW DEVICE")
        parseMessageAndPrint(byteArray)
        
        print(Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDevice))
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDevice) {
            var deviceExists = false
            if let channel = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.channel,
                let controlType = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                
                let MAC:[Byte] = Array(byteArray[9...14])
                if devices != [] {
                    for device in devices { if Int(device.address) == Int(byteArray[4]) {deviceExists = true} }
                } else { deviceExists = false }
                
                if !deviceExists {
                    for i in 1...channel{
                        var isClimate = false
                        if controlType == ControlType.Climate { isClimate = true }
                        
                        let deviceInformation = DeviceInformation(address: Int(byteArray[4]), channel: i, numberOfDevices: channel, type: controlType, gateway: gateways[0], mac: Data(bytes: UnsafePointer<UInt8>(MAC), count: MAC.count), isClimate:isClimate)
                        
                        if let moc = appDel.managedObjectContext {
                            if (controlType == ControlType.Sensor ||
                                controlType == ControlType.IntelligentSwitch) && i > 1 {
                                
                                let _ = Device(context: moc, specificDeviceInformation: deviceInformation)
                                
                            } else if controlType == ControlType.Climate ||
                                controlType == ControlType.SaltoAccess ||
                                controlType == ControlType.AnalogInput ||
                                controlType == ControlType.AnalogOutput ||
                                controlType == ControlType.DigitalInput ||
                                controlType == ControlType.DigitalOutput ||
                                controlType == ControlType.IRTransmitter ||
                                controlType == ControlType.Curtain ||
                                controlType == ControlType.PC ||
                                controlType == ControlType.Relay ||
                                controlType == ControlType.Dimmer{
                                
                                let _ = Device(context: moc, specificDeviceInformation: deviceInformation)
                            }
                        }
                        
                        CoreDataController.sharedInstance.saveChanges()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
                    }
                    let data = ["deviceAddresInGateway":Int(byteArray[4])]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDevice), object: self, userInfo: data)
                }
            }
        }
    }
    func parseMessageNewDevicSalto (_ byteArray:[Byte]) {
        print("NEW DEVICE SALTO")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDevice) {
            var deviceExists = false
            if let controlType = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                let MAC:[Byte] = Array(byteArray[9...14])
                if devices != [] {
                    for device in devices { if Int(device.address) == Int(byteArray[4]) {deviceExists = true} }
                } else {deviceExists = false}
                
                if !deviceExists {
                    for i in 1...4 {
                        let deviceInformation = DeviceInformation(address: Int(byteArray[4]), channel: i, numberOfDevices: 4, type: controlType, gateway: gateways[0], mac: Data(bytes: UnsafePointer<UInt8>(MAC), count: MAC.count), isClimate:false)
                        
                        if controlType == ControlType.SaltoAccess {
                            if let moc = appDel.managedObjectContext { let _ = Device(context: moc, specificDeviceInformation: deviceInformation, channelName: "Lock \(i)") }
                        }
                        
                        CoreDataController.sharedInstance.saveChanges()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
                    }
                    let data = ["deviceAddresInGateway":Int(byteArray[4])]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDevice), object: self, userInfo: data)
                }
            }
        }
        
    }
    
    func parseMessageNewDeviceParameter(_ byteArray:[Byte]) {
        print("NEW DEVICE PARAMETER")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
            for device in devices {
                if isCorrectDeviceAddress(device: device, for: byteArray) {
                    if let moc = appDel.managedObjectContext {
                        let name: String = getName(count: 12, byteArray: byteArray) // device name
                        if name != "" { device.name = name } else { device.name = "Unknown" }
                        
                        device.categoryId = getNSNumber(for: byteArray[8])
                        device.zoneId = getNSNumber(for: byteArray[9])
                        device.parentZoneId = getNSNumber(for: byteArray[10])
                        // When we change category it will reset images
                        device.resetImages(moc)
                    }
                }
            }
            CoreDataController.sharedInstance.saveChanges()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        }
    }
    
    // MARK: - Salto functions
    func parseMessageSaltoParameters(_ byteArray: [Byte]) {
        print("SALTO PARAMETERS")
        parseMessageAndPrint(byteArray)
        
        // This response message contains two bytes which carry information about which channel (device) is selected.
        // There can be max 4 devices for Salto (on that address). Which ever is selected in admin panel (1...16) must be shown and device channel is set to that number
        // For example: If 1 and 16 is selected, we will have two bytes with tat information 0x80 0x01, and there should be four devices:
        // Lock 1: channel 1
        // Lock 2: channel 16
        // Lock 3: chaneel 0
        // Lock 4: channel 0
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
            // Get two bytes that carry info
            var first8Devices = byteArray[8]
            var second8Devices = byteArray[7]
            
            // Get which channels should be set
            var arrayOfActiveChannels: [Int] = []
            for i in 1...8 {
                if first8Devices & 0x1 == 1 { arrayOfActiveChannels.append(i) }
                first8Devices = first8Devices >> 1
            }
            for i in 1...8 {
                if second8Devices & 0x1 == 1 { arrayOfActiveChannels.append(i + 8) }
                second8Devices = second8Devices >> 1
            }
            
            if arrayOfActiveChannels.count > 4 { return } // something is wrong if we could select more than 4
            
            var devicesForSalto: [Device] = []
            // Get needed devices and be sure that everything is in good order
            for i in 0..<devices.count{
                if isCorrectDeviceAddress(i: i, for: byteArray) { devicesForSalto.append(devices[i]) }
            }
            devicesForSalto = devicesForSalto.sorted(by: { (dev1, dev2) -> Bool in
                return (dev1.name < dev2.name)
            })
            
            // Set new parameters for device
            for device in devicesForSalto {
                if arrayOfActiveChannels.count > 0 {
                    device.isEnabled    = getNSNumber(from: true)
                    device.isVisible    = getNSNumber(from: true)
                    device.controlType  = ControlType.SaltoAccess
                    device.channel      = NSNumber(value: arrayOfActiveChannels.first!)
                    arrayOfActiveChannels.removeFirst()
                } else {
                    device.isEnabled   = getNSNumber(from: false)
                    device.isVisible   = getNSNumber(from: false)
                    device.controlType = ControlType.SaltoAccess
                    device.channel     = 0
                }
            }
            let data = ["deviceIndexForFoundName":Int(byteArray[4]), "saltoAccess": 1]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDeviceName), object: self, userInfo: data)
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func parseMessageSaltoStatus(_ byteArray: [Byte]) {
        print("SALTO STATUS")
        parseMessageAndPrint(byteArray)
        
        let allInformationByte  = byteArray[9]
        let bateryStatusByte    = (0x03 & allInformationByte)
        let onOffIndicatorTemp  = (0x80 & allInformationByte)
        let onOffIndicator      = onOffIndicatorTemp >> 7
        let modeTemp            = (0x70 & allInformationByte)
        let mode:Int            = Int(modeTemp >> 4)
        
        var devicesForSalto: [Device] = []
        // Get needed devices and be sure that everything is in good order
        for i in 0..<devices.count {
            if isCorrectDeviceAddress(i: i, for: byteArray) && isCorrectDeviceChannel(i: i, byteArray: byteArray) { devicesForSalto.append(self.devices[i]) }
        }
        
        if let device = devicesForSalto.first {
            // Current state - On-Off
            // 1 - Open
            // 2 - Closed
            device.currentValue = onOffIndicator == 0x1 ? 1 : 0
            
            // Mode 0, 1, 2, 3
            switch mode {
            case 0: device.saltoMode = 0
            case 1: device.saltoMode = 1
            case 2: device.saltoMode = 2
            case 4: device.saltoMode = 3
            default: device.saltoMode = 0
            }
        
            // Batery 3 - High, 2 - Normal, 1 - Low, 0 - Very low
            device.bateryStatus = Int(bateryStatusByte)
        }
    }

    // MARK: - Air Condition functions
    func parseMessageACstatus (_ byteArray:[Byte]) {
        print("AC STATUS - FULL")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for i in 0..<devices.count {
            if isCorrectDeviceAddress(i: i, for: byteArray) {
                
                let channel = Int(devices[i].channel)
                devices[i].currentValue = getNSNumber(for: byteArray[8+13*(channel-1)])
                
                if let mode         = DeviceInfo.setMode[Int(byteArray[9+13*(channel-1)])] { devices[i].mode = mode } else { devices[i].mode = "Auto" }
                if let modeState    = DeviceInfo.modeState[Int(byteArray[10+13*(channel-1)])] { devices[i].modeState = modeState } else { devices[i].modeState = "Off" }
                if let speed        = DeviceInfo.setSpeed[Int(byteArray[11+13*(channel-1)])] { devices[i].speed = speed } else { devices[i].speed = "Auto" }
                if let speedState   = DeviceInfo.speedState[Int(byteArray[12+13*(channel-1)])] { devices[i].speedState = speedState } else { devices[i].speedState = "Off" }

                devices[i].coolTemperature   = getNSNumber(for: byteArray[13+13*(channel-1)])
                devices[i].heatTemperature   = getNSNumber(for: byteArray[14+13*(channel-1)])
                devices[i].roomTemperature   = getNSNumber(for: byteArray[15+13*(channel-1)])
                devices[i].humidity          = getNSNumber(for: byteArray[16+13*(channel-1)])
                devices[i].filterWarning     = byteArray[17+13*(channel-1)] == 0x00 ? false : true
                devices[i].allowEnergySaving = byteArray[18+13*(channel-1)] == 0x00 ? getNSNumber(from: false) : getNSNumber(from: true)
                devices[i].current           = getNSNumber(for: byteArray[19+13*(channel-1)] + byteArray[20+13*(channel-1)])
                let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: self, userInfo: data)
            }
        }
        CoreDataController.sharedInstance.saveChanges()

        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshClimate), object: self, userInfo: nil)
    }
    
    func parseMessageSingleACStatus(_ byteArray: [Byte]) {
        print("AC STATUS - SINGLE")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for i in 0..<devices.count {
            if isCorrectDeviceAddress(i: i, for: byteArray) && isCorrectDeviceChannel(i: i, byteArray: byteArray) {
                
                devices[i].currentValue = getNSNumber(for: byteArray[8])
                
                if let mode       = DeviceInfo.setMode[Int(byteArray[9])] { devices[i].mode = mode } else { devices[i].mode = "Auto" }
                if let modeState  = DeviceInfo.modeState[Int(byteArray[10])] { devices[i].modeState = modeState } else { devices[i].modeState = "Off" }
                if let speed      = DeviceInfo.setSpeed[Int(byteArray[11])] { devices[i].speed = speed } else { devices[i].speed = "Auto" }
                if let speedState = DeviceInfo.speedState[Int(byteArray[12])] { devices[i].speedState = speedState } else { devices[i].speedState = "Off" }
                
                devices[i].coolTemperature   = getNSNumber(for: byteArray[13])
                devices[i].heatTemperature   = getNSNumber(for: byteArray[14])
                devices[i].roomTemperature   = getNSNumber(for: byteArray[15])
                devices[i].humidity          = getNSNumber(for: byteArray[16])
                devices[i].filterWarning     = byteArray[17] == 0x00 ? false : true
                devices[i].allowEnergySaving = byteArray[18] == 0x00 ? getNSNumber(from: false) : getNSNumber(from: true)
                devices[i].current           = getNSNumber(for: byteArray[19] + byteArray[20])
                let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: self, userInfo: data)
            }
        }
        CoreDataController.sharedInstance.saveChanges()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshClimate), object: self, userInfo: nil)
    }
    
    func parseMessageACParametar (_ byteArray:[Byte]) {
        print("AC PARAMETAR")
        parseMessageAndPrint(byteArray)
        
        print(Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName))
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
            for i in 0..<devices.count {
                if isCorrectDeviceAddress(i: i, for: byteArray) && isCorrectDeviceChannel(i: i, byteArray: byteArray) {
                    
                    let name: String = getName(count: 42, byteArray: byteArray) // device name
                    if name != "" { devices[i].name = name } else { devices[i].name = "Unknown" }
                    
                    // PLC doesn't send info about this, so we put TRUE as default
                    devices[i].isEnabled = getNSNumber(from: true)
                    devices[i].isVisible = getNSNumber(from: true)
                    
                    devices[i].categoryId = getNSNumber(for: byteArray[32])
                    
                    // Parse zone and parent zone
                    if Int(byteArray[34]) == 0 {
                        devices[i].zoneId       = 0
                        devices[i].parentZoneId = getNSNumber(for: byteArray[33])
                    } else {
                        devices[i].zoneId       = getNSNumber(for: byteArray[33])
                        devices[i].parentZoneId = getNSNumber(for: byteArray[34])
                    }
                    
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDeviceName), object: self, userInfo: data)
                }
            }
            CoreDataController.sharedInstance.saveChanges()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        }
    }
    
    // MARK: - IR
    func parseMessageSingleIRCode(_ byteArray: [Byte]) {
        print("IR CODE")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for i in 0..<devices.count {
            if isCorrectDeviceAddress(i: i, for: byteArray) && isCorrectDeviceChannel(i: i, byteArray: byteArray) {
                
                devices[i].currentValue = getNSNumber(for: byteArray[8])
                CoreDataController.sharedInstance.saveChanges()
                // TODO
            }
        }
    }
    
    func parseMessageIRCode(_ byteArray: [Byte]) {
        print("IR CODE")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for i in 0..<devices.count {
            if isCorrectDeviceAddress(i: i, for: byteArray) {
                
                // TODO
            }
        }
    }
    
    func parseMessageIRLearningState(_ byteArray: [Byte]) {
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        print("IR LEARNING STATE")
        parseMessageAndPrint(byteArray)
        for i in 0..<devices.count {
            if isCorrectDeviceAddress(i: i, for: byteArray) && isCorrectDeviceChannel(i: i, byteArray: byteArray) {
                // TODO
            }
        }
    }
    func parseMessageIRSerialLibrary(_ byteArray: [Byte]) {
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        print("IR SERIAL LIBRARY")
        parseMessageAndPrint(byteArray)
        
        for i in 0..<devices.count {
            if isCorrectDeviceAddress(i: i, for: byteArray) {
                // TODO
            }
        }
    }
    
    func parseMessageIRSerialLibraryName(_ byteArray: [Byte]) {
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        print("IR SERIAL LIBRARY NAME")
        parseMessageAndPrint(byteArray)
        for i in 0..<devices.count {
            if isCorrectDeviceAddress(i: i, for: byteArray) {
                // TODO
            }
        }
    }
    
    // MARK: - Dimmer functions
    func parseMessageDimmerGetRunningTime (_ byteArray:[Byte]) {
        print("DIMMER RUNNING TIME")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for i in  0..<devices.count{
            if isCorrectDeviceAddress(i: i, for: byteArray) {
                if byteArray[7] != 0xFF && byteArray[7] != 0xF0 {
                    devices[i].runningTime = returnRunningTime([byteArray[8], byteArray[9], byteArray[10], byteArray[11]])
                } else if byteArray[7] == 0xF0 {
                    
                } else {
                    let channel = Int(devices[i].channel)
                    print(Int(devices[i].channel))
                    devices[i].runningTime = returnRunningTime([byteArray[8+4*(channel-1)], byteArray[9+4*(channel-1)], byteArray[10+4*(channel-1)], byteArray[11+4*(channel-1)]])
                    print(devices[i].controlType )
                    print(devices[i].runningTime)
                }
            }
        }
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }

    //  MARK: - Multisensor functions   |   informacije o imenima uredjaja na MULTISENSORU
    func parseMessageInterfaceName (_ byteArray:[Byte]) {
        print("INTERFACE NAME")
        parseMessageAndPrint(byteArray)
        
        print(Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName))
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
            for i in  0..<devices.count {
                
                if isCorrectDeviceAddress(i: i, for: byteArray) && isCorrectDeviceChannel(i: i, byteArray: byteArray) {
                    let name = getName(count: 9, byteArray: byteArray) // device name
                    if name != "" { devices[i].name = name } else { devices[i].name = "Unknown" }
                    
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDeviceName), object: self, userInfo: data)
                }
            }
            CoreDataController.sharedInstance.saveChanges()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        }
    }
    
    // MARK: - Interface functions
    func parseMessageInterfaceEnableStatus (_ byteArray: [Byte]) {
        print("INTERFACE ENABLE STATUS")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for device in devices {
            
            if isCorrectDeviceAddress(device: device, for: byteArray) && isCorrectDeviceChannel(device: device, byteArray: byteArray) {
                if byteArray[8] >= 0x80 { device.isEnabled = getNSNumber(from: true) } else { device.isEnabled = getNSNumber(from: false) }
                print("INTERFACE ENABLED STATUS: ", device.isEnabled)
            }
        }
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    
    func parseMessageInterfaceParametar (_ byteArray:[Byte]) {
        print("INTERFACE PARAMETAR")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        var counter = 0
        
        for device in devices {
            if isCorrectDeviceAddress(device: device, for: byteArray) && isCorrectDeviceChannel(device: device, byteArray: byteArray) {
                if let moc = appDel.managedObjectContext {
                    device.categoryId = NSNumber(value: Int(byteArray[8]))
                    
                    // Parse zone and parent zone
                    if Int(byteArray[10]) == 0 {
                        device.zoneId       = 0
                        device.parentZoneId = getNSNumber(for: byteArray[9])
                    } else {
                        device.zoneId       = getNSNumber(for: byteArray[9])
                        device.parentZoneId = getNSNumber(for: byteArray[10])
                    }
                    
                    // When we change category it will reset images
                    device.digitalInputMode = Int(byteArray[14]) as NSNumber?
                    if byteArray[11] >= 0x80 {
                        device.isEnabled = getNSNumber(from: true)
                        device.isVisible = getNSNumber(from: true)
                    } else {
                        device.isEnabled = getNSNumber(from: false)
                        device.isVisible = getNSNumber(from: false)
                    }
                    device.resetImages(moc)
                    let data = ["sensorIndexForFoundParametar":counter]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshInterface), object: self, userInfo: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindSensorParametar), object: self, userInfo: data)
                }
            }
            counter = counter + 1
        }
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    
    //  informacije o parametrima (statusu) uredjaja na MULTISENSORU - MISLIM DA JE OVO U REDU
    func parseMessageInterfaceStatus (_ byteArray:[Byte]) {
        print("INTERFACE STATUS")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for i in 0..<self.devices.count{
            
            if isCorrectDeviceAddress(i: i, for: byteArray) {
                let channel = Int(devices[i].channel)
                devices[i].currentValue = getNSNumber(for: byteArray[7+channel])
                print("INTERFACE STATUS: ", devices[i].currentValue)
            }
            
        }
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }

    // MARK: - Channel functions   |   informacije o stanjima na uredjajima
    func parseMessageChannelsState (_ byteArray:[Byte]) {
        print("CHANNEL'S STATE")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        if devices.count != 0 {
            for i in 0..<devices.count {
                if isCorrectDeviceAddress(i: i, for: byteArray) {
                    let channelNumber = Int(devices[i].channel)
                    
                    // Problem: If device is dimmer, then value that is received is in range from 0-100. In rest of the cases value is 0x00 or 0xFF (0 or 255)
                    // That is why we must check whether device value is >100. If value is greater than 100 that means that it is not dimmer and the only value greater than 100 can be 255
                    if Int(byteArray[8+5*(channelNumber-1)]) > 100 {
                        devices[i].currentValue = getNSNumber(for: byteArray[8+5*(channelNumber-1)]) // device is NOT dimmer and the value should be saved as received
                    } else {
                        devices[i].currentValue = NSNumber(value:  Int(byteArray[8+5*(channelNumber-1)])*255/100) // two cases: the device is dimmer and has some value. the device is not dimmer but the value is 0
                    }
                    print("CHANNELS STATE RECEIVED :", devices[i].currentValue)
                    
                    // check if number of channel is lower than bytearray
                    if 12+5*(channelNumber-1) < byteArray.count {
                        devices[i].current     = NSNumber(value: Int(UInt16(byteArray[9+5*(channelNumber-1)])*256 + UInt16(byteArray[10+5*(channelNumber-1)]))) // current
                        devices[i].voltage     = getNSNumber(for: byteArray[11+5*(channelNumber-1)]) // voltage
                        devices[i].temperature = getNSNumber(for: byteArray[12+5*(channelNumber-1)]) // temperature
                        let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: self, userInfo: data)
                    }
                }
            }
        }

        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    
    //  informacije o parametrima kanala
    func parseMessageChannelParameter(_ byteArray:[Byte]) {
        print("CHANNEL'S PARAMETER")
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
            for i in 0..<devices.count {
                if  isCorrectDeviceAddress(i: i, for: byteArray) && isCorrectDeviceChannel(i: i, byteArray: byteArray) {
                    if let moc = appDel.managedObjectContext {
                        // Parse device name
                        let name: String = getName(count: 8+47, byteArray: byteArray) // device name
                        if name != "" { devices[i].name = name } else { devices[i].name = "Unknown" }
                        
                        devices[i].overrideControl1 = getNSNumber(for: byteArray[23])
                        devices[i].overrideControl2 = getNSNumber(for: byteArray[24])
                        devices[i].overrideControl3 = getNSNumber(for: byteArray[25])
                        
                        // Parse zone and parent zone
                        if Int(byteArray[10]) == 0 {
                            devices[i].zoneId       = 0
                            devices[i].parentZoneId = getNSNumber(for: byteArray[9])
                        } else {
                            devices[i].zoneId       = getNSNumber(for: byteArray[9])
                            devices[i].parentZoneId = getNSNumber(for: byteArray[10])
                        }
                        
                        // Parse Category
                        devices[i].categoryId = getNSNumber(for: byteArray[8])
                        devices[i].resetImages(moc)
                        
                        // Enabled/Visible
                        if byteArray[22] == 0x01 {
                            devices[i].isEnabled = getNSNumber(from: true)
                            devices[i].isVisible = getNSNumber(from: true)
                        } else {
                            devices[i].isEnabled = getNSNumber(from: false)
                            devices[i].isVisible = getNSNumber(from: false)
                        }
                        
                        if byteArray[28] == 0x01 {
                            devices[i].isDimmerModeAllowed = getNSNumber(from: true)
                            devices[i].controlType         = ControlType.Dimmer
                        }
                        if byteArray[33] == 0x01 {
                            devices[i].isCurtainModeAllowed = getNSNumber(from: true)
                            devices[i].controlType          = ControlType.Curtain
                        }
                        devices[i].curtainGroupID     = getNSNumber(for: byteArray[34]) // CurtainGroupID defines the curtain device. If curtain group is the same on 2 channels then that is the same Curtain
                        devices[i].curtainControlMode = getNSNumber(for: byteArray[35]) // Will be used later (17.07.2016)
                        let data = ["deviceIndexForFoundName":i]
                        NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDeviceName), object: self, userInfo: data)
                    }
                }
            }
            CoreDataController.sharedInstance.saveChanges()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        }
    }
    
    func parseMessageChannelWarnings (_ byteArray:[Byte]) {
        print("CHANNEL WARNINGS")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for device in devices {
            if isCorrectDeviceAddress(device: device, for: byteArray) { device.warningState = Int(byteArray[6+5+6*(Int(device.channel)-1)]); print("CHANNEL WARNING")}
        }
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    
    // MARK: - Curtains functions
    func parseMessageCurtainState(_ byteArray:[Byte]) {
        print("CURTAIN STATE")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        for device in devices {
            
            if isCorrectDeviceAddress(device: device, for: byteArray) {
                let data = ["deviceDidReceiveSignalFromGateway":device]
                print("RECEIVED CURTAIN STATE FOR :", device.name)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: self, userInfo: data)
                break
            }
        }
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    
    //  MARK: - Flag functions   |   informacije o parametrima kanala
    func parseMessageFlagStatus (_ byteArray:[Byte]) {
        print("FLAG STATUS")
        parseMessageAndPrint(byteArray)
        
        let flags = DatabaseFlagsController.shared.getAllFlags()
        for i in 1...32 {
            for item in flags {
                if isCorrectFlagAddress(i: i, flag: item, byteArray: byteArray) {
                    
                    if Int(byteArray[7+i]) == 1 { item.setState = getNSNumber(from: false) } else if Int(byteArray[7+i]) == 0 { item.setState = getNSNumber(from: true) }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFlag), object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func parseMessageSecurityFeedbackHandler(_ byteArray:[Byte]) {
        print("SECURITY")
        parseMessageAndPrint(byteArray)
        
        let sortDescriptor = NSSortDescriptor(key: "securityName", ascending: true)
        let securities = DatabaseSecurityController.shared.getAllSecuritiesSortedBy(sortDescriptor)
        
        //FIXME: Pucalo je security zato sto nema u svim gatewayovima security
        if securities.count != 0 {
            if isCorrectSecurityAddress(security: securities[0], byteArray: byteArray) {
                let defaults = Foundation.UserDefaults.standard
                
                if byteArray[7] == 0x02 {
                    switch byteArray[8] {
                    case 0x00: defaults.setValue(SecurityControlMode.Disarm, forKey: UserDefaults.Security.SecurityMode)
                    case 0x01: defaults.setValue(SecurityControlMode.Away, forKey: UserDefaults.Security.SecurityMode)
                    case 0x02: defaults.setValue(SecurityControlMode.Night, forKey: UserDefaults.Security.SecurityMode)
                    case 0x03: defaults.setValue(SecurityControlMode.Day, forKey: UserDefaults.Security.SecurityMode)
                    case 0x04: defaults.setValue(SecurityControlMode.Vacation, forKey: UserDefaults.Security.SecurityMode)
                    default: break
                    }
                }
                if byteArray[7] == 0x03 {
                    switch byteArray[8] {
                    case 0x00: defaults.setValue(AlarmState.Idle, forKey: UserDefaults.Security.AlarmState)
                    case 0x01: defaults.setValue(AlarmState.Trouble, forKey: UserDefaults.Security.AlarmState)
                    case 0x02: defaults.setValue(AlarmState.Alert, forKey: UserDefaults.Security.AlarmState)
                    case 0x03: defaults.setValue(AlarmState.Alarm, forKey: UserDefaults.Security.AlarmState)
                    default: break
                    }
                }
                if byteArray[7] == 0x04 {
                    switch byteArray[8] {
                    case 0x00: defaults.set(false, forKey: UserDefaults.Security.IsPanic)
                    case 0x01: defaults.set(true, forKey: UserDefaults.Security.IsPanic)
                    default: break
                    }
                }
                print("EHGSecuritySecurityMode - \(String(describing: defaults.value(forKey: UserDefaults.Security.SecurityMode))) *** EHGSecurityAlarmState - \(String(describing: defaults.value(forKey: UserDefaults.Security.AlarmState))) *** EHGSecurityPanic - \(String(describing: defaults.bool(forKey: UserDefaults.Security.IsPanic)))")
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.Security.ControlModeStopBlinking), object: self, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshSecurity), object: self, userInfo: nil)
            }

        }
    }
    
    // MARK: - Get zones and categories
    func parseMessageNewZone(_ byteArray:[Byte]) {
        print("NEW ZONE")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningForZones) {
            // Miminum is 12, but that is also doubtful...
            if byteArray.count > 12 {
                let name        = getName(count: 11, baCount: 11 + Int(byteArray[10]), byteArray: byteArray) // device name
                let id          = byteArray[8]
                let level       = byteArray[byteArray.count - 2 - 1]
                
                var description = ""
                
                if byteArray[11+Int(byteArray[10])+2] != 0x00 {
                    let number = 11 + Int(byteArray[10]) + 2
                    description = getName(count: number, baCount: number + Int(byteArray[number-1]), byteArray: byteArray) // device name
                }
                
                var idDoesExist = false
                let zones = DatabaseHandler.sharedInstance.fetchZonesWithLocationId(gateways[0].location)
                
                for zone in zones {
                    if zone.id == getNSNumber(for: id) {
                        idDoesExist = true
                        (zone.name, zone.level, zone.zoneDescription) = (name, getNSNumber(for: level), description)
                        CoreDataController.sharedInstance.saveChanges()
                        break
                    }
                }
                
                if idDoesExist {
                } else {
                    if let moc = appDel.managedObjectContext {
                        let zone = Zone(context: moc)
                        (zone.id, zone.name, zone.level, zone.zoneDescription, zone.location, zone.orderId, zone.allowOption, zone.isVisible) = (getNSNumber(for: id), name, getNSNumber(for: level), description, gateways[0].location, getNSNumber(for: id), 1, true)
                        CoreDataController.sharedInstance.saveChanges()
                    }
                }
                
                let data = ["zoneId":Int(id)]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveZoneFromGateway), object: self, userInfo: data)
            }
        }
    }
    func parseMessageNewCategory(_ byteArray:[Byte]) {
        print("NEW CATEGORY")
        parseMessageAndPrint(byteArray)
        
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningForCategories) {
            var name:String = ""
            
            if 11+Int(byteArray[10]) < byteArray.count { name = getName(count: 11, baCount: 11 + Int(byteArray[10]), byteArray: byteArray) } // device name
            
            let id = byteArray[8]
            
            var description = ""
            
            if 11+Int(byteArray[10])+2 < byteArray.count {  //
                if byteArray[11+Int(byteArray[10])+2] != 0x00 {
                    let number = 11+Int(byteArray[10])+2
                    description = getName(count: number, baCount: number + Int(byteArray[number-1]), byteArray: byteArray) // device name
                }
            }
            var idDoesExist = false
            let categories  = DatabaseHandler.sharedInstance.fetchCategoriesWithLocationId(gateways[0].location)
            
            for category in categories {
                if category.id == getNSNumber(for: id) {
                    idDoesExist = true
                    (category.name, category.categoryDescription) = (name, description)
                    CoreDataController.sharedInstance.saveChanges()
                    break
                }
            }
            if !idDoesExist {
                if let moc = appDel.managedObjectContext {
                    if let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: moc) as? Category {
                        (category.id, category.name, category.categoryDescription, category.location, category.orderId, category.allowOption, category.isVisible) = (getNSNumber(for: id), name, description, gateways[0].location, getNSNumber(for: id), 3, true)
                        CoreDataController.sharedInstance.saveChanges()
                    }                    
                }
            }
            
            let data = ["categoryId":Int(id)]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveCategoryFromGateway), object: self, userInfo: data)
        }
    }
    
    //MARK: - PC Control functions
    func parsePCStatus(_ byteArray: [Byte]) {
        print("PC STATUS")
        parseMessageAndPrint(byteArray)
        
        devices = CoreDataController.sharedInstance.fetchDevicesForGateway(gateways[0])
        
        for device in devices {
            if isCorrectDeviceAddress(device: device, for: byteArray) { device.currentValue = getNSNumber(for: byteArray[8]); print("PC STATUS RECEIVED") }
        }
        
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshPC), object: self, userInfo: nil)
    }
    
}

// MARK: - Helper methods
extension IncomingHandler {
    
    func isCorrectDeviceAddress(i: Int, for byteArray: [Byte]) -> Bool {
        if Int(devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(devices[i].address) == Int(byteArray[4]) { return true }
        return false
    }
    func isCorrectDeviceAddress(device: Device, for byteArray: [Byte]) -> Bool {
        if Int(device.gateway.addressOne) == Int(byteArray[2]) && Int(device.gateway.addressTwo) == Int(byteArray[3]) && Int(device.address) == Int(byteArray[4]) { return true }
        return false
    }
    func isCorrectSecurityAddress(security: Security, byteArray: [Byte]) -> Bool {
        if byteArray[2] == Byte(Int(security.addressOne)) && byteArray[3] == Byte(Int(security.addressTwo)) && byteArray[4] == Byte(Int(security.addressThree)) { return true }
        return false
    }
    func isCorrectTimerAddress(i: Int, timer: Timer, byteArray: [Byte]) -> Bool {
        if Int(timer.gateway.addressOne) == byteArray[2] && Int(timer.gateway.addressTwo) == byteArray[3] && Int(timer.address) == byteArray[4] && Int(timer.timerId) == Int(i) { return true }
        return false
    }
    func isCorrectFlagAddress(i: Int, flag: Flag, byteArray: [Byte]) -> Bool {
        if Int(flag.gateway.addressOne) == Int(byteArray[2]) && Int(flag.gateway.addressTwo) == Int(byteArray[3]) && Int(flag.address) == Int(byteArray[4]) && Int(flag.flagId) == Int(i) { return true }
        return false
    }
    
    func isCorrectDeviceChannel(i: Int, byteArray: [Byte]) -> Bool {
        if Int(devices[i].channel) == Int(byteArray[7]) { return true }
        return false
    }
    func isCorrectDeviceChannel(device: Device, byteArray: [Byte]) -> Bool {
        if Int(device.channel) == Int(byteArray[7]) { return true }
        return false
    }
    
    func getNSNumber(for byte: Byte) -> NSNumber {
        return NSNumber(value: Int(byte))
    }
    
    func getNSNumber(from bool: Bool) -> NSNumber {
        return NSNumber(value: bool as Bool)
    }
    
    func getString(from byte: Byte) -> String {
        return "\(Character(UnicodeScalar(Int(byte))!))"
    }
    
    func getName(count: Int, byteArray: [Byte]) -> String {
        var string: String = ""
        for j in count..<byteArray.count-2 { string = string + getString(from: byteArray[j]) }
        return string
    }
    func getName(count: Int, baCount: Int, byteArray: [Byte]) -> String {
        var string: String = ""
        for j in count..<baCount { string = string + getString(from: byteArray[j]) }
        return string
    }
    
    func returnRunningTime (_ runningTimeByteArray:[Byte]) -> String {
        print(runningTimeByteArray)
        let x = Int(UInt.convertFourBytesToUInt(runningTimeByteArray))
        //        var z = UnsafePointer<UInt16>(runningTimeByteArray).memory
        //        var y = Int(runningTimeByteArray[0])*1*256 + Int(runningTimeByteArray[1])*1*256 + Int(runningTimeByteArray[2])*1*256 + Int(runningTimeByteArray[3])
        var seconds = x / 10
        let hours   = seconds / 3600
        let minutes = (seconds % 3600) / 60
        seconds     = seconds % 60
        let secdiv  = (x % 60) % 10
        return "\(returnTwoPlaces(hours)):\(returnTwoPlaces(minutes)):\(returnTwoPlaces(seconds)),\(secdiv)s"
    }
    
    func returnTwoPlaces (_ number:Int) -> String {
        return String(format: "%02d",number)
    }
    
    func parseMessageAndPrint(_ byteArray: [UInt8]){
        let byteLength = byteArray.count
        let SOI        = byteArray[0]
        let LEN        = byteArray[1]
        let ADDR       = [byteArray[2], byteArray[3], byteArray[4]]
        let CID1       = byteArray[5]
        let CID2       = byteArray[6]
        
        var INFO: [UInt8] = []
        guard 7 < byteLength-3 else { print("ParseMessageAndPrint: upperBound of range is < lowerBound"); return }
        for i in 7...byteLength-3 { INFO = INFO + [byteArray[i]] }
        
        let CHK = byteArray[byteArray.count-2]
        let EOI = byteArray[byteArray.count-1]
        print("-------------")
        print("SOI: \(SOI)")
        print("LEN: \(LEN)")
        print("ADDR: \(ADDR)")
        print("CID1: \(CID1)")
        print("CID2: \(CID2)")
        print("INFO: \(INFO)")
        print("CHK: \(CHK)")
        print("EOI: \(EOI)")
        print("-------------")
    }
    
}



// MARK: - Recieved message helpers
extension IncomingHandler {
    func messageIsValid() -> Bool {
        if byteArray[0] == 0xAA && byteArray[byteArray.count-1] == 0x10 { return true }
        return false
    }
    
    func messageIsNewDevice() -> Bool {
        if byteArray[5] == 0xF1 && byteArray[6] == 0x01 { return true }
        return false
    }
    
    func messageIsNewDeviceParameters() -> Bool {
        if byteArray[5] == 0xF1 && byteArray[6] == 0x0D { return true }
        return false
    }
    
    func messageIsNewDeviceSalto() -> Bool {
        if byteArray[5] == 0xF1 && byteArray[6] == 0x01 && byteArray[7] == 0x03 && byteArray[8] == 0x03 { return true }
        return false
    }
    
    func messageIsNewDeviceSaltoParameter() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x55 { return true }
        return false
    }
    
    func messageIsSaltoStatus() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x50 { return true }
        return false
    }
    
    func messageIsChannelParameter() -> Bool {
        if byteArray[5] == 0xF3 && byteArray[6] == 0x01 { return true }
        return false
    }
    
    func messageIsChannelState() -> Bool {
        if byteArray[5] == 0xF3 && byteArray[6] == 0x06 && byteArray[7] == 0xFF { return true }
        return false
    }
    
    func messageIsCurtainState() -> Bool {
        if byteArray[5] == 0xF3 && byteArray[6] == 0x06 && byteArray[7] == 0xF0 { return true }
        return false
    }
    
    func messageIsRunningTime() -> Bool {
        if byteArray[5] == 0xF3 && byteArray[6] == 0x0C { return true }
        return false
    }
    
    func messageIsChannelWarning() -> Bool {
        if byteArray[5] == 0xF3 && byteArray[6] == 0x10 { return true }
        return false
    }
    
    func messageIsAcParameter() -> Bool {
        if byteArray[5] == 0xF4 && byteArray[6] == 0x01 { return true }
        return false
    }
    
    func messageIsAcControlStatus() -> Bool {
        if byteArray[5] == 0xF4 && byteArray[6] == 0x03 && byteArray[7] == 0xFF { return true }
        return false
    }
    
    func messageIsSingleACControlStatus() -> Bool {
        if byteArray[5] == 0xF4 && byteArray[6] == 0x03 && byteArray[7] != 0xFF { return true }
        return false
    }
    
    func messageIsInterfaceParameter() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x02 { return true }
        return false
    }
    
    func messageIsInterfaceStatus() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x01 && byteArray[7] == 0xFF { return true }
        return false
    }
    
    func messageIsSecurityFeedbackHandler() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x01 { return true }
        return false
    }
    
    func messageIsInterfaceEnableStatus() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x03 { return true }
        return false
    }
    
    func messageIsInterfaceName() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x04 { return true }
        return false
    }
    
    func messageIsTimerStatus() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x17 && byteArray[7] == 0xFF { return true }
        return false
    }
    
    func messageIsTimerStatusData() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x19 && byteArray[7] == 0xFF { return true }
        return false
    }
    
    func messageIsTimerName() -> Bool{
        if byteArray[5] == 0xF5 && byteArray[6] == 0x15 { return true }
        return false
    }
    
    func messageIsTimerParameters() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x13 { return true }
        return false
    }
    
    func messageIsFlagStatus() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x06 && byteArray[7] == 0xFF { return true }
        return false
    }
    
    func messageIsNewFlag() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x04 { return true }
        return false
    }
    
    func messageIsNewFlagParameter() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x02 { return true }
        return false
    }
    
    func messageIsEventStatus() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x12 { return true }
        return false
    }
    
    func messageIsNewEvent() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x08 { return true }
        return false
    }
    
    func messageIsNewCardName() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x57 { return true }
        return false
    }
    
    func messageIsNewCardParameter() -> Bool {
        if byteArray[5] == 0xF5 && byteArray[6] == 0x56 { return true }
        return false
    }
    
    func messageIsNewZone() -> Bool {
        if byteArray[5] == 0xF2 && byteArray[6] == 0x11 && byteArray[7] == 0x00 { return true }
        return false
    }
    
    func messageIsNewCategory() -> Bool {
        if byteArray[5] == 0xF2 && byteArray[6] == 0x13 && byteArray[7] == 0x00 { return true }
        return false
    }
    
    func messageIsNewScene() -> Bool {
        if byteArray[5] == 0xF3 && byteArray[6] == 0x08 { return true }
        return false
    }
    
    func messageIsNewSequence() -> Bool {
        if byteArray[5] == 0xF3 && byteArray[6] == 0x0A { return true }
        return false
    }
    
    func messageIsPCStatus() -> Bool {
        if byteArray[5] == 0xFA && byteArray[6] == 0x01 { return true }
        return false
    }
    // IR
    func messageIsIRCode() -> Bool {
        if byteArray[5] == 0xF9 && byteArray[6] == 0x01 { return true }
        return false
    }
    func messageIsSingleIRCode() -> Bool {
        if byteArray[5] == 0xF9 && byteArray[6] == 0x02 { return true }
        return false
    }
    func messageIsIRLearningState() -> Bool {
        if byteArray[5] == 0xF9 && (byteArray[6] == 0x03 || byteArray[6] == 0x04) { return true }
        return false
    }
    func messageIsIRSerialLibrary() -> Bool {
        if byteArray[5] == 0xF9 && (byteArray[6] == 0x0A || byteArray[6] == 0x0B) { return true }
        return false
    }
    func messageIsIRSerialLibraryName() -> Bool {
        if byteArray[5] == 0xF9 && (byteArray[6] == 0x0C || byteArray[6] == 0x0D) { return true }
        return false
    }
    
}
