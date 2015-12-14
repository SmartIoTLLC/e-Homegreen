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
    optional func clickedOnGatewayWithObjectID(objectId:String)
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
    var chooseList:[TableList] = [TableList(name: "Devices", id: -1),
        TableList(name: "Scenes", id: -1),
        TableList(name: "Events", id: -1),
        TableList(name: "Sequences", id: -1),
        TableList(name: "Timers", id: -1),
        TableList(name: "Flag", id: -1),
        TableList(name: "Zones", id: -1),
        TableList(name: "Categories", id: -1)]
    var chooseTimerTypeList:[TableList] = [TableList(name: "Once", id: 7),
        TableList(name: "Daily", id: 7),
        TableList(name: "Monthly", id: 7),
        TableList(name: "Yearly", id: 7),
        TableList(name: "Hourly", id: 7),
        TableList(name: "Minutely", id: 7),
        TableList(name: "Countdown", id: 7)]
    var tableList:[TableList] = []
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var error:NSError? = nil
    var filterGateway:Gateway?
    
    @IBOutlet weak var table: UITableView!
    
    var indexTab: Int = 0
    var delegate : PopOverIndexDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate

        table.layer.cornerRadius = 8
        
        // Do any additional setup after loading the view.
    }
    func updateDeviceList (whatToFetch:String, withGateway:Gateway) {
        if whatToFetch == "Zone" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "level != %@", NSNumber(short: 0))
            let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "gateway == %@", withGateway)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateTwo, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in distinctSorted {
                    tableList.append(TableList(name: item, id: 3))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Level" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "level == %@", NSNumber(short: 0))
            let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "gateway == %@", withGateway)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateTwo, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in distinctSorted {
                    tableList.append(TableList(name: item, id: 2))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Category" {
            let fetchRequest = NSFetchRequest(entityName: "Category")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "gateway == %@", withGateway)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Category]
                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in distinctSorted {
                    tableList.append(TableList(name: item, id: 4))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
    }
    func updateDeviceList (whatToFetch:String) {
        if whatToFetch == "Gateway" {
            let fetchRequest = NSFetchRequest(entityName: "Gateway")
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne])
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = compoundPredicate
//            fetchRequest.returnsDistinctResults = true
//            fetchRequest.returnsObjectsAsFaults = false
//            fetchRequest.propertiesToFetch = ["name"]
//            fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Gateway]
//                let distinct = NSSet(array: results.valueForKeyPath("name") as [String])
//                With Swift 2.0 I prefer
                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
//                let distinct = NSSet(array: results.sort { $0.name < $1.name })
//                let distinct2 = distinct.sort { $0 < $1 }
                print(distinct)
                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                print(distinctSorted)
//                let distinct2 = distinct.sortedArrayUsingDescriptors([sortDescriptor])
//                let distinct = results.map { String($0.name) }
//                NSLog("\(distinct)")
                for item in distinctSorted {
                    tableList.append(TableList(name: item, id: -1))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Zone" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "level != %@", NSNumber(short: 0))
            let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "gateway.name == %@", filterGateway!.name)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateTwo, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in distinctSorted {
                    //                    tableList.append(TableList(name: item.name, id: Int(item.id)))
                    //                    tableList.append(TableList(name: "\(item.id)", id: 2))
                    tableList.append(TableList(name: item, id: 3))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Level" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "level == %@", NSNumber(short: 0))
            let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "gateway.name == %@", filterGateway!.name)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateTwo, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in distinctSorted {
                    //                    tableList.append(TableList(name: item.name, id: Int(item.id)))
                    //                    tableList.append(TableList(name: "\(item.id)", id: 3))
                    tableList.append(TableList(name: item, id: 2))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "Category" {
            let fetchRequest = NSFetchRequest(entityName: "Category")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "gateway.name == %@", filterGateway!.name)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Category]
                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in distinctSorted {
                    //                    tableList.append(TableList(name: item.name, id: Int(item.id)))
                    //                    tableList.append(TableList(name: "\(item.id)", id: 4))
                    tableList.append(TableList(name: item, id: 4))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        
        if whatToFetch == "IBeacon" {
            let fetchRequest = NSFetchRequest(entityName: "IBeacon")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptors]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [IBeacon]
                for item in results {
                    tableList.append(TableList(name: item.name!, id: -1))
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
        case ScanTimerType = 7
        case iBeacon = 8
        case LevelsPick = 12
        case ZonesPick = 13
        case CategoriesPick = 14
    }
    override func viewWillAppear(animated: Bool) {
        if indexTab == PopOver.Gateways.rawValue {
            updateDeviceList("Gateway")
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.Levels.rawValue {
            updateDeviceList("Level")
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.Zones.rawValue {
            updateDeviceList("Zone")
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.Categories.rawValue {
            updateDeviceList("Category")
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.LevelsPick.rawValue {
            updateDeviceList("Level", withGateway: filterGateway!)
        } else if indexTab == PopOver.ZonesPick.rawValue {
            updateDeviceList("Zone", withGateway: filterGateway!)
        } else if indexTab == PopOver.CategoriesPick.rawValue {
            updateDeviceList("Category", withGateway: filterGateway!)
        } else if indexTab == PopOver.Scenes.rawValue {
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.ScanGateway.rawValue {
            tableList = chooseList
        } else if indexTab == PopOver.ScanTimerType.rawValue {
            tableList = chooseTimerTypeList
        } else if indexTab == PopOver.iBeacon.rawValue {
            updateDeviceList("IBeacon")
            tableList.insert(TableList(name: "No iBeacon", id: -1), atIndex: 0)
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
