//
//  DatabaseDeviceController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/14/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseDeviceController: NSObject {

    static let shared = DatabaseDeviceController()
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getPCs(_ filterParametar: FilterItem) -> [Device] {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
            
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "gateway.name", ascending: true),
                NSSortDescriptor(key: "address", ascending: true),
                NSSortDescriptor(key: "type", ascending: true),
                NSSortDescriptor(key: "channel", ascending: true)
            ]
            
            var predicateArray = [
                NSPredicate(format: "gateway.location.user == %@", user),
                NSPredicate(format: "type == %@", ControlType.PC)
            ]
            
            if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location)) }
            if filterParametar.levelId != 0 && filterParametar.levelId != 255 { predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int))) }
            if filterParametar.zoneId != 0 && filterParametar.zoneId != 255 { predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int))) }
            if filterParametar.categoryId != 0 && filterParametar.categoryId != 255 { predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int))) }
            
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate

            do {
                if let moc = appDel.managedObjectContext {
                    if let fetResults = try moc.fetch(fetchRequest) as? [Device] {
                        return fetResults
                    }
                }
                
            } catch let error as NSError { print("Unresolved error \(error), \(error.userInfo)") }
            
        }
        return []
    }
    
    func getIRDevice(withChannelID id: Int) -> Device? {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
            
            let sortDescriptors = [
                NSSortDescriptor(key: "gateway.name", ascending: true),
                NSSortDescriptor(key: "address", ascending: true),
                NSSortDescriptor(key: "type", ascending: true),
                NSSortDescriptor(key: "channel", ascending: true)
            ]
            fetchRequest.sortDescriptors = sortDescriptors
            
            let predicateArray = [
                NSPredicate(format: "gateway.location.user == %@", user),
                NSPredicate(format: "type == %@", ControlType.Sensor),
                NSPredicate(format: "channel == %ld", id)
            ]
            
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
            
            fetchRequest.predicate = compoundPredicate
            
            do {
                if let moc = appDel.managedObjectContext {
                    if let fetchResults = try moc.fetch(fetchRequest) as? [Device] {
                        return fetchResults.first
                    }                    
                }
                
            } catch {}
        }
        
        return nil
    }
    
    func getDevices() -> [Device]? {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
            
            let sortDescriptors = [
                NSSortDescriptor(key: "gateway.name", ascending: true),
                NSSortDescriptor(key: "address", ascending: true),
                NSSortDescriptor(key: "type", ascending: true),
                NSSortDescriptor(key: "channel", ascending: true)
            ]
            fetchRequest.sortDescriptors = sortDescriptors
            
            fetchRequest.predicate = NSPredicate(format: "gateway.location.user == %@", user)
            
            do {
                if let moc = appDel.managedObjectContext {
                    if var fetchResults = try moc.fetch(fetchRequest) as? [Device] {
                        if user.sortDevicesByUsage!.boolValue {
                            fetchResults.sort { (one, two) -> Bool in
                                one.usageCounter!.intValue > two.usageCounter!.intValue
                            }
                        }
                        return fetchResults
                    }
                }
            } catch { }
        }
        
        return nil
    }
    
    func getDevicesOnDevicesScreen(filterParametar: FilterItem, user: User) -> [Device]? {
        
        var devices: [Device] = []
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        
        var predicateArray:[NSPredicate] = [
            NSPredicate(format: "gateway.location.user == %@", user),
            NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool)),
            NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool)),
            NSPredicate(format: "type != %@", ControlType.PC)         // Filtering out PC devices
        ]
        
        // Filtering by parametars from filter
        if filterParametar.location != "All" { predicateArray.append(NSPredicate(format: "gateway.location.name == %@", filterParametar.location)) }
        if filterParametar.levelId != 0 && filterParametar.levelId != 255 { predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int))) }
        if filterParametar.zoneId != 0 && filterParametar.zoneId != 255 { predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int))) }
        if filterParametar.categoryId != 0 && filterParametar.categoryId != 255 { predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int))) }
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "gateway.name", ascending: true),
            NSSortDescriptor(key: "address", ascending: true),
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "channel", ascending: true)
        ]
        
        do {
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Device] {
                    devices = fetResults.map({$0})
                    // filter Curtain devices that are, actually, one device
                    
                    // All curtains
                    let curtainDevices = devices.filter({$0.controlType == ControlType.Curtain})
                    if curtainDevices.count > 0 {
                        for i in 0...curtainDevices.count - 1 {
                            if i+1 < curtainDevices.count { // if next exist
                                for j in i+1...curtainDevices.count - 1 {
                                    if (curtainDevices[i].address == curtainDevices[j].address
                                        && curtainDevices[i].controlType == curtainDevices[j].controlType
                                        && curtainDevices[i].isCurtainModeAllowed.boolValue
                                        && curtainDevices[j].isCurtainModeAllowed.boolValue
                                        && curtainDevices[i].curtainGroupID == curtainDevices[j].curtainGroupID) {
                                        
                                        if let indexOfDeviceToBeNotShown = devices.index(of: curtainDevices[j]) { devices.remove(at: indexOfDeviceToBeNotShown) }
                                    }
                                }
                            }
                        }
                    }
                    for device in devices { device.cellTitle = returnNameForDeviceAccordingToFilter(filterParameter: filterParametar, device: device) }
                    if user.sortDevicesByUsage!.boolValue {
                        devices.sort(by: { (one, two) -> Bool in one.usageCounter!.intValue > two.usageCounter!.intValue })
                    }
                    return devices
                }
            }
            
            
        } catch let error as NSError { print("Unresolved error \(String(describing: error)), \(error.userInfo)") }
        
        return nil
    }
    
    
    func returnNameForDeviceAccordingToFilter (filterParameter: FilterItem, device:Device) -> String {
        if filterParameter.location != "All" {
            if filterParameter.levelId != 0 && filterParameter.levelId != 255 {
                if filterParameter.zoneId != 0 && filterParameter.zoneId != 255 { return "\(device.name)"
                } else {
                    if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(device.zoneId.intValue, location: device.gateway.location), let name = zone.name { return "\(name) \(device.name)"
                    } else { return "\(device.name)" } }
                
            } else {
                if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(device.parentZoneId.intValue, location: device.gateway.location), let name = zone.name {
                    if let zone2 = DatabaseHandler.sharedInstance.returnZoneWithId(device.zoneId.intValue, location: device.gateway.location), let name2 = zone2.name {
                        return "\(name) \(name2) \(device.name)"
                    } else { return "\(name) \(device.name)" }
                    
                } else { return "\(device.name)" } }
            
        } else {
            var text = "\(device.gateway.location.name ?? "")"
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(device.parentZoneId.intValue, location: device.gateway.location), let name = zone.name { text += " " + name }
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(device.zoneId.intValue, location: device.gateway.location), let name = zone.name { text += " " + name }
            text += " " + device.name
            
            return text
        }
        
    }
    
    func returnNameForFavoriteDevice(filterParameter: FilterItem, nameType: FavDeviceFilterType, device:Device) -> String {
        var locationName: String?
        var levelName: String?
        var zoneName: String?
        let deviceName: String = device.name
        
        var fullName: String = ""
        
        if let location = device.gateway.location.name {
            if location != "All" { locationName = location }
        }
        if let levelId = device.parentZoneId as? Int {
            if let level = DatabaseHandler.sharedInstance.returnZoneWithId(levelId, location: device.gateway.location)?.name { levelName = level }
        }
        
        if let zoneId = device.zoneId as? Int {
            if let zone = DatabaseHandler.sharedInstance.returnZoneWithId(zoneId, location: device.gateway.location)?.name { zoneName = zone }
        }
        
        switch nameType {
        case .locationLevelZoneName:
            if let locationName = locationName { fullName += "\(locationName) " }
            if let levelName = levelName { fullName += "\(levelName) " }
            if let zoneName = zoneName { fullName += "\(zoneName) " }
            fullName += deviceName
        case .levelZoneName:
            if let levelName = levelName { fullName += "\(levelName) " }
            if let zoneName = zoneName { fullName += "\(zoneName) " }
            fullName += deviceName
        case .zoneName:
            if let zoneName = zoneName { fullName += "\(zoneName) " }
            fullName += deviceName
        case .deviceName:
            fullName += deviceName
        }
        
        return fullName
    }
    
    func toggleFavoriteDevice(device: Device, favoriteButton: UIButton) {
        device.isFavorite = NSNumber(value: !device.isFavorite!.boolValue)
        switch device.isFavorite!.boolValue {
            case true: favoriteButton.setImage(#imageLiteral(resourceName: "favorite"), for: UIControlState())
            case false: favoriteButton.setImage(#imageLiteral(resourceName: "unfavorite"), for: UIControlState())
        }
        
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: .favoriteDeviceToggled, object: nil)
    }
    
}
