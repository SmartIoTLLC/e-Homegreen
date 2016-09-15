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
        case Location, Security
    }
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "SecurityCell"
    
    var sidebarMenuOpen : Bool!
    var securities:[Security] = []
    var location:[Location] = []
    
    var scrollView = FilterPullDown()
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRectMake(0, 0, CGFloat.max, 44))
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Security)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var lblAlarmState: UILabel!
    @IBOutlet weak var securityCollectionView: UICollectionView!
    @IBOutlet weak var refreshBtn: UIButton!
    
    var securityItem:SecurityItem = SecurityItem.Location
    
    @IBAction func fullScreen(sender: AnyObject) {
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
    @IBAction func refresh(sender: AnyObject) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 1
        rotateAnimation.toValue = CGFloat(M_PI)
        refreshBtn.layer.addAnimation(rotateAnimation, forKey: nil)
        refreshSecurityAlarmStateAndSecurityMode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.redColor())
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Security", subtitle: "All All All")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let alarmState = defaults.valueForKey(UserDefaults.Security.AlarmState){
            lblAlarmState.text = "Alarm state: \(alarmState)"
        }
        
        refreshSecurityAlarmStateAndSecurityMode()
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SecurityViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.Security)
        
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
        
        refreshSecurity()
        
        changeFullScreeenImage()
        
    }
    override func viewDidAppear(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SecurityViewController.refreshSecurity), name: NotificationKey.RefreshSecurity, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SecurityViewController.startBlinking(_:)), name: NotificationKey.Security.ControlModeStartBlinking, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SecurityViewController.stopBlinking(_:)), name: NotificationKey.Security.ControlModeStopBlinking, object: nil)
        
    }
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        securityCollectionView.reloadData()
        
    }
    override func nameAndId(name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshSecurity, object: nil)
    }
    
    func defaultFilter(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            scrollView.setDefaultFilterItem(Menu.Security)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func updateSubtitle(){
        headerTitleSubtitleView.setTitleAndSubtitle("Security", subtitle: filterParametar.location + " " + filterParametar.levelName + " " + filterParametar.zoneName)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func changeFullScreeenImage(){
        if UIApplication.sharedApplication().statusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
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
                    SendingHandler.sendCommand(byteArray: Function.getCurrentAlarmState(address), gateway: gateway)
                    SendingHandler.sendCommand(byteArray: Function.getCurrentSecurityMode(address), gateway: gateway)
                }
            }
        }
    }
    
    func updateSecurityList () {
        if filterParametar.location == "All"{
            securityItem = SecurityItem.Location
            location = FilterController.shared.getLocationForFilterByUser()
        }else{
            securityItem = SecurityItem.Security
            securities = DatabaseSecurityController.shared.getSecurity(filterParametar)
        }
    }
    
    func openParametar (gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            switch securities[tag].securityName! {
            case "Away":
                let location = gestureRecognizer.locationInView(securityCollectionView)
                if let index = securityCollectionView.indexPathForItemAtPoint(location){
                    let cell = securityCollectionView.cellForItemAtIndexPath(index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Night":
                let location = gestureRecognizer.locationInView(securityCollectionView)
                if let index = securityCollectionView.indexPathForItemAtPoint(location){
                    let cell = securityCollectionView.cellForItemAtIndexPath(index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Day":
                let location = gestureRecognizer.locationInView(securityCollectionView)
                if let index = securityCollectionView.indexPathForItemAtPoint(location){
                    let cell = securityCollectionView.cellForItemAtIndexPath(index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Vacation":
                let location = gestureRecognizer.locationInView(securityCollectionView)
                if let index = securityCollectionView.indexPathForItemAtPoint(location){
                    let cell = securityCollectionView.cellForItemAtIndexPath(index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Disarm":
                let location = gestureRecognizer.locationInView(securityCollectionView)
                if let index = securityCollectionView.indexPathForItemAtPoint(location){
                    let cell = securityCollectionView.cellForItemAtIndexPath(index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            case "Panic":
                let location = gestureRecognizer.locationInView(securityCollectionView)
                if let index = securityCollectionView.indexPathForItemAtPoint(location){
                    let cell = securityCollectionView.cellForItemAtIndexPath(index)
                    showSecurityParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
                }
            default: break
            }
        }
    }
    
    func openMode(gestureRecognizer:UITapGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            showSecurityLocationParametar()
        }
    }
    
    func buttonPressed (gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        switch securities[tag].securityName! {
        case "Away":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                let defaults = NSUserDefaults.standardUserDefaults()
                if let securityMode = defaults.valueForKey(UserDefaults.Security.SecurityMode) as? String {
                    if securityMode != SecurityControlMode.Disarm{
                        showSecurityInformation(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y))
                    }else{
                        showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])
                    }
                }
            }
        case "Night":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if let securityMode = defaults.valueForKey(UserDefaults.Security.SecurityMode) as? String {
                    if securityMode != SecurityControlMode.Disarm{
                        showSecurityInformation(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y))
                    }else{
                        showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])
                    }
                }
            }
        case "Day":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                let defaults = NSUserDefaults.standardUserDefaults()
                if let securityMode = defaults.valueForKey(UserDefaults.Security.SecurityMode) as? String {
                    if securityMode != SecurityControlMode.Disarm{
                        showSecurityInformation(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y))
                    }else{
                        showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])
                    }
                }
            }
        case "Vacation":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                let defaults = NSUserDefaults.standardUserDefaults()
                if let securityMode = defaults.valueForKey(UserDefaults.Security.SecurityMode) as? String {
                    if securityMode != SecurityControlMode.Disarm{
                        showSecurityInformation(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y))
                    }else{
                        showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text: securities[tag].securityDescription!, security: securities[tag])

                    }
                }
            }
        case "Disarm":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                let defaults = NSUserDefaults.standardUserDefaults()
                
                showSecurityPad(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), security: securities[tag])
            }
        case "Panic":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].securityDescription!, security: securities[tag])
            }
        default: break
        }
    }
    
    func startBlinking(notification: NSNotification){
        securityCollectionView.scrollEnabled = false
    }
    func stopBlinking(notification: NSNotification){
        securityCollectionView.scrollEnabled = true
    }

}

