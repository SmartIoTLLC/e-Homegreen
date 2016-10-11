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

class SecurityViewController: PopoverVC{
    
    enum SecurityItem{
        case location, security
    }
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "SecurityCell"
    
    var securities:[Security] = []
    var location:[Location] = []
    
    var scrollView = FilterPullDown()
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var filterParametar:FilterItem!
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var lblAlarmState: UILabel!
    @IBOutlet weak var securityCollectionView: UICollectionView!
    @IBOutlet weak var refreshBtn: UIButton!
    
    var securityItem:SecurityItem = SecurityItem.location
    
    @IBAction func fullScreen(_ sender: AnyObject) {
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
    @IBAction func refresh(_ sender: AnyObject) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 1
        rotateAnimation.toValue = CGFloat(M_PI)
        refreshBtn.layer.add(rotateAnimation, forKey: nil)
        refreshSecurityAlarmStateAndSecurityMode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Security", subtitle: "All All All")
        
        let defaults = Foundation.UserDefaults.standard
        if let alarmState = defaults.value(forKey: UserDefaults.Security.AlarmState){
            lblAlarmState.text = "Alarm state: \(alarmState)"
        }
        
        refreshSecurityAlarmStateAndSecurityMode()
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SecurityViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.security)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SecurityViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSecurity), object: nil)
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
        
        securityCollectionView.isUserInteractionEnabled = true
        
        refreshSecurity()
        
        changeFullScreeenImage()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SecurityViewController.refreshSecurity), name: NSNotification.Name(rawValue: NotificationKey.RefreshSecurity), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SecurityViewController.startBlinking(_:)), name: NSNotification.Name(rawValue: NotificationKey.Security.ControlModeStartBlinking), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SecurityViewController.stopBlinking(_:)), name: NSNotification.Name(rawValue: NotificationKey.Security.ControlModeStopBlinking), object: nil)
        
    }
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        securityCollectionView.reloadData()
        
    }
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshSecurity), object: nil)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.security)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func updateSubtitle(){
        headerTitleSubtitleView.setTitleAndSubtitle("Security", subtitle: filterParametar.location + " " + filterParametar.levelName + " " + filterParametar.zoneName)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    
    func reorganizeSecurityArray () {
        var tempSecurities:[Security] = securities
        for security in securities {
            if security.securityName == "Away" {
                tempSecurities[0] = security
            }
            if security.securityName == "Night" {
                tempSecurities[1] = security
            }
            if security.securityName == "Day" {
                tempSecurities[2] = security
            }
            if security.securityName == "Vacation" {
                tempSecurities[3] = security
            }
            if security.securityName == "Disarm" {
                tempSecurities[4] = security
            }
            if security.securityName == "Panic" {
                tempSecurities[5] = security
            }
        }
        securities = tempSecurities
    }
    
    func refreshSecurity() {
        updateSecurityList()
//        self.securityCollectionView.performBatchUpdates({ 
//            self.securityCollectionView.reloadSections(NSIndexSet(index: 0))
//            }) { (finished) in
//                self.securityCollectionView.setNeedsDisplay()
//        }
        self.securityCollectionView.reloadData()
    }
    
    func refreshSecurityAlarmStateAndSecurityMode () {
        if securities.count > 0{
            let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
            if let id = securities[0].gatewayId{
                if let gateway = DatabaseGatewayController.shared.getGatewayByid(id)  {
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurrentAlarmState(address), gateway: gateway)
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurrentSecurityMode(address), gateway: gateway)
                }
            }
        }
    }
    
    func updateSecurityList () {
        if filterParametar.location == "All"{
            securityItem = SecurityItem.location
            location = FilterController.shared.getLocationForFilterByUser()
        }else{
            securityItem = SecurityItem.security
            securities = DatabaseSecurityController.shared.getSecurity(filterParametar)
        }
    }
    
    func openParametar (_ gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            switch securities[tag].securityName! {
            case "Away":
                let location = gestureRecognizer.location(in: securityCollectionView)
                if let index = securityCollectionView.indexPathForItem(at: location){
                    let cell = securityCollectionView.cellForItem(at: index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Night":
                let location = gestureRecognizer.location(in: securityCollectionView)
                if let index = securityCollectionView.indexPathForItem(at: location){
                    let cell = securityCollectionView.cellForItem(at: index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Day":
                let location = gestureRecognizer.location(in: securityCollectionView)
                if let index = securityCollectionView.indexPathForItem(at: location){
                    let cell = securityCollectionView.cellForItem(at: index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Vacation":
                let location = gestureRecognizer.location(in: securityCollectionView)
                if let index = securityCollectionView.indexPathForItem(at: location){
                    let cell = securityCollectionView.cellForItem(at: index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Disarm":
                let location = gestureRecognizer.location(in: securityCollectionView)
                if let index = securityCollectionView.indexPathForItem(at: location){
                    let cell = securityCollectionView.cellForItem(at: index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Panic":
                let location = gestureRecognizer.location(in: securityCollectionView)
                if let index = securityCollectionView.indexPathForItem(at: location){
                    let cell = securityCollectionView.cellForItem(at: index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            default: break
            }
        }
    }
    
    func openMode(_ gestureRecognizer:UITapGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            showSecurityLocationParametar()
        }
    }
    
    func buttonPressed (_ gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        switch securities[tag].securityName! {
        case "Away":
            let location = gestureRecognizer.location(in: securityCollectionView)
            if let index = securityCollectionView.indexPathForItem(at: location){
                let cell = securityCollectionView.cellForItem(at: index)
                let defaults = Foundation.UserDefaults.standard
                if let securityMode = defaults.value(forKey: UserDefaults.Security.SecurityMode) as? String {
                    if securityMode != SecurityControlMode.Disarm{
                        showSecurityInformation(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y))
                    }else{
                        showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])
                    }
                }
            }
        case "Night":
            let location = gestureRecognizer.location(in: securityCollectionView)
            if let index = securityCollectionView.indexPathForItem(at: location){
                let cell = securityCollectionView.cellForItem(at: index)
                
                let defaults = Foundation.UserDefaults.standard
                if let securityMode = defaults.value(forKey: UserDefaults.Security.SecurityMode) as? String {
                    if securityMode != SecurityControlMode.Disarm{
                        showSecurityInformation(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y))
                    }else{
                        showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])
                    }
                }
            }
        case "Day":
            let location = gestureRecognizer.location(in: securityCollectionView)
            if let index = securityCollectionView.indexPathForItem(at: location){
                let cell = securityCollectionView.cellForItem(at: index)
                let defaults = Foundation.UserDefaults.standard
                if let securityMode = defaults.value(forKey: UserDefaults.Security.SecurityMode) as? String {
                    if securityMode != SecurityControlMode.Disarm{
                        showSecurityInformation(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y))
                    }else{
                        showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])
                    }
                }
            }
        case "Vacation":
            let location = gestureRecognizer.location(in: securityCollectionView)
            if let index = securityCollectionView.indexPathForItem(at: location){
                let cell = securityCollectionView.cellForItem(at: index)
                let defaults = Foundation.UserDefaults.standard
                if let securityMode = defaults.value(forKey: UserDefaults.Security.SecurityMode) as? String {
                    if securityMode != SecurityControlMode.Disarm{
                        showSecurityInformation(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y))
                    }else{
                        showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])

                    }
                }
            }
        case "Disarm":
            let location = gestureRecognizer.location(in: securityCollectionView)
            if let index = securityCollectionView.indexPathForItem(at: location){
                let cell = securityCollectionView.cellForItem(at: index)
                
                showSecurityPad(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
            }
        case "Panic":
            let location = gestureRecognizer.location(in: securityCollectionView)
            if let index = securityCollectionView.indexPathForItem(at: location){
                let cell = securityCollectionView.cellForItem(at: index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].securityDescription!, security: securities[tag])
            }
        default: break
        }
    }
    
    func startBlinking(_ notification: Notification){
        securityCollectionView.isScrollEnabled = false
    }
    func stopBlinking(_ notification: Notification){
        securityCollectionView.isScrollEnabled = true
    }

    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.security)
    }
}

