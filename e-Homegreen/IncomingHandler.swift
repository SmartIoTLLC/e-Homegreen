
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
        gateways = CoreDataController.shahredInstance.fetchGatewaysForHost(host, port: port)
        
        guard let dataFrame = DataFrame(byteArray: byteArrayToHandle) else {
            return
        }
        //  Checks if there are any gateways
        if gateways.count > 0 {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            self.byteArray = byteArrayToHandle
            if messageIsValid() {
                if messageIsNewDeviceSalto(){
                    self.parseMessageNewDevicSalto(self.byteArray)
                }
                else{
                    if messageIsNewDevice() {
                        self.parseMessageNewDevice(self.byteArray)
                    }
                }
                if messageIsNewDeviceParameters() {
                    self.parseMessageNewDeviceParameter(self.byteArray)
                }
            
                //  ACKNOWLEDGEMENT ABOUT CHANNEL PARAMETAR (Get Channel Parametar) IMENA
                if messageIsChannelParameter() {
                    self.parseMessageChannelParameter(self.byteArray)
                }
                if messageIsChannelState() {
                    self.parseMessageChannelsState(self.byteArray)
                }
                
                //  ACKNOWLEDGMENT ABOUT CHANNEL WARNINGS (Get Channel On Last Current Change Warning)
                if messageIsChannelWarning() {
                    self.parseMessageChannelWarnings(self.byteArray)
                }
                if messageIsCurtainState() {
                    self.parseMessageCurtainState(self.byteArray)
                }
                
                //  ACKNOWLEDGMENT ABOUT RUNNING TIME (Get Channel On Time Count)
                if messageIsRunningTime() {
                    self.parseMessageDimmerGetRunningTime(self.byteArray)
                }
                if messageIsAcParameter() {
                    self.parseMessageACParametar(self.byteArray)
                }
                if messageIsAcControlStatus() {
                    self.parseMessageACstatus(self.byteArray)
                }
                if messageIsInterfaceParameter() {
                    self.parseMessageInterfaceParametar(self.byteArray)
                }
                if messageIsInterfaceStatus(){ // OVO NE MOZE OVAKO DA BUDE
                    self.parseMessageInterfaceStatus(self.byteArray)
                }
                if messageIsSecurityFeedbackHandler() {
                    self.parseMessageSecurityFeedbackHandler(self.byteArray)
                }
                if messageIsInterfaceEnableStatus() {
                    self.parseMessageInterfaceEnableStatus(self.byteArray)
                }
                if messageIsInterfaceName() {
                    self.parseMessageInterfaceName(self.byteArray)
                }
                if messageIsTimerStatus() {
                    self.parseMessageTimerStatus(self.byteArray)
                }
                if messageIsFlagStatus() {
                    self.parseMessageFlagStatus(self.byteArray)
                }
                if messageIsNewZone() {
                    self.parseMessageNewZone(self.byteArray)
                }
                if messageIsNewCategory() {
                    self.parseMessageNewCategory(self.byteArray)
                }
                if messageIsEventStatus() {
                    self.parseMessageRefreshEvent(self.byteArray)
                }
                if messageIsTimerStatusData() {
                    self.parseTimerStatus(dataFrame)
                }
                if messageIsTimerName() {
                    self.parseMessageTimerName(self.byteArray)
                }
                if messageIsTimerParameters() {
                    self.parseMessageTimerParameters(self.byteArray)
                }
                if messageIsNewScene(){
                    self.parseMessageNewScene(self.byteArray)
                }
                if messageIsNewSequence() {
                    self.parseMessageNewSequence(self.byteArray)
                }
                if messageIsNewEvent() {
                    self.parseMessageNewEvent(self.byteArray)
                }
                if messageIsNewFlag() {
                    self.parseMessageFlagName(self.byteArray)
                }
                if messageIsNewFlagParameter() {
                    self.parseMessageFlagParameters(self.byteArray)
                }
                if messageIsNewCardName() {
                    self.parseMessageCardName(self.byteArray)
                }
                if messageIsNewCardParameter() {
                    self.parseMessageCardParameters(self.byteArray)
                }
                if messageIsNewDeviceSaltoParameter() {
                    self.parseMessageSaltoParameters(self.byteArray)
                }
            }
        }
    }
    
    // MARK - Timers
    func parseMessageTimerName(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningTimerNames) {
            var timerId = Int(byteArray[7])
            // Miminum is 12b
            if Int(byteArray[8]) != 0 {
                var name:String = ""
                for j in 9 ..< 9+Int(byteArray[8]) {
                    name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  timer name
                }
                timerId = Int(byteArray[7])
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 {
                    DatabaseTimersController.shared.addTimer(timerId, timerName: name, moduleAddress: moduleAddress, gateway: gateways.first!, type: nil, levelId: nil, selectedZoneId: nil, categoryId: nil)
                }else{
                    return
                }
            }
            let data = ["timerId":timerId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveTimerFromGateway), object: self, userInfo: data)
        }
    }
    func parseMessageTimerParameters(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningTimerParameters) {
            var timerId = Int(byteArray[7])
            // Miminum is 14b
            if byteArray.count > 14 {
                timerId = Int(byteArray[7])
                let timerCategoryId = byteArray[8]
                let timerZoneId = byteArray[9]
                let timerLevelId = byteArray[10]
                let timerType = byteArray[12]
                
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 {
                    DatabaseTimersController.shared.addTimer(timerId, timerName: nil, moduleAddress: moduleAddress, gateway: gateways.first!, type: Int(timerType), levelId: Int(timerLevelId), selectedZoneId: Int(timerZoneId), categoryId: Int(timerCategoryId))
                }else{
                    return
                }
            }
            let data = ["timerId":timerId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveTimerParameterFromGateway), object: self, userInfo: data)
        }
    }
    func parseTimerStatus(_ dataFrame:DataFrame) {
        
        let sortDescriptor = NSSortDescriptor(key: "timerName", ascending: true)
        let timers = DatabaseTimersController.shared.getAllTimersSortedBy(sortDescriptor)
        
        // For loop in data frame INFO block
        for i in 1...16 {
            for item in timers {
                if  Int(item.gateway.addressOne) == Int(dataFrame.ADR1) && Int(item.gateway.addressTwo) == Int(dataFrame.ADR2) && Int(item.address) == Int(dataFrame.ADR3) && Int(item.timerId) == Int(i) {
                    let position = (i - 1)*4
                    let fourBytes = [dataFrame.INFO[1+position], dataFrame.INFO[2+position], dataFrame.INFO[3+position], dataFrame.INFO[4+position]]
                    item.count = NSNumber(value: UInt.convertFourBytesToUInt(fourBytes) as UInt)
                    item.timerCount = UInt.convertFourBytesToUInt(fourBytes)
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshTimer), object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
    }
    
    // MARK - Scenes
    func parseMessageNewScene(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningSceneNameAndParameters) {
            var sceneId = Int(byteArray[7])
            // Miminum is 80b
            if byteArray.count > 80 {
                sceneId = Int(byteArray[7])
                let sceneZoneId = Int(byteArray[74])
                let sceneLevelId = Int(byteArray[75])
                let sceneCategoryId = Int(byteArray[76])
                
                var name:String = ""
                for j in 78 ..< 78+Int(byteArray[77]) {
                    name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  scene name
                }
                
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 {
                    DatabaseScenesController.shared.createScene(sceneId, sceneName: name, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: sceneLevelId, zoneId: sceneZoneId, categoryId: sceneCategoryId)
                }else{
                    return
                }
            }
            let data = ["sceneId":sceneId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveSceneFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK - Sequences
    func parseMessageNewSequence(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningSequencesNameAndParameters) {
            var sequenceId = Int(byteArray[7])
            // Miminum is 82b
            if byteArray.count > 82 {
                
                let bytes:[UInt8] = [byteArray[9], byteArray[8]]
                
                let id = UnsafePointer(bytes).withMemoryRebound(to: UInt16.self, capacity: 1) {
                    $0.pointee
                }
                
                sequenceId = Int(byteArray[7])
                let sequenceZoneId = Int(byteArray[76])
                let sequenceLevelId = Int(byteArray[77])
                let sequenceCategoryId = Int(byteArray[78])
                
                var name:String = ""
                for j in 80 ..< 80+Int(byteArray[79]) {
                    name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  sequences name
                }
                
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 {
                    DatabaseSequencesController.shared.createSequence(Int(id), sequenceName: name, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: sequenceLevelId, zoneId: sequenceZoneId, categoryId: sequenceCategoryId)
                }else{
                    return
                }
                
                
            }
            let data = ["sequenceId":sequenceId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveSequenceFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK - Event
    func parseMessageNewEvent(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningEventsNameAndParameters) {
            var eventId = Int(byteArray[7])
            // Miminum is 14b
            if byteArray.count > 14 {
                eventId = Int(byteArray[7])
                let eventZoneId = Int(byteArray[10])
                let eventLevelId = Int(byteArray[11])
                let eventCategoryId = Int(byteArray[9])
                
                var name:String = ""
                for j in 13 ..< 13+Int(byteArray[12]) {
                    name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  event name
                }
                
                if name.trimmingCharacters(in: CharacterSet(charactersIn: "")) != "" {
                    let moduleAddress = Int(byteArray[4])
                    
                    if gateways.count > 0 {
                        DatabaseEventsController.shared.createEvent(eventId, eventName: name, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: eventLevelId, zoneId: eventZoneId, categoryId: eventCategoryId)
                    }else{
                        return
                    }
                }
            }
            let data = ["eventId":eventId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveEventFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK - Flags
    func parseMessageFlagName(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningFlagNames) {
            var flagId = Int(byteArray[7]) - 100
            // Miminum is 12b
            if Int(byteArray[8]) != 0 {
                var name:String = ""
                for j in 9 ..< 9+Int(byteArray[8]) {
                    name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  timer name
                }
                flagId = Int(byteArray[7]) - 100
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 {
                    DatabaseFlagsController.shared.createFlag(flagId, flagName: name, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: nil, selectedZoneId: nil, categoryId: nil)
                }else{
                    return
                }
            }
            let data = ["flagId":flagId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveFlagFromGateway), object: self, userInfo: data)
        }
    }
    func parseMessageFlagParameters(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningFlagParameters) {
            var flagId = Int(byteArray[7]) - 100
            // Miminum is 14b
            if byteArray.count > 14 {
                flagId = Int(byteArray[7]) - 100
                let flagCategoryId = Int(byteArray[8])
                let flagZoneId = Int(byteArray[9])
                let flagLevelId = Int(byteArray[10])
                
                let moduleAddress = Int(byteArray[4])
                
                if gateways.count > 0 {
                    DatabaseFlagsController.shared.createFlag(flagId, flagName: nil, moduleAddress: moduleAddress, gateway: gateways.first!, levelId: flagLevelId, selectedZoneId: flagZoneId, categoryId: flagCategoryId)
                }else{
                    return
                }
            }
            let data = ["flagId":flagId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveFlagParameterFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK - Cards
    func parseMessageCardName(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningCardNames) {
            let id = Int(byteArray[8])
            // Miminum is 12b
            if id != 0 {
                var name:String = ""
                if Int(byteArray[9]) > 0 && Int(byteArray[9]) != 255{
                    for j in 10 ..< 10+Int(byteArray[9]) {
                        name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  timer name
                    }
                    let moduleAddress = Int(byteArray[4])
                    
                    if gateways.count > 0 {
                        DatabaseCardsController.shared.createCard(id, cardId: nil, cardName: name, moduleAddress: moduleAddress, gateway: gateways.first!)
                    }else{
                        return
                    }
                }
            }
            let data = ["cardId":id]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveCardFromGateway), object: self, userInfo: data)
        }
    }
    func parseMessageCardParameters(_ byteArray: [Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningCardParameters) {
            let id = Int(byteArray[8])
            // Miminum is 14b
            if id != 0 {
                
                let moduleAddress = Int(byteArray[4])
                
                var isEnabled:Bool = true
                if byteArray[9] == 0x00{
                    isEnabled = false
                }
                
                let cardId = NSString(format: "%02X %02X %02X %02X %02X %02X %02X", byteArray[10], byteArray[11], byteArray[12], byteArray[13], byteArray[14], byteArray[15], byteArray[16])
                
                let timerAddress:Int = Int(byteArray[53])
                let timerId = Int(byteArray[54])
                
                if gateways.count > 0 {
                    DatabaseCardsController.shared.createCard(id, cardId: cardId as String, cardName: nil, moduleAddress: moduleAddress, gateway: gateways.first!, isEnabled: isEnabled, timerAddress: timerAddress, timerId: timerId)
                }else{
                    return
                }
            }
            let data = ["cardId":id]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveCardParameterFromGateway), object: self, userInfo: data)
        }
    }
    
    // MARK - New devices
    func parseMessageNewDevice (_ byteArray:[Byte]) {
        print(Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDevice))
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDevice) {
            var deviceExists = false
            if let channel = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.channel,
                let controlType = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                
                let MAC:[Byte] = Array(byteArray[9...14])
                if devices != [] {
                    for device in devices {
                        if Int(device.address) == Int(byteArray[4]) {deviceExists = true}
                    }
                } else {deviceExists = false}
                if !deviceExists {
                    for i in 1...channel{
                        var isClimate = false
                        if controlType == ControlType.Climate {
                            isClimate = true
                        }
                        let deviceInformation = DeviceInformation(address: Int(byteArray[4]), channel: i, numberOfDevices: channel, type: controlType, gateway: gateways[0], mac: Data(bytes: UnsafePointer<UInt8>(MAC), count: MAC.count), isClimate:isClimate)
                        
                        if (controlType == ControlType.Sensor ||
                            controlType == ControlType.IntelligentSwitch) && i > 1{
                            
                            let _ = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                            
                        }else if controlType == ControlType.Climate ||
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
                            
                            let _ = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation)
                        }
                        
                        CoreDataController.shahredInstance.saveChanges()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
                    }
                    let data = ["deviceAddresInGateway":Int(byteArray[4])]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDevice), object: self, userInfo: data)
                }
            }
        }
    }
    func parseMessageNewDevicSalto (_ byteArray:[Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDevice) {
            var deviceExists = false
            if let controlType = DeviceInfo.deviceType[DeviceType(deviceId: byteArray[7], subId: byteArray[8])]?.name {
                let MAC:[Byte] = Array(byteArray[9...14])
                if devices != [] {
                    for device in devices {
                        if Int(device.address) == Int(byteArray[4]) {deviceExists = true}
                    }
                } else {deviceExists = false}
                if !deviceExists {
                    for i in 1...4{
                        let deviceInformation = DeviceInformation(address: Int(byteArray[4]), channel: i, numberOfDevices: 4, type: controlType, gateway: gateways[0], mac: Data(bytes: UnsafePointer<UInt8>(MAC), count: MAC.count), isClimate:false)
                        
                        if (controlType == ControlType.SaltoAccess){
                            let _ = Device(context: appDel.managedObjectContext!, specificDeviceInformation: deviceInformation, channelName: "Lock \(i)")
                        }
                        
                        CoreDataController.shahredInstance.saveChanges()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
                    }
                    let data = ["deviceAddresInGateway":Int(byteArray[4])]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDevice), object: self, userInfo: data)
                }
            }
        }
        
    }
    func parseMessageSaltoParameters(_ byteArray: [Byte]){
        // MARK - Salto
        // This response message contains two bytes which carry information about which channel (device) is selected.
        // There can be max 4 devices for Salto (on that address). Which ever is selected in admin panel (1...16) must be shown and device channel is set to that number
        // For example: If 1 and 16 is selected, we will have two bytes with tat information 0x80 0x01, and there should be four devices:
        // Lock 1: channel 1
        // Lock 2: channel 16
        // Lock 3: chaneel 0
        // Lock 4: channel 0
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            // Get two bytes that carry info
            var first8Devices = byteArray[8]
            var second8Devices = byteArray[7]
            
            // Get which channels should be set
            var arrayOfActiveChannels: [Int] = []
            for i in 1...8 {
                if first8Devices & 0x1 == 1{
                    arrayOfActiveChannels.append(i)
                }
                first8Devices = first8Devices >> 1
            }
            for i in 1...8 {
                if second8Devices & 0x1 == 1{
                    arrayOfActiveChannels.append(i + 8)
                }
                second8Devices = second8Devices >> 1
            }
            
            if arrayOfActiveChannels.count > 4 { // something is wrong if we could select more than 4
                return
            }
            var devicesForSalto: [Device] = []
            // Get needed devices and be sure that everything is in good order
            for i in 1..<devices.count{
                if  Int(devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(devices[i].address) == Int(byteArray[4]){
                    devicesForSalto.append(devices[i])
                }
            }
            devicesForSalto = devicesForSalto.sorted(by: { (dev1, dev2) -> Bool in
                return (dev1.name < dev2.name)
            })
            
            // Set new parameters for device
            for device in devicesForSalto {
                if arrayOfActiveChannels.count > 0{
                    device.isEnabled = NSNumber(value: true as Bool)
                    device.isVisible = NSNumber(value: true as Bool)
                    device.controlType = ControlType.SaltoAccess
                    device.channel = NSNumber(value: arrayOfActiveChannels.first!)
                    arrayOfActiveChannels.removeFirst()
                }else{
                    device.isEnabled = NSNumber(value: false as Bool)
                    device.isVisible = NSNumber(value: false as Bool)
                    device.controlType = ControlType.SaltoAccess
                    device.channel = 0
                }
            }
            let data = ["deviceIndexForFoundName":Int(byteArray[4])]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDeviceName), object: self, userInfo: data)
            CoreDataController.shahredInstance.saveChanges()
        }
    }
    
    func parseMessageRefreshEvent(_ byteArray:[Byte]){
        let data = ["id":Int(byteArray[7]), "value":Int(byteArray[8])]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReportEvent"), object: self, userInfo: data)
    }
    func parseMessageChannelWarnings (_ byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for device in devices {
            if Int(device.gateway.addressOne) == Int(byteArray[2]) && Int(device.gateway.addressTwo) == Int(byteArray[3]) && Int(device.address) == Int(byteArray[4]) {
                //                var number = Int(byteArray[6+5*Int(device.channel)])
                print("\(6+6*Int(device.channel)) - \(Int(device.channel)) - \(Int(byteArray[6+5+6*(Int(device.channel)-1)]))")
                device.warningState = Int(byteArray[6+5+6*(Int(device.channel)-1)])
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    
    func parseMessageACstatus (_ byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for i in 0..<devices.count{
            if Int(devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(devices[i].address) == Int(byteArray[4]) {
                let channel = Int(devices[i].channel)
                devices[i].currentValue = NSNumber(value: Int(byteArray[8+13*(channel-1)]))
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
                devices[i].coolTemperature = NSNumber(value: Int(byteArray[13+13*(channel-1)]))
                devices[i].heatTemperature = NSNumber(value: Int(byteArray[14+13*(channel-1)]))
                devices[i].roomTemperature = NSNumber(value: Int(byteArray[15+13*(channel-1)]))
                devices[i].humidity = NSNumber(value: Int(byteArray[16+13*(channel-1)]))
                devices[i].filterWarning = byteArray[17+13*(channel-1)] == 0x00 ? false : true
                devices[i].allowEnergySaving = byteArray[18+13*(channel-1)] == 0x00 ? NSNumber(value: false as Bool) : NSNumber(value: true as Bool)
                devices[i].current = NSNumber(value: (Int(byteArray[19+13*(channel-1)]) + Int(byteArray[20+13*(channel-1)])))
                let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: self, userInfo: data)
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshClimate), object: self, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    
    func parseMessageDimmerGetRunningTime (_ byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for i in  0..<devices.count{
            if Int(devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(devices[i].address) == Int(byteArray[4]) {
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }

    //  informacije o imenima uredjaja na MULTISENSORU
    func parseMessageInterfaceName (_ byteArray:[Byte]) {
        print(Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName))
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            var string:String = ""
            for j in 9..<byteArray.count-2{
                string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  device name
            }
            for i in  0..<devices.count{
                if Int(devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(devices[i].address) == Int(byteArray[4]) && Int(devices[i].channel) == Int(byteArray[7]) {
                    //                var channel = Int(devices[i].channel)
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDeviceName), object: self, userInfo: data)
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        }
    }
    func parseMessageInterfaceEnableStatus (_ byteArray: [Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for device in devices {
            if Int(device.gateway.addressOne) == Int(byteArray[2]) && Int(device.gateway.addressTwo) == Int(byteArray[3]) && Int(device.address) == Int(byteArray[4]) && Int(device.channel) == Int(byteArray[7]) {
                if byteArray[8] >= 0x80 {
                    device.isEnabled = NSNumber(value: true as Bool)
                } else {
                    device.isEnabled = NSNumber(value: false as Bool)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    func parseMessageInterfaceParametar (_ byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        var counter = 0
        for device in devices {
            if Int(device.gateway.addressOne) == Int(byteArray[2]) && Int(device.gateway.addressTwo) == Int(byteArray[3]) && Int(device.address) == Int(byteArray[4]) && Int(device.channel) == Int(byteArray[7]) {
                device.zoneId = NSNumber(value: Int(byteArray[9]))
                device.parentZoneId = NSNumber(value: Int(byteArray[10]))
                device.categoryId = NSNumber(value: Int(byteArray[8]))
                // When we change category it will reset images
                device.digitalInputMode = Int(byteArray[14]) as NSNumber?
                //                var interfaceParametar:[Byte] = []
                //                for var i = 7; i < byteArray.count-2; i++ {
                //                    interfaceParametar.append(byteArray[i])
                //                }
                //                device.interfaceParametar = interfaceParametar
                if byteArray[11] >= 0x80 {
                    device.isEnabled = NSNumber(value: true as Bool)
                    device.isVisible = NSNumber(value: true as Bool)
                } else {
                    device.isEnabled = NSNumber(value: false as Bool)
                    device.isVisible = NSNumber(value: false as Bool)
                }
                device.resetImages(appDel.managedObjectContext!)
                let data = ["sensorIndexForFoundParametar":counter]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshInterface), object: self, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindSensorParametar), object: self, userInfo: data)
                
            }
            counter = counter + 1
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    func parseMessageACParametar (_ byteArray:[Byte]) {
        print(Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName))
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            var string:String = ""
            for i in 9..<byteArray.count-2{
                string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))!))" //  device name
                print(string)
            }
            for i in 0..<devices.count {
                if Int(devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(devices[i].address) == Int(byteArray[4]) && Int(devices[i].channel) == Int(byteArray[7]) {
                    var string:String = ""
                    for j in 42..<byteArray.count-2{
                        string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  device name
                    }
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    
                    // PLC doesn't send info about this, so we put TRUE as default
                    devices[i].isEnabled = NSNumber(value: true as Bool)
                    devices[i].isVisible = NSNumber(value: true as Bool)
                    
                    devices[i].zoneId = NSNumber(value: Int(byteArray[33]))
                    devices[i].parentZoneId = NSNumber(value: Int(byteArray[34]))
                    devices[i].categoryId = NSNumber(value: Int(byteArray[32]))
                    //                    devices[i].enabled = ""
                    //                    if byteArray[22] == 0x01 {
                    //                        devices[i].isEnabled = NSNumber(bool: true)
                    //                    } else {
                    //                        devices[i].isEnabled = NSNumber(bool: false)
                    //                    }
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDeviceName), object: self, userInfo: data)
                    
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        }
    }
    
    //  informacije o parametrima (statusu) urdjaja na MULTISENSORU - MISLIM DA JE OVO U REDU
    func parseMessageInterfaceStatus (_ byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for i in 0..<self.devices.count{
            if Int(self.devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(self.devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(self.devices[i].address) == Int(byteArray[4]) {
                let channel = Int(self.devices[i].channel)
                self.devices[i].currentValue = NSNumber(value: Int(byteArray[7+channel]) * 255/100) // This calculation is added because app uses 0-255 range, and PLC is sending 0-100
                print(Int(byteArray[7+channel]))
            }
            
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    func parseMessageNewDeviceParameter(_ byteArray:[Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            for device in devices {
                if Int(device.gateway.addressOne) == Int(byteArray[2]) && Int(device.gateway.addressTwo) == Int(byteArray[3]) && Int(device.address) == Int(byteArray[4]) {
                    var string:String = ""
                    for j in 12..<(byteArray.count-2) {
                        string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  device name
                    }
                    if string != "" {
                        device.name = string
                    } else {
                        device.name = "Unknown"
                    }
                    device.categoryId = NSNumber(value: Int(byteArray[8]))
                    device.zoneId = NSNumber(value: Int(byteArray[9]))
                    device.parentZoneId = NSNumber(value: Int(byteArray[10]))
                    // When we change category it will reset images
                    device.resetImages(appDel.managedObjectContext!)
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        }
    }
    //  informacije o stanjima na uredjajima
    func parseMessageChannelsState (_ byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for i in 0..<devices.count{
            if Int(devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(devices[i].address) == Int(byteArray[4]) {
                let channelNumber = Int(devices[i].channel)
                // Problem: If device is dimmer, then value that is received is in range from 0-100. In rest of the cases value is 0x00 of 0xFF (0 or 255)
                // That is why we must check whether device value is >100. If value is greater than 100 that means that it is not dimmer and the only value greater than 100 can be 255
                if Int(byteArray[8+5*(channelNumber-1)]) > 100 {
                    devices[i].currentValue = NSNumber(value: Int(byteArray[8+5*(channelNumber-1)])) // device is NOT dimmer and the value should be saved as received
                }else{
                    devices[i].currentValue = NSNumber(value:  Int(byteArray[8+5*(channelNumber-1)])*255/100) // two cases: the device is dimmer and has some value. the device is not dimmer but the value is 0
                }
                //                let data = NSData(bytes: [byteArray[9+5*(channelNumber-1)], byteArray[10+5*(channelNumber-1)]], length: 2)
                devices[i].current = NSNumber(value: Int(UInt16(byteArray[9+5*(channelNumber-1)])*256 + UInt16(byteArray[10+5*(channelNumber-1)]))) // current
                devices[i].voltage = NSNumber(value: Int(byteArray[11+5*(channelNumber-1)])) // voltage
                devices[i].temperature = NSNumber(value: Int(byteArray[12+5*(channelNumber-1)])) // temperature
                let data = ["deviceDidReceiveSignalFromGateway":devices[i]]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: self, userInfo: data)
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    //  informacije o parametrima kanala
    func parseMessageChannelParameter(_ byteArray:[Byte]){
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
            for i in 0..<devices.count{
                if  Int(devices[i].gateway.addressOne) == Int(byteArray[2]) && Int(devices[i].gateway.addressTwo) == Int(byteArray[3]) && Int(devices[i].address) == Int(byteArray[4]) && Int(devices[i].channel) == Int(byteArray[7]) {
                    // Parse device name
                    var string:String = ""
                    for j in (8+47)..<(byteArray.count-2){
                        string = string + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  device name
                    }
                    if string != "" {
                        devices[i].name = string
                    } else {
                        devices[i].name = "Unknown"
                    }
                    
                    devices[i].overrideControl1 = NSNumber(value: Int(byteArray[23]))
                    devices[i].overrideControl2 = NSNumber(value: Int(byteArray[24]))
                    devices[i].overrideControl3 = NSNumber(value: Int(byteArray[25]))
                    
                    // Parse zone and parent zone
                    if Int(byteArray[10]) == 0 {
                        devices[i].zoneId = 0
                        devices[i].parentZoneId = NSNumber(value: Int(byteArray[9]))
                    } else {
                        devices[i].zoneId = NSNumber(value: Int(byteArray[9]))
                        devices[i].parentZoneId = NSNumber(value: Int(byteArray[10]))
                    }
                    
                    // Parse Category
                    devices[i].categoryId = NSNumber(value: Int(byteArray[8]))
                    devices[i].resetImages(appDel.managedObjectContext!)
                    
                    // Enabled/Visible
                    if byteArray[22] == 0x01 {
                        devices[i].isEnabled = NSNumber(value: true as Bool)
                        devices[i].isVisible = NSNumber(value: true as Bool)
                    } else {
                        devices[i].isEnabled = NSNumber(value: false as Bool)
                        devices[i].isVisible = NSNumber(value: false as Bool)
                    }
                    
                    if byteArray[28] == 0x01 {
                        devices[i].isDimmerModeAllowed = NSNumber(value: true as Bool)
                        devices[i].controlType = ControlType.Dimmer
                    }
                    if byteArray[33] == 0x01 {
                        devices[i].isCurtainModeAllowed = NSNumber(value: true as Bool)
                        devices[i].controlType = ControlType.Curtain
                    }
                    devices[i].curtainGroupID = NSNumber(value: Int(byteArray[34]))          // CurtainGroupID defines the curtain device. Ic curtain group is the same on 2 channels then that is the same Curtain
                    devices[i].curtainControlMode = NSNumber(value: Int(byteArray[35]))      // Will be used later (17.07.2016)
                    let data = ["deviceIndexForFoundName":i]
                    NSLog("dosao je u ovaj incoming handler sa deviceom: \(i)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidFindDeviceName), object: self, userInfo: data)
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
        }
    }
    
    func parseMessageTimerStatus (_ byteArray:[Byte]){
        //  0x00 Waiting = 0
        //  0x01 Started = 1
        //  0xF0 Elapsed = 240
        //  0xEE Suspend = 238
        //  informacije o parametrima kanala
        let sortDescriptor = NSSortDescriptor(key: "timerName", ascending: true)
        let timers = DatabaseTimersController.shared.getAllTimersSortedBy(sortDescriptor)
        for i in 1...16 {
            print(timers.count)
            for item in timers {
                if  Int(item.gateway.addressOne) == Int(byteArray[2]) && Int(item.gateway.addressTwo) == Int(byteArray[3]) && Int(item.address) == Int(byteArray[4]) && Int(item.timerId) == Int(i) {
                    item.timerState = NSNumber(value: Int(byteArray[7+i]) as Int)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshTimer), object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
    }
    //  informacije o parametrima kanala
    func parseMessageFlagStatus (_ byteArray:[Byte]){
        let flags = DatabaseFlagsController.shared.getAllFlags()
        for i in 1...32 {
            print(flags.count)
            for item in flags {
                if  Int(item.gateway.addressOne) == Int(byteArray[2]) && Int(item.gateway.addressTwo) == Int(byteArray[3]) && Int(item.address) == Int(byteArray[4]) && Int(item.flagId) == Int(i) {
                    print("alo \(NSNumber(value: Int(byteArray[7+i]) as Int))")
                    if Int(byteArray[7+i]) == 1 {
                        item.setState = NSNumber(value: false as Bool)
                    } else if Int(byteArray[7+i]) == 0 {
                        item.setState = NSNumber(value: true as Bool)
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFlag), object: self, userInfo: nil)
                }
            }
        }
        CoreDataController.shahredInstance.saveChanges()
    }
    func parseMessageSecurityFeedbackHandler(_ byteArray:[Byte]) {
        let sortDescriptor = NSSortDescriptor(key: "securityName", ascending: true)
        let securities = DatabaseSecurityController.shared.getAllSecuritiesSortedBy(sortDescriptor)
        
        
        //FIXME: Pucalo je security zato sto nema u svim gatewayovima security
        if securities.count != 0 {
            let address = [Byte(Int(securities[0].addressOne)), Byte(Int(securities[0].addressTwo)), Byte(Int(securities[0].addressThree))]
            if byteArray[2] == address[0] && byteArray[3] == address[1] && byteArray[4] == address[2] {
                let defaults = Foundation.UserDefaults.standard
                
                if byteArray[7] == 0x02 {
                    switch byteArray[8] {
                    case 0x00:
                        defaults.setValue(SecurityControlMode.Disarm, forKey: UserDefaults.Security.SecurityMode)
                    case 0x01:
                        defaults.setValue(SecurityControlMode.Away, forKey: UserDefaults.Security.SecurityMode)
                    case 0x02:
                        defaults.setValue(SecurityControlMode.Night, forKey: UserDefaults.Security.SecurityMode)
                    case 0x03:
                        defaults.setValue(SecurityControlMode.Day, forKey: UserDefaults.Security.SecurityMode)
                    case 0x04:
                        defaults.setValue(SecurityControlMode.Vacation, forKey: UserDefaults.Security.SecurityMode)
                    default: break
                    }
                }
                if byteArray[7] == 0x03 {
                    switch byteArray[8] {
                    case 0x00:
                        defaults.setValue(AlarmState.Idle, forKey: UserDefaults.Security.AlarmState)
                    case 0x01:
                        defaults.setValue(AlarmState.Trouble, forKey: UserDefaults.Security.AlarmState)
                    case 0x02:
                        defaults.setValue(AlarmState.Alert, forKey: UserDefaults.Security.AlarmState)
                    case 0x03:
                        defaults.setValue(AlarmState.Alarm, forKey: UserDefaults.Security.AlarmState)
                    default: break
                    }
                }
                if byteArray[7] == 0x04 {
                    switch byteArray[8] {
                    case 0x00:
                        defaults.set(false, forKey: UserDefaults.Security.IsPanic)
                    case 0x01:
                        defaults.set(true, forKey: UserDefaults.Security.IsPanic)
                    default: break
                    }
                }
                print("EHGSecuritySeczurityMode - \(defaults.value(forKey: UserDefaults.Security.SecurityMode)) *** EHGSecurityAlarmState - \(defaults.value(forKey: UserDefaults.Security.AlarmState)) *** EHGSecurityPanic - \(defaults.bool(forKey: UserDefaults.Security.IsPanic))")
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.Security.ControlModeStopBlinking), object: self, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshSecurity), object: self, userInfo: nil)
            }
        }
    }
    
    // MARK: - Get zones and categories
    func parseMessageNewZone(_ byteArray:[Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningForZones) {
            // Miminum is 12, but that is also doubtful...
            if byteArray.count > 12 {
                var name:String = ""
                for j in 11..<(11+Int(byteArray[10])){
                    name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  device name
                }
                let id = byteArray[8]
                let level = byteArray[byteArray.count - 2 - 1]
                var description = ""
                if byteArray[11+Int(byteArray[10])+2] != 0x00 {
                    let number = 11+Int(byteArray[10])+2
                    for j in number..<(number+Int(byteArray[number-1])){
                        description = description + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  device name
                    }
                }
                
                var doesIdExist = false
                let zones = DatabaseHandler.sharedInstance.fetchZonesWithLocationId(gateways[0].location)
                
                for zone in zones {
                    if zone.id == NSNumber(value: Int(id) as Int) {
                        doesIdExist = true
                        (zone.name, zone.level, zone.zoneDescription) = (name, NSNumber(value: Int(level) as Int), description)
                        CoreDataController.shahredInstance.saveChanges()
                        break
                    }
                }
                
                if doesIdExist {
                } else {
                    let zone = Zone(context: appDel.managedObjectContext!)
                    (zone.id, zone.name, zone.level, zone.zoneDescription, zone.location, zone.orderId, zone.allowOption, zone.isVisible) = (NSNumber(value: Int(id) as Int), name, NSNumber(value: Int(level) as Int), description, gateways[0].location, NSNumber(value: Int(id) as Int), 1, true)
                    CoreDataController.shahredInstance.saveChanges()
                }
                
                let data = ["zoneId":Int(id)]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveZoneFromGateway), object: self, userInfo: data)
            }
        }
    }
    func parseMessageNewCategory(_ byteArray:[Byte]) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningForCategories) {
            var name:String = ""
            
            if 11+Int(byteArray[10]) < byteArray.count {
                for j in 11..<(11+Int(byteArray[10])){
                    name = name + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  device name
                }
            }
            let id = byteArray[8]
            var description = ""
            
            if 11+Int(byteArray[10])+2 < byteArray.count {  //
                if byteArray[11+Int(byteArray[10])+2] != 0x00 {
                    let number = 11+Int(byteArray[10])+2
                    for j in number..<(number+Int(byteArray[number-1])){
                        description = description + "\(Character(UnicodeScalar(Int(byteArray[j]))!))" //  device name
                    }
                }
            }
            var doesIdExist = false
            let categories = DatabaseHandler.sharedInstance.fetchCategoriesWithLocationId(self.gateways[0].location)
            
            for category in categories {
                if category.id == NSNumber(value: Int(id) as Int) {
                    doesIdExist = true
                    (category.name, category.categoryDescription) = (name, description)
                    CoreDataController.shahredInstance.saveChanges()
                    break
                }
            }
            if !doesIdExist {
                let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: appDel.managedObjectContext!) as! Category
                (category.id, category.name, category.categoryDescription, category.location, category.orderId, category.allowOption, category.isVisible) = (NSNumber(value: Int(id) as Int), name, description, gateways[0].location, NSNumber(value: Int(id) as Int), 3, true)
                CoreDataController.shahredInstance.saveChanges()
            }
            
            
            let data = ["categoryId":Int(id)]
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveCategoryFromGateway), object: self, userInfo: data)
        }
    }
    
    // Curtains
    func parseMessageCurtainState(_ byteArray:[Byte]) {
        self.devices = CoreDataController.shahredInstance.fetchDevicesForGateway(self.gateways[0])
        for device in devices {
            if Int(device.gateway.addressOne) == Int(byteArray[2]) && Int(device.gateway.addressTwo) == Int(byteArray[3]) && Int(device.address) == Int(byteArray[4]) {
                device.currentValue = NSNumber(value: Int(byteArray[8]))
                let data = ["deviceDidReceiveSignalFromGateway":device]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.DidReceiveDataForRepeatSendingHandler), object: self, userInfo: data)
                break
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
    
    // Helpers
    func parseMessageAndPrint(_ byteArray: [UInt8]){
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
        print("LEN: \(LEN)")
        print("ADDR: \(ADDR)")
        print("CID1: \(CID1)")
        print("CID2: \(CID2)")
        print("INFO: \(INFO)")
        print("CHK: \(CHK)")
        print("EOI: \(EOI)")
    }
    func returnRunningTime (_ runningTimeByteArray:[Byte]) -> String {
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
    func returnTwoPlaces (_ number:Int) -> String {
        return String(format: "%02d",number)
    }
    func returnIncommingMessageType(){
        
    }
}
// Recieved message helpers
extension IncomingHandler {
    func messageIsValid() -> Bool{
        if self.byteArray[0] == 0xAA && self.byteArray[self.byteArray.count-1] == 0x10 {
            return true
        }
        return false
    }
    
    func messageIsNewDevice() -> Bool {
        if self.byteArray[5] == 0xF1 && self.byteArray[6] == 0x01{
            return true
        }
        return false
    }
    func messageIsNewDeviceParameters() -> Bool {
        if self.byteArray[5] == 0xF1 && self.byteArray[6] == 0x0D {
            return true
        }
        return false
    }
    func messageIsNewDeviceSalto() -> Bool {
        if self.byteArray[5] == 0xF1 && self.byteArray[6] == 0x01 && self.byteArray[7] == 0x03 && self.byteArray[8] == 0x03{
            return true
        }
        return false
    }
    func messageIsNewDeviceSaltoParameter() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x55 {
            return true
        }
        return false
    }
    
    func messageIsChannelParameter() -> Bool {
        if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x01 {
            return true
        }
        return false
    }
    func messageIsChannelState() -> Bool {
        if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x06 && self.byteArray[7] == 0xFF {
            return true
        }
        return false
    }
    
    func messageIsCurtainState() -> Bool {
        if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x06 && self.byteArray[7] == 0xF0 {
            return true
        }
        return false
    }
    func messageIsRunningTime() -> Bool {
        if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x0C {
            return true
        }
        return false
    }
    func messageIsChannelWarning() -> Bool {
        if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x10 {
            return true
        }
        return false
    }
    
    func messageIsAcParameter() -> Bool {
        if self.byteArray[5] == 0xF4 && self.byteArray[6] == 0x01 {
            return true
        }
        return false
    }
    func messageIsAcControlStatus() -> Bool {
        if self.byteArray[5] == 0xF4 && self.byteArray[6] == 0x03 && self.byteArray[7] == 0xFF {
            return true
        }
        return false
    }
    func messageIsInterfaceParameter() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x02 {
            return true
        }
        return false
    }
    func messageIsInterfaceStatus() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 && self.byteArray[7] == 0xFF {
            return true
        }
        return false
    }
    func messageIsSecurityFeedbackHandler() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x01 {
            return true
        }
        return false
    }
    func messageIsInterfaceEnableStatus() -> Bool{
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x03 {
            return true
        }
        return false
    }
    func messageIsInterfaceName() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x04{
            return true
        }
        return false
    }
    
    func messageIsTimerStatus() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x17 && self.byteArray[7] == 0xFF {
            return true
        }
        return false
    }
    func messageIsTimerStatusData() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x19 && self.byteArray[7] == 0xFF {
            return true
        }
        return false
    }
    func messageIsTimerName() -> Bool{
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x15 {
            return true
        }
        return false
    }
    func messageIsTimerParameters() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x13{
            return true
        }
        return false
    }
    
    func messageIsFlagStatus() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x06 && self.byteArray[7] == 0xFF {
            return true
        }
        return false
    }
    func messageIsNewFlag() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x04 {
            return true
        }
        return false
    }
    func messageIsNewFlagParameter() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x02 {
            return true
        }
        return false
    }
    
    func messageIsEventStatus() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x12 {
            return true
        }
        return false
    }
    func messageIsNewEvent() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x08 {
            return true
        }
        return false
    }
    
    func messageIsNewCardName() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x57 {
            return true
        }
        return false
    }
    func messageIsNewCardParameter() -> Bool {
        if self.byteArray[5] == 0xF5 && self.byteArray[6] == 0x56 {
            return true
        }
        return false
    }
    
    func messageIsNewZone() -> Bool {
        if self.byteArray[5] == 0xF2 && self.byteArray[6] == 0x11 && self.byteArray[7] == 0x00 {
            return true
        }
        return false
    }
    func messageIsNewCategory() -> Bool {
        if self.byteArray[5] == 0xF2 && self.byteArray[6] == 0x13 && self.byteArray[7] == 0x00 {
            return true
        }
        return false
    }
    func messageIsNewScene() -> Bool {
        if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x08 {
            return true
        }
        return false
    }
    func messageIsNewSequence() -> Bool {
        if self.byteArray[5] == 0xF3 && self.byteArray[6] == 0x0A {
            return true
        }
        return false
    }
}
