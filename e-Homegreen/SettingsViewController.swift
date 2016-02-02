//
//  SettingsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SettingsViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate {

    var settingArray:[String]!
    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    var hourRefresh:Int = 0
    var minRefresh:Int = 0
    
//    @IBOutlet weak var centarY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        settingArray = ["Main menu", "Connections", "Refresh status delay", "Open last screen", "Surveillance", "Security", "iBeacon", "Broadcast"]
        
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
        if settingArray[indexPath.section] == "Broadcast" {
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
        if settingArray[indexPath.section] == "Main menu" || settingArray[indexPath.section] == "Connections" || settingArray[indexPath.section] == "Surveillance" || settingArray[indexPath.section] == "Security" || settingArray[indexPath.section] == "iBeacon"{
            let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as! SettinsTableViewCell
            cell.settingsButton.tag = indexPath.section
            cell.settingsButton.addTarget(self, action: "didTouchSettingButton:", forControlEvents: .TouchUpInside)
            cell.settingsButton.setTitle(settingArray[indexPath.section], forState: .Normal)
            cell.backgroundColor = UIColor.clearColor()
            cell.layer.cornerRadius = 5
            
            return cell
        } else if settingArray[indexPath.section] == "Refresh status delay" {
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
        } else if settingArray[indexPath.section] == "Open last screen" {
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
        } else if settingArray[indexPath.section] == "Broadcast" {
            let cell = tableView.dequeueReusableCellWithIdentifier("idBroadcastCurrentAppTimeAndDate") as! BroadcastTimeAndDateTVC
            cell.setBroadcast()
            cell.txtM.delegate = self
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
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year , .Month , .Day, .Hour, .Minute, .Second, .Weekday, .WeekdayOrdinal] , fromDate: date)
        
        let year =  components.year-2000
        let month = components.month
        let day = components.day
        let hour =  components.hour
        let minute = components.minute
        let second = components.second
        let weekday = components.weekday-1
        
        SendingHandler.sendCommand(byteArray: Function.setInternalClockRTC([0xFF,0xFF,0xFF], year: Byte(year), month: Byte(month), day: Byte(day), hour: Byte(hour), minute: Byte(minute), second: Byte(second), dayOfWeak: Byte(weekday)), ip: BroadcastPreference.getBroadcastIp(), port: UInt16 (BroadcastPreference.getBroadcastPort()))
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        let cell = textField.superview?.superview as! BroadcastTimeAndDateTVC
        settingsTableView.scrollToRowAtIndexPath(settingsTableView.indexPathForCell(cell)!, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
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
        self.txtIp.delegate = self
        self.txtPort.delegate = self
        self.txtH.delegate = self
        self.txtM.delegate = self
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
//    func keyboardWillShow(notification: NSNotification) {
//        var info = notification.userInfo!
//        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        if txtDescription.isFirstResponder(){
//            if backView.frame.origin.y + txtDescription.frame.origin.y + 65 - self.scrollViewConnection.contentOffset.y > self.view.frame.size.height - keyboardFrame.size.height{
//                
//                self.centarY.constant = 5 + (self.backView.frame.origin.y + self.txtDescription.frame.origin.y + 65 - self.scrollViewConnection.contentOffset.y - (self.view.frame.size.height - keyboardFrame.size.height))
//                
//            }
//        }
//        
//        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
//        
//    }

}
