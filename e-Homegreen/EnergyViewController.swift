//
//  EnergyViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class EnergyViewController: CommonViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate {
    
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var powerUsage: UILabel!
    
    var pullDown = PullDownView()
    
    var senderButton:UIButton?
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    var sumAmp:Float = 0
    var sumPow:Float = 0
    
    var locationSearchText = ["", "", "", "", "", "", ""]

    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String) {
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (gateway, level, zone, category, levelName, zoneName, categoryName)
        LocalSearchParametar.setLocalParametar("Energy", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName])
        locationSearchText = LocalSearchParametar.getLocalParametar("Energy")
        refreshLocalParametars()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var pullDown = PullDownView()
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: NotificationKey.RefreshFilter, object: nil)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        locationSearchText = LocalSearchParametar.getLocalParametar("Energy")
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            
        } else {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
        }
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6])
    }
    
    func refreshLocalParametars() {
        locationSearchText = LocalSearchParametar.getLocalParametar("Energy")
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6])
        updateDeviceList()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    override func viewDidAppear(animated: Bool) {
        refreshLocalParametars()
        addObservers()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: NotificationKey.RefreshFilter, object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
    }
    
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    var zoneSearchName:String = "All"
    var levelSearchName:String = "All"
    var categorySearchName:String = "All"
    
    func updateDeviceList() {
        sumAmp = 0
        sumPow = 0
        let fetchRequest = NSFetchRequest(entityName: "Device")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        let predicateNull = NSPredicate(format: "categoryId != 0")
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo]
        //        fetchRequest.predicate = predicate
        
//        if locationSearch != "All" {
//            let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearch)
//            predicateArray.append(locationPredicate)
//        }
//        if levelSearch != "All" {
//            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: Int(levelSearch)!))
//            predicateArray.append(levelPredicate)
//        }
//        if zoneSearch != "All" {
//            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: Int(zoneSearch)!))
//            predicateArray.append(zonePredicate)
//        }
//        if categorySearch != "All" {
//            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: Int(categorySearch)!))
//            predicateArray.append(categoryPredicate)
//        }
        if locationSearch != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearch)
            predicateArray.append(locationPredicate)
        }
        if levelSearch != "All" {
            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: Int(levelSearch)!))
            let levelPredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", levelSearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [levelPredicate, levelPredicateTwo])
            predicateArray.append(copmpoundPredicate)
        }
        if zoneSearch != "All" {
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: Int(zoneSearch)!))
            let zonePredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", zoneSearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicate, zonePredicateTwo])
            predicateArray.append(copmpoundPredicate)
        }
        if categorySearch != "All" {
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: Int(categorySearch)!))
            let categoryPredicateTwo = NSPredicate(format: "ANY gateway.categories.name == %@", categorySearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, categoryPredicateTwo])
            predicateArray.append(copmpoundPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            devices = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        for item in devices {
//            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            sumAmp += Float(item.current)
            sumPow += Float(item.current) * Float(item.voltage) * 0.01
        }
        current.text = "\(sumAmp * 0.01) A"
        powerUsage.text = "\(sumPow) W"
    }
    

}
