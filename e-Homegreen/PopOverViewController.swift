//
//  PopOverViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 6/25/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

@objc protocol PopOverIndexDelegate
{
    optional func saveText (strText : String)
    optional func clickedOnGatewayWithIndex (index : Int)
}

class PopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var locationList:[String] = ["All"]
    var levelList:[String] = ["All"]
    var zoneList:[String] = ["Zone 1", "Zone 2", "All"]
    var categoryList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    var gatewayList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    var tableList:[String] = []
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var error:NSError? = nil
    
    @IBOutlet weak var table: UITableView!
    
    var indexTab: Int = 0
    var delegate : PopOverIndexDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.layer.cornerRadius = 8
        
        
        
        // Do any additional setup after loading the view.
    }
    func updateDeviceList () {
        println("ovde je uslo")
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: "Device")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        var sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            println("ovde je uslo 2")
            devices = results
        } else {
            println("ovde je uslo 3")
        }
        println("ovde je izaslo")
    }
    override func viewWillAppear(animated: Bool) {
        if indexTab == 1{
            tableList = locationList
        } else if indexTab == 2 {
            tableList = levelList
        } else if indexTab == 3 {
            tableList = zoneList
        } else {
            tableList = categoryList
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("pullCell") as? PullDownViewCell {
            cell.tableItem.text = tableList[indexPath.row]
            return cell
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexTab != 4 {
            delegate?.saveText!(tableList[indexPath.row])
        } else {
            delegate?.clickedOnGatewayWithIndex!(indexPath.row)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return false
    }

    



}

class PullDownViewCell: UITableViewCell {
    
    @IBOutlet weak var tableItem: UILabel!
    
}
