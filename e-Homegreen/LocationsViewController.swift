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

enum TypeOfLocationDevice:Int{
    case Ehomegreen = 0, Surveillance, Ehomeblue
    var description:String{
        switch self{
        case .Ehomegreen: return "e-Homegreen"
        case .Surveillance: return "IP Camera"
        case .Ehomeblue: return "e-Homeblue"
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
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.gatewayTableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        updateLocationList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gatewayTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan" {
            if let vc = segue.destination as? ScanViewController {
                if let gateway = sender as? Gateway{
                    vc.gateway = gateway
                }
            }
        }
    }
    
    // add, edit and delete location
    @IBAction func btnAddNewLocation(_ sender: AnyObject) {
        self.showAddLocation(nil, user: user).delegate = self
        
    }
    
    @IBAction func deleteLocation(_ sender: UIButton) {
        showAlertView(sender, message: "Delete location?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                DatabaseLocationController.shared.stopMonitoringLocation(self.locationList[sender.tag].location)
                DatabaseLocationController.shared.deleteLocation(self.locationList[sender.tag].location)
                self.reloadLocations()
            }
        }
    }
    
    @IBAction func editLocation(_ sender: AnyObject) {
        self.showAddLocation(locationList[sender.tag].location, user: nil).delegate = self
    }
    
    @IBAction func addNewElementInLocation(_ sender: UIButton) {
        index = sender.tag
        var popoverList:[PopOverItem] = []
        for item in TypeOfLocationDevice.allValues{
            popoverList.append(PopOverItem(name: item.description, id: ""))
        }
        
        openPopover(sender, popOverList:popoverList)
    }   // add camera or gateway

    override func nameAndId(_ name: String, id: String) {
        if TypeOfLocationDevice.Ehomegreen.description == name{
            self.showConnectionSettings(nil, location: locationList[index].location, gatewayType: TypeOfLocationDevice.Ehomegreen).delegate = self
        }
        if TypeOfLocationDevice.Surveillance.description == name{
            showSurveillanceSettings(nil, location: locationList[index].location).delegate = self
        }
        if TypeOfLocationDevice.Ehomeblue.description == name{
            self.showConnectionSettings(nil, location: locationList[index].location, gatewayType: TypeOfLocationDevice.Ehomeblue).delegate = self
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
                    if Int(gateway.gatewayType) == TypeOfLocationDevice.Ehomegreen.rawValue{
                        listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomegreen))
                    }else{
                        listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomeblue))
                    }
                }
            }
            if let listOfSurveillance = item.surveillances {
                for surv in listOfSurveillance{
                    listOfChildrenDevice.append(LocationDevice(device: surv as AnyObject, typeOfLocationDevice: .Surveillance))
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
                if Int(gateway.gatewayType) == TypeOfLocationDevice.Ehomegreen.rawValue{
                    listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomegreen))
                }else{
                    listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomeblue))
                }
            }
        }
        if let listOfSurveillance = locationEdit.surveillances {
            for surv in listOfSurveillance{
                listOfChildrenDevice.append(LocationDevice(device: surv as AnyObject, typeOfLocationDevice: .Surveillance))
            }
        }
        locationList[index].children = listOfChildrenDevice
        gatewayTableView.reloadData()
    }
}

extension LocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as? LocationCell {
                cell.setItem(locationList[(indexPath as NSIndexPath).section].location, isColapsed: locationList[indexPath.section].isCollapsed)
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
                if let cell = tableView.dequeueReusableCell(withIdentifier: "gatewayCell") as? GatewayCell {
                    if let gateway = device.device as? Gateway{
                        cell.setEhomegreen()
                        cell.delegate = self
                        cell.setItem(gateway)
                    }
                    return cell
                }
                break
            case TypeOfLocationDevice.Surveillance:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "survCell") as? SurvCell {
                    if let surv = device.device as? Surveillance{
                        cell.delegate = self
                        cell.setItem(surv)
                    }
                    return cell
                }
                break
            case TypeOfLocationDevice.Ehomeblue:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "gatewayCell") as? GatewayCell {
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = ""
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locationList[section].isCollapsed{
            return (locationList[section].children).count + 1
        }else{
            return 1
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return locationList.count
    }
}

extension LocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0{
            locationList[indexPath.section].isCollapsed = !locationList[indexPath.section].isCollapsed
            tableView.reloadData()
        }else{
            let device = locationList[indexPath.section].children[indexPath.row - 1]
            if let surv = device.device as? Surveillance{
                DispatchQueue.main.async(execute: {
                    self.showSurveillanceSettings(surv, location: surv.location).delegate = self
                })
            }
            if let gateway = device.device as? Gateway{
                DispatchQueue.main.async(execute: {
                    if let type = TypeOfLocationDevice(rawValue: Int(gateway.gatewayType)){
                        self.showConnectionSettings(gateway, location: nil, gatewayType: type).delegate = self
                    }
                })
            }
        }
        index = indexPath.section
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
}

extension LocationViewController: GatewayCellDelegate{
    func deleteGateway(_ gateway: Gateway, sender:UIButton) {
        showAlertView(sender, message: "Delete e-Homegreen?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                DatabaseGatewayController.shared.deleteGateway(gateway)
                DispatchQueue.main.async(execute: {
                    self.editLocation()
                })
            }
        }
    }
    
    func scanDevice(_ gateway: Gateway) {
        performSegue(withIdentifier: "scan", sender: gateway)
    }
    
    // Turn on/off gateway
    func changeSwitchValue(_ gateway:Gateway, gatewaySwitch:UISwitch){
        if gatewaySwitch.isOn == true {
            gateway.turnedOn = true
        }else {
            gateway.turnedOn = false
        }
        CoreDataController.shahredInstance.saveChanges()
        gatewayTableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
}

extension LocationViewController: SurveillanceCellDelegate {
    func deleteSurveillance(_ surveillance:Surveillance, sender:UIButton){
        showAlertView(sender, message: "Delete camera?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                DatabaseSurveillanceController.shared.deleteSurveillance(surveillance)
                DispatchQueue.main.async(execute: {
                    self.editLocation()
                })
            }
        }
    }
    func scanURL(_ surveillance:Surveillance){
        showCameraUrls(surveillance: surveillance)
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
