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
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "SecurityCell"
    
    var sidebarMenuOpen : Bool!
    var securities:[Security] = []

    var scrollView = FilterPullDown()
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRectMake(0, 0, CGFloat.max, 44))
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Security)
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var lblAlarmState: UILabel!
    
    @IBOutlet weak var securityCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)

        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Security)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Security", subtitle: "All, All, All")
        
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let alarmState = defaults.valueForKey(UserDefaults.Security.AlarmState)
//        lblAlarmState.text = "Alarm state: \(alarmState!)"
        
//        refreshSecurityAlarmStateAndSecurityMode()
        
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
        refreshSecurity()
    }
    
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        securityCollectionView.reloadData()
        
    }
    
    override func nameAndId(name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func defaultFilter(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            scrollView.setDefaultFilterItem(Menu.Security)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    func updateSubtitle(location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Security", subtitle: location + ", " + level + ", " + zone)
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
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshSecurity, object: nil)
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
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let alarmState = defaults.valueForKey(UserDefaults.Security.AlarmState)
//        lblAlarmState.text = "Alarm state: \(alarmState!)"
        securityCollectionView.reloadData()
    }
    
    func refreshSecurityAlarmStateAndSecurityMode () {
        let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
        if let id = securities[0].gatewayId{
            if let gateway = DatabaseGatewayController.shared.getGatewayByid(id)  {
                SendingHandler.sendCommand(byteArray: Function.getCurrentAlarmState(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: Function.getCurrentSecurityMode(address), gateway: gateway)
            }
        }
        
    }
    
    func updateSecurityList () {
        
        securities = DatabaseSecurityController.shared.getSecurity(filterParametar)

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
    
    func buttonPressed (gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        switch securities[tag].securityName! {
        case "Away":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].securityDescription!, security: securities[tag])
            }
        case "Night":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].securityDescription!, security: securities[tag])
            }
        case "Day":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].securityDescription!, security: securities[tag])
            }
        case "Vacation":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].securityDescription!, security: securities[tag])
            }
        case "Disarm":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
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
    
}

// Parametar from filter and relaod data
extension SecurityViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Security)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Security)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.Security)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.Security)
        refreshSecurity()
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
        return securities.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SecurityCollectionCell
        var name:String = ""
        if filterParametar.location == "All" {
            name += securities[indexPath.row].location!.name! + " "
        }
        name += securities[indexPath.row].securityName!
        cell.securityTitle.text = name
        
        cell.securityTitle.tag = indexPath.row
        cell.securityTitle.userInteractionEnabled = true
        let openParametar:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SecurityViewController.openParametar(_:)))
        openParametar.minimumPressDuration = 0.5
        cell.securityImageView.image = UIImage(named: "maaa")
        cell.securityButton.setTitle("ARG", forState: UIControlState.Normal)
        switch securities[indexPath.row].securityName! {
        case "Away":
            cell.setImageForSecuirity(UIImage(named: "inactiveaway")!)
            cell.securityButton.tag = indexPath.row
            cell.securityImageView.image = UIImage(named: "inactiveaway")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.buttonPressed(_:)))
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Night":
            cell.setImageForSecuirity(UIImage(named: "inactivenight")!)
            cell.securityImageView.image = UIImage(named: "inactivenight")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.buttonPressed(_:)))
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Day":
            cell.setImageForSecuirity(UIImage(named: "inactiveday")!)
            cell.securityImageView.image = UIImage(named: "inactiveday")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.buttonPressed(_:)))
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Vacation":
            cell.setImageForSecuirity(UIImage(named: "inactivevacation")!)
            cell.securityImageView.image = UIImage(named: "inactivevacation")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.buttonPressed(_:)))
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Disarm":
            cell.setImageForSecuirity(UIImage(named: "inactivedisarm")!)
            cell.securityImageView.image = UIImage(named: "inactivedisarm")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ENTER CODE", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.buttonPressed(_:)))
            cell.securityButton.addGestureRecognizer(tap)
        case "Panic":
            cell.setImageForSecuirity(UIImage(named: "inactivepanic")!)
            cell.securityImageView.image = UIImage(named: "inactivepanic")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("TRIGGER", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecurityViewController.buttonPressed(_:)))
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        default: break
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        if let securityMode = defaults.valueForKey(UserDefaults.Security.SecurityMode) as? String {
            if securities[indexPath.row].securityName == securityMode {
                switch securityMode {
                case "Away":
                    cell.setImageForSecuirity(UIImage(named: "away")!)
                    cell.securityImageView.image = UIImage(named: "away")
                case "Night":
                    cell.setImageForSecuirity(UIImage(named: "night")!)
                    cell.securityImageView.image = UIImage(named: "night")
                case "Day":
                    cell.setImageForSecuirity(UIImage(named: "day")!)
                    cell.securityImageView.image = UIImage(named: "day")
                case "Vacation":
                    cell.setImageForSecuirity(UIImage(named: "vacation")!)
                    cell.securityImageView.image = UIImage(named: "vacation")
                case "Disarm":
                    cell.setImageForSecuirity(UIImage(named: "disarm")!)
                    cell.securityImageView.image = UIImage(named: "disarm")
                default: break
                }
            }
        }
        if securities[indexPath.row].securityName == "Panic" {
            if defaults.boolForKey(UserDefaults.Security.IsPanic) {
                cell.setImageForSecuirity(UIImage(named: "panic")!)
                cell.securityImageView.image = UIImage(named: "panic")
            } else {
                cell.setImageForSecuirity(UIImage(named: "inactivepanic")!)
                cell.securityImageView.image = UIImage(named: "inactivepanic")
            }
        }
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}
