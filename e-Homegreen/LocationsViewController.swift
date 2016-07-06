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

enum TypeOfLocationDevice{
    case Ehomegreen, Surveillance
    var description:String{
        switch self{
        case Ehomegreen: return "e-Homegreen"
        case Surveillance: return "IP Camera"
        }
    }
    static let allValues = [Ehomegreen, Surveillance]
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

class LocationViewController: UIViewController, UIPopoverPresentationControllerDelegate  {
    
    @IBOutlet weak var ipHostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var gatewayTableView: UITableView!
    
    var gateways:[Gateway] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    var user:User!
    var locationList:[CollapsableViewModel] = []
    var popoverVC:PopOverViewController = PopOverViewController()
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
    @IBAction func deleteLocation(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Delete location?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            DatabaseLocationController.shared.stopMonitoringLocation(self.locationList[sender.tag].location)
            DatabaseLocationController.shared.deleteLocation(self.locationList[sender.tag].location)
            self.reloadLocations()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    @IBAction func editLocation(sender: AnyObject) {
        self.showAddLocation(locationList[sender.tag].location, user: nil).delegate = self
    }
    @IBAction func addNewElementInLocation(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        index = sender.tag
        popoverVC.indexTab = 26
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
        
    }   // add camera or gateway
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
            if let listOfGateway = item.gateways {
                for gateway in listOfGateway{
                    listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomegreen))
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
        if let listOfGateway = locationEdit.gateways {
            for gateway in listOfGateway{
                listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Ehomegreen))
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
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
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
                    self.showConnectionSettings(gateway, location: nil).delegate = self
                })
            }
        }
        index = indexPath.section
    }
}

extension LocationViewController: GatewayCellDelegate{
    func deleteGateway(gateway: Gateway) {
        let optionMenu = UIAlertController(title: nil, message: "Delete e-Homegreen?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            DatabaseGatewayController.shared.deleteGateway(gateway)
            dispatch_async(dispatch_get_main_queue(),{
                self.editLocation()
            })
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
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
        saveChanges()
        gatewayTableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
}

extension LocationViewController: SurveillanceCellDelegate {
    func deleteSurveillance(surveillance:Surveillance){
        let optionMenu = UIAlertController(title: nil, message: "Delete camera?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            DatabaseSurveillanceController.shared.deleteSurveillance(surveillance)
            dispatch_async(dispatch_get_main_queue(),{
                self.editLocation()
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
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

extension LocationViewController: PopOverIndexDelegate{
    func saveText(text: String, id: Int) {
        if TypeOfLocationDevice.Ehomegreen.description == text{
            self.showConnectionSettings(nil, location: locationList[index].location).delegate = self
        }
        if TypeOfLocationDevice.Surveillance.description == text{
            showSurveillanceSettings(nil, location: locationList[index].location).delegate = self
        }
    }
}