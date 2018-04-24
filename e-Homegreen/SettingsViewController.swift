//
//  SettingsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

enum SettingsItem{
    case mainMenu, interfaces, refreshStatusDelay, openLastScreen, sortingDevices, broadcast, refreshConnection, lockProfile, resetPassword
    var description:String{
        switch self{
            case .mainMenu: return "Main Menu"
            case .interfaces: return "Locations"
            case .refreshStatusDelay: return "Refresh Status Delay"
            case .openLastScreen: return "Open Last Screen:"
            case .sortingDevices: return "Sorting devices:"
            case .broadcast: return "Broadcast"
            case .refreshConnection: return "Refresh Connection"
            case .lockProfile: return "Lock Profile"
            case .resetPassword: return "Reset Password"
        }
    }
    
}

class SettingsViewController: UIViewController, UIGestureRecognizerDelegate, SWRevealViewControllerDelegate, SettingsDelegate {
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var user:User?
    var appDel:AppDelegate!
    var error:NSError? = nil
    var hourRefresh:Int {
        get {
            return defaults.integer(forKey: UserDefaults.RefreshDelayHours)
        }
        set {
            defaults.setValue(newValue, forKey: UserDefaults.RefreshDelayHours)
        }
    }
    var minRefresh:Int {
        get {
            return defaults.integer(forKey: UserDefaults.RefreshDelayMinutes)
        }
        set {
            defaults.setValue(newValue, forKey: UserDefaults.RefreshDelayMinutes)
        }
    }
    var settingArray:[SettingsItem]!
    var isMore = false
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func setupViews() {
        if AdminController.shared.isAdminLogged() || user != nil { navigationItem.leftBarButtonItems = [] }
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        titleView.setTitle("Settings")
        navigationItem.titleView = titleView
        
        settingArray = [.mainMenu, .interfaces, .refreshStatusDelay, .openLastScreen, .sortingDevices, .broadcast]
        
        if !AdminController.shared.isAdminLogged() { settingArray.append(.lockProfile) }
        
        settingArray.append(.resetPassword)
        
        if let hour = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayHours) as? Int { hourRefresh = hour }
        if let min = Foundation.UserDefaults.standard.value(forKey: UserDefaults.RefreshDelayMinutes) as? Int { minRefresh = min }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !AdminController.shared.isAdminLogged() && user == nil {
            self.revealViewController().delegate = self
            setupSWRevealViewController(menuButton: menuButton)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "connection" {
            if let destinationVC = segue.destination as? LocationViewController {
                
                if let user = user { destinationVC.user = user } else { let tempUser = DatabaseUserController.shared.getLoggedUser(); destinationVC.user = tempUser }
            }
        }
        
        if segue.identifier == "mainMenu" {
            if let destinationVC = segue.destination as? MenuSettingsViewController {
                if let user = user { destinationVC.user = user } else { let tempUser = DatabaseUserController.shared.getLoggedUser(); destinationVC.user = tempUser }
            }
        }
    }

    func resetPasswordFinished() {
        self.view.makeToast(message: "Passwords was changed successfully")
    }
    
    func btnAddHourPressed(_ sender:UIButton) {
        if sender.tag == 1 {
            if hourRefresh < 23 { hourRefresh += 1 } else { hourRefresh = 0 }
            settingsTableView.reloadData()
            Foundation.UserDefaults.standard.setValue(hourRefresh, forKey: UserDefaults.RefreshDelayHours)
            Foundation.UserDefaults.standard.synchronize()
        } else {
            if minRefresh < 59 { minRefresh += 1 } else { minRefresh = 0 }
            settingsTableView.reloadData()
            Foundation.UserDefaults.standard.setValue(minRefresh, forKey: UserDefaults.RefreshDelayMinutes)
            Foundation.UserDefaults.standard.synchronize()
        }
        
    }
    
    func btnDecHourPressed(_ sender:UIButton) {
        switch sender.tag {
            case 1:
                if hourRefresh > 0 { hourRefresh -= 1 } else { hourRefresh = 23 }
            default:
                if minRefresh > 0 { minRefresh -= 1 } else { minRefresh = 59 }
        }
        settingsTableView.reloadData()
    }
    
    func changeValue(_ sender:UISwitch) {
        if let user = user { user.openLastScreen = sender.isOn as NSNumber!
        } else { if let tempUser = DatabaseUserController.shared.getLoggedUser() { tempUser.openLastScreen = sender.isOn as NSNumber! } }
    }
    
    func lockProfile(_ sender:UISwitch) {
        
        if let user = user { user.isLocked = sender.isOn as NSNumber
        } else if let user = DatabaseUserController.shared.getLoggedUser() { user.isLocked = sender.isOn as NSNumber }
        CoreDataController.sharedInstance.saveChanges()
    }
    
