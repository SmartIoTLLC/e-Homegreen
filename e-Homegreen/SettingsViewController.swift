//
//  SettingsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

enum SettingsItem{
    case MainMenu, Interfaces, RefreshStatusDelay, OpenLastScreen, Surveillance, Security, IBeacon, Broadcast, RefreshConnection
    var description:String{
        switch self{
            case MainMenu: return "Main Menu"
            case Interfaces: return "Locations"
            case RefreshStatusDelay: return "Refresh Status Delay"
            case OpenLastScreen: return "Open Last Screen"
            case Surveillance: return "Surveillance"
            case Security: return "Security"
            case IBeacon: return "IBeacon"
            case Broadcast: return "Broadcast"
            case RefreshConnection: return "Refresh Connection"
        }
    }
    
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate {

    var settingArray:[SettingsItem]!
    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    var hourRefresh:Int = 0
    var minRefresh:Int = 0
    
//    @IBOutlet weak var centarY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        settingArray = [.MainMenu, .Interfaces, .RefreshStatusDelay, .OpenLastScreen, .Broadcast, .RefreshConnection]
        
        if let hour = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayHours) as? Int {
            hourRefresh = hour
        }
        
        if let min = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayMinutes) as? Int {
            minRefresh = min
        }
        
        
        // This is aded because highlighted was calling itself fast and late because of this property of UIScrollView
        settingsTableView.delaysContentTouches = false
        // Not a permanent solution as Apple can deside to change view hierarchy inf the future
        for currentView in settingsTableView.subviews {
            if let view = currentView as? UIScrollView {
                (currentView as! UIScrollView).delaysContentTouches = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//                dispatch_async(dispatch_get_main_queue(),{
//                    self.performSegueWithIdentifier("menuSettings", sender: self)
//                })
//                if (UIApplication.sharedApplication().delegate as! AppDelegate).changeDB {
//                    (UIApplication.sharedApplication().delegate as! AppDelegate).changeDB = false
//                } else {
//                    (UIApplication.sharedApplication().delegate as! AppDelegate).changeDB = true
//                }
//                (UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinatorNew("e_homegreen.sqlite")
//                (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContextNew()
                (UIApplication.sharedApplication().delegate as! AppDelegate).changeCoreDataStackPreferences("")
            }
            if tag == 1 {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("connectionSettings", sender: self)
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
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }
    func update(){
        self.settingsTableView.userInteractionEnabled = true
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController 
        destinationVC.modalPresentationStyle = UIModalPresentationStyle.Custom
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
                self.tableBottomConstraint.constant = endFrame.size.height + 5
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
            
            self.tableBottomConstraint.constant = 0
            
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
}

class SettinsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingsButton: CustomGradientButton!
}

class SettingsRefreshDelayTableViewCell: UITableViewCell {
//    @IBOutlet weak var txtDelayResfreshStatus: UITextField!
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var btnAddHourPressed: UIButton!
    @IBOutlet weak var btnDecHourPressed: UIButton!
    
    @IBOutlet weak var btnAddMinPressed: UIButton!
    @IBOutlet weak var btnDecMinPressed: UIButton!

}

class SettingsLastScreenTableViewCell: UITableViewCell {
    @IBOutlet weak var openLastScreen: UISwitch!
    
}
class SettingsRefreshConnectionEvery: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var txtMinutesField: UITextField!
    
    func setRefreshCell() {
        self.txtMinutesField.text = "\(RefreshConnectionsPreference.getMinutes())"
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        saveData()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        saveData()
        return true
    }
    
    func saveData() {
        self.txtMinutesField.resignFirstResponder()
        if let minutes = Int(self.txtMinutesField.text!) {
            RefreshConnectionsPreference.setMinutes(minutes)
        }
        self.txtMinutesField.text = "\(RefreshConnectionsPreference.getMinutes())"
    }
}
class BroadcastTimeAndDateTVC: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var txtIp: UITextField!
    @IBOutlet weak var txtPort: UITextField!
    @IBOutlet weak var txtH: UITextField!
    @IBOutlet weak var txtM: UITextField!
    @IBOutlet weak var isBroadcastOnStartUp: UISwitch!
    @IBOutlet weak var isBroadcastEvery: UISwitch!
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        saveData()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        saveData()
        return true
    }
    
    func setBroadcast () {
        self.txtIp.text = BroadcastPreference.getBroadcastIp()
        self.txtPort.text = "\(BroadcastPreference.getBroadcastPort())"
        self.txtH.text = "\(BroadcastPreference.getBroadcastHour())"
        self.txtM.text = "\(BroadcastPreference.getBroadcastMin())"
        self.isBroadcastOnStartUp.on = BroadcastPreference.getIsBroadcastOnStartUp()
        self.isBroadcastEvery.on = BroadcastPreference.getIsBroadcastOnEvery()
    }
    func saveData() {
        self.txtIp.resignFirstResponder()
        self.txtPort.resignFirstResponder()
        self.txtH.resignFirstResponder()
        self.txtM.resignFirstResponder()
        BroadcastPreference.setBroadcastIp(self.txtIp.text!)
        if let port = Int(self.txtPort.text!) {
            if port <= 65535 {
                BroadcastPreference.setBroadcastPort(port)
            }
        }
        if let hour = Int(self.txtH.text!) {
            if hour <= 23 {
                BroadcastPreference.setBroadcastHour(hour)
            }
        }
        if let min = Int(self.txtM.text!) {
            if min <= 59 {
                BroadcastPreference.setBroadcastMin(min)
            }
        }
        self.txtIp.text = BroadcastPreference.getBroadcastIp()
        self.txtPort.text = "\(BroadcastPreference.getBroadcastPort())"
        self.txtH.text = "\(BroadcastPreference.getBroadcastHour())"
        self.txtM.text = "\(BroadcastPreference.getBroadcastMin())"
        
    }
    @IBAction func isBroadcastOnStartUp(sender: AnyObject) {
        if let swtitchIs = sender as? UISwitch {
            BroadcastPreference.setIsBroadcastOnStartUp(swtitchIs.on)
        }
    }
    @IBAction func isBroadcastEvery(sender: AnyObject) {
        if let swtitchIs = sender as? UISwitch {
            BroadcastPreference.setIsBroadcastOnEvery(swtitchIs.on)
        }
    }
}
