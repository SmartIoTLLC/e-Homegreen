//
//  ScanDevicesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

struct SearchParametars {
    let from:Int
    let to:Int
    let count:Int
    let initialPercentage:Float
}

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
//        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningDeviceName)
//        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningDevice)
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
        removeObservers()
        addObservers()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nameReceivedFromPLC:", name: NotificationKey.DidFindDeviceName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceReceivedFromPLC:", name: NotificationKey.DidFindDevice, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sensorParametarReceivedFromPLC:", name: NotificationKey.DidFindSensorParametar, object: nil)
    }    
    func removeObservers() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningDeviceName)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningDevice)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningSensorParametars)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidFindDeviceName, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidFindDevice, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidFindSensorParametar, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func returnThreeCharactersForByte (number:Int) -> String {
//        return String(format: "%03d",number)
//    }
    
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
    @IBAction func btnDeleteTextFields(sender: AnyObject) {
        rangeFrom.text = ""
        rangeTo.text = ""
    }
    
    // MARK: - FINDING DEVICES FOR GATEWAY
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
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDevice) {
            if let info = notification.userInfo! as? [String:Int] {
                if let deviceIndex = info["deviceAddresInGateway"] {
                    if deviceIndex == searchForDeviceWithId {
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
                }
            }
        }
    }
    func setProgressBarParametarsForSearchingDevices (address:[UInt8]) {
        print(address)
        var index:Int = Int(address[2])
        index = index - fromAddress! + 1
        let howMuchOf = toAddress!-fromAddress!+1
        pbFD?.lblHowMuchOf.text = "\(index) / \(howMuchOf)"
        pbFD?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(index)/Float(howMuchOf)*100) + " %"
        pbFD?.progressView.progress = Float(index)/Float(howMuchOf)
    }
    
    func setProgressBarParametarsForFindingNames (var index:Int) {
        index = index - fromAddress! + 1
        pbFN?.lblHowMuchOf.text = "\(index) / \(toAddress!-fromAddress!+1)"
        pbFN?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(index)/Float(toAddress!-fromAddress!+1)*100) + " %"
        pbFN?.progressView.progress = Float(index)/Float(toAddress!-fromAddress!+1)
    }
    
    func setProgressBarParametarsForFindingSensorParametar (deviceIndex:Int, numberInArray:Int) {
        if numberInArray == 7 {
            
        }
        if numberInArray == 8 {
            
        }
        if numberInArray == 9 {
            
        }
        pbFN?.lblHowMuchOf.text = "\(numberInArray+1) / \(arrayOfSensorAdresses.count)"
        pbFN?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(numberInArray+1)/Float(arrayOfSensorAdresses.count)*100) + " %"
        pbFN?.progressView.progress = Float(numberInArray+1)/Float(arrayOfSensorAdresses.count)
    }
    
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        //   For finding names
        index = 0
        deviceNameTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningDeviceName)
        pbFN?.dissmissProgressBar()
        
        //   For finding devices
        searchForDeviceWithId = 0
        searchDeviceTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningDevice)
        pbFD?.dissmissProgressBar()
        if !findSensorParametar {
            UIApplication.sharedApplication().idleTimerDisabled = false
        } else {
            findParametarsForSensor()
        }
    }
    
    // MARK: - FINDING NAMES FOR DEVICE
    // ======================= *** FINDING NAMES FOR DEVICE *** =======================
    
    var deviceNameTimer:NSTimer?
    
    var index:Int = 0
    var timesRepeatedCounter:Int = 0
    
    func nameReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            if let info = notification.userInfo! as? [String:Int] {
                if let deviceIndex = info["deviceIndexForFoundName"] {
                    if deviceIndex >= toAddress! {
                        dismissScaningControls()
                    } else {
                        index = deviceIndex + 1
                        timesRepeatedCounter = 0
                        deviceNameTimer?.invalidate()
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                        NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(deviceIndex)")
                        sendCommandForFindingName(index: index)
                    }
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
                    NSLog("func checkIfDeviceDidGetName \(index)")
                    sendCommandForFindingName(index: deviceIndex)
                } else {
                    if index == devices.count - 1 {
                        dismissScaningControls()
                    } else {
                        index = deviceIndex + 1
                        timesRepeatedCounter = 0
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                        NSLog("func checkIfDeviceDidGetName 2 \(index)")
                        sendCommandForFindingName(index: index)
                    }
                }
            } else {
                if index == 0 {
                    // uslo je jednom i non stop se ponavljalo
                    if timesRepeatedCounter < 3 {
                        timesRepeatedCounter += 1
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                        NSLog("func checkIfDeviceDidGetName 3 \(index)")
                        sendCommandForFindingName(index: 0)
                    } else {
                        if index == devices.count - 1 {
                            dismissScaningControls()
                        } else {
                            index = deviceIndex + 1
                            timesRepeatedCounter = 0
                            deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                            NSLog("func checkIfDeviceDidGetName 2 \(index)")
                            sendCommandForFindingName(index: index)
                        }
                    }
                } else {
                    //   Najverovatnije je index veci od toAddress
                    dismissScaningControls()
                    print("VELIKI PROBLEM ANGAZUJ SVE LJDUE IZ FIRME I OKUPI VELIKI BRAIN TRUST, SNAGU I NADU NASE FIRME!")
                }
            }
        }
    }
