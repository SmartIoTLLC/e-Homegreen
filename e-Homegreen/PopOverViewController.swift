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
    
    var locationList:[String] = []
    var levelList:[String] = []
    var zoneList:[String] = []
    var categoryList:[String] = []
    var gatewayList:[String] = []
    var sceneList:[String] = ["Scene 1", "Scene 2", "Scene 3", "All"]
    var chooseList:[String] = ["Devices", "Scenes", "Events", "Sequences", "Zones", "Categories"]
    
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
        let fetchRequest = NSFetchRequest(entityName: "Device")
        fetchRequest.propertiesToFetch = [whatToFetch]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        let sortDescriptor = NSSortDescriptor(key: whatToFetch, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest)
            for device in results {
                print(device[whatToFetch]!)
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
                        print(zoneList)
                    }
                }
                if let gatewayName = device[whatToFetch] as? String {
                    gatewayList.append("\(gatewayName)")
                }
            }
        } catch let error1 as NSError {
            error = error1
            
        }
    }
    enum PopOver: Int {
        case Gateways = 1
        case Levels = 2
        case Zones = 3
        case Categories = 4
        case Scenes = 5
        case ScanGateway = 6
    }
    override func viewWillAppear(animated: Bool) {
        if indexTab == PopOver.Gateways.rawValue {
            updateDeviceList("gateway.name", array:"gatewayList")
            tableList = gatewayList
            tableList.append("All")
        } else if indexTab == PopOver.Levels.rawValue {
            updateDeviceList("level", array:"levelList")
            tableList = levelList
            tableList.append("All")
        } else if indexTab == PopOver.Zones.rawValue {
            updateDeviceList("zoneId", array:"zoneList")
            tableList = zoneList
            tableList.append("All")
        } else if indexTab == PopOver.Categories.rawValue {
            updateDeviceList("categoryId", array:"categoryList")
            tableList = categoryList
            tableList.append("All")
        } else if indexTab == PopOver.Scenes.rawValue {
            tableList = sceneList
            tableList.append("All")
        } else if indexTab == PopOver.ScanGateway.rawValue {
            tableList = chooseList
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
            delegate?.saveText!(tableList[indexPath.row])
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
