//
//  MenuSettinsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/1/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

enum Menu:Int{
    case Dashboard = 0, Devices, Scenes, Events, Sequences, Timers, Security, Surveillance, Flags, Users, PCControl, Chat, Energy, Settings, NotSuperUserSettings
    var description:String{
        switch self{
            case .Dashboard: return "Dashboard"
            case .Devices: return "Devices"
            case .Scenes: return "Scenes"
            case .Events: return "Events"
            case .Sequences: return "Sequences"
            case .Timers: return "Timers"
            case .Flags: return "Flags"
            case .Chat: return "Chat"
            case .Security: return "Security"
            case .Surveillance: return "Surveillance"
            case .Energy: return "Energy"
            case .Users: return "Users"
            case .PCControl: return "PC Control"
            case .Settings: return "Settings"
            case .NotSuperUserSettings: return "Settings"
        }
    }
    
    var controller:UINavigationController{
        switch self{
        case .Dashboard: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Dashboard") as! UINavigationController)
        case .Devices: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Devices") as! UINavigationController)
        case .Scenes: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Scenes") as! UINavigationController)
        case .Events: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Events") as! UINavigationController)
        case .Sequences: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Sequences") as! UINavigationController)
        case .Timers: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Timers") as! UINavigationController)
        case .Flags: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Flags") as! UINavigationController)
        case .Chat: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Chat") as! UINavigationController)
        case .Security: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Security") as! UINavigationController)
        case .Surveillance: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Surveillance") as! UINavigationController)
        case .Energy: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Energy") as! UINavigationController)
        case .Users: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Users") as! UINavigationController)
        case .PCControl: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("PC Control") as! UINavigationController)
        case .Settings: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Settings") as! UINavigationController)
        case .NotSuperUserSettings: return (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("NotSuperUserSettings") as! UINavigationController)
        }
    }
    
    static let allMenuItem = [Dashboard, Devices, Scenes, Events, Sequences, Timers, Security, Surveillance, Flags, Users, PCControl, Chat, Energy, Settings]
    static let allMenuItemNotSuperUser = [Dashboard, Devices, Scenes, Events, Sequences, Timers, Security, Surveillance, Flags, Users, PCControl, Chat, Energy, NotSuperUserSettings]
}

class MenuSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var topView: UIView!
    var user:User!
    
    var menu:[MenuItem] = []
    
    var menuList:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for item in  Menu.allMenuItem {
//            menuList.append(item.description)
//        }
        menu = DatabaseMenuController.shared.getMenuItemByUser(user)
      
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("menuSettingsCell") as? MenuSettingsCell {
            cell.setItem(menu[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = ""
        cell.contentView.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }


}

class MenuSettingsCell:UITableViewCell{
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuSwitch: UISwitch!
    @IBOutlet weak var menuLabel: UILabel!
    
    var menuItem:MenuItem!
    
    func setItem(menuItem:MenuItem){
        self.menuItem = menuItem
        if let item = Menu(rawValue: Int(menuItem.id)){
            menuImage.image = UIImage(named: item.description)
            menuLabel.text = item.description
            menuSwitch.on = Bool(menuItem.isVisible)
            if item == Menu.Settings{
                menuSwitch.enabled = false
            }else{
                menuSwitch.enabled = true
            }
            
        }
    }
    
    @IBAction func changeValue(sender: AnyObject) {
        DatabaseMenuController.shared.changeState(menuItem)
    }
}
