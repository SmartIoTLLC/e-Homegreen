//
//  MenuSettinsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/1/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

enum Menu{
    case Dashboard, Devices, Scenes, Events, Sequences, Timers, Flags, Chat, Security, Surveillance, Energy, Users, PCControl, Settings
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
        }
    }
    
    static let allMenuItem = [Dashboard, Devices, Scenes, Events, Sequences, Timers, Flags, Chat, Security, Surveillance, Energy, Users, PCControl, Settings]
}

class MenuSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var topView: UIView!
//    var menuItems: Array<MenuItem>!
//    var menuList:[NSString] = []
//    var listOfMenuItems: Array<MenuItem>!
    var user:User!
    
    var menuList:[String] = [] //["Dashboard", "Devices", "Scenes", "Events", "Sequences", "Timers", "Flags", "Chat", "Security", "Surveillance", "Energy", "PC Control", "Users", "Settings"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in  Menu.allMenuItem {
            menuList.append(item.description)
        }
        
//        menuItems = MenuViewControllers.sharedInstance.allMenuItems()
//        listOfMenuItems = MenuViewControllers.sharedInstance.allMenuItems1()
        
//        for item in menuItems{
//            for item1 in listOfMenuItems{
//                if item.title == item1.title{
//                    item.state = true
//                }
//            }
//        }
//        
//        var defaultMenu = menuItems
//        for (index, item) in defaultMenu.enumerate() {
//            if item.title == "Settings" {
////                defaultMenu.removeAtIndex(index)
//            }
//        }
//        menuItems = defaultMenu
//        // Do any additional setup after loading the view.
//    }
//    
//    func changeValue(sender:UISwitch){
//        if sender.tag == 11{
//            sender.on = true
//        }else{
//            if sender.on == true {
//                menuItems[sender.tag].state = true
//            }else {
//                menuItems[sender.tag].state = false
//            }
//        }
//        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("menuSettingsCell") as? MenuSettingsCell {
            cell.menuImage.image = UIImage(named: menuList[indexPath.row])
            cell.menuLabel.text = menuList[indexPath.row]
            cell.menuSwitch.tag = indexPath.row
//            cell.menuSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
//            if menuItems[indexPath.row].state == true {
//                cell.menuSwitch.on = true
//            }else {
//                cell.menuSwitch.on = false
//            }
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = ""
        cell.contentView.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
//    @IBAction func backButton(sender: AnyObject) {
//        for items in menuItems{
//            if items.state == true{
//                menuList.append(items.title!)
//            }
//        }
//        NSUserDefaults.standardUserDefaults().setObject(menuList, forKey: "menu")
//        NSUserDefaults.standardUserDefaults().synchronize()
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }

}

class MenuSettingsCell:UITableViewCell{
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuSwitch: UISwitch!
    @IBOutlet weak var menuLabel: UILabel!
    
}
