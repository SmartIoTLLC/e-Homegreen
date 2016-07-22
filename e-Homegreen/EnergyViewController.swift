//
//  EnergyViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class EnergyViewController: PopoverVC  {
    
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var powerUsage: UILabel!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    var scrollView = FilterPullDown()
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRectMake(0, 0, CGFloat.max, 44))
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    var sumAmp:Float = 0
    var sumPow:Float = 0
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Energy)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Energy", subtitle: "All, All, All")
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
                revealViewController().rearViewRevealWidth = 200
            }else{
                revealViewController().rearViewRevealWidth = 200
            }
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        changeFullScreeenImage()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        refreshLocalParametars()
        addObservers()
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y > 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }

    }
    
    override func nameAndId(name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }

    
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    
    func updateSubtitle(location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Energy", subtitle: location + ", " + level + ", " + zone)
    }
    
    @IBAction func fullScreen(sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    func changeFullScreeenImage(){
        if UIApplication.sharedApplication().statusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        }
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        updateDeviceList()
    }

    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EnergyViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
    }
    
    func updateDeviceList() {
        sumAmp = 0
        sumPow = 0
        let fetchRequest = NSFetchRequest(entityName: "Device")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        let predicateNull = NSPredicate(format: "categoryId != 0")
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo]
        //        fetchRequest.predicate = predicate
        if filterParametar.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", filterParametar.location)
            predicateArray.append(locationPredicate)
        }
        if filterParametar.levelId != 0 {
            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: filterParametar.levelId))
//            let levelPredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", levelSearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [levelPredicate])
            predicateArray.append(copmpoundPredicate)
        }
        if filterParametar.zoneId != 0 {
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: filterParametar.zoneId))
//            let zonePredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", zoneSearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicate])
            predicateArray.append(copmpoundPredicate)
        }
        if filterParametar.categoryId != 0 {
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: filterParametar.categoryId))
//            let categoryPredicateTwo = NSPredicate(format: "ANY gateway.categories.name == %@", categorySearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
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

// Parametar from filter and relaod data
extension EnergyViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Energy)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        
        refreshLocalParametars()
    }
}

extension EnergyViewController : SWRevealViewControllerDelegate{
    
}
