//
//  MenuSettinsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/1/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

enum Menu:Int{
    case dashboard = 0, devices, macros, security, settings, notSuperUserSettings
    var description:String{
        switch self{
        case .dashboard: return "Dashboard"
        case .devices: return "Devices"
        case .macros       : return "Macros"
        case .security: return "Security"
        case .settings: return "Settings"
        case .notSuperUserSettings: return "Settings"
        }
    }
    
    var controller:UINavigationController{
        switch self{
        case .dashboard: return MenuViewController.dushboardVC
        case .devices: return MenuViewController.devicesVC
        case .macros : return MenuViewController.macrosVC
        case .security: return MenuViewController.securityVC
        case .settings: return MenuViewController.settingsVC
        case .notSuperUserSettings: return MenuViewController.notSuperUserVC
        }
    }
    
    static let allMenuItem = [dashboard, devices, macros, security, settings]
    static let allMenuItemNotSuperUser = [dashboard, devices, macros, security, notSuperUserSettings]
}

class MenuViewController{
    static let dushboardVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Dashboard") as! UINavigationController)
    static let devicesVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Devices") as! UINavigationController)
    static let macrosVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Macros") as! UINavigationController)
    static let scenesVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Scenes") as! UINavigationController)
    static let eventsVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Events") as! UINavigationController)
    static let sequencesVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Sequences") as! UINavigationController)
    static let timersVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Timers") as! UINavigationController)
    static let flagsVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Flags") as! UINavigationController)
    static let chatVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Chat") as! UINavigationController)
    static let securityVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Security") as! UINavigationController)
    static let surveillanceVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Surveillance") as! UINavigationController)
    static let energyVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Energy") as! UINavigationController)
    static let usersVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Users") as! UINavigationController)
    static let pccontrolVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PC Control") as! UINavigationController)
    static let settingsVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Settings") as! UINavigationController)
    static let notSuperUserVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NotSuperUserSettings") as! UINavigationController)
}

class MenuSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var topView: UIView!
    var user:User!
    
    var menu:[MenuItem] = []
    
    var menuList:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu = DatabaseMenuController.shared.getDefaultMenuItemByUser(user)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "menuSettingsCell") as? MenuSettingsCell {
            cell.setItem(menu[(indexPath as NSIndexPath).row])
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

class MenuSettingsCell:UITableViewCell{
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuSwitch: UISwitch!
    @IBOutlet weak var menuLabel: UILabel!
    
    var menuItem:MenuItem!
    
    func setItem(_ menuItem:MenuItem){
        self.menuItem = menuItem
        if let item = Menu(rawValue: Int(menuItem.id)){
            menuImage.image = UIImage(named: item.description)
            menuLabel.text = item.description
            menuSwitch.isOn = Bool(menuItem.isVisible)
            if item == Menu.settings{
                menuSwitch.isEnabled = false
            }else{
                menuSwitch.isEnabled = true
            }
            
        }
    }
    
    @IBAction func changeValue(_ sender: AnyObject) {
        DatabaseMenuController.shared.changeState(menuItem)
    }
}

