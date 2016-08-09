//
//  CreateUserFromJSONController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 5/10/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import Zip
import CoreData

class CreateUserFromJSONController: NSObject {
    
    static var shared = CreateUserFromJSONController()
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func unzipAndDeleteFile(url:NSURL){
        if let filePath = url.path {
            let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
            let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
            do{
                try Zip.unzipFile(url, destination: documentsDirectoryPath, overwrite: true, password: nil, progress: { (progress) -> () in
                    print(progress)
                })
            }
            catch {
                print("Something went wrong")
            }
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(filePath)
                    print("file has been removed")
                } catch {
                    print("file didn't remove")
                }
            }
            
            let jsonFilePath = documentsDirectoryPath.URLByAppendingPathComponent("test.json")
            createUserFromJSON(jsonFilePath.path!)
            
        }
    }
    
    func createUserFromJSON(filePath:String){
        
        ///na drugoj strani
        var data:NSData? = NSData(contentsOfFile: filePath)
        if let data = data{
            if let jsonObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary{
                if let json = jsonObject as? JSONDictionary{
                    if let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: appDel.managedObjectContext!) as? User{
                        if let userName = json["username"] as? String{
                            user.username = userName
                        }
                        if let password = json["password"] as? String{
                            user.password = password
                        }
                        if let isLocked = json["is_locked"] as? Bool{
                            user.isLocked = isLocked
                        }
                        if let isSuperUser = json["is_super_user"] as? Bool{
                            user.isSuperUser = isSuperUser
                        }
                        if let openLastScreen = json["open_last_screen"] as? Bool{
                            user.openLastScreen = openLastScreen
                        }
                        if let lastScreenId = json["last_screen_id"] as? Int{
                            user.lastScreenId = lastScreenId
                        }
                        if let imageData = json["profile_picture"] as? NSData{
                            user.profilePicture = imageData
                        }
                        if let menus = json["menu"] as? [JSONDictionary] {
                            createMenuFromJSON(menus, user: user)
                        }
                        if let locations = json["locations"] as? [JSONDictionary]{
                            createLocationFromJSON(locations, user: user)
                        }
                        print(jsonObject)
                    }
                }
                CoreDataController.shahredInstance.saveChanges()
            }
        }
    }
    
    func createMenuFromJSON(menus:[JSONDictionary], user:User){
        for menu in menus{
            if let menuItem = NSEntityDescription.insertNewObjectForEntityForName("MenuItem", inManagedObjectContext: appDel.managedObjectContext!) as? MenuItem{
                if let id = menu["id"] as? Int{
                    menuItem.id = id
                }
                if let isVisible = menu["is_visible"] as? Bool{
                    menuItem.isVisible = isVisible
                }
                if let orderId = menu["order_id"] as? Int{
                    menuItem.orderId = orderId
                }
                menuItem.user = user
            }
        }
    }
    
    func createLocationFromJSON(locations:[JSONDictionary], user:User){
        for location in locations{
            if let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: appDel.managedObjectContext!) as? Location{
                if let name = location["name"] as? String{
                    newLocation.name = name
                }
                if let orderId = location["order_id"] as? Int{
                    newLocation.orderId = orderId
                }
                if let radius = location["radius"] as? Int{
                    newLocation.radius = radius
                }
                if let latitude = location["latitude"] as? Double{
                    newLocation.latitude = latitude
                }
                if let longitude = location["longitude"] as? Double{
                    newLocation.longitude = longitude
                }
                if let timerId = location["timer_id"] as? String{
                    newLocation.timerId = timerId
                }
                if let categories = location["categories"] as? [JSONDictionary]{
                    createCategoriesFromJSON(categories, location: newLocation)
                }
                if let zones = location["zones"] as? [JSONDictionary]{
                    createZonesFromJSON(zones, location: newLocation)
                }
                if let ssids = location["ssids"] as? [JSONDictionary]{
                    createSSIDfromJSON(ssids, location: newLocation)
                }
                if let gateways = location["gateways"] as? [JSONDictionary]{
                    createGatewaysFromJSON(gateways, location: newLocation)
                }
                if let surveillances = location["surveillances"] as? [JSONDictionary]{
                    createSurveillancesFromJSON(surveillances, location: newLocation)
                }
                if let securities = location["security"] as? [JSONDictionary]{
                    createSecuritiesFromJSON(securities, location: newLocation)
                }
                newLocation.user = user
            }
        }
    }
    
    func createSecuritiesFromJSON(securities:[JSONDictionary], location:Location){
        for security in securities{
            if let newSecurity = NSEntityDescription.insertNewObjectForEntityForName("Security", inManagedObjectContext: appDel.managedObjectContext!) as? Security{
                if let addOne = security["addressOne"] as? Int{
                    newSecurity.addressOne = addOne
                }
                if let addTwo = security["addressTwo"] as? Int{
                    newSecurity.addressTwo = addTwo
                }
                if let addThree = security["addressThree"] as? Int{
                    newSecurity.addressThree = addThree
                }
                if let desc = security["securityDescription"] as? String{
                    newSecurity.securityDescription = desc
                }
                if let id = security["gatewayId"] as? String{
                    newSecurity.gatewayId = id
                }
                if let name = security["securityName"] as? String{
                    newSecurity.securityName = name
                }
                newSecurity.location = location
            }
        }
    }
    
    func createGatewaysFromJSON(gateways:[JSONDictionary], location:Location){
        for gateway in gateways{
            if let newGateway = NSEntityDescription.insertNewObjectForEntityForName("Gateway", inManagedObjectContext: appDel.managedObjectContext!) as? Gateway{
                if let addOne = gateway["address_one"] as? Int{
                    newGateway.addressOne = addOne
                }
                if let addTwo = gateway["address_two"] as? Int{
                    newGateway.addressTwo = addTwo
                }
                if let addThree = gateway["address_three"] as? Int{
                    newGateway.addressThree = addThree
                }
                if let ard = gateway["auto_reconnect_delay"] as? Int{
                    newGateway.autoReconnectDelay = ard
                }
                if let desc = gateway["description"] as? String{
                    newGateway.gatewayDescription = desc
                }
                if let localIp = gateway["local_ip"] as? String{
                    newGateway.localIp = localIp
                }
                if let localPort = gateway["local_port"] as? Int{
                    newGateway.localPort = localPort
                }
                if let remoteIp = gateway["remote_ip"] as? String{
                    newGateway.remoteIp = remoteIp
                }
                if let lremotePort = gateway["remote_port"] as? Int{
                    newGateway.remotePort = lremotePort
                }
                if let remoteIpInUSe = gateway["remote_ip_in_use"] as? String{
                    newGateway.remoteIpInUse = remoteIpInUSe
                }
                if let turnedOn = gateway["turned_on"] as? Bool{
                    newGateway.turnedOn = turnedOn
                }
                if let gwid = gateway["gateway_id"] as? String{
                    newGateway.gatewayId = gwid
                }
                if let devices = gateway["devices"] as? [JSONDictionary]{
                    createDevicesFromJSON(devices, gateway: newGateway)
                }
                if let scenes = gateway["scenes"] as? [JSONDictionary]{
                    createScenesFromJSON(scenes, gateway: newGateway)
                }
                if let events = gateway["events"] as? [JSONDictionary]{
                    createEventsFromJSON(events, gateway: newGateway)
                }
                if let flags = gateway["flags"] as? [JSONDictionary]{
                    createFlagsFromJSON(flags, gateway: newGateway)
                }
                if let sequences = gateway["sequences"] as? [JSONDictionary]{
                    createSequencesFromJSON(sequences, gateway: newGateway)
                }
                if let timers = gateway["timers"] as? [JSONDictionary]{
                    createTimersFromJSON(timers, gateway: newGateway)
                }
                newGateway.location = location
            }
        }
    }
    
    func createTimersFromJSON(timers:[JSONDictionary], gateway:Gateway){
        for timer in timers{
            if let newTimer = NSEntityDescription.insertNewObjectForEntityForName("Timer", inManagedObjectContext: appDel.managedObjectContext!) as? Timer{
                if let address = timer["address"] as? Int{
                    newTimer.address = address
                }
                if let count = timer["count"] as? Int{
                    newTimer.count = count
                }
                if let level = timer["entity_level"] as? String{
                    newTimer.entityLevel = level
                }
                if let isBroadcast = timer["is_broadcast"] as? Bool{
                    newTimer.isBroadcast = isBroadcast
                }
                if let isLocalcast = timer["is_localcast"] as? Bool{
                    newTimer.isLocalcast = isLocalcast
                }
                if let timerCategory = timer["timer_category"] as? String{
                    newTimer.timerCategory = timerCategory
                }
                if let timerId = timer["timer_id"] as? Int{
                    newTimer.timerId = timerId
                }
                if let id = timer["id"] as? String{
                    newTimer.id = id
                }
                if let timerImageOne = timer["timer_image_one"] as? NSData{
                    newTimer.timerImageOne = timerImageOne
                }
                if let timerImageTwo = timer["timer_image_two"] as? NSData{
                    newTimer.timerImageTwo = timerImageTwo
                }
                if let timerName = timer["timer_name"] as? String{
                    newTimer.timerName = timerName
                }
                if let timerState = timer["timer_state"] as? Int{
                    newTimer.timerState = timerState
                }
                if let type = timer["type"] as? String{
                    newTimer.type = type
                }
                if let timeZone = timer["time_zone"] as? String{
                    newTimer.timeZone = timeZone
                }
                newTimer.gateway = gateway
            }
        }
    }
    
    func createSequencesFromJSON(sequences:[JSONDictionary], gateway:Gateway){
        for sequence in sequences{
            if let newSecuence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: appDel.managedObjectContext!) as? Sequence{
                if let address = sequence["address"] as? Int{
                    newSecuence.address = address
                }
                if let level = sequence["entity_level"] as? String{
                    newSecuence.entityLevel = level
                }
                if let isBroadcast = sequence["is_broadcast"] as? Bool{
                    newSecuence.isBroadcast = isBroadcast
                }
                if let isLocalcast = sequence["is_localcast"] as? Bool{
                    newSecuence.isLocalcast = isLocalcast
                }
                if let sequenceCategory = sequence["sequence_category"] as? String{
                    newSecuence.sequenceCategory = sequenceCategory
                }
                if let sequenceCycles = sequence["sequence_cycles"] as? Int{
                    newSecuence.sequenceCycles = sequenceCycles
                }
                if let sequenceId = sequence["sequence_id"] as? Int{
                    newSecuence.sequenceId = sequenceId
                }
                if let sequenceImageOne = sequence["sequence_image_one"] as? NSData{
                    newSecuence.sequenceImageOne = sequenceImageOne
                }
                if let sequenceImageTwo = sequence["sequence_image_two"] as? NSData{
                    newSecuence.sequenceImageTwo = sequenceImageTwo
                }
                if let sequenceName = sequence["sequence_name"] as? String{
                    newSecuence.sequenceName = sequenceName
                }
                if let sequenceZone = sequence["sequence_zone"] as? String{
                    newSecuence.sequenceZone = sequenceZone
                }
                newSecuence.gateway = gateway
            }
        }
    }
    
    func createFlagsFromJSON(flags:[JSONDictionary], gateway:Gateway){
        for flag in flags{
            if let newFlag = NSEntityDescription.insertNewObjectForEntityForName("Flag", inManagedObjectContext: appDel.managedObjectContext!) as? Flag{
                if let address = flag["address"] as? Int{
                    newFlag.address = address
                }
                if let level = flag["entity_level"] as? String{
                    newFlag.entityLevel = level
                }
                if let isBroadcast = flag["is_broadcast"] as? Bool{
                    newFlag.isBroadcast = isBroadcast
                }
                if let isLocalcast = flag["is_localcast"] as? Bool{
                    newFlag.isLocalcast = isLocalcast
                }
                if let flagCategory = flag["flag_category"] as? String{
                    newFlag.flagCategory = flagCategory
                }
                if let flagId = flag["flag_id"] as? Int{
                    newFlag.flagId = flagId
                }
                if let flagImageOne = flag["flag_image_one"] as? NSData{
                    newFlag.flagImageOne = flagImageOne
                }
                if let flagImageTwo = flag["scene_image_two"] as? NSData{
                    newFlag.flagImageTwo = flagImageTwo
                }
                if let flagName = flag["flag_name"] as? String{
                    newFlag.flagName = flagName
                }
                if let flagZone = flag["flag_zone"] as? String{
                    newFlag.flagZone = flagZone
                }
                if let setState = flag["set_state"] as? Int{
                    newFlag.setState = setState
                }
                newFlag.gateway = gateway
            }
        }
    }
    
    func createScenesFromJSON(scenes:[JSONDictionary], gateway:Gateway){
        for scene in scenes{
            if let newScene = NSEntityDescription.insertNewObjectForEntityForName("Scene", inManagedObjectContext: appDel.managedObjectContext!) as? Scene{
                if let address = scene["address"] as? Int{
                    newScene.address = address
                }
                if let level = scene["entity_level"] as? String{
                    newScene.entityLevel = level
                }
                if let isBroadcast = scene["is_broadcast"] as? Bool{
                    newScene.isBroadcast = isBroadcast
                }
                if let isLocalcast = scene["is_localcast"] as? Bool{
                    newScene.isLocalcast = isLocalcast
                }
                if let sceneCategory = scene["scene_category"] as? String{
                    newScene.sceneCategory = sceneCategory
                }
                if let sceneId = scene["scene_id"] as? Int{
                    newScene.sceneId = sceneId
                }
                if let sceneImageOne = scene["scene_image_one"] as? NSData{
                    newScene.sceneImageOne = sceneImageOne
                }
                if let sceneImageTwo = scene["scene_image_two"] as? NSData{
                    newScene.sceneImageTwo = sceneImageTwo
                }
                if let sceneName = scene["scene_name"] as? String{
                    newScene.sceneName = sceneName
                }
                if let sceneZone = scene["scene_zone"] as? String{
                    newScene.sceneZone = sceneZone
                }
                newScene.gateway = gateway
            }
        }
    }
    
    func createEventsFromJSON(events:[JSONDictionary], gateway:Gateway){
        for event in events{
            if let newEvent = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: appDel.managedObjectContext!) as? Event{
                if let address = event["address"] as? Int{
                    newEvent.address = address
                }
                if let level = event["entity_level"] as? String{
                    newEvent.entityLevel = level
                }
                if let eventCategory = event["event_category"] as? String{
                    newEvent.eventCategory = eventCategory
                }
                if let eventId = event["event_id"] as? Int{
                    newEvent.eventId = eventId
                }
                if let eventImageOne = event["event_image_one"] as? NSData{
                    newEvent.eventImageOne = eventImageOne
                }
                if let eventImageTwo = event["event_image_two"] as? NSData{
                    newEvent.eventImageTwo = eventImageTwo
                }
                if let eventName = event["event_name"] as? String{
                    newEvent.eventName = eventName
                }
                if let eventZone = event["event_zone"] as? String{
                    newEvent.eventZone = eventZone
                }
                if let isBroadcast = event["is_broadcast"] as? Bool{
                    newEvent.isBroadcast = isBroadcast
                }
                if let isLocalcast = event["is_localcast"] as? Bool{
                    newEvent.isLocalcast = isLocalcast
                }
                newEvent.gateway = gateway
            }
        }
    }
    
    func createDevicesFromJSON(devices:[JSONDictionary], gateway:Gateway){
        for device in devices{
            if let newDevice = NSEntityDescription.insertNewObjectForEntityForName("Device", inManagedObjectContext: appDel.managedObjectContext!) as? Device{
                if let address = device["address"] as? Int{
                    newDevice.address = address
                }
                if let aes = device["allow_energy_saving"] as? Int{
                    newDevice.allowEnergySaving = aes
                }
                if let amp = device["amp"] as? String{
                    newDevice.amp = amp
                }
                if let catId = device["category_id"] as? Int{
                    newDevice.categoryId = catId
                }
                if let catName = device["category_name"] as? String{
                    newDevice.categoryName = catName
                }
                if let channel = device["channel"] as? Int{
                    newDevice.channel = channel
                }
                if let controlType = device["control_type"] as? String{
                    newDevice.controlType = controlType
                }
                if let coolTemperature = device["cool_temperature"] as? Int{
                    newDevice.coolTemperature = coolTemperature
                }
                if let current = device["current"] as? Int{
                    newDevice.current = current
                }
                if let currentValue = device["current_value"] as? Int{
                    newDevice.currentValue = currentValue
                }
                if let curtainControlMode = device["curtain_control_mode"] as? Int{
                    newDevice.curtainControlMode = curtainControlMode
                }
                if let curtainGroupID = device["curtain_group_id"] as? Int{
                    newDevice.curtainGroupID = curtainGroupID
                }
                if let delay = device["delay"] as? Int{
                    newDevice.delay = delay
                }
                if let digitalInputMode = device["digital_input_mode"] as? Int{
                    newDevice.digitalInputMode = digitalInputMode
                }
                if let heatTemperature = device["heat_temperature"] as? Int{
                    newDevice.heatTemperature = heatTemperature
                }
                if let humidity = device["humidity"] as? Int{
                    newDevice.humidity = humidity
                }
                if let isCurtainModeAllowed = device["is_curtain_mode_allowed"] as? Bool{
                    newDevice.isCurtainModeAllowed = isCurtainModeAllowed
                }
                if let isDimmerModeAllowed = device["is_dimmer_mode_allowed"] as? Bool{
                    newDevice.isDimmerModeAllowed = isDimmerModeAllowed
                }
                if let isEnabled = device["is_enabled"] as? Bool{
                    newDevice.isEnabled = isEnabled
                }
                if let isVisible = device["is_visible"] as? Bool{
                    newDevice.isVisible = isVisible
                }
                if let mac = device["mac"] as? NSData{
                    newDevice.mac = mac
                }
                if let mode = device["mode"] as? String{
                    newDevice.mode = mode
                }
                if let modeState = device["mode_state"] as? String{
                    newDevice.modeState = modeState
                }
                if let name = device["name"] as? String{
                    newDevice.name = name
                }
                if let numberOfDevices = device["number_of_devices"] as? Int{
                    newDevice.numberOfDevices = numberOfDevices
                }
                if let overrideControl1 = device["override_control1"] as? Int{
                    newDevice.overrideControl1 = overrideControl1
                }
                if let overrideControl2 = device["override_control2"] as? Int{
                    newDevice.overrideControl2 = overrideControl2
                }
                if let overrideControl3 = device["override_control3"] as? Int{
                    newDevice.overrideControl3 = overrideControl3
                }
                if let parentZoneId = device["parent_zone_id"] as? Int{
                    newDevice.parentZoneId = parentZoneId
                }
                if let roomTemperature = device["room_temperature"] as? Int{
                    newDevice.roomTemperature = roomTemperature
                }
                if let runningTime = device["running_time"] as? String{
                    newDevice.runningTime = runningTime
                }
                if let runtime = device["runtime"] as? Int{
                    newDevice.runtime = runtime
                }
                if let skipState = device["skip_state"] as? Int{
                    newDevice.skipState = skipState
                }
                if let speed = device["speed"] as? String{
                    newDevice.speed = speed
                }
                if let speedState = device["speed_state"] as? String{
                    newDevice.speedState = speedState
                }
                if let stateUpdatedAt = device["state_updated_at"] as? NSDate{
                    newDevice.stateUpdatedAt = stateUpdatedAt
                }
                if let temperature = device["temperature"] as? Int{
                    newDevice.temperature = temperature
                }
                if let type = device["type"] as? String{
                    newDevice.type = type
                }
                if let voltage = device["voltage"] as? Int{
                    newDevice.voltage = voltage
                }
                if let zoneId = device["zone_id"] as? Int{
                    newDevice.zoneId = zoneId
                }
                if let deviceImages = device["device_images"] as? [JSONDictionary]{
                    createDeviceImagesFromJSON(deviceImages, device: newDevice)
                }
                if let deviceImages = device["device_images"] as? [JSONDictionary]{
                    createDeviceImagesFromJSON(deviceImages, device: newDevice)
                }
                if let pccommands = device["pc_commands"] as? [JSONDictionary]{
                    createPCControllFromJSON(pccommands, device: newDevice)
                }
                newDevice.gateway = gateway
            }
        }
    }
    
    func createDeviceImagesFromJSON(deviceImages:[JSONDictionary], device:Device){
        for deviceImage in deviceImages{
            if let newImage = NSEntityDescription.insertNewObjectForEntityForName("DeviceImage", inManagedObjectContext: appDel.managedObjectContext!) as? DeviceImage{
                if let defaultImage =  deviceImage["default_image"] as? String {
                    newImage.defaultImage = defaultImage
                }
                if let state =  deviceImage["default_image"] as? Int {
                    newImage.state = state
                }
                newImage.device = device
            }
        }
    }
    
    func createPCControllFromJSON(pccommands:[JSONDictionary], device:Device){
        for pccommand in pccommands{
            if let newPCCommand = NSEntityDescription.insertNewObjectForEntityForName("PCCommand", inManagedObjectContext: appDel.managedObjectContext!) as? PCCommand{
                if let name =  pccommand["name"] as? String {
                    newPCCommand.name = name
                }
                if let comand =  pccommand["comand"] as? String {
                    newPCCommand.comand = comand
                }
                if let isRunCommand =  pccommand["is_run_command"] as? Bool {
                    newPCCommand.isRunCommand = isRunCommand
                }
                newPCCommand.device = device
            }
        }
    }
    
    func createSurveillancesFromJSON(surveillances:[JSONDictionary], location:Location){
        for survaillance in surveillances{
            if let newSurveillance = NSEntityDescription.insertNewObjectForEntityForName("Surveillance", inManagedObjectContext: appDel.managedObjectContext!) as? Surveillance{
                if let name = survaillance["name"] as? String{
                    newSurveillance.name = name
                }
                if let isVisible = survaillance["is_visible"] as? Bool{
                    newSurveillance.isVisible = isVisible
                }
                if let localIp = survaillance["local_ip"] as? String{
                    newSurveillance.localIp = localIp
                }
                if let localPort = survaillance["local_port"] as? String{
                    newSurveillance.localPort = localPort
                }
                if let ip = survaillance["ip"] as? String{
                    newSurveillance.ip = ip
                }
                if let port = survaillance["port"] as? Int{
                    newSurveillance.port = port
                }
                if let username = survaillance["username"] as? String{
                    newSurveillance.username = username
                }
                if let password = survaillance["password"] as? String{
                    newSurveillance.password = password
                }
                if let level = survaillance["surveillance_level"] as? String{
                    newSurveillance.surveillanceLevel = level
                }
                if let zone = survaillance["surveillance_zone"] as? String{
                    newSurveillance.surveillanceZone = zone
                }
                if let category = survaillance["surveillance_category"] as? String{
                    newSurveillance.surveillanceCategory = category
                }
                if let ass = survaillance["aut_span_step"] as? Int{
                    newSurveillance.autSpanStep = ass
                }
                if let dwt = survaillance["dwell_time"] as? Int{
                    newSurveillance.dwellTime = dwt
                }
                if let ps = survaillance["pan_step"] as? Int{
                    newSurveillance.panStep = ps
                }
                if let ts = survaillance["tilt_step"] as? Int{
                    newSurveillance.tiltStep = ts
                }
                if let uap = survaillance["url_auto_pan"] as? String{
                    newSurveillance.urlAutoPan = uap
                }
                if let uaps = survaillance["url_auto_pan_stop"] as? String{
                    newSurveillance.urlAutoPanStop = uaps
                }
                if let ugi = survaillance["url_get_image"] as? String{
                    newSurveillance.urlGetImage = ugi
                }
                if let uh = survaillance["url_home"] as? String{
                    newSurveillance.urlHome = uh
                }
                if let umd = survaillance["url_move_down"] as? String{
                    newSurveillance.urlMoveDown = umd
                }
                if let uml = survaillance["url_move_left"] as? String{
                    newSurveillance.urlMoveLeft = uml
                }
                if let umr = survaillance["url_move_right"] as? String{
                    newSurveillance.urlMoveRight = umr
                }
                if let umu = survaillance["url_move_up"] as? String{
                    newSurveillance.urlMoveUp = umu
                }
                if let ups = survaillance["url_preset_sequence"] as? String{
                    newSurveillance.urlPresetSequence = ups
                }
                if let upss = survaillance["url_preset_sequence_stop"] as? String{
                    newSurveillance.urlPresetSequenceStop = upss
                }
                newSurveillance.location = location
            }
        }
    }
    
    func createZonesFromJSON(zones:[JSONDictionary], location:Location){
        for zone in zones{
            if let newZone = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as? Zone{
                if let name = zone["name"] as? String{
                    newZone.name = name
                }
                if let desc = zone["description"] as? String{
                    newZone.zoneDescription = desc
                }
                if let isVisible = zone["is_visible"] as? Bool{
                    newZone.isVisible = isVisible
                }
                if let id = zone["id"] as? Int{
                    newZone.id = id
                }
                if let level = zone["level"] as? Int{
                    newZone.level = level
                }
                if let orderId = zone["order_id"] as? Int{
                    newZone.orderId = orderId
                }
                newZone.allowOption = 1
                newZone.location = location
            }
        }
    }
    
    func createCategoriesFromJSON(categories:[JSONDictionary], location:Location){
        for category in categories{
            if let newCategory = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as? Category{
                if let name = category["name"] as? String{
                    newCategory.name = name
                }
                if let desc = category["description"] as? String{
                    newCategory.categoryDescription = desc
                }
                if let isVisible = category["is_visible"] as? Bool{
                    newCategory.isVisible = isVisible
                }
                if let id = category["id"] as? Int{
                    newCategory.id = id
                }
                if let orderId = category["order_id"] as? Int{
                    newCategory.orderId = orderId
                }
                newCategory.allowOption = 3
                newCategory.location = location
            }
        }
    }
    
    func createSSIDfromJSON(ssids:[JSONDictionary], location:Location){
        for ssid in ssids{
            if let newSSID = NSEntityDescription.insertNewObjectForEntityForName("SSID", inManagedObjectContext: appDel.managedObjectContext!) as? SSID{
                if let name = ssid["name"] as? String{
                    newSSID.name = name
                }
                newSSID.location = location
            }
        }
    }
}
