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
    
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func unzipAndDeleteFile(_ url:URL){
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        do{
            try Zip.unzipFile(url, destination: documentsDirectoryPath, overwrite: true, password: nil, progress: { (progress) -> () in
                
            })
        }
        catch {
            
        }
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            } catch {
            }
        }
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("user.json")
        createUserFromJSON(jsonFilePath.path)
        
        if FileManager.default.fileExists(atPath: jsonFilePath.path) {
            do {
                try FileManager.default.removeItem(atPath: jsonFilePath.path)
            } catch {
            }
        } 
    }
    
    func createUserFromJSON(_ filePath:String){
        
        ///na drugoj strani
        let data:Data? = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        if let data = data{
            if let jsonObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary{
                if let json = jsonObject as? JSONDictionary{
                    if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: appDel.managedObjectContext!) as? User{
                        if let userName = json["username"] as? String{
                            user.username = userName
                        }
                        if let password = json["password"] as? String{
                            user.password = password
                        }
                        if let isLocked = json["is_locked"] as? Bool{
                            user.isLocked = isLocked as NSNumber
                        }
                        if let isSuperUser = json["is_super_user"] as? Bool{
                            user.isSuperUser = isSuperUser as NSNumber
                        }
                        if let openLastScreen = json["open_last_screen"] as? Bool{
                            user.openLastScreen = openLastScreen as NSNumber!
                        }
                        if let lastScreenId = json["last_screen_id"] as? Int{
                            user.lastScreenId = lastScreenId as NSNumber?
                        }
                        if let defaultImage = json["default_image"] as? String{
                            user.defaultImage = defaultImage
                        }
                        if let customImage = json["custom_image_id"] as? String{
                            user.customImageId = customImage
                        }
                        if let menus = json["menu"] as? [JSONDictionary] {
                            createMenuFromJSON(menus, user: user)
                        }
                        if let locations = json["locations"] as? [JSONDictionary]{
                            createLocationFromJSON(locations, user: user)
                        }
                        if let filters = json["filters"] as? [JSONDictionary]{
                            createFiltersFromJSON(filters, user: user)
                        }
                        if let images = json["images"] as? [JSONDictionary]{
                            createImagesFromJSON(images, user: user)
                        }
                    }
                }
                CoreDataController.shahredInstance.saveChanges()
            }
        }
    }
    
    func createImagesFromJSON(_ images:[JSONDictionary], user:User){
        for image in images{
            if let newImage = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                if let imageData = image["image_data"] as? Data{
                    newImage.imageData = imageData
                }
                if let id = image["image_id"] as? String{
                    newImage.imageId = id
                }
                
                newImage.user = user
            }
        }
    }
    
    func createFiltersFromJSON(_ filters:[JSONDictionary], user:User){
        for filter in filters{
            if let filterItem = NSEntityDescription.insertNewObject(forEntityName: "FilterParametar", into: appDel.managedObjectContext!) as? FilterParametar{
                if let id = filter["filter_id"] as? Int{
                    filterItem.filterId = NSNumber(value: id)
                }
                if let isDefault = filter["is_default"] as? Bool{
                    filterItem.isDefault = isDefault as NSNumber
                }
                if let location = filter["location_id"] as? String{
                    filterItem.locationId = location
                }
                if let level = filter["level_id"] as? String{
                    filterItem.levelId = level
                }
                if let zone = filter["zone_id"] as? String{
                    filterItem.zoneId = zone
                }
                if let category = filter["category_id"] as? String{
                    filterItem.categoryId = category
                }
                if let duration = filter["timer_duration"] as? Int{
                    filterItem.timerDuration = NSNumber(value: duration)
                }
                filterItem.user = user
            }
        }
    }
    
    func createMenuFromJSON(_ menus:[JSONDictionary], user:User){
        for menu in menus{
            if let menuItem = NSEntityDescription.insertNewObject(forEntityName: "MenuItem", into: appDel.managedObjectContext!) as? MenuItem{
                if let id = menu["id"] as? Int{
                    menuItem.id = NSNumber(value: id)
                }
                if let isVisible = menu["is_visible"] as? Bool{
                    menuItem.isVisible = isVisible as NSNumber
                }
                if let orderId = menu["order_id"] as? Int{
                    menuItem.orderId = NSNumber(value: orderId)
                }
                menuItem.user = user
            }
        }
    }
    
    func createLocationFromJSON(_ locations:[JSONDictionary], user:User){
        for location in locations{
            if let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: appDel.managedObjectContext!) as? Location{
                if let name = location["name"] as? String{
                    newLocation.name = name
                }
                if let orderId = location["order_id"] as? Int{
                    newLocation.orderId = orderId as NSNumber?
                }
                if let radius = location["radius"] as? Int{
                    newLocation.radius = radius as NSNumber?
                }
                if let latitude = location["latitude"] as? Double{
                    newLocation.latitude = latitude as NSNumber?
                }
                if let longitude = location["longitude"] as? Double{
                    newLocation.longitude = longitude as NSNumber?
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
                if let filterOnLocation = location["filter_on_location"] as? Bool{
                    newLocation.filterOnLocation = filterOnLocation as NSNumber?
                }
                newLocation.user = user
            }
        }
    }
    
    func createSecuritiesFromJSON(_ securities:[JSONDictionary], location:Location){
        for security in securities{
            if let newSecurity = NSEntityDescription.insertNewObject(forEntityName: "Security", into: appDel.managedObjectContext!) as? Security{
                if let addOne = security["address_one"] as? Int{
                    newSecurity.addressOne = NSNumber(value: addOne)
                }
                if let addTwo = security["address_two"] as? Int{
                    newSecurity.addressTwo = NSNumber(value: addTwo)
                }
                if let addThree = security["address_three"] as? Int{
                    newSecurity.addressThree = NSNumber(value: addThree)
                }
                if let desc = security["description"] as? String{
                    newSecurity.securityDescription = desc
                }
                if let id = security["gateway_id"] as? String{
                    newSecurity.gatewayId = id
                }
                if let name = security["security_name"] as? String{
                    newSecurity.securityName = name
                }
                newSecurity.location = location
            }
        }
    }
    
    func createGatewaysFromJSON(_ gateways:[JSONDictionary], location:Location){
        for gateway in gateways{
            if let newGateway = NSEntityDescription.insertNewObject(forEntityName: "Gateway", into: appDel.managedObjectContext!) as? Gateway{
                if let addOne = gateway["address_one"] as? Int{
                    newGateway.addressOne = NSNumber(value: addOne)
                }
                if let addTwo = gateway["address_two"] as? Int{
                    newGateway.addressTwo = NSNumber(value: addTwo)
                }
                if let addThree = gateway["address_three"] as? Int{
                    newGateway.addressThree = NSNumber(value: addThree)
                }
                if let ard = gateway["auto_reconnect_delay"] as? Int{
                    newGateway.autoReconnectDelay = ard as NSNumber?
                }
                if let desc = gateway["description"] as? String{
                    newGateway.gatewayDescription = desc
                }
                if let localIp = gateway["local_ip"] as? String{
                    newGateway.localIp = localIp
                }
                if let localPort = gateway["local_port"] as? Int{
                    newGateway.localPort = NSNumber(value: localPort)
                }
                if let remoteIp = gateway["remote_ip"] as? String{
                    newGateway.remoteIp = remoteIp
                }
                if let lremotePort = gateway["remote_port"] as? Int{
                    newGateway.remotePort = NSNumber(value: lremotePort)
                }
                if let remoteIpInUSe = gateway["remote_ip_in_use"] as? String{
                    newGateway.remoteIpInUse = remoteIpInUSe
                }
                if let type = gateway["type"] as? Int{
                    newGateway.gatewayType = NSNumber(value: type)
                }
                if let turnedOn = gateway["turned_on"] as? Bool{
                    newGateway.turnedOn = turnedOn as NSNumber
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
    
    func createTimersFromJSON(_ timers:[JSONDictionary], gateway:Gateway){
        for timer in timers{
            if let newTimer = NSEntityDescription.insertNewObject(forEntityName: "Timer", into: appDel.managedObjectContext!) as? Timer{
                if let address = timer["address"] as? Int{
                    newTimer.address = NSNumber(value: address)
                }
                if let count = timer["count"] as? Int{
                    newTimer.count = NSNumber(value: count)
                }
                if let levelId = timer["entity_level_id"] as? Int{
                    newTimer.entityLevelId = levelId as NSNumber?
                }
                if let isBroadcast = timer["is_broadcast"] as? Bool{
                    newTimer.isBroadcast = isBroadcast as NSNumber
                }
                if let isLocalcast = timer["is_localcast"] as? Bool{
                    newTimer.isLocalcast = isLocalcast as NSNumber
                }
                if let timerCategoryId = timer["timer_category_id"] as? Int{
                    newTimer.timerCategoryId = timerCategoryId as NSNumber?
                }
                if let timerId = timer["timer_id"] as? Int{
                    newTimer.timerId = NSNumber(value: timerId)
                }
                if let id = timer["id"] as? String{
                    newTimer.id = id
                }
                if let timerImageOneCustom = timer["timer_image_one_custom"] as? String{
                    newTimer.timerImageOneCustom = timerImageOneCustom
                }
                if let timerImageOneDefault = timer["timer_image_one_default"] as? String{
                    newTimer.timerImageOneDefault = timerImageOneDefault
                }
                if let timerImageTwoCustom = timer["timer_image_two_custom"] as? String{
                    newTimer.timerImageTwoCustom = timerImageTwoCustom
                }
                if let timerImageTwoDefault = timer["timer_image_two_default"] as? String{
                    newTimer.timerImageTwoDefault = timerImageTwoDefault
                }
                if let timerName = timer["timer_name"] as? String{
                    newTimer.timerName = timerName
                }
                if let timerState = timer["timer_state"] as? Int{
                    newTimer.timerState = NSNumber(value: timerState)
                }
                if let type = timer["type"] as? Int{
                    newTimer.type = NSNumber(value: type)
                }
                if let timeZoneId = timer["time_zone_id"] as? Int{
                    newTimer.timeZoneId = timeZoneId as NSNumber?
                }
                newTimer.gateway = gateway
            }
        }
    }
    
    func createSequencesFromJSON(_ sequences:[JSONDictionary], gateway:Gateway){
        for sequence in sequences{
            if let newSecuence = NSEntityDescription.insertNewObject(forEntityName: "Sequence", into: appDel.managedObjectContext!) as? Sequence{
                if let address = sequence["address"] as? Int{
                    newSecuence.address = NSNumber(value: address)
                }
                if let levelId = sequence["entity_level_id"] as? Int{
                    newSecuence.entityLevelId = levelId as NSNumber?
                }
                if let isBroadcast = sequence["is_broadcast"] as? Bool{
                    newSecuence.isBroadcast = isBroadcast as NSNumber
                }
                if let isLocalcast = sequence["is_localcast"] as? Bool{
                    newSecuence.isLocalcast = isLocalcast as NSNumber
                }
                if let sequenceCategoryId = sequence["sequence_category_id"] as? Int{
                    newSecuence.sequenceCategoryId = sequenceCategoryId as NSNumber?
                }
                if let sequenceCycles = sequence["sequence_cycles"] as? Int{
                    newSecuence.sequenceCycles = NSNumber(value: sequenceCycles)
                }
                if let sequenceId = sequence["sequence_id"] as? Int{
                    newSecuence.sequenceId = NSNumber(value: sequenceId)
                }
                if let sequenceImageOneCustom = sequence["sequence_image_one_custom"] as? String{
                    newSecuence.sequenceImageOneCustom = sequenceImageOneCustom
                }
                if let sequenceImageOneDefault = sequence["sequence_image_one_default"] as? String{
                    newSecuence.sequenceImageOneDefault = sequenceImageOneDefault
                }
                if let sequenceImageTwoCustom = sequence["sequence_image_two_custom"] as? String{
                    newSecuence.sequenceImageTwoCustom = sequenceImageTwoCustom
                }
                if let sequenceImageTwoDefault = sequence["sequence_image_two_default"] as? String{
                    newSecuence.sequenceImageTwoDefault = sequenceImageTwoDefault
                }
                if let sequenceName = sequence["sequence_name"] as? String{
                    newSecuence.sequenceName = sequenceName
                }
                if let sequenceZoneId = sequence["sequence_zone_id"] as? Int{
                    newSecuence.sequenceZoneId = sequenceZoneId as NSNumber?
                }
                newSecuence.gateway = gateway
            }
        }
    }
    
    func createFlagsFromJSON(_ flags:[JSONDictionary], gateway:Gateway){
        for flag in flags{
            if let newFlag = NSEntityDescription.insertNewObject(forEntityName: "Flag", into: appDel.managedObjectContext!) as? Flag{
                if let address = flag["address"] as? Int{
                    newFlag.address = NSNumber(value: address)
                }
                if let levelId = flag["entity_level_id"] as? Int{
                    newFlag.entityLevelId = levelId as NSNumber?
                }
                if let isBroadcast = flag["is_broadcast"] as? Bool{
                    newFlag.isBroadcast = isBroadcast as NSNumber
                }
                if let isLocalcast = flag["is_localcast"] as? Bool{
                    newFlag.isLocalcast = isLocalcast as NSNumber
                }
                if let flagCategoryId = flag["flag_category_id"] as? Int{
                    newFlag.flagCategoryId = flagCategoryId as NSNumber?
                }
                if let flagId = flag["flag_id"] as? Int{
                    newFlag.flagId = NSNumber(value: flagId)
                }
                if let flagImageOneCustom = flag["flag_image_one_custom"] as? String{
                    newFlag.flagImageOneCustom = flagImageOneCustom
                }
                if let flagImageOneDefault = flag["flag_image_one_default"] as? String{
                    newFlag.flagImageOneDefault = flagImageOneDefault
                }
                if let flagImageTwoCustom = flag["flag_image_two_custom"] as? String{
                    newFlag.flagImageTwoCustom = flagImageTwoCustom
                }
                if let flagImageTwoDefault = flag["flag_image_two_default"] as? String{
                    newFlag.flagImageTwoDefault = flagImageTwoDefault
                }
                if let flagName = flag["flag_name"] as? String{
                    newFlag.flagName = flagName
                }
                if let flagZoneId = flag["flag_zone_id"] as? Int{
                    newFlag.flagZoneId = flagZoneId as NSNumber?
                }
                if let setState = flag["set_state"] as? Int{
                    newFlag.setState = NSNumber(value: setState)
                }
                newFlag.gateway = gateway
            }
        }
    }
    
    func createScenesFromJSON(_ scenes:[JSONDictionary], gateway:Gateway){
        for scene in scenes{
            if let newScene = NSEntityDescription.insertNewObject(forEntityName: "Scene", into: appDel.managedObjectContext!) as? Scene{
                if let address = scene["address"] as? Int{
                    newScene.address = NSNumber(value: address)
                }
                if let levelId = scene["entity_level_id"] as? Int{
                    newScene.entityLevelId = levelId as NSNumber?
                }
                if let isBroadcast = scene["is_broadcast"] as? Bool{
                    newScene.isBroadcast = isBroadcast as NSNumber
                }
                if let isLocalcast = scene["is_localcast"] as? Bool{
                    newScene.isLocalcast = isLocalcast as NSNumber
                }
                if let sceneCategoryId = scene["scene_category_id"] as? Int{
                    newScene.sceneCategoryId = sceneCategoryId as NSNumber?
                }
                if let sceneId = scene["scene_id"] as? Int{
                    newScene.sceneId = NSNumber(value: sceneId)
                }
                if let sceneImageOneCustom = scene["scene_image_one_custom"] as? String{
                    newScene.sceneImageOneCustom = sceneImageOneCustom
                }
                if let sceneImageOneDefault = scene["scene_image_one_default"] as? String{
                    newScene.sceneImageOneDefault = sceneImageOneDefault
                }
                if let sceneImageTwoCustom = scene["scene_image_two_custom"] as? String{
                    newScene.sceneImageTwoCustom = sceneImageTwoCustom
                }
                if let sceneImageTwoDefault = scene["scene_image_two_default"] as? String{
                    newScene.sceneImageTwoDefault = sceneImageTwoDefault
                }
                if let sceneName = scene["scene_name"] as? String{
                    newScene.sceneName = sceneName
                }
                if let sceneZoneId = scene["scene_zone_id"] as? Int{
                    newScene.sceneZoneId = sceneZoneId as NSNumber?
                }
                newScene.gateway = gateway
            }
        }
    }
    
    func createEventsFromJSON(_ events:[JSONDictionary], gateway:Gateway){
        for event in events{
            if let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Event", into: appDel.managedObjectContext!) as? Event{
                if let address = event["address"] as? Int{
                    newEvent.address = NSNumber(value: address)
                }
                if let levelId = event["entity_level_id"] as? Int{
                    newEvent.entityLevelId = levelId as NSNumber?
                }
                if let eventCategoryId = event["event_category_id"] as? Int{
                    newEvent.eventCategoryId = eventCategoryId as NSNumber?
                }
                if let eventId = event["event_id"] as? Int{
                    newEvent.eventId = NSNumber(value: eventId)
                }
                if let eventImageOneCustom = event["event_image_one_custom"] as? String{
                    newEvent.eventImageOneCustom = eventImageOneCustom
                }
                if let eventImageOneDefault = event["event_image_one_default"] as? String{
                    newEvent.eventImageOneDefault = eventImageOneDefault
                }
                if let eventImageTwoCustom = event["event_image_two_custom"] as? String{
                    newEvent.eventImageTwoCustom = eventImageTwoCustom
                }
                if let eventImageTwoDefault = event["event_image_two_default"] as? String{
                    newEvent.eventImageTwoDefault = eventImageTwoDefault
                }
                if let eventName = event["event_name"] as? String{
                    newEvent.eventName = eventName
                }
                if let isBroadcast = event["is_broadcast"] as? Bool{
                    newEvent.isBroadcast = isBroadcast as NSNumber
                }
                if let isLocalcast = event["is_localcast"] as? Bool{
                    newEvent.isLocalcast = isLocalcast as NSNumber
                }
                newEvent.gateway = gateway
            }
        }
    }
    
    func createDevicesFromJSON(_ devices:[JSONDictionary], gateway:Gateway){
        for device in devices{
            if let newDevice = NSEntityDescription.insertNewObject(forEntityName: "Device", into: appDel.managedObjectContext!) as? Device{
                if let address = device["address"] as? Int{
                    newDevice.address = NSNumber(value: address)
                }
                if let aes = device["allow_energy_saving"] as? Int{
                    newDevice.allowEnergySaving = NSNumber(value: aes)
                }
                if let amp = device["amp"] as? String{
                    newDevice.amp = amp
                }
                if let amv = device["auto_mode_visible"] as? Bool{
                    newDevice.autoModeVisible = amv as NSNumber?
                }
                if let asv = device["auto_speed_visible"] as? Bool{
                    newDevice.autoSpeedVisible = asv as NSNumber?
                }
                if let catId = device["category_id"] as? Int{
                    newDevice.categoryId = NSNumber(value: catId)
                }
                if let catName = device["category_name"] as? String{
                    newDevice.categoryName = catName
                }
                if let channel = device["channel"] as? Int{
                    newDevice.channel = NSNumber(value: channel)
                }
                if let controlType = device["control_type"] as? String{
                    newDevice.controlType = controlType
                }
                if let cmv = device["cool_mode_visible"] as? Bool{
                    newDevice.coolModeVisible = cmv as NSNumber?
                }
                if let coolTemperature = device["cool_temperature"] as? Int{
                    newDevice.coolTemperature = NSNumber(value: coolTemperature)
                }
                if let current = device["current"] as? Int{
                    newDevice.current = NSNumber(value: current)
                }
                if let currentValue = device["current_value"] as? Int{
                    newDevice.currentValue = NSNumber(value: currentValue)
                }
                if let curtainControlMode = device["curtain_control_mode"] as? Int{
                    newDevice.curtainControlMode = NSNumber(value: curtainControlMode)
                }
                if let curtainGroupID = device["curtain_group_id"] as? Int{
                    newDevice.curtainGroupID = NSNumber(value: curtainGroupID)
                }
                if let delay = device["delay"] as? Int{
                    newDevice.delay = NSNumber(value: delay)
                }
                if let digitalInputMode = device["digital_input_mode"] as? Int{
                    newDevice.digitalInputMode = digitalInputMode as NSNumber?
                }
                if let fmv = device["fan_mode_visible"] as? Bool{
                    newDevice.fanModeVisible = fmv as NSNumber?
                }
                if let hmv = device["heat_mode_visible"] as? Bool{
                    newDevice.heatModeVisible = hmv as NSNumber?
                }
                if let heatTemperature = device["heat_temperature"] as? Int{
                    newDevice.heatTemperature = NSNumber(value: heatTemperature)
                }
                if let hsv = device["high_speed_visible"] as? Bool{
                    newDevice.highSpeedVisible = hsv as NSNumber?
                }
                if let humidity = device["humidity"] as? Int{
                    newDevice.humidity = NSNumber(value: humidity)
                }
                if let hv = device["humidity_visible"] as? Bool{
                    newDevice.humidityVisible = hv as NSNumber?
                }
                if let isCurtainModeAllowed = device["is_curtain_mode_allowed"] as? Bool{
                    newDevice.isCurtainModeAllowed = isCurtainModeAllowed as NSNumber
                }
                if let isDimmerModeAllowed = device["is_dimmer_mode_allowed"] as? Bool{
                    newDevice.isDimmerModeAllowed = isDimmerModeAllowed as NSNumber
                }
                if let isEnabled = device["is_enabled"] as? Bool{
                    newDevice.isEnabled = isEnabled as NSNumber
                }
                if let isVisible = device["is_visible"] as? Bool{
                    newDevice.isVisible = isVisible as NSNumber
                }
                if let lsv = device["low_speed_visible"] as? Bool{
                    newDevice.lowSpeedVisible = lsv as NSNumber?
                }
                if let mac = device["mac"] as? Data{
                    newDevice.mac = mac
                }
                if let msv = device["med_speed_visible"] as? Bool{
                    newDevice.medSpeedVisible = msv as NSNumber?
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
                
                if let nd = device["notification_delay"] as? Int{
                    newDevice.notificationDelay = nd as NSNumber?
                }
                if let ndt = device["notification_display_time"] as? Int{
                    newDevice.notificationDisplayTime = ndt as NSNumber?
                }
                if let np = device["notification_position"] as? Int{
                    newDevice.notificationPosition = np as NSNumber?
                }
                if let nt = device["notification_type"] as? Int{
                    newDevice.notificationType = nt as NSNumber?
                }
                if let numberOfDevices = device["number_of_devices"] as? Int{
                    newDevice.numberOfDevices = NSNumber(value: numberOfDevices)
                }
                if let oldValue = device["old_value"] as? Int{
                    newDevice.oldValue = oldValue as NSNumber?
                }
                if let overrideControl1 = device["override_control1"] as? Int{
                    newDevice.overrideControl1 = NSNumber(value: overrideControl1)
                }
                if let overrideControl2 = device["override_control2"] as? Int{
                    newDevice.overrideControl2 = NSNumber(value: overrideControl2)
                }
                if let overrideControl3 = device["override_control3"] as? Int{
                    newDevice.overrideControl3 = NSNumber(value: overrideControl3)
                }
                if let parentZoneId = device["parent_zone_id"] as? Int{
                    newDevice.parentZoneId = NSNumber(value: parentZoneId)
                }
                if let roomTemperature = device["room_temperature"] as? Int{
                    newDevice.roomTemperature = NSNumber(value: roomTemperature)
                }
                if let runningTime = device["running_time"] as? String{
                    newDevice.runningTime = runningTime
                }
                if let runtime = device["runtime"] as? Int{
                    newDevice.runtime = NSNumber(value: runtime)
                }
                if let skipState = device["skip_state"] as? Int{
                    newDevice.skipState = NSNumber(value: skipState)
                }
                if let speed = device["speed"] as? String{
                    newDevice.speed = speed
                }
                if let speedState = device["speed_state"] as? String{
                    newDevice.speedState = speedState
                }
                if let stateUpdatedAt = device["state_updated_at"] as? Date{
                    newDevice.stateUpdatedAt = stateUpdatedAt
                }
                if let temperature = device["temperature"] as? Int{
                    newDevice.temperature = NSNumber(value: temperature)
                }
                if let tv = device["temperature_visible"] as? Bool{
                    newDevice.temperatureVisible = tv as NSNumber?
                }
                if let type = device["type"] as? String{
                    newDevice.type = type
                }
                if let voltage = device["voltage"] as? Int{
                    newDevice.voltage = NSNumber(value: voltage)
                }
                if let zoneId = device["zone_id"] as? Int{
                    newDevice.zoneId = NSNumber(value: zoneId)
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
    
    func createDeviceImagesFromJSON(_ deviceImages:[JSONDictionary], device:Device){
        for deviceImage in deviceImages{
            if let newImage = NSEntityDescription.insertNewObject(forEntityName: "DeviceImage", into: appDel.managedObjectContext!) as? DeviceImage{
                if let defaultImage =  deviceImage["default_image"] as? String {
                    newImage.defaultImage = defaultImage
                }
                if let state =  deviceImage["state"] as? Int {
                    newImage.state = state as NSNumber?
                }
                if let text =  deviceImage["text"] as? String {
                    newImage.text = text
                }
                if let id =  deviceImage["custom_image_id"] as? String {
                    newImage.customImageId = id
                }
                newImage.device = device
            }
        }
    }
    
    func createPCControllFromJSON(_ pccommands:[JSONDictionary], device:Device){
        for pccommand in pccommands{
            if let newPCCommand = NSEntityDescription.insertNewObject(forEntityName: "PCCommand", into: appDel.managedObjectContext!) as? PCCommand{
                if let name =  pccommand["name"] as? String {
                    newPCCommand.name = name
                }
                if let comand =  pccommand["comand"] as? String {
                    newPCCommand.comand = comand
                }
                if let commandType =  pccommand["command_type"] as? Bool {
                    newPCCommand.commandType = commandType as NSNumber?
                }
                newPCCommand.device = device
            }
        }
    }
    
    func createSurveillancesFromJSON(_ surveillances:[JSONDictionary], location:Location){
        for survaillance in surveillances{
            if let newSurveillance = NSEntityDescription.insertNewObject(forEntityName: "Surveillance", into: appDel.managedObjectContext!) as? Surveillance{
                if let name = survaillance["name"] as? String{
                    newSurveillance.name = name
                }
                if let isVisible = survaillance["is_visible"] as? Bool{
                    newSurveillance.isVisible = isVisible as NSNumber?
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
                    newSurveillance.port = port as NSNumber?
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
                if let levelId = survaillance["surveillance_level_id"] as? Int{
                    newSurveillance.surveillanceLevelId = levelId as NSNumber?
                }
                if let zone = survaillance["surveillance_zone"] as? String{
                    newSurveillance.surveillanceZone = zone
                }
                if let zoneId = survaillance["surveillance_zone_id"] as? Int{
                    newSurveillance.surveillanceZoneId = zoneId as NSNumber?
                }
                if let category = survaillance["surveillance_category"] as? String{
                    newSurveillance.surveillanceCategory = category
                }
                if let categoryId = survaillance["surveillance_category_id"] as? Int{
                    newSurveillance.surveillanceCategoryId = categoryId as NSNumber?
                }
                if let ass = survaillance["aut_span_step"] as? Int{
                    newSurveillance.autSpanStep = ass as NSNumber?
                }
                if let dwt = survaillance["dwell_time"] as? Int{
                    newSurveillance.dwellTime = dwt as NSNumber?
                }
                if let ps = survaillance["pan_step"] as? Int{
                    newSurveillance.panStep = ps as NSNumber?
                }
                if let ts = survaillance["tilt_step"] as? Int{
                    newSurveillance.tiltStep = ts as NSNumber?
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
    
    func createZonesFromJSON(_ zones:[JSONDictionary], location:Location){
        for zone in zones{
            if let newZone = NSEntityDescription.insertNewObject(forEntityName: "Zone", into: appDel.managedObjectContext!) as? Zone{
                if let name = zone["name"] as? String{
                    newZone.name = name
                }
                if let desc = zone["description"] as? String{
                    newZone.zoneDescription = desc
                }
                if let isVisible = zone["is_visible"] as? Bool{
                    newZone.isVisible = isVisible as NSNumber
                }
                if let id = zone["id"] as? Int{
                    newZone.id = id as NSNumber?
                }
                if let level = zone["level"] as? Int{
                    newZone.level = level as NSNumber?
                }
                if let orderId = zone["order_id"] as? Int{
                    newZone.orderId = orderId as NSNumber?
                }
                if let allowOption = zone["allow_option"] as? Int{
                    newZone.allowOption = allowOption as NSNumber!
                }
                newZone.allowOption = 1
                newZone.location = location
            }
        }
    }
    
    func createCategoriesFromJSON(_ categories:[JSONDictionary], location:Location){
        for category in categories{
            if let newCategory = NSEntityDescription.insertNewObject(forEntityName: "Category", into: appDel.managedObjectContext!) as? Category{
                if let name = category["name"] as? String{
                    newCategory.name = name
                }
                if let desc = category["description"] as? String{
                    newCategory.categoryDescription = desc
                }
                if let isVisible = category["is_visible"] as? Bool{
                    newCategory.isVisible = isVisible as NSNumber
                }
                if let id = category["id"] as? Int{
                    newCategory.id = id as NSNumber?
                }
                if let orderId = category["order_id"] as? Int{
                    newCategory.orderId = orderId as NSNumber?
                }
                if let allowOption = category["allow_option"] as? Int{
                    newCategory.allowOption = allowOption as NSNumber!
                }
                newCategory.location = location
            }
        }
    }
    
    func createSSIDfromJSON(_ ssids:[JSONDictionary], location:Location){
        for ssid in ssids{
            if let newSSID = NSEntityDescription.insertNewObject(forEntityName: "SSID", into: appDel.managedObjectContext!) as? SSID{
                if let name = ssid["name"] as? String{
                    newSSID.name = name
                }
                newSSID.location = location
            }
        }
    }
}
