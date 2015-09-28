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
    optional func saveText (text : String, id:Int)
    optional func clickedOnGatewayWithIndex (index : Int)
}

struct TableList {
    var name:String
    var id:Int
}

class PopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var levelList:[Zone] = []
    var zoneList:[Zone] = []
    var categoryList:[Category] = []
    var gatewayList:[Gateway] = []
    var sceneList:[String] = ["Scene 1", "Scene 2", "Scene 3", "All"]
    var chooseList:[String] = ["Devices", "Scenes", "Events", "Sequences", "Zones", "Categories"]
    
    var tableList:[TableList] = []
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var error:NSError? = nil
    
    @IBOutlet weak var table: UITableView!
    
    var indexTab: Int = 0
    var delegate : PopOverIndexDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate

        table.layer.cornerRadius = 8
        
        // Do any additional setup after loading the view.
    }
//    func updateDeviceList (whatToFetch:String, array:String) {
//        let fetchRequest = NSFetchRequest(entityName: "Device")
//        fetchRequest.propertiesToFetch = [whatToFetch]
//        fetchRequest.returnsObjectsAsFaults = false
//        fetchRequest.returnsDistinctResults = true
//        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
//        let sortDescriptor = NSSortDescriptor(key: whatToFetch, ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        do {
//            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest)
//            print(results)
//            for device in results {
//                print(device[whatToFetch]!)
////                var zoneIdString = device["zoneId"]
//                if let fetchedObject:Int = device[whatToFetch] as? Int {
//                    switch array {
//                    case "gatewayList":
//                        gatewayList.append("\(fetchedObject)")
//                    case "levelList":
//                        levelList.append("\(fetchedObject)")
//                    case "zoneList":
//                        zoneList.append("\(fetchedObject)")
//                    case "categoryList":
//                        categoryList.append("\(fetchedObject)")
//                    default:
//                        print(zoneList)
//                    }
//                }
//                if let gatewayName = device[whatToFetch] as? String {
//                    gatewayList.append("\(gatewayName)")
//                }
//            }
//        } catch let error1 as NSError {
//            error = error1
//            
//        }
//    }
    func updateDeviceList (whatToFetch:String) {
        if whatToFetch == "Gateway" {
            let fetchRequest = NSFetchRequest(entityName: "Gateway")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Gateway]
                for item in results {
                    tableList.append(TableList(name: item.name, id: -1))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Zone" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
                for item in results {
                    tableList.append(TableList(name: item.name, id: Int(item.id)))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Level" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
                for item in results {
                    tableList.append(TableList(name: item.name, id: Int(item.id)))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Category" {
            let fetchRequest = NSFetchRequest(entityName: "Category")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Category]
                for item in results {
                    tableList.append(TableList(name: item.name, id: Int(item.id)))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
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
            updateDeviceList("Gateway")
            tableList.append(TableList(name: "All", id: -1))
        } else if indexTab == PopOver.Levels.rawValue {
            updateDeviceList("Level")
            tableList.append(TableList(name: "All", id: -1))
        } else if indexTab == PopOver.Zones.rawValue {
            updateDeviceList("Zone")
            tableList.append(TableList(name: "All", id: -1))
        } else if indexTab == PopOver.Categories.rawValue {
            updateDeviceList("Category")
            tableList.append(TableList(name: "All", id: -1))
        } else if indexTab == PopOver.Scenes.rawValue {
            tableList.append(TableList(name: "All", id: -1))
        } else if indexTab == PopOver.ScanGateway.rawValue {
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("pullCell") as? PullDownViewCell {
            cell.tableItem.text = tableList[indexPath.row].name
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            delegate?.saveText!(tableList[indexPath.row].name, id: tableList[indexPath.row].id)
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
