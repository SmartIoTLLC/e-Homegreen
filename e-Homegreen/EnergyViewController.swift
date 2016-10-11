//
//  EnergyViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class EnergyViewController: PopoverVC  {
    
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var powerUsage: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    var scrollView = FilterPullDown()
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    var sumAmp:Float = 0
    var sumPow:Float = 0
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Energy)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Energy", subtitle: "All All All")
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        // Do any additional setup after loading the view.        
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EnergyViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.energy)
        NotificationCenter.default.addObserver(self, selector: #selector(EnergyViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEnergy), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            
            revealViewController().rearViewRevealWidth = 200
            
         
        }
        
        changeFullScreeenImage()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }

    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.energy)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Energy", subtitle: location + " " + level + " " + zone)
    }
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        updateDeviceList()
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(EnergyViewController.refreshLocalParametars), name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    
    func updateDeviceList() {
        sumAmp = 0
        sumPow = 0
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        let predicateNull = NSPredicate(format: "categoryId != 0")
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool))
        let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool))
        var predicateArray:[NSPredicate] = [predicateNull, predicateOne, predicateTwo]
        //        fetchRequest.predicate = predicate
        if filterParametar.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", filterParametar.location)
            predicateArray.append(locationPredicate)
        }
        if filterParametar.levelId != 0 && filterParametar.levelId != 255{
            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int))
//            let levelPredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", levelSearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [levelPredicate])
            predicateArray.append(copmpoundPredicate)
        }
        if filterParametar.zoneId != 0 && filterParametar.zoneId != 255{
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int))
//            let zonePredicateTwo = NSPredicate(format: "ANY gateway.zones.name == %@", zoneSearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicate])
            predicateArray.append(copmpoundPredicate)
        }
        if filterParametar.categoryId != 0 && filterParametar.categoryId != 255{
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int))
//            let categoryPredicateTwo = NSPredicate(format: "ANY gateway.categories.name == %@", categorySearchName)
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
            predicateArray.append(copmpoundPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Device]
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
    
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.energy)
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), for: UIControlState())
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
}

// Parametar from filter and relaod data
extension EnergyViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Energy)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.energy)
        refreshLocalParametars()
        
        TimerForFilter.shared.counterEnergy = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.energy)
        TimerForFilter.shared.startTimer(type: Menu.energy)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension EnergyViewController : SWRevealViewControllerDelegate{
    
}
