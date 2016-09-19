//
//  LocationViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

struct LocationDevice {
    var device:AnyObject
    var typeOfLocationDevice:TypeOfLocationDevice
}

enum TypeOfLocationDevice:String{
    case Ehomegreen = "e-Homegreen", Surveillance = "IP Camera", Ehomeblue = "e-Homeblue"
    var description:String{
        switch self{
        case Ehomegreen: return "e-Homegreen"
        case Surveillance: return "IP Camera"
        case Ehomeblue: return "e-Homeblue"
        }
    }
    static let allValues = [Ehomegreen, Surveillance, Ehomeblue]
}

struct CollapsableViewModel {
    let location: Location
    var children: [LocationDevice]
    var isCollapsed: Bool
    
    init(location: Location, children: [LocationDevice] = [], isCollapsed: Bool = true) {
        self.location = location
        self.children = children
        self.isCollapsed = isCollapsed
    }
}

class LocationViewController: PopoverVC  {
    
    @IBOutlet weak var ipHostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var gatewayTableView: UITableView!
    
    var gateways:[Gateway] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    var user:User!
    var locationList:[CollapsableViewModel] = []
    var index = 0   // Which section is selected
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gatewayTableView.estimatedRowHeight = 44.0
        gatewayTableView.rowHeight = UITableViewAutomaticDimension
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateLocationList()
    }
    
    override func viewWillAppear(animated: Bool) {
        gatewayTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scan" {
            if let vc = segue.destinationViewController as? ScanViewController {
                if let gateway = sender as? Gateway{
                    vc.gateway = gateway
                }
            }
        }
    }
    
    // add, edit and delete location
    @IBAction func btnAddNewLocation(sender: AnyObject) {
        self.showAddLocation(nil, user: user).delegate = self
        
    }
    
    @IBAction func deleteLocation(sender: UIButton) {
        showAlertView(sender, message: "Delete location?") { (action) in
            if action == ReturnedValueFromAlertView.Delete {
                DatabaseLocationController.shared.stopMonitoringLocation(self.locationList[sender.tag].location)
                DatabaseLocationController.shared.deleteLocation(self.locationList[sender.tag].location)
                self.reloadLocations()
            }
        }
    }
    
    @IBAction func editLocation(sender: AnyObject) {
        self.showAddLocation(locationList[sender.tag].location, user: nil).delegate = self
    }
    
    @IBAction func addNewElementInLocation(sender: UIButton) {
        index = sender.tag
        var popoverList:[PopOverItem] = []
        for item in TypeOfLocationDevice.allValues{
            popoverList.append(PopOverItem(name: item.rawValue, id: ""))
        }
        
        openPopover(sender, popOverList:popoverList)
    }   // add camera or gateway

    override func nameAndId(name: String, id: String) {
        if TypeOfLocationDevice.Ehomegreen.rawValue == name{
            self.showConnectionSettings(nil, location: locationList[index].location, gatewayType: TypeOfLocationDevice.Ehomegreen.description).delegate = self
        }
        if TypeOfLocationDevice.Surveillance.rawValue == name{
            showSurveillanceSettings(nil, location: locationList[index].location).delegate = self
        }
        if TypeOfLocationDevice.Ehomeblue.rawValue == name{
            self.showConnectionSettings(nil, location: locationList[index].location, gatewayType: TypeOfLocationDevice.Ehomeblue.description).delegate = self
        }
    }
    
    func reloadLocations(){
        updateLocationList()
        gatewayTableView.reloadData()
    }
    
    func updateLocationList(){
        locationList = []
        let location = DatabaseLocationController.shared.getLocation(user)
        
        for item in location{
            var listOfChildrenDevice:[LocationDevice] = []
            if let listOfGateway = item.gateways?.allObjects as? [Gateway]{
                for gateway in listOfGateway{
                    if gateway.gatewayType == TypeOfLocationDevice.Ehomegreen.description{
                        listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomegreen))
                    }else{
                        listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomeblue))
                    }
                }
            }
            if let listOfSurveillance = item.surveillances {
                for surv in listOfSurveillance{
                    listOfChildrenDevice.append(LocationDevice(device: surv, typeOfLocationDevice: .Surveillance))
                }
            }
            locationList.append(CollapsableViewModel(location: item, children: listOfChildrenDevice))
        }
    }
    
    // Edit location, when delete or add camera/gateway remember index and reload only that section
    func editLocation(){
        let locationEdit = locationList[index].location
        locationList[index].children = []
        var listOfChildrenDevice:[LocationDevice] = []
        if let listOfGateway = locationEdit.gateways?.allObjects as? [Gateway] {
            for gateway in listOfGateway{
                if gateway.gatewayType == TypeOfLocationDevice.Ehomegreen.description{
                    listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomegreen))
                }else{
                    listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomeblue))
                }
            }
        }
        if let listOfSurveillance = locationEdit.surveillances {
            for surv in listOfSurveillance{
                listOfChildrenDevice.append(LocationDevice(device: surv, typeOfLocationDevice: .Surveillance))
            }
        }
        locationList[index].children = listOfChildrenDevice
        gatewayTableView.reloadData()
    }
}

