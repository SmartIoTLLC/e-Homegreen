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
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager()
    
    func getNextAvailableId(_ user:User) -> Int{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Location.fetchRequest()
        let sortDescriptorTwo = NSSortDescriptor(key: "orderId", ascending: true)
        let predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Location]
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
    
    func startMonitoringLocation(_ location: Location){
        if !AdminController.shared.isAdminLogged(){
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                return
            }
            let region = regionWithLocation(location)
            locationManager.startMonitoring(for: region)
        }
    }
    
    func regionWithLocation(_ location: Location) -> CLCircularRegion {
        let region = CLCircularRegion(center: CLLocationCoordinate2DMake(Double(location.latitude!), Double(location.longitude!)) , radius: Double(location.radius!), identifier: location.objectID.uriRepresentation().absoluteString)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    func stopMonitoringLocation(_ location: Location) {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == location.objectID.uriRepresentation().absoluteString {
                    locationManager.stopMonitoring(for: circularRegion)
                }
            }
        }
    }
    
    func stopAllLocationMonitoring(){
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                locationManager.stopMonitoring(for: circularRegion)
            }
        }
    }
    
    func startMonitoringAllLocationByUser(_ user:User){
        if let locations = user.locations?.allObjects as? [Location] {
            for location in locations{
                startMonitoringLocation(location)
            }
        }
    }
    
    func deleteLocation(_ location:Location){
        appDel.managedObjectContext?.delete(location)
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func getLocation(_ user:User) -> [Location]{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Location.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "orderId", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo]
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Location]
            return fetchResults!
        } catch _ as NSError {
            abort()
        }
        return []
    }
    
    
}
