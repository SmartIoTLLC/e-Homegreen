//
//  SettingsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

enum SettingsItem{
    case MainMenu, Interfaces, RefreshStatusDelay, OpenLastScreen, Broadcast, RefreshConnection, LockProfile, ResetPassword
    var description:String{
        switch self{
            case MainMenu: return "Main Menu"
            case Interfaces: return "Locations"
            case RefreshStatusDelay: return "Refresh Status Delay"
            case OpenLastScreen: return "Open Last Screen"
            case Broadcast: return "Broadcast"
            case RefreshConnection: return "Refresh Connection"
            case .LockProfile: return "Lock Profile"
            case .ResetPassword: return "Reset Password"
        }
    }
    
}

class SettingsViewController: UIViewController, UIGestureRecognizerDelegate, SWRevealViewControllerDelegate, SettingsDelegate {
    
    var user:User?
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    var settingArray:[SettingsItem]!
    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    var hourRefresh:Int = 0
    var minRefresh:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AdminController.shared.isAdminLogged() || user != nil {
            navigationItem.leftBarButtonItems = []
        }
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.KeyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.KeyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        settingArray = [.MainMenu, .Interfaces, .RefreshStatusDelay, .OpenLastScreen, .Broadcast]
        
        if !AdminController.shared.isAdminLogged() {
            settingArray.append(.LockProfile)
        }
        
        settingArray.append(.ResetPassword)
        
