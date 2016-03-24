//
//  UserSettingsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/24/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning{
    
    var user:User!
    
    var isPresenting:Bool = false
    
    var settingArray:[SettingsItem]!
    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    var hourRefresh:Int = 0
    var minRefresh:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        settingArray = [.MainMenu, .Interfaces, .RefreshStatusDelay, .OpenLastScreen, .Broadcast, .RefreshConnection]
        
        if let hour = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayHours) as? Int {
            hourRefresh = hour
        }
        
        if let min = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayMinutes) as? Int {
            minRefresh = min
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("KeyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("KeyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        settingsTableView.delaysContentTouches = false
        
        for currentView in settingsTableView.subviews {
            if let view = currentView as? UIScrollView {
                (currentView as! UIScrollView).delaysContentTouches = false
            }
        }

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settingArray.count
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRectMake(0, 0, 1024, 3))
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView:UIView = UIView(frame: CGRectMake(0, 0, 1024, 3))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 { return 90 }
        if settingArray[indexPath.section] == SettingsItem.Broadcast {
            if isMore {
                return 192
            }
        }
        return 44
    }
    
    func btnAddHourPressed(sender:UIButton){
        if sender.tag == 1{
            if hourRefresh < 23 {
                hourRefresh++
            }else{
                hourRefresh = 0
            }
            settingsTableView.reloadData()
            NSUserDefaults.standardUserDefaults().setValue(hourRefresh, forKey: UserDefaults.RefreshDelayHours)
            NSUserDefaults.standardUserDefaults().synchronize()
        }else{
            if minRefresh < 59 {
                minRefresh++
            }else{
                minRefresh = 0
            }
            settingsTableView.reloadData()
            NSUserDefaults.standardUserDefaults().setValue(minRefresh, forKey: UserDefaults.RefreshDelayMinutes)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    func btnDecHourPressed(sender:UIButton){
        if sender.tag == 1{
            if hourRefresh > 0 {
                hourRefresh--
            }else{
                hourRefresh = 23
            }
            settingsTableView.reloadData()
            NSUserDefaults.standardUserDefaults().setValue(hourRefresh, forKey: UserDefaults.RefreshDelayHours)
            NSUserDefaults.standardUserDefaults().synchronize()
        }else{
            if minRefresh > 0 {
                minRefresh--
            }else{
                minRefresh = 59
            }
            settingsTableView.reloadData()
            NSUserDefaults.standardUserDefaults().setValue(minRefresh, forKey: UserDefaults.RefreshDelayMinutes)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if settingArray[indexPath.section] == SettingsItem.MainMenu || settingArray[indexPath.section] == SettingsItem.Interfaces || settingArray[indexPath.section] == SettingsItem.Surveillance || settingArray[indexPath.section] == SettingsItem.Security || settingArray[indexPath.section] == SettingsItem.IBeacon {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as! SettinsTableViewCell
            cell.settingsButton.tag = indexPath.section
            cell.settingsButton.addTarget(self, action: "didTouchSettingButton:", forControlEvents: .TouchUpInside)
            cell.settingsButton.setTitle(settingArray[indexPath.section].description, forState: .Normal)
            cell.backgroundColor = UIColor.clearColor()
            cell.layer.cornerRadius = 5
            
            return cell
        } else if settingArray[indexPath.section] == SettingsItem.RefreshStatusDelay {
            let cell = tableView.dequeueReusableCellWithIdentifier("delayRefreshStatus") as! SettingsRefreshDelayTableViewCell
            cell.layer.cornerRadius = 5
            
            cell.btnAddHourPressed.addTarget(self, action: "btnAddHourPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnAddHourPressed.tag = 1
            cell.btnDecHourPressed.addTarget(self, action: "btnDecHourPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnDecHourPressed.tag = 1
            cell.hourLabel.text = "\(hourRefresh)"
            
            cell.backgroundColor = UIColor.clearColor()
            
            cell.btnAddMinPressed.addTarget(self, action: "btnAddHourPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnDecMinPressed.addTarget(self, action: "btnDecHourPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.minLabel.text = "\(minRefresh)"
            
            return cell
        } else if settingArray[indexPath.section] == SettingsItem.OpenLastScreen {
            let cell = tableView.dequeueReusableCellWithIdentifier("openLastScreen") as! SettingsLastScreenTableViewCell
            cell.openLastScreen.tag = indexPath.section
            cell.backgroundColor = UIColor.clearColor()
            cell.openLastScreen.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
            if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.OpenLastScreen) {
                cell.openLastScreen.on = true
            }else{
                cell.openLastScreen.on = false
            }
            
            cell.backgroundColor = UIColor.clearColor()
            cell.layer.cornerRadius = 5
            return cell
        } else if settingArray[indexPath.section] == SettingsItem.Broadcast {
            let cell = tableView.dequeueReusableCellWithIdentifier("idBroadcastCurrentAppTimeAndDate") as! BroadcastTimeAndDateTVC
            cell.setBroadcast()
            cell.txtIp.delegate = self
            cell.txtPort.delegate = self
            cell.txtH.delegate = self
            cell.txtM.delegate = self
            cell.backgroundColor = UIColor.clearColor()
            cell.layer.cornerRadius = 5
            return cell
        } else if settingArray[indexPath.section] == SettingsItem.RefreshConnection {
            let cell = tableView.dequeueReusableCellWithIdentifier("idRefreshGatewayTimerCell") as! SettingsRefreshConnectionEvery
            cell.setRefreshCell()
            cell.txtMinutesField.delegate = self
            cell.backgroundColor = UIColor.clearColor()
            cell.layer.cornerRadius = 5
            return cell
        } else {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
            cell.textLabel?.text = "dads"
            return cell
        }
    }
    
    func changeValue(sender:UISwitch){
        if sender.on == true {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.OpenLastScreen)
            
        }else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey:UserDefaults.OpenLastScreen)
            
        }
    }
    func didTouchSettingButton (sender:AnyObject) {
        if let view = sender as? UIButton {
            let tag = view.tag
            self.settingsTableView.userInteractionEnabled = false
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: false)
            if tag == 0 {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("menuSettings", sender: self)
                })
            }
            if tag == 1 {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("connection", sender: self)
                })
            }
            if tag == 4 {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("surveillanceSettings", sender: self)
                })
            }
            if tag == 5 {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("securitySettings", sender: self)
                })
            }
            if tag == 6 {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("iBeaconSettings", sender: self)
                })
            }
            
        }
    }
    
    func update(){
        self.settingsTableView.userInteractionEnabled = true
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "connection"{
            if let destinationVC = segue.destinationViewController as? ConnectionsViewController{
                destinationVC.modalPresentationStyle = UIModalPresentationStyle.Custom
                destinationVC.user = user
            }
        }
    }
    var isMore = false
    @IBAction func btnMore(sender: AnyObject) {
        isMore = !isMore
        settingsTableView.reloadData()
    }
    @IBAction func broadcastTimeAndDateFromPhone(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).sendDataToBroadcastTimeAndDate()
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        if let cell = textField.superview?.superview as? BroadcastTimeAndDateTVC {
            settingsTableView.scrollToRowAtIndexPath(settingsTableView.indexPathForCell(cell)!, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
        
        if let cell = textField.superview?.superview as? SettingsRefreshConnectionEvery {
            settingsTableView.scrollToRowAtIndexPath(settingsTableView.indexPathForCell(cell)!, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }
    func KeyboardWillShow(notification: NSNotification){
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if let endFrame = endFrame{
//                self.tableBottomConstraint.constant = endFrame.size.height + 5
            }
            UIView.animateWithDuration(duration,
                                       delay: NSTimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    func KeyboardWillHide(notification: NSNotification){
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
//            self.tableBottomConstraint.constant = 0
            
            UIView.animateWithDuration(duration,
                                       delay: NSTimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let cell = textField.superview?.superview as? BroadcastTimeAndDateTVC {
            cell.saveData()
        }
        
        if let cell = textField.superview?.superview as? SettingsRefreshConnectionEvery {
            cell.saveData()
        }
        return true
    }

    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
//        self.performSegueWithIdentifier("segueUnwind", sender: self)
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.center.x += containerView!.bounds.size.width
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x -= containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x += containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }





}
