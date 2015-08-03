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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        settingArray = ["Main menu", "Scan device", "Connections"]
        
        settingArray = ["Main menu", "Connections"]


//        commonConstruct()
        // Do any additional setup after loading the view.
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
        if let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as? SettinsTableViewCell {
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.tableCellTitle.text = settingArray[indexPath.section]
            cell.layer.cornerRadius = 5
            return cell
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("menuSettings", sender: self)
            })
        }
<<<<<<< HEAD
//        if indexPath.row == 1 {
//            dispatch_async(dispatch_get_main_queue(),{
//                self.performSegueWithIdentifier("databaseSettings", sender: self)
//            })
//        }
        if indexPath.row == 1 {
            dispatch_async(dispatch_get_main_queue(),{
=======
        if indexPath.section == 1 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("databaseSettings", sender: self)
            })
        }
        if indexPath.section == 2 {
            dispatch_async(dispatch_get_main_queue(),{
>>>>>>> origin/master
                self.performSegueWithIdentifier("connectionSettings", sender: self)
//                self.showCellParametar()
            })
        }
//        if indexPath.row == 3 {
//            dispatch_async(dispatch_get_main_queue(),{
//                 self.showConnectionSettings(-1)
//            })
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationVC = segue.destinationViewController as! UIViewController
        destinationVC.modalPresentationStyle = UIModalPresentationStyle.Custom
//        if segue.identifier == "menuSettings"{
//            var destinationVC = segue.destinationViewController as! MenuSettingsViewController
//            destinationVC.transitioningDelegate = se
//            
//        }
    }
}

class SettinsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableCellTitle: UILabel!
}
