//
//  SecurityViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SecurityViewController: CommonViewController {
    
    private var sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "SecurityCell"
    var pullDown = PullDownView()
    
    var securities:[Security] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var lblAlarmState: UILabel!
    
    @IBOutlet weak var securityCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 118, height: 144)
        }
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        //        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        
        // Do any additional setup after loading the view.
        
        refreshSecurity()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let alarmState = defaults.valueForKey(UserDefaults.Security.AlarmState)
        lblAlarmState.text = "Alarm state: \(alarmState!)"
        
        refreshSecurityAlarmStateAndSecurityMode()
        
    }
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSecurity", name: NotificationKey.RefreshSecurity, object: nil)
        refreshSecurity()
    }
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshSecurity, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.width == 568{
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            }else if self.view.frame.size.width == 667{
                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            }
        }else{
            if self.view.frame.size.width == 320{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }else if self.view.frame.size.width == 375{
                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }
        }
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
            print(securities.count)
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
            cell.securityButton.tag = indexPath.row
            cell.securityImageView.image = UIImage(named: "inactiveaway")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Night":
            cell.securityImageView.image = UIImage(named: "inactivenight")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Day":
            cell.securityImageView.image = UIImage(named: "inactiveday")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Vacation":
            cell.securityImageView.image = UIImage(named: "inactivevacation")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
            cell.securityTitle.addGestureRecognizer(openParametar)
        case "Disarm":
            cell.securityImageView.image = UIImage(named: "inactivedisarm")
            cell.securityButton.tag = indexPath.row
            cell.securityButton.setTitle("ENTER CODE", forState: UIControlState.Normal)
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
        case "Panic":
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
                    cell.securityImageView.image = UIImage(named: "away")
                case "Night":
                    cell.securityImageView.image = UIImage(named: "night")
                case "Day":
                    cell.securityImageView.image = UIImage(named: "day")
                case "Vacation":
                    cell.securityImageView.image = UIImage(named: "vacation")
                case "Disarm":
                    cell.securityImageView.image = UIImage(named: "disarm")
                default: break
                }
            }
        }
        if securities[indexPath.row].name == "Panic" {
            if defaults.boolForKey(UserDefaults.Security.IsPanic) {
                cell.securityImageView.image = UIImage(named: "panic")
            } else {
                cell.securityImageView.image = UIImage(named: "inactivepanic")
            }
        }
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}
class SecurityCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var securityTitle: UILabel!
    @IBOutlet weak var securityImageView: UIImageView!
    @IBOutlet weak var securityButton: UIButton!
    
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGrayColor().setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
    }
    
    
}