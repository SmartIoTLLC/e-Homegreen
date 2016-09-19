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
        let data:NSData? = NSData(contentsOfFile: filePath)
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
    
    func createImagesFromJSON(images:[JSONDictionary], user:User){
        for image in images{
            if let newImage = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                if let imageData = image["image_data"] as? NSData{
                    newImage.imageData = imageData
                }
                if let id = image["image_id"] as? String{
                    newImage.imageId = id
                }
                
                newImage.user = user
            }
        }
    }
    
    func createFiltersFromJSON(filters:[JSONDictionary], user:User){
        for filter in filters{
            if let filterItem = NSEntityDescription.insertNewObjectForEntityForName("FilterParametar", inManagedObjectContext: appDel.managedObjectContext!) as? FilterParametar{
                if let id = filter["filter_id"] as? Int{
                    filterItem.filterId = id
                }
                if let isDefault = filter["is_default"] as? Bool{
                    filterItem.isDefault = isDefault
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
                filterItem.user = user
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
                if let filterOnLocation = location["filter_on_location"] as? Bool{
                    newLocation.filterOnLocation = filterOnLocation
                }
                newLocation.user = user
            }
        }
    }
    
    func createSecuritiesFromJSON(securities:[JSONDictionary], location:Location){
        for security in securities{
            print(security)
            if let newSecurity = NSEntityDescription.insertNewObjectForEntityForName("Security", inManagedObjectContext: appDel.managedObjectContext!) as? Security{
                if let addOne = security["address_one"] as? Int{
                    newSecurity.addressOne = addOne
                }
                if let addTwo = security["address_two"] as? Int{
                    newSecurity.addressTwo = addTwo
                }
                if let addThree = security["address_three"] as? Int{
                    newSecurity.addressThree = addThree
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
                if let type = gateway["type"] as? String{
                    newGateway.gatewayType = type
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
                if let levelId = timer["entity_level_id"] as? Int{
                    newTimer.entityLevelId = levelId
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
                if let timerCategoryId = timer["timer_category_id"] as? Int{
                    newTimer.timerCategoryId = timerCategoryId
                }
                if let timerId = timer["timer_id"] as? Int{
                    newTimer.timerId = timerId
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
                    newTimer.timerState = timerState
                }
                if let type = timer["type"] as? String{
                    newTimer.type = type
                }
                if let timeZone = timer["time_zone"] as? String{
                    newTimer.timeZone = timeZone
                }
                if let timeZoneId = timer["time_zone_id"] as? Int{
                    newTimer.timeZoneId = timeZoneId
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
                if let levelId = sequence["entity_level_id"] as? Int{
                    newSecuence.entityLevelId = levelId
                }
                if let isBroadcast = sequence["is_broadcast"] as? Bool{
                    newSecuence.isBroadcast = isBroadcast
                }
                if let isLocalcast = sequence["is_localcast"] as? Bool{
                    newSecuence.isLocalcast = isLocalcast
                }
                if let sequenceCategoryId = sequence["sequence_category_id"] as? Int{
                    newSecuence.sequenceCategoryId = sequenceCategoryId
                }
                if let sequenceCycles = sequence["sequence_cycles"] as? Int{
                    newSecuence.sequenceCycles = sequenceCycles
                }
                if let sequenceId = sequence["sequence_id"] as? Int{
                    newSecuence.sequenceId = sequenceId
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
                    newSecuence.sequenceZoneId = sequenceZoneId
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
                if let levelId = flag["entity_level_id"] as? Int{
                    newFlag.entityLevelId = levelId
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
                if let flagCategoryId = flag["flag_category_id"] as? Int{
                    newFlag.flagCategoryId = flagCategoryId
                }
                if let flagId = flag["flag_id"] as? Int{
                    newFlag.flagId = flagId
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
                if let flagZone = flag["flag_zone"] as? String{
                    newFlag.flagZone = flagZone
                }
                if let flagZoneId = flag["flag_zone_id"] as? Int{
                    newFlag.flagZoneId = flagZoneId
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
                if let levelId = scene["entity_level_id"] as? Int{
                    newScene.entityLevelId = levelId
                }
                if let isBroadcast = scene["is_broadcast"] as? Bool{
                    newScene.isBroadcast = isBroadcast
                }
                if let isLocalcast = scene["is_localcast"] as? Bool{
                    newScene.isLocalcast = isLocalcast
                }
                if let sceneCategoryId = scene["scene_category_id"] as? Int{
                    newScene.sceneCategoryId = sceneCategoryId
                }
                if let sceneId = scene["scene_id"] as? Int{
                    newScene.sceneId = sceneId
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
                    newScene.sceneZoneId = sceneZoneId
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
                if let levelId = event["entity_level_id"] as? Int{
                    newEvent.entityLevelId = levelId
                }
                if let eventCategoryId = event["event_category_id"] as? Int{
                    newEvent.eventCategoryId = eventCategoryId
                }
                if let eventId = event["event_id"] as? Int{
                    newEvent.eventId = eventId
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
                if let amv = device["auto_mode_visible"] as? Bool{
                    newDevice.autoModeVisible = amv
                }
                if let asv = device["auto_speed_visible"] as? Bool{
                    newDevice.autoSpeedVisible = asv
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
                if let cmv = device["cool_mode_visible"] as? Bool{
                    newDevice.coolModeVisible = cmv
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
                if let fmv = device["fan_mode_visible"] as? Bool{
                    newDevice.fanModeVisible = fmv
                }
                if let hmv = device["heat_mode_visible"] as? Bool{
                    newDevice.heatModeVisible = hmv
                }
                if let heatTemperature = device["heat_temperature"] as? Int{
                    newDevice.heatTemperature = heatTemperature
                }
                if let hsv = device["high_speed_visible"] as? Bool{
                    newDevice.highSpeedVisible = hsv
                }
                if let humidity = device["humidity"] as? Int{
                    newDevice.humidity = humidity
                }
                if let hv = device["humidity_visible"] as? Bool{
                    newDevice.humidityVisible = hv
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
                if let lsv = device["low_speed_visible"] as? Bool{
                    newDevice.lowSpeedVisible = lsv
                }
                if let mac = device["mac"] as? NSData{
                    newDevice.mac = mac
                }
                if let msv = device["med_speed_visible"] as? Bool{
                    newDevice.medSpeedVisible = msv
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
                    newDevice.notificationDelay = nd
                }
                if let ndt = device["notification_display_time"] as? Int{
                    newDevice.notificationDisplayTime = ndt
                }
                if let np = device["notification_position"] as? Int{
                    newDevice.notificationPosition = np
                }
                if let nt = device["notification_type"] as? Int{
                    newDevice.notificationType = nt
                }
                if let numberOfDevices = device["number_of_devices"] as? Int{
                    newDevice.numberOfDevices = numberOfDevices
                }
                if let oldValue = device["old_value"] as? Int{
                    newDevice.oldValue = oldValue
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
                if let tv = device["temperature_visible"] as? Bool{
                    newDevice.temperatureVisible = tv
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
                if let state =  deviceImage["state"] as? Int {
                    newImage.state = state
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
    
    func createPCControllFromJSON(pccommands:[JSONDictionary], device:Device){
        for pccommand in pccommands{
            if let newPCCommand = NSEntityDescription.insertNewObjectForEntityForName("PCCommand", inManagedObjectContext: appDel.managedObjectContext!) as? PCCommand{
                if let name =  pccommand["name"] as? String {
                    newPCCommand.name = name
                }
                if let comand =  pccommand["comand"] as? String {
                    newPCCommand.comand = comand
                }
                if let commandType =  pccommand["command_type"] as? Bool {
                    newPCCommand.commandType = commandType
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
                if let levelId = survaillance["surveillance_level_id"] as? Int{
                    newSurveillance.surveillanceLevelId = levelId
                }
                if let zone = survaillance["surveillance_zone"] as? String{
                    newSurveillance.surveillanceZone = zone
                }
                if let zoneId = survaillance["surveillance_zone_id"] as? Int{
                    newSurveillance.surveillanceZoneId = zoneId
                }
                if let category = survaillance["surveillance_category"] as? String{
                    newSurveillance.surveillanceCategory = category
                }
                if let categoryId = survaillance["surveillance_category_id"] as? Int{
                    newSurveillance.surveillanceCategoryId = categoryId
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
                if let allowOption = zone["allow_option"] as? Int{
                    newZone.allowOption = allowOption
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
                if let allowOption = category["allow_option"] as? Int{
                    newCategory.allowOption = allowOption
                }
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
