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
        
        settingArray = ["Main menu", "Connections", "Refresh status delay", "Open last screen", "Surveillance", "Security", "iBeacon"]
        
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
            if NSUserDefaults.standardUserDefaults().boolForKey("firstBool") {
                cell.openLastScreen.on = true
            }else{
                cell.openLastScreen.on = false
            }
            
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
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstBool")

        }else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstBool")

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
