//
//  ScanDevicesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanDevicesViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ProgressBarDelegate {
    
    @IBOutlet weak var rangeFrom: UITextField!
    @IBOutlet weak var rangeTo: UITextField!
    
    @IBOutlet weak var deviceTableView: UITableView!
//    var loader : ViewControllerUtils = ViewControllerUtils()
    
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var devices:[Device] = []
    var gateway:Gateway?
    
    func endEditingNow(){
        rangeFrom.resignFirstResponder()
        rangeTo.resignFirstResponder()
    }
    deinit {
        print("deinit - ScanDevicesViewController.swift")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "NameAndParametarsForDeviceRequested")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        print(parentViewController)
        print(presentingViewController)
        for device in gateway!.devices {
            devices.append(device as! Device)
        }
        refreshDeviceList()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        rangeFrom.text = "\(Int(gateway!.addressThree)+1)"
        rangeTo.text = "\(Int(gateway!.addressThree)+1)"
        //
        rangeFrom.inputAccessoryView = keyboardDoneButtonView
        rangeTo.inputAccessoryView = keyboardDoneButtonView
    }
    override func viewDidAppear(animated: Bool) {
        addObservers()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nameReceivedFromPLC:", name: "PLCdidFindNameForDevice", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceReceivedFromPLC:", name: "PLCDidFindDevice", object: nil)
    }    
    func removeObservers() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "NameAndParametarsForDeviceRequested")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "DevicesFromGatewayRequested")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "refreshDeviceListNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "PLCdidFindNameForDevice", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "PLCDidFindDevice", object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    func updateDeviceList () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Device")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            devices = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    // ======================= *** FINDING DEVICES FOR GATEWAY *** =======================
    
    var searchDeviceTimer:NSTimer?
    var searchForDeviceWithId:Int?
    var fromAddress:Int?
    var toAddress:Int?
    
    func checkIfGatewayDidGetDevice (timer:NSTimer) {
        if let index = timer.userInfo as? Int {
            updateDeviceList()
            if (timesRepeatedCounter + 1) != 4 {
                timesRepeatedCounter = timesRepeatedCounter + 1
                var deviceFound = false
                if devices.count > 0 {
                    for i in 0...devices.count-1 {
                        if Int(devices[i].address) == index {
                            deviceFound = true
                            break
                        }
                    }
                }
                if deviceFound {
                    if toAddress >= (searchForDeviceWithId!+1) {
                        timesRepeatedCounter = 0
                        searchForDeviceWithId = searchForDeviceWithId! + 1
                        searchDeviceTimer?.invalidate()
                        searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                        let address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                        setProgressBarParametarsForSearchingDevices(address)
                        SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway!)
                    } else {
                        dismissScaningControls()
                    }
                } else {
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    let address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    setProgressBarParametarsForSearchingDevices(address)
                    SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway!)
                }
            } else {
                if toAddress >= searchForDeviceWithId {
                    timesRepeatedCounter = 0
                    searchForDeviceWithId = searchForDeviceWithId! + 1
                    searchDeviceTimer?.invalidate()
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    let address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    setProgressBarParametarsForSearchingDevices(address)
                    SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway!)
                } else {
                    dismissScaningControls()
                }
            }
        }
    }
    
    func deviceReceivedFromPLC (notification:NSNotification) {
        if toAddress >= (searchForDeviceWithId!+1) {
            timesRepeatedCounter = 0
            searchForDeviceWithId = searchForDeviceWithId! + 1
            searchDeviceTimer?.invalidate()
            searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
            let address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
            setProgressBarParametarsForSearchingDevices(address)
            SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway!)
        } else {
            dismissScaningControls()
        }
    }
    
    func setProgressBarParametarsForSearchingDevices (address:[UInt8]) {
        var number:Int = Int(address[2])
        number = number - fromAddress! + 1
        let howMuchOf = toAddress!-fromAddress!+1
        pbFD?.lblHowMuchOf.text = "\(number)/\(howMuchOf)"
        pbFD?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(number)/Float(howMuchOf)*100) + " %"
        pbFD?.progressView.progress = Float(number)/Float(howMuchOf)
    }
    
    func setProgressBarParametarsForFindingNames (var index:Int) {
        index = index - fromAddress! + 1
        pbFN?.lblHowMuchOf.text = "\(index)/\(toAddress!-fromAddress!+1)"
        pbFN?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(index)/Float(toAddress!-fromAddress!+1)*100) + " %"
        pbFN?.progressView.progress = Float(index)/Float(toAddress!-fromAddress!+1)
    }
    func dismissScaningControls() {
        
        timesRepeatedCounter = 0
        
        //   For finding names
        index = 0
        deviceNameTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "NameAndParametarsForDeviceRequested")
        pbFN?.dissmissProgressBar()
        
        //   For finding devices
        searchForDeviceWithId = 0
        searchDeviceTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "DevicesFromGatewayRequested")
        pbFD?.dissmissProgressBar()
    }
    // ======================= *** FINDING NAMES FOR DEVICE *** =======================
    
    var deviceNameTimer:NSTimer?
    
    var index:Int = 0
    var timesRepeatedCounter:Int = 0
    
    func nameReceivedFromPLC (notification:NSNotification) {
        if let info = notification.userInfo! as? [String:Int] {
            if let deviceIndex = info["deviceIndexForFoundName"] {
                if deviceIndex == toAddress! {
                    dismissScaningControls()
                } else {
                    index = deviceIndex + 1
                    timesRepeatedCounter = 0
                    deviceNameTimer?.invalidate()
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                    sendCommandForFindingName(index: index)
                }
            }
        }
    }
    
    func checkIfDeviceDidGetName (timer:NSTimer) {
        if let deviceIndex = timer.userInfo as? Int {
            if (index != 0 || deviceIndex < index) && deviceIndex <= toAddress {
                timesRepeatedCounter += 1
                if timesRepeatedCounter < 3 {
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: deviceIndex, repeats: false)
                    sendCommandForFindingName(index: deviceIndex)
                } else {
                    if index == devices.count - 1 {
                        dismissScaningControls()
                    } else {
                        index = deviceIndex + 1
                        timesRepeatedCounter = 0
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                        sendCommandForFindingName(index: index)
                    }
                }
            } else {
                if index == 0 {
                    timesRepeatedCounter += 1
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: 0, repeats: false)
                    sendCommandForFindingName(index: 0)
                } else {
                    //   Najverovatnije je index veci od toAddress
                    dismissScaningControls()
                    print("VELIKI PROBLEM ANGAZUJ SVE LJDUE IZ FIRME I OKUPI VELIKI BRAIN TRUST, SNAGU I NADU NASE FIRME!")
                }
            }
        }
    }
    func sendCommandForFindingName (index index:Int) {
        setProgressBarParametarsForFindingNames(index)
//        index = index - 1
        if devices[index].type == "Dimmer" {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "curtainsRelay" || devices[index].type == "appliance" {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "hvac" {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getACName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "sensor" {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getSensorName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            SendingHandler.sendCommand(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
    }
    
    func refreshDeviceList() {
        updateDeviceList()
        deviceTableView.reloadData()
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
    func progressBarDidPressedExit() {
        dismissScaningControls()
    }
    
    
    // ======================= *** DELETING DEVICES FOR GATEWAY *** =======================
    
    func changeValueEnable (sender:UISwitch) {
        if sender.on {
            devices[sender.tag].isEnabled = NSNumber(bool: true)
        } else {
            devices[sender.tag].isEnabled = NSNumber(bool: false)
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
    }
    
    func changeValueVisible (sender:UISwitch) {
        if sender.on {
            devices[sender.tag].isVisible = NSNumber(bool: true)
        } else {
            devices[sender.tag].isVisible = NSNumber(bool: false)
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
    }
    
    var pbFD:ProgressBarVC?
    var pbFN:ProgressBarVC?
    @IBAction func findDevice(sender: AnyObject) {
        if rangeFrom.text != "" && rangeTo.text != "" {
            if let numberOne = Int(rangeFrom.text!), let numberTwo = Int(rangeTo.text!) {
                if numberTwo >= numberOne {
                    fromAddress = numberOne
                    toAddress = numberTwo
                    searchForDeviceWithId = numberOne
                    timesRepeatedCounter = 0
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "DevicesFromGatewayRequested")
                    pbFD = ProgressBarVC(title: "Finding devices", percentage: Float(fromAddress!)/Float(toAddress!), howMuchOf: "1 / \(toAddress!-fromAddress!+1)")
                    pbFD?.delegate = self
                    self.presentViewController(pbFD!, animated: true, completion: nil)
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    let address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway!)
                }
            }
        }
    }
    
    
    @IBAction func deleteAll(sender: AnyObject) {
        for var item = 0; item < devices.count; item++ {
            if devices[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(devices[item])
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    
    @IBAction func findNames(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NameAndParametarsForDeviceRequested")
        if rangeFrom.text != "" && rangeTo.text != "" {
            if let numberOne = Int(rangeFrom.text!), let numberTwo = Int(rangeTo.text!) {
                if devices.count != 0 {
                    if numberTwo >= numberOne  && numberTwo <= devices.count && numberOne >= 0 {
                        fromAddress = numberOne - 1
                        toAddress = numberTwo - 1
                        index = fromAddress!
                        timesRepeatedCounter = 0
                        pbFN = ProgressBarVC(title: "Finding names", percentage: 0.0, howMuchOf: "0 / \((fromAddress!-toAddress!)+1)")
                        pbFN?.delegate = self
                        self.presentViewController(pbFN!, animated: true, completion: nil)
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                        sendCommandForFindingName(index: index)
                    }
                }
            }
        }
    }
    
    func returnZoneWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func returnCategoryWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("scanCell") as? ScanCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblRow.text = "\(indexPath.row+1)."
            cell.lblDesc.text = "\(devices[indexPath.row].name)"
            cell.lblAddress.text = "Address: \(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].address))), Channel: \(devices[indexPath.row].channel)"
            cell.lblType.text = "Control Type: \(devices[indexPath.row].type)"
            cell.isEnabledSwitch.on = devices[indexPath.row].isEnabled.boolValue
            cell.lblZone.text = "Zone: \(returnZoneWithId(Int(devices[indexPath.row].zoneId))) Level: \(returnZoneWithId(Int(devices[indexPath.row].parentZoneId)))"
            cell.lblCategory.text = "Category: \(returnCategoryWithId(Int(devices[indexPath.row].categoryId)))"
            cell.isEnabledSwitch.tag = indexPath.row
            cell.isEnabledSwitch.addTarget(self, action: "changeValueEnable:", forControlEvents: UIControlEvents.ValueChanged)
            cell.isVisibleSwitch.on = devices[indexPath.row].isVisible.boolValue
            cell.isVisibleSwitch.tag = indexPath.row
            cell.isVisibleSwitch.addTarget(self, action: "changeValueVisible:", forControlEvents: UIControlEvents.ValueChanged)
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = deviceTableView.cellForRowAtIndexPath(indexPath)
        showChangeDeviceParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceTableView.contentOffset.y), device: devices[indexPath.row])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gateway!.devices.count
    }
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.deviceTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
            }
            let cancelDelete = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            deleteMenu.addAction(delete)
            deleteMenu.addAction(cancelDelete)
            if let presentationController = deleteMenu.popoverPresentationController {
                presentationController.sourceView = tableView.cellForRowAtIndexPath(indexPath)
                presentationController.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
            }
            self.presentViewController(deleteMenu, animated: true, completion: nil)
        })
        
        button.backgroundColor = UIColor.redColor()
        return [button]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Here needs to be deleted even devices that are from gateway that is going to be deleted
            appDel.managedObjectContext?.deleteObject(devices[indexPath.row])
            saveChanges()
            updateDeviceList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
        }
        
    }
    
}

class ScanCell:UITableViewCell{
    
    @IBOutlet weak var lblRow: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var isEnabledSwitch: UISwitch!
    @IBOutlet weak var isVisibleSwitch: UISwitch!
}
