//
//  SettingsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SettingsViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    var settingArray:[String]!
    @IBOutlet weak var settingsTableView: UITableView!
    
    var hourRefresh:Int = 0
    var minRefresh:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        BroadcastPreference.setBroadcastIp("areoffice.selfip.net")
        BroadcastPreference.setBroadcastPort(5101)
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year , .Month , .Day, .Hour, .Minute, .Second, .Weekday], fromDate: date)
        
        let year =  components.year-2000
        let month = components.month
        let day = components.day
        let hour =  components.hour
        let minute = components.minute
        let second = components.second
        let weekday = components.weekday-1 // OVO BI MOGAO DA BUDE PROBLEM
        
        SendingHandler.sendCommand(byteArray: Function.setInternalClockRTC([0xFF,0xFF,0xFF], year: Byte(year), month: Byte(month), day: Byte(day), hour: Byte(hour), minute: Byte(minute), second: Byte(second), dayOfWeak: Byte(weekday)), ip: BroadcastPreference.getBroadcastIp(), port: UInt16 (BroadcastPreference.getBroadcastPort()))
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
}
class BroadcastPreference {
    class func getBroadcastIp() -> String {
        if let ip = NSUserDefaults.standardUserDefaults().stringForKey("kBroadcastIp") {
            return ip
        } else {
            return ""
        }
    }
    class func setBroadcastIp(ip:String) {
        NSUserDefaults.standardUserDefaults().setValue(ip, forKey: "kBroadcastIp")
    }
    
    class func getBroadcastPort() -> Int {
        let port = NSUserDefaults.standardUserDefaults().integerForKey("kBroadcastPort")
        return port
    }
    class func setBroadcastPort(port:Int) {
        NSUserDefaults.standardUserDefaults().setValue(port, forKey: "kBroadcastPort")
    }
    
    class func getIsBroadcastOnStartUp() -> Bool {
        let port = NSUserDefaults.standardUserDefaults().boolForKey("kIsBroadcastOnStartUp")
        return port
    }
    class func setIsBroadcastOnStartUp(port:Bool) {
        NSUserDefaults.standardUserDefaults().setBool(port, forKey: "kIsBroadcastOnStartUp")
    }
    
    class func getIsBroadcastOnEvery() -> Bool {
        let port = NSUserDefaults.standardUserDefaults().boolForKey("kIsBroadcastOnEvery")
        return port
    }
    class func setIsBroadcastOnEvery(port:Bool) {
        NSUserDefaults.standardUserDefaults().setBool(port, forKey: "kIsBroadcastOnEvery")
    }
    
    class func getBroadcastHour() -> Int {
        let port = NSUserDefaults.standardUserDefaults().integerForKey("kBroadcastHour")
        return port
    }
    class func setBroadcastHour(port:Int) {
        NSUserDefaults.standardUserDefaults().setValue(port, forKey: "kBroadcastHour")
    }
    
    class func getBroadcastMin() -> Int {
        let port = NSUserDefaults.standardUserDefaults().integerForKey("kBroadcastMin")
        return port
    }
    class func setBroadcastMin(port:Int) {
        NSUserDefaults.standardUserDefaults().setValue(port, forKey: "kBroadcastMin")
    }
}
