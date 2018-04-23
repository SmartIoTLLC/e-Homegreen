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
            case .Ehomegreen   : return "Green IoT CONTROLS"
            case .Surveillance : return "IP Camera"
            case .Ehomeblue    : return "Blue IoT CONTROLS"
        }
    }
    static let allValues = [Ehomegreen, Surveillance, Ehomeblue]
}

struct CollapsableViewModel {
    let location: Location
    var children: [LocationDevice]
    var isCollapsed: Bool
    
    init(location: Location, children: [LocationDevice] = [], isCollapsed: Bool = true) {
        self.location    = location
        self.children    = children
        self.isCollapsed = isCollapsed
    }
}

class LocationViewController: PopoverVC  {
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    @IBOutlet weak var ipHostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var gatewayTableView: UITableView!
    
    var gateways:[Gateway] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    var user:User!
    var locationList:[CollapsableViewModel] = []
    var index = 0   // Which section is selected
    
    // add, edit and delete location
    @IBAction func btnAddNewLocation(_ sender: AnyObject) {
        self.showAddLocation(nil, user: user).delegate = self
        
    }
    @IBAction func deleteLocation(_ sender: UIButton) {
        deleteLocation(via: sender)
    }
    @IBAction func editLocation(_ sender: AnyObject) {
        editLocation(via: sender)
    }
    @IBAction func addNewElementInLocation(_ sender: UIButton) {
        addNewElement(sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
        updateLocationList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gatewayTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan" {
            if let vc = segue.destination as? ScanViewController {
                if let gateway = sender as? Gateway { vc.gateway = gateway }
            }
        }
    }

    override func nameAndId(_ name: String, id: String) {
        if TypeOfLocationDevice.Ehomegreen.description == name {
            self.showConnectionSettings(nil, location: locationList[index].location, gatewayType: TypeOfLocationDevice.Ehomegreen).delegate = self
        }
        if TypeOfLocationDevice.Surveillance.description == name {
            showSurveillanceSettings(nil, location: locationList[index].location).delegate = self
        }
        if TypeOfLocationDevice.Ehomeblue.description == name {
            self.showConnectionSettings(nil, location: locationList[index].location, gatewayType: TypeOfLocationDevice.Ehomeblue).delegate = self
        }
    }

}