//    UIApplication.sharedApplication().idleTimerDisabled = true
    func sendCommandForFindingName(index index:Int) {
        setProgressBarParametarsForFindingNames(index)
        //        index = index - 1
        if devices[index].type == ControlType.Dimmer {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        print(devices[index].type)
        if devices[index].type == ControlType.Curtain {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getModuleName(address), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Relay {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Climate {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getACName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Sensor || devices[index].type == ControlType.HumanInterfaceSeries || devices[index].type == ControlType.Gateway {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getSensorName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            //            SendingHandler.sendCommand(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
//        if devices[index].type == ControlType.HumanInterfaceSeries {
//            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
//            SendingHandler.sendCommand(byteArray: Function.getModuleName(address), gateway: devices[index].gateway)
//            //            SendingHandler.sendCommand(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
//        }
    }
    func sendComandForSensorZone(deviceIndex deviceIndex:Int, numberInArray:Int) {
        setProgressBarParametarsForFindingSensorParametar(deviceIndex, numberInArray:numberInArray)
        if devices[deviceIndex].controlType == ControlType.Sensor || devices[deviceIndex].controlType == ControlType.HumanInterfaceSeries || devices[deviceIndex].controlType == ControlType.Gateway {
            let address = [UInt8(Int(devices[deviceIndex].gateway.addressOne)), UInt8(Int(devices[deviceIndex].gateway.addressTwo)), UInt8(Int(devices[deviceIndex].address))]
            SendingHandler.sendCommand(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[deviceIndex].channel))), gateway: devices[deviceIndex].gateway)
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
    
    
    // MARK: - DELETING DEVICES FOR GATEWAY
    // ======================= *** DELETING DEVICES FOR GATEWAY *** =======================
    
    func changeValueEnable (sender:UISwitch) {
        if sender.on {
            devices[sender.tag].isEnabled = NSNumber(bool: true)
        } else {
            devices[sender.tag].isEnabled = NSNumber(bool: false)
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: NotificationKey.RefreshDevice, object: nil)
    }
    
    func changeValueVisible (sender:UISwitch) {
        if sender.on {
            devices[sender.tag].isVisible = NSNumber(bool: true)
        } else {
            devices[sender.tag].isVisible = NSNumber(bool: false)
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: NotificationKey.RefreshDevice, object: nil)
    }
    
    var pbFD:ProgressBarVC?
    var pbFN:ProgressBarVC?
    
    @IBAction func findDevice(sender: AnyObject) {
        do {
            let sp = try returnSearchParametars(rangeFrom.text!, to: rangeTo.text!, isScaningNamesAndParametars: false)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningDevice)
            UIApplication.sharedApplication().idleTimerDisabled = true
            fromAddress = sp.from
            toAddress = sp.to
            searchForDeviceWithId = sp.from
            timesRepeatedCounter = 0
            pbFD = ProgressBarVC(title: "Finding devices", percentage: sp.initialPercentage, howMuchOf: "1 / \(sp.count)")
            pbFD?.delegate = self
            self.presentViewController(pbFD!, animated: true, completion: nil)
            searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
            let address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
            SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway!)
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    
    
    @IBAction func deleteAll(sender: AnyObject) {
        for var item = 0; item < devices.count; item++ {
            if devices[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(devices[item])
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }
    // MARK: - Sensor parametar
    //   ============================================   Sensor parametar   ============================================
    var findSensorParametar = false
    var arrayOfSensorAdresses:[Int] = []
    
    func findParametarsForSensor() {
        arrayOfSensorAdresses = []
        for var i = fromAddress!; i<=toAddress; i++ {
            if devices[i].controlType == ControlType.Sensor || devices[i].type == ControlType.HumanInterfaceSeries || devices[i].type == ControlType.Gateway {
                arrayOfSensorAdresses.append(i)
            }
        }
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningSensorParametars)
        index = 0
        timesRepeatedCounter = 0
        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfSensorDidGotParametar:", userInfo: index, repeats: false)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.pbFN = ProgressBarVC(title: "Finding sensor parametars", percentage: Float(1)/Float(self.arrayOfSensorAdresses.count), howMuchOf: "1 / \(self.arrayOfSensorAdresses.count)")
            self.pbFN?.delegate = self
            self.presentViewController(self.pbFN!, animated: true, completion: nil)
            self.sendComandForSensorZone(deviceIndex:self.arrayOfSensorAdresses[self.index], numberInArray:self.index)
        }
    }
    
    func sensorParametarReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningSensorParametars) {
            if let info = notification.userInfo! as? [String:Int] {
                if let deviceIndex = info["sensorIndexForFoundParametar"] {
                    if deviceIndex >= toAddress! {
                        findSensorParametar = false
                        dismissScaningControls()
                    } else {
                        index = index + 1
                        timesRepeatedCounter = 0
                        deviceNameTimer?.invalidate()
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfSensorDidGotParametar:", userInfo: index, repeats: false)
                        NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(deviceIndex)")
                        sendComandForSensorZone(deviceIndex: arrayOfSensorAdresses[index], numberInArray: index)
                    }
                }
            }
        }
    }
    
    func checkIfSensorDidGotParametar (timer:NSTimer) {
        if let deviceIndex = timer.userInfo as? Int {
//            if (index != 0 || deviceIndex < index) && deviceIndex <= toAddress {
            if (index != 0 || deviceIndex < index) && deviceIndex <= arrayOfSensorAdresses.last {
                timesRepeatedCounter += 1
                if timesRepeatedCounter < 3 {
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfSensorDidGotParametar:", userInfo: deviceIndex, repeats: false)
                    NSLog("func checkIfSensorDidGotParametar \(index)")
                    sendComandForSensorZone(deviceIndex:arrayOfSensorAdresses[index], numberInArray:index)
                } else {
                    if deviceIndex == arrayOfSensorAdresses.last {
                        findSensorParametar = false
                        dismissScaningControls()
                    } else {
                        index = index + 1
                        timesRepeatedCounter = 0
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfSensorDidGotParametar:", userInfo: index, repeats: false)
                        NSLog("func checkIfSensorDidGotParametar 2 \(index)")
                        sendComandForSensorZone(deviceIndex:arrayOfSensorAdresses[index], numberInArray:index)
                    }
                }
            } else {
                if index == 0 {
                    timesRepeatedCounter += 1
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfSensorDidGotParametar:", userInfo: index, repeats: false)
                    NSLog("func checkIfSensorDidGotParametar 3 \(index)")
                    sendComandForSensorZone(deviceIndex:arrayOfSensorAdresses[index], numberInArray:index)
                } else {
                    //   Najverovatnije je index veci od toAddress
                    findSensorParametar = false
                    dismissScaningControls()
                    print("VELIKI PROBLEM ANGAZUJ SVE LJDUE IZ FIRME I OKUPI VELIKI BRAIN TRUST, SNAGU I NADU NASE FIRME!")
                }
            }
        }
    }
    // MARK: - Find names
    //   ============================================   Sensor parametar   ============================================
    @IBAction func findNames(sender: AnyObject) {
        do {
            let sp = try returnSearchParametars(rangeFrom.text!, to: rangeTo.text!, isScaningNamesAndParametars: true)
            if devices.count != 0 {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningDeviceName)
                for var i = sp.from-1; i <= sp.to-1; i++ {
                    if devices[i].controlType == ControlType.Sensor || devices[i].controlType == ControlType.HumanInterfaceSeries || devices[i].controlType == ControlType.Gateway
                    {
                        findSensorParametar = true
                        break
                    }
                }
                arrayOfSensorAdresses = []
                UIApplication.sharedApplication().idleTimerDisabled = true
                fromAddress = sp.from - 1
                toAddress = sp.to - 1
                index = fromAddress!
                timesRepeatedCounter = 0
                pbFN = ProgressBarVC(title: "Finding names", percentage:sp.initialPercentage, howMuchOf: "1 / \(sp.count)")
                pbFN?.delegate = self
                self.presentViewController(pbFN!, animated: true, completion: nil)
                deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                NSLog("func findNames \(index)")
                sendCommandForFindingName(index: index)
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    var alertController:UIAlertController?
    func alertController (title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController!.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController!.addAction(OKAction)
        
        self.presentViewController(alertController!, animated: true) {
            // ...
        }
    }
    func returnSearchParametars (from:String, to:String, isScaningNamesAndParametars:Bool) throws -> SearchParametars {
        if !isScaningNamesAndParametars {
            guard let from = Int(from), let to = Int(to) else {
                throw InputError.NotConvertibleToInt
            }
            if from < 0 || to < 0 {
                throw InputError.NotPositiveNumbers
            }
            if from > to {
                throw InputError.FromBiggerThanTo
            }
            let count = to - from + 1
            let percent = Float(1)/Float(count)
            return SearchParametars(from: from, to: to, count: count, initialPercentage: percent)
        } else {
            if from == "" && to == "" {
                print(devices.count)
                let percent = Float(1)/Float(devices.count)
                return SearchParametars(from: 1, to: devices.count, count: devices.count, initialPercentage: percent)
            } else {
                guard let from = Int(from), let to = Int(to) else {
                    throw InputError.NotConvertibleToInt
                }
                if from < 0 || to < 0 {
                    throw InputError.NumbersAreNegative
                }
                if from > to {
                    throw InputError.FromBiggerThanTo
                }
                if from <= 0 || to <= 0 {
                    throw InputError.NotPositiveNumbers
                }
                if devices.count == 0 {
                    throw InputError.NothingToSearchFor
                }
                if devices.count < to {
                    throw InputError.OutOfRange
                }
                let count = to - from + 1
                let percent = Float(1)/Float(count)
                return SearchParametars(from: from, to: to, count: count, initialPercentage: percent)
            }
        }
    }
    //MARK:- Table view dlegates and data source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("scanCell") as? ScanCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblRow.text = "\(indexPath.row+1)."
            cell.lblDesc.text = "\(devices[indexPath.row].name)"
            cell.lblAddress.text = "Address: \(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].address))), Channel: \(devices[indexPath.row].channel)"
            cell.lblType.text = "Control Type: \(devices[indexPath.row].controlType)"
            cell.isEnabledSwitch.on = devices[indexPath.row].isEnabled.boolValue
            cell.lblZone.text = "Zone: \(DatabaseHandler.returnZoneWithId(Int(devices[indexPath.row].zoneId), gateway: devices[indexPath.row].gateway)) Level: \(DatabaseHandler.returnZoneWithId(Int(devices[indexPath.row].parentZoneId), gateway: devices[indexPath.row].gateway))"
            cell.lblCategory.text = "Category: \(DatabaseHandler.returnCategoryWithId(Int(devices[indexPath.row].categoryId), gateway: devices[indexPath.row].gateway))"
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
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
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
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
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