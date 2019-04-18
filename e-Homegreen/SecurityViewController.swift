//
//  SecurityViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class SecurityViewController: PopoverVC {
    
    var refreshTimer: Foundation.Timer?
    
    fileprivate func startRefreshTimer() {
        refreshTimer = Foundation.Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(refreshSecurityAlarmStateAndSecurityMode), userInfo: nil, repeats: true)
    }
    fileprivate func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    enum SecurityItem {
        case location, security
    }
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "SecurityCell"
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var securities:[Security] = []
    var location:[Location] = []
        
    var scrollView = FilterPullDown()
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var filterParametar:FilterItem!
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var securityItem:SecurityItem = SecurityItem.location
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var lblAlarmState: UILabel!
    @IBOutlet weak var securityCollectionView: UICollectionView!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBAction func fullScreen(_ sender: AnyObject) {
        (sender as! UIButton).switchFullscreen(viewThatNeedsOffset: scrollView)
    }
    @IBAction func refresh(_ sender: AnyObject) {
        (sender as! UIButton).rotate(1)
        refreshSecurityAlarmStateAndSecurityMode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        updateViews()
        refreshSecurityAlarmStateAndSecurityMode()
        
        addObserversVDL()
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        securityCollectionView.isUserInteractionEnabled = true
        
        refreshSecurity()
                
        changeFullscreenImage(fullscreenButton: fullScreenButton)
        startRefreshTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        
        addObserversVDA()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { securityCollectionView.reloadData() })
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopRefreshTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            scrollView.setDefaultFilterItem(Menu.security)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - View Setup
extension SecurityViewController {
    
    fileprivate func getCell(at indexPath: IndexPath, _ collectionView: UICollectionView) -> UICollectionViewCell {
        if securityItem == .security {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SecurityCollectionCell {
                var name:String = ""
                if filterParametar.location == "All" { name += securities[indexPath.row].location!.name! + " " }
                name += securities[indexPath.row].securityName!
                
                cell.setCell(name, security: securities[indexPath.row], tag: indexPath.row)
                
                let openParametar = UILongPressGestureRecognizer(target: self, action: #selector(openParametar(_:)))
                openParametar.minimumPressDuration = 0.5
                cell.securityTitle.addGestureRecognizer(openParametar)
                cell.securityButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonPressed(_:))))
                
                return cell
            }
            
            return UICollectionViewCell()
            
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecurityLocationCell", for: indexPath) as? SecurityLocationCell {
                
                cell.setItem(location[indexPath.row], tag: indexPath.row)
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(openMode(_:)))
                longPress.minimumPressDuration = 0.5
                cell.loactionTitleLabel.addGestureRecognizer(longPress)
                
                return cell
            }
            
            return UICollectionViewCell()
        }
    }
    
    func setupScrollView() {
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(view)
        scrollView.setFilterItem(Menu.security)
    }
    
    func updateViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: .red)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Security", subtitle: "All All All")
        
        if let alarmState = defaults.value(forKey: UserDefaults.Security.AlarmState) { lblAlarmState.text = "Alarm state: \(alarmState)" }
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
    }
    
    fileprivate func addObserversVDL() {
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSecurity), object: nil)
    }
    
    fileprivate func addObserversVDA() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSecurity), name: NSNotification.Name(rawValue: NotificationKey.RefreshSecurity), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startBlinking(_:)), name: NSNotification.Name(rawValue: NotificationKey.Security.ControlModeStartBlinking), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopBlinking(_:)), name: NSNotification.Name(rawValue: NotificationKey.Security.ControlModeStopBlinking), object: nil)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshSecurity), object: nil)
    }
    
    func reorganizeSecurityArray () {
        var tempSecurities:[Security] = securities
        for security in securities {
            if security.securityName == "Away" { tempSecurities[0] = security }
            if security.securityName == "Night" { tempSecurities[1] = security }
            if security.securityName == "Day" { tempSecurities[2] = security }
            if security.securityName == "Vacation" { tempSecurities[3] = security }
            if security.securityName == "Disarm" { tempSecurities[4] = security }
            if security.securityName == "Panic" { tempSecurities[5] = security }
        }
        securities = tempSecurities
    }
}

// MARK: - Logic
extension SecurityViewController {
    
    @objc func refreshSecurity() {
        updateSecurityList()
        reorganizeSecurityArray()
        securityCollectionView.reloadData()
    }
    
    func updateSecurityList () {
        if let _ = DatabaseUserController.shared.loggedUserOrAdmin() {
            if filterParametar.location == "All" {
                securityItem = SecurityItem.location
            } else {
                securityItem = SecurityItem.security
            }
            location     = FilterController.shared.getLocationForFilterByUser()
            securities   = DatabaseSecurityController.shared.getSecurity(filterParametar) // todo puklo
        } else { view.makeToast(message: "No user database selected.") }
        
    }
    
