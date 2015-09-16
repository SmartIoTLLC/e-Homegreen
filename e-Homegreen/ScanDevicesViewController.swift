//
//  ScanDevicesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanDevicesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var rangeFrom: UITextField!
    @IBOutlet weak var rangeTo: UITextField!
    
    @IBOutlet weak var deviceTableView: UITableView!
    var loader : ViewControllerUtils = ViewControllerUtils()
    
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var devices:[Device] = []
    var gateway:Gateway?
    
    func endEditingNow(){
        rangeFrom.resignFirstResponder()
        rangeTo.resignFirstResponder()        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        println(parentViewController)
        println(presentingViewController)
        if let parentVC = parentViewController as? ScanViewController {
            gateway = parentVC.gateway
            for device in gateway!.devices {
                devices.append(device as! Device)
            }
        }
        refreshDeviceList()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        var toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        rangeFrom.text = "\(Int(gateway!.addressThree)+1)"
        rangeTo.text = "\(Int(gateway!.addressThree)+1)"
//
        rangeFrom.inputAccessoryView = keyboardDoneButtonView
        rangeTo.inputAccessoryView = keyboardDoneButtonView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nameReceivedFromPLC:", name: "PLCdidFindNameForDevice", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceReceivedFromPLC:", name: "PLCDidFindDevice", object: nil)

        
        
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
        var fetchRequest = NSFetchRequest(entityName: "Device")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        var sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
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
                // OVDE JE PUKLO JEDNOM!!!
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
                        var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                        SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
                    } else {
                        loader.hideActivityIndicator()
                    }
                } else {
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
                }
            } else {
                if toAddress >= searchForDeviceWithId {
                    timesRepeatedCounter = 0
                    searchForDeviceWithId = searchForDeviceWithId! + 1
                    searchDeviceTimer?.invalidate()
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
                } else {
                    loader.hideActivityIndicator()
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
            var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
            SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
        } else {
            searchForDeviceWithId = 0
            timesRepeatedCounter = 0
            searchDeviceTimer?.invalidate()
            loader.hideActivityIndicator()
        }
    }
    
    func hideActivitIndicator () {
        loader.hideActivityIndicator()
    }
    
    // ======================= *** FINDING NAMES FOR DEVICE *** =======================
    
    var deviceNameTimer:NSTimer?
    
    
    
    var index:Int = 0
    var timesRepeatedCounter:Int = 0
    
    func nameReceivedFromPLC (notification:NSNotification) {
        if let info = notification.userInfo! as? [String:Int] {
            if let deviceIndex = info["deviceIndexForFoundName"] {
                if deviceIndex == devices.count-1 {
                    index = 0
                    timesRepeatedCounter = 0
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
            if index != 0 || deviceIndex < index {
                //                index = index + 1
                timesRepeatedCounter += 1
                if timesRepeatedCounter < 4 {
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: deviceIndex, repeats: false)
                    sendCommandForFindingName(index: deviceIndex)
                } else {
                    var newIndex = deviceIndex + 1
                    timesRepeatedCounter = 0
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: newIndex, repeats: false)
                    sendCommandForFindingName(index: newIndex)
                }
            }
        }
    }
    
    func sendCommandForFindingName (#index:Int) {
        if devices[index].type == "Dimmer" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "curtainsRelay" || devices[index].type == "appliance" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "hvac" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Function.getACName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "sensor" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Function.getSensorName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            SendingHandler(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
    }
    
    func getDevicesNames (timer:NSTimer) {
        if let index = timer.userInfo as? Int {
            sendCommandForFindingName(index: index)
        }
    }
    
    func refreshDeviceList() {
        updateDeviceList()
        deviceTableView.reloadData()
    }
    
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
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
    
    @IBAction func findDevice(sender: AnyObject) {
        if rangeFrom.text != "" && rangeTo.text != "" {
            if let numberOne = rangeFrom.text.toInt(), let numberTwo = rangeTo.text.toInt() {
                if numberTwo >= numberOne {
                    fromAddress = numberOne
                    toAddress = numberTwo
                    searchForDeviceWithId = numberOne
                    timesRepeatedCounter = 0
                    loader.showActivityIndicator(self.view)
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
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
        var index:Int
        if devices.count != 0 {
            index = 0
            timesRepeatedCounter = 0
            deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: 0, repeats: false)
            sendCommandForFindingName(index: 0)
        }
    }
    
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueReusableCellWithIdentifier("scanCell") as? ScanCell {
                cell.backgroundColor = UIColor.clearColor()
                cell.lblRow.text = "\(indexPath.row+1)."
                cell.lblDesc.text = "\(devices[indexPath.row].name)"
                cell.lblAddress.text = "Address: \(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].address))), Channel: \(devices[indexPath.row].channel)"
                cell.lblType.text = "Type: \(devices[indexPath.row].type)"
                cell.isEnabledSwitch.on = devices[indexPath.row].isEnabled.boolValue
                cell.isEnabledSwitch.tag = indexPath.row
                cell.isEnabledSwitch.addTarget(self, action: "changeValueEnable:", forControlEvents: UIControlEvents.ValueChanged)
                cell.isVisibleSwitch.on = devices[indexPath.row].isVisible.boolValue
                cell.isVisibleSwitch.tag = indexPath.row
                cell.isVisibleSwitch.addTarget(self, action: "changeValueVisible:", forControlEvents: UIControlEvents.ValueChanged)
    //
    //            return cell
    //        }
    //        }
    //        if tableView == sceneTableView {
    //            if let cell = tableView.dequeueReusableCellWithIdentifier("sceneCell") as? SceneCell {
    //                if choosedTab == .Scenes {
    //                    cell.backgroundColor = UIColor.clearColor()
    //                    cell.labelID.text = "\(choosedTabArray[indexPath.row].sceneId)"
    //                    cell.labelName.text = "\(choosedTabArray[indexPath.row].sceneName)"
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageOne) {
    //                        cell.imageOne.image = sceneImage
    //                    }
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageTwo) {
    //                        cell.imageTwo.image = sceneImage
    //                    }
    //                } else if choosedTab == .Events {
    //                    cell.backgroundColor = UIColor.clearColor()
    //                    cell.labelID.text = "\(choosedTabArray[indexPath.row].eventId)"
    //                    cell.labelName.text = "\(choosedTabArray[indexPath.row].eventName)"
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].eventImageOne) {
    //                        cell.imageOne.image = sceneImage
    //                    }
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].eventImageTwo) {
    //                        cell.imageTwo.image = sceneImage
    //                    }
    //                } else if choosedTab == .Sequences {
    //                    cell.backgroundColor = UIColor.clearColor()
    //                    cell.labelID.text = "\(choosedTabArray[indexPath.row].sequenceId)"
    //                    cell.labelName.text = "\(choosedTabArray[indexPath.row].sequenceName)"
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sequenceImageOne) {
    //                        cell.imageOne.image = sceneImage
    //                    }
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sequenceImageTwo) {
    //                        cell.imageTwo.image = sceneImage
    //                    }
    //                }
                    return cell
                }
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
            cell.textLabel?.text = "dads"
            return cell
    
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return gateway!.devices.count
        }

}

class ScanCell:UITableViewCell{
    
    @IBOutlet weak var lblRow: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var isEnabledSwitch: UISwitch!
    @IBOutlet weak var isVisibleSwitch: UISwitch!
}
