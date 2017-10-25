//
//  RunnableList.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 10/17/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

public class RunnableList {
    
    open static let sharedInstance = RunnableList()
    
    var runnableList: [NSManagedObjectID: NSNumber] = [:]
    var deviceHasValue: [NSManagedObjectID: Bool] = [:]
    var deviceOldValue: [NSManagedObjectID: NSNumber] = [:]
    
    func checkForSameDevice(device: NSManagedObjectID, newCommand: NSNumber, oldValue: NSNumber) {
        
        if deviceHasValue[device] == nil { deviceHasValue[device] = true } else { deviceHasValue[device] = false }

        if deviceHasValue[device] == true { deviceOldValue[device] = oldValue }
        
        if runnableList[device] != nil && runnableList[device] != newCommand {
                let oldDataToSend = [device: runnableList[device]!]
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.SameDeviceDifferentCommand), object: self, userInfo: oldDataToSend)
                print("Notification sent for device with ID: ", device, "\n")
        }
        
        runnableList[device] = newCommand
        print("Device with ID: ", device, "received a new command", newCommand, "\n")
    }
    
    func removeDeviceFromRunnableList(device: NSManagedObjectID) {
        runnableList.removeValue(forKey: device)
        print("Removed from list device with ID: ", device)
        if deviceHasValue[device] != nil {
            deviceHasValue.removeValue(forKey: device)
            if deviceOldValue[device] != nil { deviceOldValue.removeValue(forKey: device) }
        }
    }
    
}
