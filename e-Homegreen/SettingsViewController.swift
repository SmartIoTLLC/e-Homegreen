//
//  SettingsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

enum SettingsItem{
    case mainMenu, interfaces, refreshStatusDelay, openLastScreen, broadcast, refreshConnection, lockProfile, resetPassword
    var description:String{
        switch self{
            case .mainMenu: return "Main Menu"
            case .interfaces: return "Locations"
            case .refreshStatusDelay: return "Refresh Status Delay"
            case .openLastScreen: return "Open Last Screen"
            case .broadcast: return "Broadcast"
            case .refreshConnection: return "Refresh Connection"
            case .lockProfile: return "Lock Profile"
            case .resetPassword: return "Reset Password"
        }
    }
    
}

class SettingsViewController: UIViewController, UIGestureRecognizerDelegate, SWRevealViewControllerDelegate, SettingsDelegate {
    var user:User?
    var appDel:AppDelegate!
    var error:NSError? = nil
    var hourRefresh:Int = 0
    var minRefresh:Int = 0
    var settingArray:[SettingsItem]!
    var isMore = false
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AdminController.shared.isAdminLogged() || user != nil {
            navigationItem.leftBarButtonItems = []
        }
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.KeyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.KeyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        settingArray = [.mainMenu, .interfaces, .refreshStatusDelay, .openLastScreen, .broadcast]
        
        if !AdminController.shared.isAdminLogged() {
            settingArray.append(.lockProfile)
        }
        
        settingArray.append(.resetPassword)
        
