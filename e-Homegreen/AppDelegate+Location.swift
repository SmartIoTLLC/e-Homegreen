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
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    }
    
    func startMonitoringItem(_ item: IBeacon) {
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: item.uuid!)!, major: UInt16(item.major!.intValue) , minor: UInt16(item.minor!.intValue), identifier: item.name!)
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    func stopMonitoringItem(_ item: IBeacon) {
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: item.uuid!)!, major: UInt16(item.major!.intValue) , minor: UInt16(item.minor!.intValue), identifier: item.name!)
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion { handleRegionEvent(region) }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion { handleRegionEvent(region) }
    }
}
