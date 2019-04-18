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

private struct LocalConstants {
    static let titleLabelHeight: CGFloat = 22
    static let valueLabelHeight: CGFloat = 19
}

class EnergyViewController: PopoverVC  {
    
    fileprivate let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    private var fullScreenButton: UIButton {
        return self.makeFullscreenButton()
    }
    private var menuButton: UIBarButtonItem {
        return self.makeMenuBarButton()
    }
    
    private let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    
    fileprivate var scrollView = FilterPullDown()
    
    private let titleLabel: UILabel = UILabel()
    private let currentValueLabel: UILabel = UILabel()
    private let powerUsageValueLabel: UILabel = UILabel()
    
    fileprivate var devices:[Device] = []

    fileprivate var filterParametar:FilterItem {
        return Filter.sharedInstance.returnFilter(forTab: .Energy)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.revealViewController().delegate = self
        
        setupBarButtonItems()
        
        addTitleView()
        addBackgroundImageView()
        addPowerUsageValueLabel()
        addCurrentLabel()
        addTitleLabel()
        
        addScrollView()
        setupConstraints()
        addObserversVDL()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshLocalParametars()
        addObserversVDA()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObservers()
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    // MARK: - Setup views
    private func setupBarButtonItems() {
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: fullScreenButton)
    }
    
    private func addBackgroundImageView() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
    }
    
    private func addTitleView() {
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Energy", subtitle: "All All All")
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EnergyViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
    }
    
    private func addPowerUsageValueLabel() {
        powerUsageValueLabel.font = .tahoma(size: 15)
        powerUsageValueLabel.textColor = .white
        powerUsageValueLabel.text = "0.0 W"
        powerUsageValueLabel.textAlignment = .center
        
        view.addSubview(powerUsageValueLabel)
    }
    
    private func addCurrentLabel() {
        currentValueLabel.font = .tahoma(size: 15)
        currentValueLabel.textColor = .white
        currentValueLabel.text = "0.0 A"
        currentValueLabel.textAlignment = .center
        
        view.addSubview(currentValueLabel)
    }
    
    private func addTitleLabel() {
        titleLabel.font = .tahoma(size: 18)
        titleLabel.textColor = .white
        titleLabel.text = "Power Usage:"
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        powerUsageValueLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().dividedBy(2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.valueLabelHeight)
        }
        
        currentValueLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(powerUsageValueLabel.snp.top).inset(-(GlobalConstants.sidePadding / 2))
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.valueLabelHeight)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(currentValueLabel.snp.top).inset(-(GlobalConstants.sidePadding / 2))
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.titleLabelHeight)
        }
        
    }
    
    func addScrollView() {
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        scrollView.filterDelegate = self
        
        scrollView.setFilterItem(Menu.energy)
        
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
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
    
    // MARK: - Logic
    func updateDeviceList() {
        var sumAmp: Float = 0
        var sumPow: Float = 0
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "gateway.location.name", ascending: true),
            NSSortDescriptor(key: "address", ascending: true),
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "channel", ascending: true)
        ]
        
        var predicateArray:[NSPredicate] = [
            NSPredicate(format: "categoryId != 0"),
            NSPredicate(format: "gateway.turnedOn == %@", NSNumber(value: true as Bool)),
            NSPredicate(format: "isVisible == %@", NSNumber(value: true as Bool))
        ]
        
        if filterParametar.location != "All" {
            predicateArray.append(NSPredicate(format: "gateway.name == %@", filterParametar.location))
        }
        if filterParametar.levelId != 0 && filterParametar.levelId != 255{
            predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int)))
        }
        if filterParametar.zoneId != 0 && filterParametar.zoneId != 255{
            predicateArray.append(NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int)))
        }
        if filterParametar.categoryId != 0 && filterParametar.categoryId != 255{
            predicateArray.append(NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int)))
        }
        
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                if let fetResults = try appDel.managedObjectContext?.fetch(fetchRequest) as? [Device] {
                    devices = fetResults
                }
            }
            
        } catch let error as NSError {
            print("Unresolved error: \(String(describing: error.userInfo))")
        }
        
        for item in devices {
            sumAmp += Float(item.current)
            sumPow += Float(item.current) * Float(item.voltage) * 0.01
        }
        currentValueLabel.text = "\(sumAmp * 0.01) A"
        powerUsageValueLabel.text = "\(sumPow) W"
    }
    
}

// MARK: - Parametar from filter and relaod data
extension EnergyViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Energy)
        
        updateSubtitle(headerTitleSubtitleView, title: "Energy", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.energy)
        refreshLocalParametars()
        
        TimerForFilter.shared.counterEnergy = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.energy)
        TimerForFilter.shared.startTimer(type: Menu.energy)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
    
    @objc func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.energy)
    }
    
    @objc func refreshLocalParametars() {
        updateDeviceList()
    }
    
    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            scrollView.setDefaultFilterItem(Menu.energy)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

extension EnergyViewController : SWRevealViewControllerDelegate{
    
}
