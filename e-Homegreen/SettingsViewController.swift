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
        
        settingArray = ["Main menu", "Scan device", "Connections"]
//        settingArray = ["Menu settings", "Database", "Gateway connections", "Connections Setting"]


//        commonConstruct()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as? SettinsTableViewCell {
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.tableCellTitle.text = settingArray[indexPath.row]
            return cell
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("menuSettings", sender: self)
            })
        }
        if indexPath.row == 1 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("databaseSettings", sender: self)
            })
        }
        if indexPath.row == 2 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("connectionSettings", sender: self)
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