    @objc func refreshSecurityAlarmStateAndSecurityMode() {
        if securities.count > 0 {
            let address:[UInt8] = [getByte(securities[0].addressOne), getByte(securities[0].addressTwo), getByte(securities[0].addressThree)]
            if let id = securities[0].gatewayId {
                if let gateway = DatabaseGatewayController.shared.getGatewayByid(id) {
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurrentAlarmState(address), gateway: gateway)
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurrentSecurityMode(address), gateway: gateway)
                }
            }
        }
    }
    
    @objc func openParametar (_ gestureRecognizer:UITapGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            if gestureRecognizer.state == .began {
                let location = gestureRecognizer.location(in: securityCollectionView)
                if let index = securityCollectionView.indexPathForItem(at: location) {
                    if let cell = securityCollectionView.cellForItem(at: index) {
                        showSecurityParametar(CGPoint(x: cell.center.x, y: cell.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                    }
                }
            }
        }
    }
    
    @objc func openMode(_ gestureRecognizer:UITapGestureRecognizer){
        if gestureRecognizer.state == .began {
            showSecurityLocationParametar()
        }
    }
    
    @objc func buttonPressed (_ gestureRecognizer:UITapGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            let userDefaults = Foundation.UserDefaults.standard
            let location = gestureRecognizer.location(in: securityCollectionView)
            
            switch securities[tag].securityName! {
                
            case "Away", "Night", "Day", "Vacation":
                if let index = securityCollectionView.indexPathForItem(at: location) {
                    if let cell = securityCollectionView.cellForItem(at: index) {
                        if let securityMode = userDefaults.value(forKey: UserDefaults.Security.SecurityMode) as? String {
                            if securityMode != SecurityControlMode.Disarm {
                                showSecurityInformation(CGPoint(x: cell.center.x, y: cell.center.y - securityCollectionView.contentOffset.y))
                            } else {
                                showSecurityCommand(CGPoint(x: cell.center.x, y: cell.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])
                            }
                        }
                    }
                }
                
            case "Disarm":
                if let index = securityCollectionView.indexPathForItem(at: location) {
                    if let cell = securityCollectionView.cellForItem(at: index) {
                        showSecurityPad(CGPoint(x: cell.center.x, y: cell.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                    }
                }
                
            case "Panic":
                let security = securities[tag]
                let address = [security.addressOne.uint8Value, security.addressTwo.uint8Value, security.addressThree.uint8Value]
                if let gateway = CoreDataController.sharedInstance.fetchGatewayWithId(security.gatewayId!) {
                    let notificationName = NotificationKey.Security.ControlModeStartBlinking
                    
                    if userDefaults.bool(forKey: UserDefaults.Security.IsPanic) {
                        SendingHandler.sendCommand(byteArray: OutgoingHandler.setPanic(address, panic: 0x01), gateway: gateway)
                        userDefaults.set(false, forKey: UserDefaults.Security.IsPanic)
                    } else {
                        SendingHandler.sendCommand(byteArray: OutgoingHandler.setPanic(address, panic: 0x00), gateway: gateway)
                        userDefaults.set(true, forKey: UserDefaults.Security.IsPanic)
                    }
                    userDefaults.synchronize()
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notificationName), object: self, userInfo: ["controlMode": SecurityControlMode.Panic]))
                }
                
            default: break
            }
        }
        
    }
    
    fileprivate func didSelectSecurityLocation(at indexPath: IndexPath, _ collectionView: UICollectionView) {
        if collectionView.cellForItem(at: indexPath) is SecurityLocationCell {
            filterParametar.location = location[indexPath.row].name!
            filterParametar.locationObjectId = location[indexPath.row].objectID.uriRepresentation().absoluteString
            DatabaseFilterController.shared.saveFilter(filterParametar, menu: Menu.security)
            
            updateSubtitle(headerTitleSubtitleView, title: "Security", location: filterParametar.location, level: filterParametar.levelName, zone: filterParametar.zoneName)
            refreshSecurity()
        }
    }
    
    @objc func startBlinking(_ notification: Notification){
        securityCollectionView.isScrollEnabled = false
    }
    @objc func stopBlinking(_ notification: Notification){
        securityCollectionView.isScrollEnabled = true
    }
    
    @objc func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.security)
    }
}

// Parametar from filter and relaod data
extension SecurityViewController: FilterPullDownDelegate {
    func filterParametars(_ filterItem: FilterItem) {
        filterParametar = filterItem
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.security)
        updateSubtitle(headerTitleSubtitleView, title: "Security", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        refreshSecurity()
        TimerForFilter.shared.counterSecurity = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.security)
        TimerForFilter.shared.startTimer(type: Menu.security)
    }
    
    func saveDefaultFilter() {
        view.makeToast(message: "Default filter parametar saved!")
    }
}

extension SecurityViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition) {
        if position == .left { securityCollectionView.isUserInteractionEnabled = true } else { securityCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        if position == .left { securityCollectionView.isUserInteractionEnabled = true } else { securityCollectionView.isUserInteractionEnabled = false }
    }
}

extension SecurityViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectSecurityLocation(at: indexPath, collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension SecurityViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if securityItem == .security { return securities.count } else { return location.count }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getCell(at: indexPath, collectionView)
    }

}
