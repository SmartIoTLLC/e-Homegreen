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
    optional func saveText (text : String, gateway:Gateway)
    optional func clickedOnGatewayWithIndex (index : Int)
    optional func clickedOnGatewayWithObjectID(objectId:String)
    optional func returnNameAndPath(name:String, path:String?)
}

class PathAndName {
    var name:String
    var path:String?
    init(name: String, path:String?) {
        self.name = name
        self.path = path
    }
}

enum PowerOption{
    case ShutDown, Restart, Sleep, Hibernate, LogOff
    var description:String{
        switch self{
        case ShutDown: return "Shut Down"
        case Restart: return "Restart"
        case Sleep: return "Sleep"
        case Hibernate: return "Hibernate"
        case LogOff: return "LogOff"
        }
    }
    static let allValues = [ShutDown, Restart, Sleep, Hibernate, LogOff]
}

class TableList {
    var name:String
    var id:Int
    init(name: String, id:Int) {
        self.name = name
        self.id = id
    }
}
class SecurityFeedback {
    var name:String
    var gateway:Gateway
    init(name: String, gateway:Gateway) {
        self.name = name
        self.gateway = gateway
    }
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
        TableList(name: "Flag", id: -1)]
    var chooseTimerTypeList:[TableList] = [TableList(name: "Once", id: 7),
        TableList(name: "Daily", id: 7),
        TableList(name: "Monthly", id: 7),
        TableList(name: "Yearly", id: 7),
        TableList(name: "Hourly", id: 7),
        TableList(name: "Minutely", id: 7),
        TableList(name: "Countdown", id: 7)]
    var locationAddOption:[TableList] = [TableList(name: TypeOfLocationDevice.Gateway.description, id: -1),
        TableList(name: TypeOfLocationDevice.Surveillance.description, id: -1)]
    var tableList:[AnyObject] = []
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var error:NSError? = nil
    var filterLocation:Location?
    var locationSearch:[String] = ["All", "All", "All", "All", "All", "All", "All"]
    var device:Device?
    @IBOutlet weak var table: UITableView!
    
    var indexTab: Int = 0
    var delegate : PopOverIndexDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        table.layer.cornerRadius = 8
        
        // Do any additional setup after loading the view.
    }
    func updateDeviceList (whatToFetch:String, withLocation location:Location) {
        if whatToFetch == "Zone" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "level != %@", NSNumber(short: 0))
            let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "location == %@", location)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateTwo, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
                let distinct = NSSet(array: results.map { String($0.name!) }).allObjects as! [String]
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
//            let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateThree = NSPredicate(format: "location == %@", location)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
                let distinct = NSSet(array: results.map { String($0.name!) }).allObjects as! [String]
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
            let predicateThree = NSPredicate(format: "location == %@", location)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne, predicateThree])
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Category]
                let distinct = NSSet(array: results.map { String($0.name!) }).allObjects as! [String]
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
    func returnSuggestions(whatToFetch:String, location:Location, locationSearch:[String]) {
        if whatToFetch == "Level" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            var predicateArray:[NSPredicate] = []
            let predicateOne = NSPredicate(format: "level == %@", NSNumber(integer: 0))
            predicateArray.append(predicateOne)
            let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            predicateArray.append(predicateTwo)
            let predicateThree = NSPredicate(format: "location.name == %@", location.name!)
            predicateArray.append(predicateThree)
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
//                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
//                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                let levelNames = results.map({ (let level) -> String in
                    if let name = level.name {
                        return name
                    }
                    return ""
                }).filter({ (let name) -> Bool in
                    return name != "" ? true : false
                }).sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in levelNames {
                    tableList.append(TableList(name: item, id: 3))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Zone" {
            let fetchRequest = NSFetchRequest(entityName: "Zone")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            let predicateTwo = NSPredicate(format: "location.name == %@", location.name!)
            let predicateThree = NSPredicate(format: "level != %@", NSNumber(integer: 0))
            var predicateArray:[NSPredicate] = []
            predicateArray.append(predicateOne)
            predicateArray.append(predicateTwo)
            predicateArray.append(predicateThree)
            if let levelId = Int(locationSearch[1]) {
                let predicate = NSPredicate(format: "level == %@", NSNumber(integer: levelId))
                predicateArray.append(predicate)
            }
            if let levelId = Int(locationSearch[1]) {
                let predicate = NSPredicate(format: "ANY location.zones.level = %@", NSNumber(integer: levelId))
                predicateArray.append(predicate)
            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Zone]
//                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
//                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
//                for item in distinctSorted {
//                    tableList.append(TableList(name: item, id: 2))
//                }
                let zoneNames = results.map({ (let zone) -> String in
                    if let name = zone.name {
                        return name
                    }
                    return ""
                }).filter({ (let name) -> Bool in
                    return name != "" ? true : false
                }).sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in zoneNames {
                    tableList.append(TableList(name: item, id: 3))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Category" {
            let fetchRequest = NSFetchRequest(entityName: "Category")
            let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
            var predicateArray:[NSPredicate] = []
            let predicateOne = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
            predicateArray.append(predicateOne)
            let predicateTwo = NSPredicate(format: "location.name == %@", location.name!)
            predicateArray.append(predicateTwo)
            //            if let levelId = Int(locationSearch[1]) {
            //                let predicate = NSPredicate(format: "ANY gateway.zones.level == %@", NSNumber(integer: levelId))
            //                predicateArray.append(predicate)
            //            }
            //            if let zoneId = Int(locationSearch[2]) {
            //                let predicate = NSPredicate(format: "ANY gateway.zones.id == %@", NSNumber(integer: zoneId))
            //                predicateArray.append(predicate)
            //            }
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.sortDescriptors = [sortDescriptors]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Category]
//                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
//                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
//                for item in distinctSorted {
//                    tableList.append(TableList(name: item, id: 4))
//                }
                let categoryNames = results.map({ (let category) -> String in
                    if let name = category.name {
                        return name
                    }
                    return ""
                }).filter({ (let name) -> Bool in
                    return name != "" ? true : false
                }).sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in categoryNames {
                    tableList.append(TableList(name: item, id: 3))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
        }
    }
    func updateDeviceList (whatToFetch:String) {
        // Gateway had to return distinct values, but with II stage, and implementation of Location, this was no longer needed
        if whatToFetch == "Gateway" {
            let fetchRequest = NSFetchRequest(entityName: "Gateway")
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne])
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Gateway]
                let distinct = NSSet(array: results.map { String($0.name) }).allObjects as! [String]
                print(distinct)
                let distinctSorted = distinct.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                print(distinctSorted)
                for item in distinctSorted {
                    tableList.append(TableList(name: item, id: -1))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        // Location was intended to be distinct and unique, but there could be a situation with two locations with same name in ~ 0.0000001% of time
        if whatToFetch == "Location" {
            let fetchRequest = NSFetchRequest(entityName: "Location")
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//            let predicateOne = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
//            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateOne])
            fetchRequest.sortDescriptors = [sortDescriptor]
//            fetchRequest.predicate = compoundPredicate
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Location]
                let locationNames = results.map({ (let location) -> String in
                    if let name = location.name {
                        return name
                    }
                    return ""
                }).filter({ (let name) -> Bool in
                    return name != "" ? true : false
                }).sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                for item in locationNames {
                    tableList.append(TableList(name: item, id: -1))
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
        if whatToFetch == "Security" {
            let fetchRequest = NSFetchRequest(entityName: "Gateway")
            let sortDescriptorOne = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptorTwo = NSSortDescriptor(key: "gatewayDescription", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo]
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Gateway]
                for item in results {
                    tableList.append(SecurityFeedback(name: "\(item.name) \(item.gatewayDescription)", gateway: item))
                }
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "PowerOption" {
            for option in PowerOption.allValues{
                tableList.append(PathAndName(name: option.description, path: nil))
            }
            
        }
        if whatToFetch == "PlayOption" {
            if let device = device{
                if let list = device.pcCommands {
                    if let commandArray = Array(list) as? [PCCommand] {
                        for item in commandArray{
                            if item.isRunCommand == false{
                                tableList.append(PathAndName(name: item.name!, path: item.comand))
                            }
                        }
                    }
                }
            }
            
        }
        if whatToFetch == "RunOption" {
            if let device = device{
                if let list = device.pcCommands {
                    if let commandArray = Array(list) as? [PCCommand] {
                        for item in commandArray{
                            if item.isRunCommand == true{
                                tableList.append(PathAndName(name: item.name!, path: item.comand))
                            }
                        }
                    }
                }
            }
        }
    }
    
    enum PopOver: Int {
        case Location = 0
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
        case SecurityGateways = 15
        case ControlType = 21
        case DeviceInputMode = 22
        case PowerOption = 23
        case PlayOption = 24
        case RunOption = 25
        case LocationOptions = 26
    }
    override func viewWillAppear(animated: Bool) {
        if indexTab == PopOver.Location.rawValue {
            updateDeviceList("Location")
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.Gateways.rawValue {
            updateDeviceList("Gateway")
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.Levels.rawValue {
            returnSuggestions("Level", location: filterLocation!, locationSearch: locationSearch)
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.Zones.rawValue {
            returnSuggestions("Zone", location: filterLocation!, locationSearch: locationSearch)
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.Categories.rawValue {
            returnSuggestions("Category", location: filterLocation!, locationSearch: locationSearch)
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.LevelsPick.rawValue {
            updateDeviceList("Level", withLocation: filterLocation!)
        } else if indexTab == PopOver.ZonesPick.rawValue {
            updateDeviceList("Zone", withLocation: filterLocation!)
        } else if indexTab == PopOver.CategoriesPick.rawValue {
            updateDeviceList("Category", withLocation: filterLocation!)
        } else if indexTab == PopOver.Scenes.rawValue {
            tableList.insert(TableList(name: "All", id: -1), atIndex: 0)
        } else if indexTab == PopOver.ScanGateway.rawValue {
            tableList = chooseList
        } else if indexTab == PopOver.ScanTimerType.rawValue {
            tableList = chooseTimerTypeList
        } else if indexTab == PopOver.iBeacon.rawValue {
            updateDeviceList("IBeacon")
            tableList.insert(TableList(name: "No iBeacon", id: -1), atIndex: 0)
        } else if indexTab == PopOver.SecurityGateways.rawValue {
            updateDeviceList("Security")
        } else if indexTab == PopOver.PowerOption.rawValue {
            updateDeviceList("PowerOption")
        } else if indexTab == PopOver.PlayOption.rawValue {
            updateDeviceList("PlayOption")
        } else if indexTab == PopOver.RunOption.rawValue {
            updateDeviceList("RunOption")
        } else if indexTab == PopOver.LocationOptions.rawValue {
            tableList = locationAddOption
        } else if indexTab == PopOver.ControlType.rawValue {
            if let type = device?.type {
                changeControlType(type)
            } else {
                changeControlType("")
            }
        } else if indexTab == PopOver.DeviceInputMode.rawValue {
            tableList = [TableList(name: DigitalInput.Generic.description(), id: 22), TableList(name: DigitalInput.NormallyOpen.description(), id: 22), TableList(name: DigitalInput.NormallyClosed.description(), id: 22), TableList(name: DigitalInput.MotionSensor.description(), id: 22), TableList(name: DigitalInput.ButtonNormallyOpen.description(), id: 22), TableList(name: DigitalInput.ButtonNormallyClosed.description(), id: 22)]
        }
    }
    func changeControlType (type:String) {
        switch type  {
        case ControlType.Dimmer:
            tableList.append(TableList(name: ControlType.Dimmer, id: 21))
            tableList.append(TableList(name: ControlType.Relay, id: 21))
        case ControlType.Relay:
            tableList.append(TableList(name: ControlType.Relay, id: 21))
            tableList.append(TableList(name: ControlType.Dimmer, id: 21))
            tableList.append(TableList(name: ControlType.Curtain, id: 21))
        default: tableList.append("Not possible")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("pullCell") as? PullDownViewCell {
            if let list = tableList as? [TableList] {
                cell.tableItem.text = list[indexPath.row].name
            } else if let list = tableList as? [SecurityFeedback] {
                cell.tableItem.text = list[indexPath.row].name
            } else if let list = tableList as? [PathAndName]{
                cell.tableItem.text = list[indexPath.row].name
            }
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let list = tableList as? [TableList] {
            delegate?.saveText!(list[indexPath.row].name, id: list[indexPath.row].id)
        } else if let list = tableList as? [SecurityFeedback] {
            delegate?.saveText!(list[indexPath.row].name, gateway: list[indexPath.row].gateway)
        } else if let list = tableList as? [PathAndName]{
            delegate?.returnNameAndPath!(list[indexPath.row].name, path: list[indexPath.row].path)
        }
        
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