// MARK: - TableView Data Source
extension LocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as? LocationCell {
                cell.setItem(locationList[indexPath.section].location, isColapsed: locationList[indexPath.section].isCollapsed, tag: indexPath.section)
                return cell
            }
            
        } else {
            let location = locationList[indexPath.section]
            let device = location.children[indexPath.row - 1]
            switch device.typeOfLocationDevice {
                
                case TypeOfLocationDevice.Ehomegreen:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "gatewayCell") as? GatewayCell {
                        if let gateway = device.device as? Gateway {
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
        if locationList[section].isCollapsed { return (locationList[section].children).count + 1 } else { return 1 }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return locationList.count
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

// MARK: - TableView Delegate
extension LocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelected(at: indexPath, on: tableView)
    }

}

// MARK: - Setup views
extension LocationViewController {
    func updateViews() {
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        gatewayTableView.estimatedRowHeight = 44.0
        gatewayTableView.rowHeight          = UITableViewAutomaticDimension
        self.gatewayTableView.contentInset  = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        titleView.setTitle("Locations")
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        navigationItem.titleView = titleView
    }
}

// MARK: - Logic
extension LocationViewController {
    fileprivate func didSelected(at indexPath: IndexPath, on tableView: UITableView) {
        if indexPath.row == 0 {
            locationList[indexPath.section].isCollapsed = !locationList[indexPath.section].isCollapsed
            tableView.reloadData()
        } else {
            let device = locationList[indexPath.section].children[indexPath.row - 1]
            if let surv = device.device as? Surveillance {
                DispatchQueue.main.async(execute: { self.showSurveillanceSettings(surv, location: surv.location).delegate = self })
            }
            if let gateway = device.device as? Gateway {
                DispatchQueue.main.async(execute: {
                    if let type = TypeOfLocationDevice(rawValue: Int(gateway.gatewayType)) { self.showConnectionSettings(gateway, location: nil, gatewayType: type).delegate = self }
                })
            }
        }
        index = indexPath.section
    }
    
    // Edit location, when delete or add camera/gateway remember index and reload only that section
    func editLocation(){
        let locationEdit = locationList[index].location
        locationList[index].children = []
        var listOfChildrenDevice:[LocationDevice] = []
        if let listOfGateway = locationEdit.gateways?.allObjects as? [Gateway] {
            for gateway in listOfGateway {
                if Int(gateway.gatewayType) == TypeOfLocationDevice.Ehomegreen.rawValue { listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomegreen))
                } else { listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomeblue)) }
            }
        }
        if let listOfSurveillance = locationEdit.surveillances {
            for surv in listOfSurveillance { listOfChildrenDevice.append(LocationDevice(device: surv as AnyObject, typeOfLocationDevice: .Surveillance)) }
        }
        locationList[index].children = listOfChildrenDevice
        gatewayTableView.reloadData()
    }
    
    fileprivate func deleteLocation(via sender: UIButton) {
        showAlertView(sender, message: "Delete location?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                DatabaseLocationController.shared.stopMonitoringLocation(self.locationList[sender.tag].location)
                DatabaseLocationController.shared.deleteLocation(self.locationList[sender.tag].location)
                self.reloadLocations()
            }
        }
    }
    
    fileprivate func editLocation(via sender: AnyObject) {
        let location = locationList[sender.tag].location
        showAddLocation(location, user: nil).delegate = self
    }
    
    fileprivate func addNewElement(sender: UIButton) {
        index = sender.tag
        var popoverList:[PopOverItem] = []
        for item in TypeOfLocationDevice.allValues { popoverList.append(PopOverItem(name: item.description, id: "")) }
        
        openPopover(sender, popOverList:popoverList) // add camera or gateway
    }
    
    func reloadLocations() {
        updateLocationList()
        gatewayTableView.reloadData()
    }
    
    func updateLocationList() {
        locationList = []
        let location = DatabaseLocationController.shared.getLocation(user)
        
        for item in location {
            var listOfChildrenDevice:[LocationDevice] = []
            if let listOfGateway = item.gateways?.allObjects as? [Gateway] {
                
                for gateway in listOfGateway {
                    if Int(gateway.gatewayType) == TypeOfLocationDevice.Ehomegreen.rawValue { listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomegreen))
                    } else { listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomeblue)) }
                }
            }
            
            if let listOfSurveillance = item.surveillances {
                for surv in listOfSurveillance { listOfChildrenDevice.append(LocationDevice(device: surv as AnyObject, typeOfLocationDevice: .Surveillance)) }
            }
            locationList.append(CollapsableViewModel(location: item, children: listOfChildrenDevice))
        }
    }
}

extension LocationViewController: GatewayCellDelegate {
    func deleteGateway(_ gateway: Gateway, sender:UIButton) {
        showAlertView(sender, message: "Delete e-Homegreen?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                DatabaseGatewayController.shared.deleteGateway(gateway)
                DispatchQueue.main.async(execute: { self.editLocation() } )
            }
        }
    }
    
    func scanDevice(_ gateway: Gateway) {
        performSegue(withIdentifier: "scan", sender: gateway)
    }
    
    // Turn on/off gateway
    func changeSwitchValue(_ gateway:Gateway, gatewaySwitch:UISwitch) {
        if gatewaySwitch.isOn == true { gateway.turnedOn = true } else { gateway.turnedOn = false }
        CoreDataController.sharedInstance.saveChanges()
        gatewayTableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
}

extension LocationViewController: SurveillanceCellDelegate {
    func deleteSurveillance(_ surveillance:Surveillance, sender:UIButton) {
        showAlertView(sender, message: "Delete camera?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                DatabaseSurveillanceController.shared.deleteSurveillance(surveillance)
                DispatchQueue.main.async(execute: { self.editLocation() } )
            }
        }
    }
    func scanURL(_ surveillance:Surveillance) {
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
    func addEditSurveillanceFinished() {
        editLocation()
    }
}