    func didTouchSettingButton (_ sender:AnyObject) {
        if let view = sender as? UIButton {
            let tag = view.tag
            
            if settingArray[tag] == SettingsItem.mainMenu { DispatchQueue.main.async(execute: { self.performSegue(withIdentifier: "mainMenu", sender: self) }) }
            if settingArray[tag] == SettingsItem.interfaces { DispatchQueue.main.async(execute: { self.performSegue(withIdentifier: "connection", sender: self) }) }
            if settingArray[tag] == SettingsItem.resetPassword {
                DispatchQueue.main.async(execute: {
                    if let user = self.user { self.showResetPassword(user).delegate = self
                    } else { if let tempUser = DatabaseUserController.shared.getLoggedUser() { self.showResetPassword(tempUser).delegate = self } }
                })
            }
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if let endFrame = endFrame { self.tableBottomConstraint.constant = endFrame.size.height + 5 }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        if let userInfo = notification.userInfo {
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
        switch settingArray[indexPath.section] {
            
        case SettingsItem.mainMenu, SettingsItem.interfaces, SettingsItem.resetPassword:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as? SettinsTableViewCell {
                cell.setCell(settingsArray: settingArray, indexPath: indexPath)
                cell.settingsButton.addTarget(self, action: #selector(didTouchSettingButton(_:)), for: .touchUpInside)
                
                return cell
            }
        case SettingsItem.refreshStatusDelay:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "delayRefreshStatus") as? SettingsRefreshDelayTableViewCell {
                cell.setCell(min: minRefresh, hour: hourRefresh)
                
                cell.btnAddHourPressed.addTarget(self, action: #selector(btnAddHourPressed(_:)), for: .touchUpInside)
                cell.btnDecHourPressed.addTarget(self, action: #selector(btnDecHourPressed(_:)), for: .touchUpInside)
                cell.btnAddMinPressed.addTarget(self, action: #selector(btnAddHourPressed(_:)), for: .touchUpInside)
                cell.btnDecMinPressed.addTarget(self, action: #selector(btnDecHourPressed(_:)), for: .touchUpInside)
                
                return cell
            }
            
        case SettingsItem.sortingDevices:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SortingDevicesTableViewCell.reuseIdentifier) as? SortingDevicesTableViewCell {
                return cell
            }
            
        case SettingsItem.openLastScreen:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "openLastScreen") as? SettingsLastScreenTableViewCell {
                cell.setCell(user: user, tag: indexPath.section)
                cell.openLastScreen.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
                
                return cell
            }
        case SettingsItem.broadcast:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "idBroadcastCurrentAppTimeAndDate") as? BroadcastTimeAndDateTVC {
                cell.setBroadcast()
                cell.txtIp.delegate = self
                cell.txtPort.delegate = self
                cell.txtH.delegate = self
                cell.txtM.delegate = self
                return cell
            }
        case SettingsItem.lockProfile:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "openLastScreen") as? SettingsLastScreenTableViewCell {
                
                cell.setCell(settingsArray: settingArray, user: user, tag: indexPath.section)
                cell.openLastScreen.addTarget(self, action: #selector(lockProfile(_:)), for: .valueChanged)
                
                return cell
            }
        default: return UITableViewCell()
        }
        
        return UITableViewCell()
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
        if indexPath.section == 2 { return 90 }
        if settingArray[indexPath.section] == SettingsItem.broadcast {
            if isMore { return 192 }
        }
        return 44
    }
}

extension SettingsViewController: UITextFieldDelegate {
    
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
    
    func setCell(settingsArray: [SettingsItem], indexPath: IndexPath) {
        settingsButton.tag = indexPath.section
        settingsButton.setTitle(settingsArray[indexPath.section].description, for: UIControlState())
        backgroundColor = .clear
        layer.cornerRadius = 5
    }
}

class SettingsRefreshDelayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var btnAddHourPressed: UIButton!
    @IBOutlet weak var btnDecHourPressed: UIButton!
    
    @IBOutlet weak var btnAddMinPressed: UIButton!
    @IBOutlet weak var btnDecMinPressed: UIButton!
    
    func setCell(min: Int, hour: Int) {
        layer.cornerRadius = 5
        btnAddHourPressed.tag = 1
        btnDecHourPressed.tag = 1
        
        backgroundColor = .clear
        
        hourLabel.text = "\(hour)"
        minLabel.text = "\(min)"
    }

}

class SettingsLastScreenTableViewCell: UITableViewCell {
    @IBOutlet weak var openLastScreen: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        layer.cornerRadius = 5
    }
    
    func setCell(user: User?, tag: Int) {
        openLastScreen.tag = tag
        
        if let user = user { openLastScreen.isOn = user.openLastScreen.boolValue
        } else { if let tempUser = DatabaseUserController.shared.getLoggedUser() { openLastScreen.isOn = tempUser.openLastScreen.boolValue } }
        
    }
    
    func setCell(settingsArray: [SettingsItem], user: User?, tag: Int) {
        nameLabel.text = settingsArray[tag].description
        openLastScreen.tag = tag

        if let user = user { openLastScreen.isOn = user.isLocked as! Bool
        } else {
            if let user = DatabaseUserController.shared.getLoggedUser() { openLastScreen.isOn = user.isLocked as! Bool
            } else { openLastScreen.isOn = false }
        }
    }
    
}

// MARK: - Sorting Devices Cell
class SortingDevicesTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "sortingDevices"
    
    @IBOutlet weak var sortingLabel: UIView!
    @IBOutlet weak var sortingSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            sortingSwitch.isOn = user.sortDevicesByUsage!.boolValue
        }
        sortingSwitch.addTarget(self, action: #selector(setSortingPreferences), for: .touchUpInside)
    }
    
    @objc private func setSortingPreferences() {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            user.sortDevicesByUsage = NSNumber(value: !user.sortDevicesByUsage!.boolValue)
            sortingSwitch.isOn = user.sortDevicesByUsage!.boolValue
            CoreDataController.sharedInstance.saveChanges()
        }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        layer.cornerRadius = 5
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
            if port <= 65535 { BroadcastPreference.setBroadcastPort(port) }
        }
        if let hour = Int(self.txtH.text!) {
            if hour <= 23 { BroadcastPreference.setBroadcastHour(hour) }
        }
        if let min = Int(self.txtM.text!) {
            if min <= 59 { BroadcastPreference.setBroadcastMin(min) }
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
