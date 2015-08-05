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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        settingArray = ["Main menu", "Scan device", "Connections"]
        
        settingArray = ["Main menu", "Connections", "Refresh status delay", "Open last screen"]


//        commonConstruct()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
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
        var headerView:UIView = UIView(frame: CGRectMake(0, 0, 1024, 3))
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView:UIView = UIView(frame: CGRectMake(0, 0, 1024, 3))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if settingArray[indexPath.section] == "Main menu" || settingArray[indexPath.section] == "Connections" {
            println("Index path row is: \(indexPath.section) and settingsArray for that index is: \(settingArray[indexPath.section])")
            let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as! SettinsTableViewCell
            //            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.tableCellTitle.text = settingArray[indexPath.section]
            cell.layer.cornerRadius = 5
            return cell
        } else if settingArray[indexPath.section] == "Refresh status delay" {
            let cell = tableView.dequeueReusableCellWithIdentifier("delayRefreshStatus") as! SettingsRefreshDelayTableViewCell
            cell.layer.cornerRadius = 5
            return cell
        } else if settingArray[indexPath.section] == "Open last screen" {
            let cell = tableView.dequeueReusableCellWithIdentifier("openLastScreen") as! SettingsLastScreenTableViewCell
            cell.openLastScreen.on = NSUserDefaults.standardUserDefaults().valueForKey("openLastScreen")!.boolValue
            cell.openLastScreen.tag = indexPath.section
            cell.openLastScreen.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
            if NSUserDefaults.standardUserDefaults().boolForKey("firstBool") {
                cell.openLastScreen.on = true
            }else{
                cell.openLastScreen.on = false
            }
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
//            NSUserDefaults.standardUserDefaults().setValue(NSNumber(bool: true), forKey: "openLastScreen")
//            settingsTableView.reloadData()
        }else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstBool")
//            NSUserDefaults.standardUserDefaults().setValue(NSNumber(bool: false), forKey: "openLastScreen")
//            settingsTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("menuSettings", sender: self)
            })
        }
        if indexPath.section == 1 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("connectionSettings", sender: self)
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationVC = segue.destinationViewController as! UIViewController
        destinationVC.modalPresentationStyle = UIModalPresentationStyle.Custom
    }
}

class SettinsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableCellTitle: UILabel!
}

class SettingsRefreshDelayTableViewCell: UITableViewCell {
    @IBOutlet weak var txtDelayResfreshStatus: UITextField!
    
}

class SettingsLastScreenTableViewCell: UITableViewCell {
    @IBOutlet weak var openLastScreen: UISwitch!
    
}
