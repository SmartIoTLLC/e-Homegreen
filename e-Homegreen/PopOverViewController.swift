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
    
<<<<<<< HEAD
    var locationList:[String] = []
    var levelList:[String] = []
    var zoneList:[String] = []
    var categoryList:[String] = []
    var gatewayList:[String] = []
=======
    var locationList:[String] = ["All"]
    var levelList:[String] = ["All"]
    var zoneList:[String] = ["Zone 1", "Zone 2", "All"]
    var categoryList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    var gatewayList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    var sceneList:[String] = ["Scene 1", "Scene 2", "Scene 3", "All"]
    var chooseList:[String] = ["Devices", "Scenes"]
>>>>>>> origin/master
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
    func updateDeviceList (whatToFetch:String, array:String) {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: "Device")
        fetchRequest.propertiesToFetch = [whatToFetch]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        var sortDescriptor = NSSortDescriptor(key: whatToFetch, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let results = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            for device in results {
                println(device[whatToFetch]!)
//                var zoneIdString = device["zoneId"]
                if let fetchedObject:Int = device[whatToFetch] as? Int {
                    switch array {
                    case "gatewayList":
                        gatewayList.append("\(fetchedObject)")
                    case "levelList" :
                        levelList.append("\(fetchedObject)")
                    case "zoneList":
                        zoneList.append("\(fetchedObject)")
                    case "categoryList":
                        categoryList.append("\(fetchedObject)")
                    default:
                        println(zoneList)
                    }
                }
                if let gatewayName = device[whatToFetch] as? String {
                    gatewayList.append("\(gatewayName)")
                }
            }
        } else {
            
        }
    }
    override func viewWillAppear(animated: Bool) {
        if indexTab == 1{
            updateDeviceList("gateway.name", array:"gatewayList")
            tableList = gatewayList
        } else if indexTab == 2 {
            updateDeviceList("level", array:"levelList")
            tableList = levelList
        } else if indexTab == 3 {
            updateDeviceList("zoneId", array:"zoneList")
            tableList = zoneList
<<<<<<< HEAD
        } else {
            updateDeviceList("categoryId", array:"categoryList")
=======
        } else if indexTab == 4 {
>>>>>>> origin/master
            tableList = categoryList
        } else if indexTab == 5 {
            tableList = sceneList
        } else {
            tableList = chooseList
        }
        tableList.append("All")
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
<<<<<<< HEAD
//        if indexTab != 4 {
=======
        if indexTab != 7 {
>>>>>>> origin/master
            delegate?.saveText!(tableList[indexPath.row])
//        } else {
//            delegate?.clickedOnGatewayWithIndex!(indexPath.row)
//        }
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