        if let hour = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayHours) as? Int {
            hourRefresh = hour
        }
        
        if let min = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaults.RefreshDelayMinutes) as? Int {
            minRefresh = min
        }

    }

    override func viewWillAppear(animated: Bool) {
        if !AdminController.shared.isAdminLogged() && user == nil{
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
    }
    
    func resetPasswordFinished() {
        self.view.makeToast(message: "Passwords was changed successfully")
    }
    
    func btnAddHourPressed(sender:UIButton){
        if sender.tag == 1{
            if hourRefresh < 23 {
                hourRefresh += 1
            }else{
                hourRefresh = 0
            }
            settingsTableView.reloadData()
            NSUserDefaults.standardUserDefaults().setValue(hourRefresh, forKey: UserDefaults.RefreshDelayHours)
            NSUserDefaults.standardUserDefaults().synchronize()
        }else{
            if minRefresh < 59 {
                minRefresh += 1
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
                hourRefresh -= 1
            }else{
                hourRefresh = 23
            }
            settingsTableView.reloadData()
            NSUserDefaults.standardUserDefaults().setValue(hourRefresh, forKey: UserDefaults.RefreshDelayHours)
            NSUserDefaults.standardUserDefaults().synchronize()
        }else{
            if minRefresh > 0 {
                minRefresh -= 1
            }else{
                minRefresh = 59
            }
            settingsTableView.reloadData()
            NSUserDefaults.standardUserDefaults().setValue(minRefresh, forKey: UserDefaults.RefreshDelayMinutes)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func changeValue(sender:UISwitch){
        if let user = user{
            user.openLastScreen = sender.on
        }else{
            if let tempUser = DatabaseUserController.shared.getLoggedUser(){
                tempUser.openLastScreen = sender.on
            }
        }
    }
    
    func lockProfile(sender:UISwitch){
        if let user = user{
            user.isLocked = sender.on
        }else if let user = DatabaseUserController.shared.getLoggedUser(){
            user.isLocked = sender.on
        }
        CoreDataController.shahredInstance.saveChanges()
        
    }
    
    func didTouchSettingButton (sender:AnyObject) {
        if let view = sender as? UIButton {
            let tag = view.tag
            
            if settingArray[tag] == SettingsItem.MainMenu {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("mainMenu", sender: self)
                })

            }
            if settingArray[tag] == SettingsItem.Interfaces {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("connection", sender: self)
                })
            }
            if settingArray[tag] == SettingsItem.ResetPassword{
                dispatch_async(dispatch_get_main_queue(),{
                    if let user = self.user{
                        self.showResetPassword(user).delegate = self
                    }else{
                        if let tempUser = DatabaseUserController.shared.getLoggedUser(){
                            self.showResetPassword(tempUser).delegate = self
                        }                        
                    }
                    
                })
            }

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "connection"{
            if let destinationVC = segue.destinationViewController as? LocationViewController{
                if let user = user{
                    destinationVC.user = user
                }else{
                    let tempUser = DatabaseUserController.shared.getLoggedUser()
                    destinationVC.user = tempUser
                }
            }
        }
        if segue.identifier == "mainMenu"{
            if let destinationVC = segue.destinationViewController as? MenuSettingsViewController{
                if let user = user{
                    destinationVC.user = user
                }else{
                    let tempUser = DatabaseUserController.shared.getLoggedUser()
                    destinationVC.user = tempUser
                }
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

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if settingArray[indexPath.section] == SettingsItem.MainMenu || settingArray[indexPath.section] == SettingsItem.Interfaces || settingArray[indexPath.section] == SettingsItem.ResetPassword{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as! SettinsTableViewCell
            cell.settingsButton.tag = indexPath.section
            cell.settingsButton.addTarget(self, action: #selector(SettingsViewController.didTouchSettingButton(_:)), forControlEvents: .TouchUpInside)
            cell.settingsButton.setTitle(settingArray[indexPath.section].description, forState: .Normal)
            cell.backgroundColor = UIColor.clearColor()
            cell.layer.cornerRadius = 5
            
            return cell
        } else if settingArray[indexPath.section] == SettingsItem.RefreshStatusDelay {
            let cell = tableView.dequeueReusableCellWithIdentifier("delayRefreshStatus") as! SettingsRefreshDelayTableViewCell
            cell.layer.cornerRadius = 5
            
            cell.btnAddHourPressed.addTarget(self, action: #selector(SettingsViewController.btnAddHourPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnAddHourPressed.tag = 1
            cell.btnDecHourPressed.addTarget(self, action: #selector(SettingsViewController.btnDecHourPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnDecHourPressed.tag = 1
            cell.hourLabel.text = "\(hourRefresh)"
            
            cell.backgroundColor = UIColor.clearColor()
            
            cell.btnAddMinPressed.addTarget(self, action: #selector(SettingsViewController.btnAddHourPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnDecMinPressed.addTarget(self, action: #selector(SettingsViewController.btnDecHourPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.minLabel.text = "\(minRefresh)"
            
            return cell
        } else if settingArray[indexPath.section] == SettingsItem.OpenLastScreen {
            let cell = tableView.dequeueReusableCellWithIdentifier("openLastScreen") as! SettingsLastScreenTableViewCell
            cell.openLastScreen.tag = indexPath.section
            cell.backgroundColor = UIColor.clearColor()
            cell.openLastScreen.addTarget(self, action: #selector(SettingsViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
            
            if let user = user{
                cell.openLastScreen.on = user.openLastScreen.boolValue
            }else{
                if let tempUser = DatabaseUserController.shared.getLoggedUser(){
                    cell.openLastScreen.on = tempUser.openLastScreen.boolValue
                }
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
        }
        else if settingArray[indexPath.section] == SettingsItem.LockProfile {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("openLastScreen") as! SettingsLastScreenTableViewCell
            
            cell.nameLabel.text = settingArray[indexPath.section].description
            if let user = user{
                if let locked = user.isLocked as? Bool{
                    cell.openLastScreen.on = locked
                }else{
                    cell.openLastScreen.on = false
                }
            }else if let user = DatabaseUserController.shared.getLoggedUser(){
                if let locked = user.isLocked as? Bool{
                    cell.openLastScreen.on = locked
                }else{
                    cell.openLastScreen.on = false
                }
            }else{
                cell.openLastScreen.on = false
            }
            
            cell.openLastScreen.tag = indexPath.section
            cell.backgroundColor = UIColor.clearColor()
            cell.openLastScreen.addTarget(self, action: #selector(SettingsViewController.lockProfile(_:)), forControlEvents: UIControlEvents.ValueChanged)
            
            cell.backgroundColor = UIColor.clearColor()
            cell.layer.cornerRadius = 5
            return cell
            
        }else {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
            return cell
        }
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
}

extension SettingsViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let cell = textField.superview?.superview as? BroadcastTimeAndDateTVC {
            cell.saveData()
        }
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        if let cell = textField.superview?.superview as? BroadcastTimeAndDateTVC {
            settingsTableView.scrollToRowAtIndexPath(settingsTableView.indexPathForCell(cell)!, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }
}

class SettinsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingsButton: CustomGradientButton!
}

class SettingsRefreshDelayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var btnAddHourPressed: UIButton!
    @IBOutlet weak var btnDecHourPressed: UIButton!
    
    @IBOutlet weak var btnAddMinPressed: UIButton!
    @IBOutlet weak var btnDecMinPressed: UIButton!

}

class SettingsLastScreenTableViewCell: UITableViewCell {
    @IBOutlet weak var openLastScreen: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setItem(){
        
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