// Parametar from filter and relaod data
extension SecurityViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        filterParametar = filterItem
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.Security)
        updateSubtitle()
        refreshSecurity()
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension SecurityViewController: SWRevealViewControllerDelegate {
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            securityCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            securityCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            securityCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            securityCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }
}

extension SecurityViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SecurityLocationCell{
            
            filterParametar.location = location[indexPath.row].name!
            filterParametar.locationObjectId = location[indexPath.row].objectID.URIRepresentation().absoluteString
            DatabaseFilterController.shared.saveFilter(filterParametar, menu: Menu.Security)
            scrollView.setFilterItem(Menu.Security)
            updateSubtitle()
            refreshSecurity()
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {        return collectionViewCellSize
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
}

extension SecurityViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if securityItem == SecurityItem.Security{
            return securities.count
        }else{
            return location.count
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if securityItem == SecurityItem.Security{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SecurityCollectionCell
            var name:String = ""
            if filterParametar.location == "All" {
                name += securities[indexPath.row].location!.name! + " "
            }
            name += securities[indexPath.row].securityName!
            
            let securityName = securities[indexPath.row].securityName!
            var securityBtnTitle = ""
            if securityName == SecurityControlMode.Disarm{
                securityBtnTitle = "ENTER CODE"
            }else if securityName == SecurityControlMode.Panic{
                securityBtnTitle = "TRIGGER"
            }else{
                securityBtnTitle = "ARM"
            }
            cell.setCell(name, securityName: securityName, securityBtnTitle: securityBtnTitle)
            
            cell.securityTitle.tag = indexPath.row
            cell.securityButton.tag = indexPath.row
            
            let openParametar:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SecurityViewController.openParametar(_:)))
            openParametar.minimumPressDuration = 0.5
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.buttonPressed(_:)))
            
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(SecurityLocationCell), forIndexPath: indexPath) as! SecurityLocationCell
            cell.setItem(location[indexPath.row])
            
            let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SecurityViewController.openMode(_:)))
            longPress.minimumPressDuration = 0.5
            
            cell.loactionTitleLabel.tag = indexPath.row
            cell.loactionTitleLabel.userInteractionEnabled = true
            cell.loactionTitleLabel.addGestureRecognizer(longPress)
            
            return cell
        }
    }
}
