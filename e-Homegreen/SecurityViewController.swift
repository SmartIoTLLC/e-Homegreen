//
//  SecurityViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SecurityViewController: UIViewController, SWRevealViewControllerDelegate {
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "SecurityCell"
    var pullDown = PullDownView()
    
    var sidebarMenuOpen : Bool!
    var securities:[Security] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var lblAlarmState: UILabel!
    
    @IBOutlet weak var securityCollectionView: UICollectionView!
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        
        // Do any additional setup after loading the view.
        
        refreshSecurity()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let alarmState = defaults.valueForKey(UserDefaults.Security.AlarmState)
        lblAlarmState.text = "Alarm state: \(alarmState!)"
        
        refreshSecurityAlarmStateAndSecurityMode()
        
    }
    
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
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SecurityViewController.refreshSecurity), name: NotificationKey.RefreshSecurity, object: nil)
        refreshSecurity()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshSecurity, object: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    override func viewWillLayoutSubviews() {
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        securityCollectionView.reloadData()
    }
    
    func reorganizeSecurityArray () {
        var tempSecurities:[Security] = securities
        for security in securities {
            if security.name == "Away" {
                tempSecurities[0] = security
            }
            if security.name == "Night" {
                tempSecurities[1] = security
            }
            if security.name == "Day" {
                tempSecurities[2] = security
            }
            if security.name == "Vacation" {
                tempSecurities[3] = security
            }
            if security.name == "Disarm" {
                tempSecurities[4] = security
            }
            if security.name == "Panic" {
                tempSecurities[5] = security
            }
        }
        securities = tempSecurities
    }
    
    func refreshSecurity() {
        updateSecurityList()
        let defaults = NSUserDefaults.standardUserDefaults()
        let alarmState = defaults.valueForKey(UserDefaults.Security.AlarmState)
        lblAlarmState.text = "Alarm state: \(alarmState!)"
        securityCollectionView.reloadData()
    }
    
    func refreshSecurityAlarmStateAndSecurityMode () {
        let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
        if let gateway = securities[0].gateway {
            SendingHandler.sendCommand(byteArray: Function.getCurrentAlarmState(address), gateway: gateway)
            SendingHandler.sendCommand(byteArray: Function.getCurrentSecurityMode(address), gateway: gateway)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSecurityList () {
        let fetchRequest = NSFetchRequest(entityName: "Security")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Security]
            securities = fetResults!
            reorganizeSecurityArray()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func openParametar (gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
        switch securities[tag].name {
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
        switch securities[tag].name {
        case "Away":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].modeExplanation, security: securities[tag])
            }
        case "Night":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].modeExplanation, security: securities[tag])
            }
        case "Day":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].modeExplanation, security: securities[tag])
            }
        case "Vacation":
            let location = gestureRecognizer.locationInView(securityCollectionView)
            if let index = securityCollectionView.indexPathForItemAtPoint(location){
                let cell = securityCollectionView.cellForItemAtIndexPath(index)
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].modeExplanation, security: securities[tag])
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
                showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].modeExplanation, security: securities[tag])
            }
        default: break
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
        cell.securityTitle.text = "\(securities[indexPath.row].name)"
        cell.securityTitle.tag = indexPath.row
        cell.securityTitle.userInteractionEnabled = true
        let openParametar:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "openParametar:")
        openParametar.minimumPressDuration = 0.5
        cell.securityImageView.image = UIImage(named: "maaa")
        cell.securityButton.setTitle("ARG", forState: UIControlState.Normal)
        switch securities[indexPath.row].name {
        case "Away":
            cell.setImageForSecuirity(UIImage(named: "inactiveaway")!)
            cell.securityButton.tag = indexPath.row
            cell.securityImageView.image = UIImage(named: "inactiveaway")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Night":
            cell.setImageForSecuirity(UIImage(named: "inactivenight")!)
            cell.securityImageView.image = UIImage(named: "inactivenight")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Day":
            cell.setImageForSecuirity(UIImage(named: "inactiveday")!)
            cell.securityImageView.image = UIImage(named: "inactiveday")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Vacation":
            cell.setImageForSecuirity(UIImage(named: "inactivevacation")!)
            cell.securityImageView.image = UIImage(named: "inactivevacation")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Disarm":
            cell.setImageForSecuirity(UIImage(named: "inactivedisarm")!)
            cell.securityImageView.image = UIImage(named: "inactivedisarm")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ENTER CODE", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
        case "Panic":
            cell.setImageForSecuirity(UIImage(named: "inactivepanic")!)
            cell.securityImageView.image = UIImage(named: "inactivepanic")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("TRIGGER", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        default: break
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        if let securityMode = defaults.valueForKey(UserDefaults.Security.SecurityMode) as? String {
            if securities[indexPath.row].name == securityMode {
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
        if securities[indexPath.row].name == "Panic" {
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