        if let hour = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayHours) as? Int {
            hourRefresh = hour
        }
        
        if let min = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayMinutes) as? Int {
            minRefresh = min
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if !AdminController.shared.isAdminLogged() && user == nil{
            self.revealViewController().delegate = self
            
            if self.revealViewController() != nil {
                menuButton.target = self.revealViewController()
                menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                revealViewController().toggleAnimationDuration = 0.5

                revealViewController().rearViewRevealWidth = 200
                
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "connection"{
            if let destinationVC = segue.destination as? LocationViewController{
                if let user = user{
                    destinationVC.user = user
                }else{
                    let tempUser = DatabaseUserController.shared.getLoggedUser()
                    destinationVC.user = tempUser
                }
            }
        }
        if segue.identifier == "mainMenu"{
            if let destinationVC = segue.destination as? MenuSettingsViewController{
                if let user = user{
                    destinationVC.user = user
                }else{
                    let tempUser = DatabaseUserController.shared.getLoggedUser()
                    destinationVC.user = tempUser
                }
            }
        }
    }

    func resetPasswordFinished() {
        self.view.makeToast(message: "Passwords was changed successfully")
    }
    func btnAddHourPressed(_ sender:UIButton){
        if sender.tag == 1{
            if hourRefresh < 23 {
                hourRefresh += 1
            }else{
                hourRefresh = 0
            }
            settingsTableView.reloadData()
            Foundation.UserDefaults.standard.setValue(hourRefresh, forKey: UserDefaults.RefreshDelayHours)
            Foundation.UserDefaults.standard.synchronize()
        }else{
            if minRefresh < 59 {
                minRefresh += 1
            }else{
                minRefresh = 0
            }
            settingsTableView.reloadData()
            Foundation.UserDefaults.standard.setValue(minRefresh, forKey: UserDefaults.RefreshDelayMinutes)
            Foundation.UserDefaults.standard.synchronize()
        }
        
    }
    func btnDecHourPressed(_ sender:UIButton){
        if sender.tag == 1{
            if hourRefresh > 0 {
                hourRefresh -= 1
            }else{
                hourRefresh = 23
            }
            settingsTableView.reloadData()
            Foundation.UserDefaults.standard.setValue(hourRefresh, forKey: UserDefaults.RefreshDelayHours)
            Foundation.UserDefaults.standard.synchronize()
        }else{
            if minRefresh > 0 {
                minRefresh -= 1
            }else{
                minRefresh = 59
            }
            settingsTableView.reloadData()
            Foundation.UserDefaults.standard.setValue(minRefresh, forKey: UserDefaults.RefreshDelayMinutes)
            Foundation.UserDefaults.standard.synchronize()
        }
    }
    func changeValue(_ sender:UISwitch){
        if let user = user{
            user.openLastScreen = sender.isOn as NSNumber!
        }else{
            if let tempUser = DatabaseUserController.shared.getLoggedUser(){
                tempUser.openLastScreen = sender.isOn as NSNumber!
            }
        }
    }
    func lockProfile(_ sender:UISwitch){
        if let user = user{
            user.isLocked = sender.isOn as NSNumber
        }else if let user = DatabaseUserController.shared.getLoggedUser(){
            user.isLocked = sender.isOn as NSNumber
        }
        CoreDataController.shahredInstance.saveChanges()
        
    }
    func didTouchSettingButton (_ sender:AnyObject) {
        if let view = sender as? UIButton {
            let tag = view.tag
            
            if settingArray[tag] == SettingsItem.mainMenu {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "mainMenu", sender: self)
                })

            }
            if settingArray[tag] == SettingsItem.interfaces {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "connection", sender: self)
                })
            }
            if settingArray[tag] == SettingsItem.resetPassword{
                DispatchQueue.main.async(execute: {
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
    func KeyboardWillShow(_ notification: Notification){
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if let endFrame = endFrame{
                self.tableBottomConstraint.constant = endFrame.size.height + 5
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    func KeyboardWillHide(_ notification: Notification){
        if let userInfo = (notification as NSNotification).userInfo {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            self.tableBottomConstraint.constant = 0
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

    @IBAction func btnMore(_ sender: AnyObject) {
        isMore = !isMore
        settingsTableView.reloadData()
    }
    @IBAction func broadcastTimeAndDateFromPhone(_ sender: AnyObject) {
        (UIApplication.shared.delegate as! AppDelegate).sendDataToBroadcastTimeAndDate()
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if settingArray[(indexPath as NSIndexPath).section] == SettingsItem.mainMenu || settingArray[(indexPath as NSIndexPath).section] == SettingsItem.interfaces || settingArray[(indexPath as NSIndexPath).section] == SettingsItem.resetPassword{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettinsTableViewCell
            cell.settingsButton.tag = (indexPath as NSIndexPath).section
            cell.settingsButton.addTarget(self, action: #selector(SettingsViewController.didTouchSettingButton(_:)), for: .touchUpInside)
            cell.settingsButton.setTitle(settingArray[(indexPath as NSIndexPath).section].description, for: UIControlState())
            cell.backgroundColor = UIColor.clear
            cell.layer.cornerRadius = 5
            
            return cell
        } else if settingArray[(indexPath as NSIndexPath).section] == SettingsItem.refreshStatusDelay {
            let cell = tableView.dequeueReusableCell(withIdentifier: "delayRefreshStatus") as! SettingsRefreshDelayTableViewCell
            cell.layer.cornerRadius = 5
            
            cell.btnAddHourPressed.addTarget(self, action: #selector(SettingsViewController.btnAddHourPressed(_:)), for: UIControlEvents.touchUpInside)
            cell.btnAddHourPressed.tag = 1
            cell.btnDecHourPressed.addTarget(self, action: #selector(SettingsViewController.btnDecHourPressed(_:)), for: UIControlEvents.touchUpInside)
            cell.btnDecHourPressed.tag = 1
            cell.hourLabel.text = "\(hourRefresh)"
            
            cell.backgroundColor = UIColor.clear
            
            cell.btnAddMinPressed.addTarget(self, action: #selector(SettingsViewController.btnAddHourPressed(_:)), for: UIControlEvents.touchUpInside)
            cell.btnDecMinPressed.addTarget(self, action: #selector(SettingsViewController.btnDecHourPressed(_:)), for: UIControlEvents.touchUpInside)
            
            cell.minLabel.text = "\(minRefresh)"
            
            return cell
        } else if settingArray[(indexPath as NSIndexPath).section] == SettingsItem.openLastScreen {
            let cell = tableView.dequeueReusableCell(withIdentifier: "openLastScreen") as! SettingsLastScreenTableViewCell
            cell.openLastScreen.tag = (indexPath as NSIndexPath).section
            cell.backgroundColor = UIColor.clear
            cell.openLastScreen.addTarget(self, action: #selector(SettingsViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
            
            if let user = user{
                cell.openLastScreen.isOn = user.openLastScreen.boolValue
            }else{
                if let tempUser = DatabaseUserController.shared.getLoggedUser(){
                    cell.openLastScreen.isOn = tempUser.openLastScreen.boolValue
                }
            }
            cell.backgroundColor = UIColor.clear
            cell.layer.cornerRadius = 5
            return cell
        } else if settingArray[(indexPath as NSIndexPath).section] == SettingsItem.broadcast {
            let cell = tableView.dequeueReusableCell(withIdentifier: "idBroadcastCurrentAppTimeAndDate") as! BroadcastTimeAndDateTVC
            cell.setBroadcast()
            cell.txtIp.delegate = self
            cell.txtPort.delegate = self
            cell.txtH.delegate = self
            cell.txtM.delegate = self
            cell.backgroundColor = UIColor.clear
            cell.layer.cornerRadius = 5
            
            return cell
            
        }
        else if settingArray[(indexPath as NSIndexPath).section] == SettingsItem.lockProfile {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "openLastScreen") as! SettingsLastScreenTableViewCell
            
            cell.nameLabel.text = settingArray[(indexPath as NSIndexPath).section].description
            if let user = user{
                cell.openLastScreen.isOn = user.isLocked as Bool
            }else if let user = DatabaseUserController.shared.getLoggedUser(){
                cell.openLastScreen.isOn = user.isLocked as Bool
            }else{
                cell.openLastScreen.isOn = false
            }
            
            cell.openLastScreen.tag = indexPath.section
            cell.backgroundColor = UIColor.clear
            cell.openLastScreen.addTarget(self, action: #selector(SettingsViewController.lockProfile(_:)), for: UIControlEvents.valueChanged)
            
            cell.backgroundColor = UIColor.clear
            cell.layer.cornerRadius = 5
            return cell
            
        }else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
            return cell
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingArray.count
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 1024, height: 3))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 1024, height: 3))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 2 { return 90 }
        if settingArray[(indexPath as NSIndexPath).section] == SettingsItem.broadcast {
            if isMore {
                return 192
            }
        }
        return 44
    }

}

extension SettingsViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let cell = textField.superview?.superview as? BroadcastTimeAndDateTVC {
            cell.saveData()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let cell = textField.superview?.superview as? BroadcastTimeAndDateTVC {
            settingsTableView.scrollToRow(at: settingsTableView.indexPath(for: cell)!, at: UITableViewScrollPosition.middle, animated: true)
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
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        saveData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveData()
        return true
    }
    
    func setBroadcast () {
        self.txtIp.text = BroadcastPreference.getBroadcastIp()
        self.txtPort.text = "\(BroadcastPreference.getBroadcastPort())"
        self.txtH.text = "\(BroadcastPreference.getBroadcastHour())"
        self.txtM.text = "\(BroadcastPreference.getBroadcastMin())"
        self.isBroadcastOnStartUp.isOn = BroadcastPreference.getIsBroadcastOnStartUp()
        self.isBroadcastEvery.isOn = BroadcastPreference.getIsBroadcastOnEvery()
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
    @IBAction func isBroadcastOnStartUp(_ sender: AnyObject) {
        if let swtitchIs = sender as? UISwitch {
            BroadcastPreference.setIsBroadcastOnStartUp(swtitchIs.isOn)
        }
    }
    @IBAction func isBroadcastEvery(_ sender: AnyObject) {
        if let swtitchIs = sender as? UISwitch {
            BroadcastPreference.setIsBroadcastOnEvery(swtitchIs.isOn)
        }
    }
}
