//
//  MenuSettinsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/1/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

enum Menu:Int{
    case dashboard = 0, devices, scenes, events, remote, media, radio, quran, sequences, timers, security, surveillance, flags, users, pcControl, phone, chat, energy, settings, notSuperUserSettings
    var description:String{
        switch self{
            case .dashboard    : return "Dashboard"
            case .devices      : return "Devices"
            case .scenes       : return "Scenes"
            case .events       : return "Events"
            case .remote       : return "Remote"
            case .media        : return "Media"
            case .radio        : return "Radio"
            case .quran        : return "Quran"
            case .sequences    : return "Sequences"
            case .timers       : return "Timers"
            case .flags        : return "Flags"
            case .chat         : return "Chat"
            case .security     : return "Security"
            case .surveillance : return "Surveillance"
            case .energy       : return "Energy"
            case .users        : return "Users"
            case .pcControl    : return "PC Control"
            case .phone        : return "Phone"
            case .settings     : return "Settings"
            
            case .notSuperUserSettings: return "Settings"
        }
    }
    
    var controller:UINavigationController{
        switch self{
        case .dashboard     : return MenuViewController.dushboardVC
        case .devices       : return MenuViewController.devicesVC
        case .scenes        : return MenuViewController.scenesVC
        case .events        : return MenuViewController.eventsVC
        case .remote        : return MenuViewController.remoteVC
        case .media         : return MenuViewController.mediaVC
        case .radio         : return MenuViewController.radioVC
        case .quran         : return MenuViewController.quranVC
        case .sequences     : return MenuViewController.sequencesVC
        case .timers        : return MenuViewController.timersVC
        case .flags         : return MenuViewController.flagsVC
        case .chat          : return MenuViewController.chatVC
        case .security      : return MenuViewController.securityVC
        case .surveillance  : return MenuViewController.surveillanceVC
        case .energy        : return MenuViewController.energyVC
        case .users         : return MenuViewController.usersVC
        case .pcControl     : return MenuViewController.pccontrolVC
        case .phone         : return MenuViewController.phoneVC
        case .settings      : return MenuViewController.settingsVC
            
        case .notSuperUserSettings: return MenuViewController.notSuperUserVC
        }
    }
    
    static let allMenuItem = [dashboard, devices, scenes, events, remote, media, radio, quran, sequences, timers, security, surveillance, flags, users, pcControl, phone, chat, energy, settings]
    static let allMenuItemNotSuperUser = [dashboard, devices, scenes, events, remote, media, radio, quran, sequences, timers, security, surveillance, flags, users, pcControl, phone, chat, energy, notSuperUserSettings]
}

class MenuViewController{
    static let dushboardVC      = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Dashboard") as! UINavigationController)
    static let devicesVC        = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Devices") as! UINavigationController)
    static let scenesVC         = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Scenes") as! UINavigationController)
    static let eventsVC         = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Events") as! UINavigationController)
    static let remoteVC         = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Remote") as! UINavigationController)
    static let mediaVC          = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Media") as! UINavigationController)
    static let radioVC          = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Radio") as! UINavigationController)
    static let quranVC          = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Quran") as! UINavigationController)
    static let sequencesVC      = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Sequences") as! UINavigationController)
    static let timersVC         = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Timers") as! UINavigationController)
    static let flagsVC          = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Flags") as! UINavigationController)
    static let chatVC           = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Chat") as! UINavigationController)
    static let securityVC       = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Security") as! UINavigationController)
    static let surveillanceVC   = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Surveillance") as! UINavigationController)
    static let energyVC         = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Energy") as! UINavigationController)
    static let usersVC          = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Users") as! UINavigationController)
    static let pccontrolVC      = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PC Control") as! UINavigationController)
    static let phoneVC          = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Phone") as! UINavigationController)
    static let settingsVC       = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Settings") as! UINavigationController)
    static let notSuperUserVC   = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NotSuperUserSettings") as! UINavigationController)
}

class MenuSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var user:User!
    
    var menu:[MenuItem] = []
    var menuList:[String] = []
    
    @IBOutlet weak var topView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    fileprivate func setupViews() {
        menu = DatabaseMenuController.shared.getDefaultMenuItemByUser(user)
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        navigationItem.titleView = titleView
        titleView.setTitle("Main Menu")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "menuSettingsCell") as? MenuSettingsCell {
            cell.setItem(menu[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = ""
        cell.contentView.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }

}

class MenuSettingsCell:UITableViewCell {
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuSwitch: UISwitch!
    @IBOutlet weak var menuLabel: UILabel!
    
    var menuItem:MenuItem!
    
    func setItem(_ menuItem:MenuItem) {
        self.menuItem = menuItem
        if let item = Menu(rawValue: Int(menuItem.id)) {
            menuImage.image = UIImage(named: item.description)
            menuLabel.text  = item.description
            menuSwitch.isOn = Bool(menuItem.isVisible)
            
            if item == Menu.settings { menuSwitch.isEnabled = false } else { menuSwitch.isEnabled = true }
        }
    }
    
    @IBAction func changeValue(_ sender: AnyObject) {
        DatabaseMenuController.shared.changeState(menuItem)
    }
}
