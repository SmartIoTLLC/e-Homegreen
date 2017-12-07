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
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        addObserversVDL()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        refreshLocalParametars()
        addObserversVDA()
        scrollView.setContentOffset(bottomOffset, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }

    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
}

// MARK: - Parametar from filter and relaod data
extension EnergyViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Energy)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        
        updateSubtitle(headerTitleSubtitleView, title: "Energy", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.energy)
        refreshLocalParametars()
        
        TimerForFilter.shared.counterEnergy = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.energy)
        TimerForFilter.shared.startTimer(type: Menu.energy)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
    
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.energy)
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        updateDeviceList()
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.energy)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

// MARK: - View setup
extension EnergyViewController {
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Energy", subtitle: "All All All")
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Energy)
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EnergyViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.energy)
    }
    
    fileprivate func addObserversVDA() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocalParametars), name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    fileprivate func addObserversVDL() {
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEnergy), object: nil)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
}

// MARK: - Logic
extension EnergyViewController {
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
        
        if filterParametar.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", filterParametar.location)
            predicateArray.append(locationPredicate)
        }
        if filterParametar.levelId != 0 && filterParametar.levelId != 255{
            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int))
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [levelPredicate])
            predicateArray.append(copmpoundPredicate)
        }
        if filterParametar.zoneId != 0 && filterParametar.zoneId != 255{
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int))
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [zonePredicate])
            predicateArray.append(copmpoundPredicate)
        }
        if filterParametar.categoryId != 0 && filterParametar.categoryId != 255{
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int))
            let copmpoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
            predicateArray.append(copmpoundPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Device]
            devices = fetResults!
        } catch let error1 as NSError { error = error1; print("Unresolved error", error, error!.userInfo) }
        
        for item in devices {
            sumAmp += Float(item.current)
            sumPow += Float(item.current) * Float(item.voltage) * 0.01
        }
        current.text = "\(sumAmp * 0.01) A"
        powerUsage.text = "\(sumPow) W"
    }
}

extension EnergyViewController : SWRevealViewControllerDelegate{
    
}
