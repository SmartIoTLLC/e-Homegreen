//
//  AppDelegate+ConfigureStateForTheFirstTime.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/2/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

extension AppDelegate {
//    func preloadData () {
//        //MARK: OVO NEBI TREBALO DA POSTOJI VISE
//        let importedData = DataImporter.createSecuritiesFromFile(NSBundle.mainBundle().pathForResource("Security", ofType: "json")!)
//        for securityJSON in importedData! {
//            let security = NSEntityDescription.insertNewObjectForEntityForName("Security", inManagedObjectContext: managedObjectContext!) as! Security
//            security.name = securityJSON.name
//            security.modeExplanation = securityJSON.modeExplanation
//            security.addressOne = 1
//            security.addressTwo = 0
//            security.addressThree = 254
//            saveContext()
//        }
//    }
//    
//    func configureStateForTheFirstTime() {
//        //   Configuring data for first time
//        let defaults = NSUserDefaults.standardUserDefaults()
//        
//        let isPreloaded = defaults.boolForKey(UserDefaults.IsPreloaded)
//        if !isPreloaded {
//            preloadData()
//            defaults.setValue(0, forKey: UserDefaults.RefreshDelayHours)
//            defaults.setValue(10, forKey: UserDefaults.RefreshDelayMinutes)
//            defaults.setBool(true, forKey: UserDefaults.IsPreloaded)
//            defaults.setBool(true, forKey: UserDefaults.OpenLastScreen)
//            defaults.setObject("Idle", forKey: UserDefaults.Security.AlarmState)
//            //        Idle, Trobule, Alert, alarm
//            defaults.setObject("Disarm", forKey: UserDefaults.Security.SecurityMode)
//            //        Disarm, Away, Night, Day, Vacation
//            defaults.setObject(1, forKey: UserDefaults.Security.AddressOne)
//            //        No Panic, Panic
//            defaults.setObject(0, forKey: UserDefaults.Security.AddressTwo)
//            //        No Panic, Panic
//            defaults.setObject(254, forKey: UserDefaults.Security.AddressThree)
//            //        No Panic, Panic
//            defaults.setBool(false, forKey: UserDefaults.Security.IsPanic)
//            defaults.setInteger(3, forKey: "kRefreshConnections")
//        }
//    }
}