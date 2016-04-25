//
//  DatabaseLocationController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/20/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DatabaseLocationController: NSObject {

    static let shared = DatabaseLocationController()
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let locationManager = CLLocationManager()
    
    func getNextAvailableId(user:User) -> Int{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Location")
        let sortDescriptorTwo = NSSortDescriptor(key: "orderId", ascending: true)
        let predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Location]
            if let last = fetchResults?.last{
                if let id = last.orderId as? Int {
                    return id + 1
                }
            }
            
        } catch _ as NSError {
            abort()
        }
        return 1
    }
    
    func startMonitoringLocation(location: Location){
        if !AdminController.shared.isAdminLogged(){
            if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) || CLLocationManager.authorizationStatus() != .AuthorizedAlways {
                return
            }
            let region = regionWithLocation(location)
            locationManager.startMonitoringForRegion(region)
        }
    }
    
    func regionWithLocation(location: Location) -> CLCircularRegion {
        let region = CLCircularRegion(center: CLLocationCoordinate2DMake(Double(location.latitude!), Double(location.longitude!)) , radius: Double(location.radius!), identifier: location.objectID.URIRepresentation().absoluteString)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    func stopMonitoringLocation(location: Location) {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == location.objectID.URIRepresentation().absoluteString {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    
    func stopAllLocationMonitoring(){
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                locationManager.stopMonitoringForRegion(circularRegion)
            }
        }
    }
    
    func startMonitoringAllLocationByUser(user:User){
        if let locations = user.locations?.allObjects as? [Location] {
            for location in locations{
                startMonitoringLocation(location)
            }
        }
    }
    
    
}