extension LocationViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.row == 0{
            if let cell = tableView.dequeueReusableCellWithIdentifier("locationCell") as? LocationCell {
                cell.setItem(locationList[indexPath.section].location, isColapsed: locationList[indexPath.section].isCollapsed)
                cell.addButton.tag = indexPath.section
                cell.editButton.tag = indexPath.section
                cell.deleteButton.tag = indexPath.section
                return cell
            }
        }else{
            let location = locationList[indexPath.section]
            let device = location.children[indexPath.row - 1]
            switch device.typeOfLocationDevice{
            case TypeOfLocationDevice.Ehomegreen:
                if let cell = tableView.dequeueReusableCellWithIdentifier("gatewayCell") as? GatewayCell {
                    if let gateway = device.device as? Gateway{
                        cell.setEhomegreen()
                        cell.delegate = self
                        cell.setItem(gateway)
                    }
                    return cell
                }
                break
            case TypeOfLocationDevice.Surveillance:
                if let cell = tableView.dequeueReusableCellWithIdentifier("survCell") as? SurvCell {
                    if let surv = device.device as? Surveillance{
                        cell.delegate = self
                        cell.setItem(surv)
                    }
                    return cell
                }
                break
            case TypeOfLocationDevice.Ehomeblue:
                if let cell = tableView.dequeueReusableCellWithIdentifier("gatewayCell") as? GatewayCell {
                    if let gateway = device.device as? Gateway{
                        cell.setEhomeblue()
                        cell.delegate = self
                        cell.setItem(gateway)
                    }
                    return cell
                }
                break
            }
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = ""
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locationList[section].isCollapsed{
            return (locationList[section].children).count + 1
        }else{
            return 1
        }
        
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clearColor()
        return footer
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return locationList.count
    }
}

extension LocationViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == 0{
            locationList[indexPath.section].isCollapsed = !locationList[indexPath.section].isCollapsed
            tableView.reloadData()
        }else{
            let device = locationList[indexPath.section].children[indexPath.row - 1]
            if let surv = device.device as? Surveillance{
                dispatch_async(dispatch_get_main_queue(),{
                    self.showSurveillanceSettings(surv, location: surv.location).delegate = self
                })
            }
            if let gateway = device.device as? Gateway{
                dispatch_async(dispatch_get_main_queue(),{
                    self.showConnectionSettings(gateway, location: nil, gatewayType: gateway.gatewayType).delegate = self
                })
            }
        }
        index = indexPath.section
    }
}

extension LocationViewController: GatewayCellDelegate{
    func deleteGateway(gateway: Gateway, sender:UIButton) {
        showAlertView(sender, message: "Delete e-Homegreen?") { (action) in
            if action == ReturnedValueFromAlertView.Delete {
                DatabaseGatewayController.shared.deleteGateway(gateway)
                dispatch_async(dispatch_get_main_queue(),{
                    self.editLocation()
                })
            }
        }
    }
    
    func scanDevice(gateway: Gateway) {
        performSegueWithIdentifier("scan", sender: gateway)
    }
    
    // Turn on/off gateway
    func changeSwitchValue(gateway:Gateway, gatewaySwitch:UISwitch){
        if gatewaySwitch.on == true {
            gateway.turnedOn = true
        }else {
            gateway.turnedOn = false
        }
        CoreDataController.shahredInstance.saveChanges()
        gatewayTableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
}

extension LocationViewController: SurveillanceCellDelegate {
    func deleteSurveillance(surveillance:Surveillance, sender:UIButton){
        showAlertView(sender, message: "Delete camera?") { (action) in
            if action == ReturnedValueFromAlertView.Delete{
                DatabaseSurveillanceController.shared.deleteSurveillance(surveillance)
                dispatch_async(dispatch_get_main_queue(),{
                    self.editLocation()
                })
            }
        }
    }
    func scanURL(surveillance:Surveillance){
        showCameraUrls(self.view.center, surveillance: surveillance)
    }
}

extension LocationViewController: AddEditLocationDelegate{
    func editAddLocationFinished() {
        reloadLocations()
    }
}

extension LocationViewController: AddEditGatewayDelegate{
    func addEditGatewayFinished() {
        editLocation()
    }
}

extension LocationViewController: AddEditSurveillanceDelegate{
    func addEditSurveillanceFinished(){
        editLocation()
    }
}