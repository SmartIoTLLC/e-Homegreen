//
//  AppDelegate+Location.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/2/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Failed monitoring region: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed: \(error.description)")
    }
    
    func returnZoneWithIBeacon (iBeacon:IBeacon) -> Zone? {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicateOne = NSPredicate(format: "iBeacon == %@", iBeacon)
        fetchRequest.predicate = predicateOne
        do {
            let fetResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults?.count != 0 {
                return fetResults![0]
            }
        } catch let error1 as NSError {
            print("Unresolved error \(error1), \(error1.userInfo)")
            abort()
        }
        return nil
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        for beacon in beacons {
            for item in iBeacons {
                if (Int(beacon.major) == Int(item.major!)) && (Int(beacon.minor) == Int(item.minor!)) && (item.uuid!.uppercaseString == beacon.proximityUUID.UUIDString){
                    item.accuracy = beacon.accuracy
                }
            }
        }
    }
    func loadItems() {
        for item in iBeacons {
            startMonitoringItem(item)
        }
    }
    
    func stopiBeacons() {
        for item in iBeacons {
            stopMonitoringItem(item)
        }
    }
    func startMonitoringItem(item: IBeacon) {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: item.uuid!)!, major: UInt16(item.major!.integerValue) , minor: UInt16(item.minor!.integerValue), identifier: item.name!)
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    func stopMonitoringItem(item: IBeacon) {
        let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: item.uuid!)!, major: UInt16(item.major!.integerValue) , minor: UInt16(item.minor!.integerValue), identifier: item.name!)
        locationManager.stopMonitoringForRegion(beaconRegion)
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
}