// Parametar from filter and relaod data
extension SecurityViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.security)
        updateSubtitle()
        refreshSecurity()
        TimerForFilter.shared.counterSecurity = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.security)
        TimerForFilter.shared.startTimer(type: Menu.security)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension SecurityViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            securityCollectionView.isUserInteractionEnabled = true
        } else {
            securityCollectionView.isUserInteractionEnabled = false
        }
    }
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            securityCollectionView.isUserInteractionEnabled = true
        } else {
            securityCollectionView.isUserInteractionEnabled = false
        }
    }
}

extension SecurityViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) as? SecurityLocationCell) != nil{
            
            filterParametar.location = location[indexPath.row].name!
            filterParametar.locationObjectId = location[indexPath.row].objectID.uriRepresentation().absoluteString
            DatabaseFilterController.shared.saveFilter(filterParametar, menu: Menu.security)
            scrollView.setFilterItem(Menu.security)
            updateSubtitle()
            refreshSecurity()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {        return collectionViewCellSize
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
        if securityItem == SecurityItem.security{
            return securities.count
        }else{
            return location.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if securityItem == SecurityItem.security{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SecurityCollectionCell
            var name:String = ""
            if filterParametar.location == "All" {
                name += securities[(indexPath as NSIndexPath).row].location!.name! + " "
            }
            name += securities[(indexPath as NSIndexPath).row].securityName!
            
            let securityName = securities[(indexPath as NSIndexPath).row].securityName!
            var securityBtnTitle = ""
            if securityName == SecurityControlMode.Disarm{
                securityBtnTitle = "ENTER CODE"
            }else if securityName == SecurityControlMode.Panic{
                securityBtnTitle = "TRIGGER"
            }else{
                securityBtnTitle = "ARM"
            }
            cell.setCell(name, securityName: securityName, securityBtnTitle: securityBtnTitle)
            
            cell.securityTitle.tag = (indexPath as NSIndexPath).row
            cell.securityButton.tag = (indexPath as NSIndexPath).row
            
            let openParametar:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SecurityViewController.openParametar(_:)))
            openParametar.minimumPressDuration = 0.5
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.buttonPressed(_:)))
            
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecurityLocationCell", for: indexPath) as! SecurityLocationCell
            cell.setItem(location[(indexPath as NSIndexPath).row])
            
            let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SecurityViewController.openMode(_:)))
            longPress.minimumPressDuration = 0.5
            
            cell.loactionTitleLabel.tag = (indexPath as NSIndexPath).row
            cell.loactionTitleLabel.isUserInteractionEnabled = true
            cell.loactionTitleLabel.addGestureRecognizer(longPress)
            
            return cell
        }
    }
}
