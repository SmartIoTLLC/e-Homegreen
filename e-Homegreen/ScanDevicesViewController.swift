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

class ScanDevicesViewController: UIViewController, UITextFieldDelegate, ProgressBarDelegate {
    
    @IBOutlet weak var rangeFrom: UITextField!
    @IBOutlet weak var rangeTo: UITextField!
    @IBOutlet weak var findDevicesBtn: CustomGradientButton!
    @IBOutlet weak var findNamesBtn: CustomGradientButton!
    @IBOutlet weak var deviceTableView: UITableView!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var devices:[Device] = []
    var gateway:Gateway!
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Database)
    
    var findSensorParametar = false
    var indexOfSensorAddresses = 0
    var arrayOfSensorAdresses:[Int] = []
    
    var pbFD:ProgressBarVC?     // Device
    var pbFN:ProgressBarVC?     // Names
    
    var searchBarText:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate

        for device in gateway.devices {
            devices.append(device as! Device)
        }
        
        refreshDeviceList()
        
        rangeFrom.text = "\(Int(gateway.addressThree)+1)"
        rangeTo.text = "\(Int(gateway.addressThree)+1)"
        
        rangeFrom.inputAccessoryView = CustomToolBar()
        rangeTo.inputAccessoryView = CustomToolBar()
        
         filterParametar = Filter.sharedInstance.returnFilter(forTab: .Database)
        
        // Add  gestures to Find Devices button in order to make "click" and "long press" possible
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ScanDevicesViewController.findDevice))  //Tap function will call when user tap on button
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(ScanDevicesViewController.findDevicesLongPress(_:))) //Long function will call when user long press on button.
        tapGesture.numberOfTapsRequired = 1
        longGesture.minimumPressDuration = 1
        findDevicesBtn.addGestureRecognizer(tapGesture)
        findDevicesBtn.addGestureRecognizer(longGesture)
        
        let tapGestureFindNames = UITapGestureRecognizer(target: self, action: #selector(ScanDevicesViewController.findNames))  //Tap function will call when user tap on button
        let longGestureFindNames = UILongPressGestureRecognizer(target: self, action: #selector(ScanDevicesViewController.findNamesLongPress(_:))) //Long function will call when user long press on button.
        tapGestureFindNames.numberOfTapsRequired = 1
        longGestureFindNames.minimumPressDuration = 1
        findNamesBtn.addGestureRecognizer(tapGestureFindNames)
        findNamesBtn.addGestureRecognizer(longGestureFindNames)
    }
    override func sendFilterParametar(filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshDeviceList()
    }
    override func sendSearchBarText(text: String) {
        searchBarText = text
        refreshDeviceList()
        if !text.isEmpty{
            devices = self.devices.filter() {
                device in
                if device.name.lowercaseString.rangeOfString(text.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
            deviceTableView.reloadData()
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        removeObservers()
        addObservers()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanDevicesViewController.refreshDeviceList), name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanDevicesViewController.nameReceivedFromPLC(_:)), name: NotificationKey.DidFindDeviceName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanDevicesViewController.deviceReceivedFromPLC(_:)), name: NotificationKey.DidFindDevice, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanDevicesViewController.sensorParametarReceivedFromPLC(_:)), name: NotificationKey.DidFindSensorParametar, object: nil)
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
    
    func updateDeviceList () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Device")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "deviceIdForScanningScreen", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if filterParametar.levelName != "All" {
            predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(integer: filterParametar.levelId)))
        }
        if filterParametar.zoneName != "All" {
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: filterParametar.zoneId))
            predicateArray.append(zonePredicate)
        }
        if filterParametar.categoryName != "All" {
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: filterParametar.categoryId))
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
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
    var searchDeviceTimer:NSTimer?
    var searchForDeviceWithId:Int?
    var fromAddress:Int?
    var toAddress:Int?
    var arrayOfDevicesToBeSearched = [Int]()
    var indexOfDevicesToBeSearched = 0
    
    func findDevice() {
        arrayOfDevicesToBeSearched = [Int]()
        indexOfDevicesToBeSearched = 0
        do {
//            let sp = try returnSearchParametars(rangeFrom.text!, to: rangeTo.text!, isScaningNamesAndParametars: false)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningDevice)
            UIApplication.sharedApplication().idleTimerDisabled = true
            
            
            var from = 1
            var to = 255
            
            guard let rangeFromText = rangeFrom.text else{
                alertController("Error", message: "Range can't be empty")
                return
            }
            
            guard let rangeFrom = Int(rangeFromText) else{
                alertController("Error", message: "Range can be only number")
                return
            }
            from = rangeFrom
            
            guard let rangeToText = rangeTo.text else{
                alertController("Error", message: "Range can't be empty")
                return
            }
            
            guard let rangeTo = Int(rangeToText) else{
                alertController("Error", message: "Range can be only number")
                return
            }
            to = rangeTo
            
            if rangeTo < rangeFrom {
                alertController("Error", message: "Range \"from\" can't be higher than range \"to\"")
                return
            }

            for i in from ... to {
                arrayOfDevicesToBeSearched.append(i)
            }
            let initialPercentage = Float(0)//Float(1)/Float(arrayOfDevicesToBeSearched.count)*100
            
//            for i in sp.from ... sp.to {
//                arrayOfDevicesToBeSearched.append(i)
//            }
            fromAddress = from
            toAddress = to
            if arrayOfDevicesToBeSearched.count > 0{
                searchForDeviceWithId = arrayOfDevicesToBeSearched[0]
                timesRepeatedCounter = 0
                
                pbFD = ProgressBarVC(title: "Finding devices", percentage: initialPercentage, howMuchOf: "1 / \(arrayOfDevicesToBeSearched.count)")
                pbFD?.delegate = self
                self.presentViewController(pbFD!, animated: true, completion: nil)
                searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: searchForDeviceWithId, repeats: false)
                let address = [UInt8(Int(gateway.addressOne)), UInt8(Int(gateway.addressTwo)), UInt8(searchForDeviceWithId!)]
                self.setProgressBarParametarsForSearchingDevices(address)   // Needs to be done because progres bar is an the beginning 100%, for some reason..
                SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway)
            }else{
                alertController("Info", message: "No devices to search")
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    func findDevicesLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began{
            arrayOfDevicesToBeSearched = [Int]()
            indexOfDevicesToBeSearched = 0
            do {
                let sp = try returnSearchParametars(rangeFrom.text!, to: rangeTo.text!, isScaningNamesAndParametars: false)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningDevice)
                UIApplication.sharedApplication().idleTimerDisabled = true
                
                // Add to array all IDs from range that are not found already
                for i in sp.from ... sp.to {
                    var deviceFound = false
                    if devices.count > 0 {
                        for j in 0...devices.count-1 {
                            if i == devices[j].address.integerValue {
                                deviceFound = true
                                break
                            }
                        }
                        if deviceFound == false{
                            arrayOfDevicesToBeSearched.append(i)
                        }
                    }
                }
                fromAddress = sp.from
                toAddress = sp.to
                if arrayOfDevicesToBeSearched.count > 0 {
                    searchForDeviceWithId = arrayOfDevicesToBeSearched[0]
                    timesRepeatedCounter = 0
                    pbFD = ProgressBarVC(title: "Finding devices", percentage: sp.initialPercentage, howMuchOf: "1 / \(arrayOfDevicesToBeSearched.count)")
                    pbFD?.delegate = self
                    self.presentViewController(pbFD!, animated: true, completion: nil)
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: searchForDeviceWithId, repeats: false)
                    let address = [UInt8(Int(gateway.addressOne)), UInt8(Int(gateway.addressTwo)), UInt8(searchForDeviceWithId!)]
                    self.setProgressBarParametarsForSearchingDevices(address)   // Needs to be done because progres bar is an the beginning 100%, for some reason..
                    SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway)
                }else{
                    alertController("Info", message: "No devices to search")
                }
                
            } catch let error as InputError {
                alertController("Error", message: error.description)
            } catch {
                alertController("Error", message: "Something went wrong.")
            }
        }
    }
    func deviceReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDevice) {
            if let info = notification.userInfo! as? [String:Int] {
                if let deviceIndex = info["deviceAddresInGateway"] {
                    if deviceIndex == searchForDeviceWithId {
                        if indexOfDevicesToBeSearched+1 < arrayOfDevicesToBeSearched.count {
                            indexOfDevicesToBeSearched += 1
                            let deviceIdToBeSearched = arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched]
                            timesRepeatedCounter = 0
                            searchDeviceTimer?.invalidate()
                            searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: deviceIdToBeSearched, repeats: false)
                            let address = [UInt8(Int(gateway.addressOne)), UInt8(Int(gateway.addressTwo)), UInt8(arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched])]
                            setProgressBarParametarsForSearchingDevices(address)
                            SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway)
                        }else{
                            dismissScaningControls()
                        }
                    }
                }
            }
        }
    }
    func checkIfGatewayDidGetDevice (timer:NSTimer) {
        if let index = timer.userInfo as? Int {
            updateDeviceList()
            
            var deviceIdToBeSearched = index
            if arrayOfDevicesToBeSearched.count > 0{
                deviceIdToBeSearched = arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched]
            }
            var deviceFound = false
            if devices.count > 0 {
                for i in 0...devices.count-1 {
                    if Int(devices[i].address) == deviceIdToBeSearched {
                        deviceFound = true
                        break
                    }
                }
            }
            let address = [UInt8(Int(gateway.addressOne)), UInt8(Int(gateway.addressTwo)), UInt8(arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched])]
            // If device found, see whether next exists, go to next.
            // If device not fount, try again four times. If four times done, see if next exists, if not dismiss, if yes go to next.
            if deviceFound {
                if indexOfDevicesToBeSearched+1 < arrayOfDevicesToBeSearched.count {
                    indexOfDevicesToBeSearched += 1
                    deviceIdToBeSearched = arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched]
                    timesRepeatedCounter = 0
                    searchDeviceTimer?.invalidate()
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: deviceIdToBeSearched, repeats: false)
                    setProgressBarParametarsForSearchingDevices(address)
                    SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway)
                }else{
                    indexOfDevicesToBeSearched += 1
                    setProgressBarParametarsForSearchingDevices(address)
                    dismissScaningControls()
                }
            } else {
                if (timesRepeatedCounter + 1) != 4 {
                    timesRepeatedCounter = timesRepeatedCounter + 1
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: deviceIdToBeSearched, repeats: false)
                    setProgressBarParametarsForSearchingDevices(address)
                    SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway)
                }else{
                    if indexOfDevicesToBeSearched+1 < arrayOfDevicesToBeSearched.count {
                        indexOfDevicesToBeSearched += 1
                        deviceIdToBeSearched = arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched]
                        timesRepeatedCounter = 0
                        searchDeviceTimer?.invalidate()
                        searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: deviceIdToBeSearched, repeats: false)
                        setProgressBarParametarsForSearchingDevices(address)
                        SendingHandler.sendCommand(byteArray: Function.searchForDevices(address), gateway: gateway)
                    }else{
                        setProgressBarParametarsForSearchingDevices(address)
                        indexOfDevicesToBeSearched += 1
                        dismissScaningControls()
                    }
                }
            }
        }
    }
    func setProgressBarParametarsForSearchingDevices (address:[UInt8]) {
        let howMuchOf = arrayOfDevicesToBeSearched.count
        let index = indexOfDevicesToBeSearched+1
        if let _ = pbFD?.lblHowMuchOf, let _ = pbFD?.lblPercentage, let _ = pbFD?.progressView{
            pbFD?.lblHowMuchOf.text = "\(index) / \(howMuchOf)"
            pbFD?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(index)/Float(howMuchOf)*100) + " %"
            pbFD?.progressView.progress = Float(index)/Float(howMuchOf)
        }
    }
    
    // MARK: - DELETING DEVICES FOR GATEWAY
    func changeValueEnable (sender:UISwitch) {
        if sender.on {
            devices[sender.tag].isEnabled = NSNumber(bool: true)
        } else {
            devices[sender.tag].isEnabled = NSNumber(bool: false)
        }
        CoreDataController.shahredInstance.saveChanges()
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanDevicesViewController.refreshDeviceList), name: NotificationKey.RefreshDevice, object: nil)
    }
    func changeValueVisible (sender:UISwitch) {
        if sender.on {
            devices[sender.tag].isVisible = NSNumber(bool: true)
        } else {
            devices[sender.tag].isVisible = NSNumber(bool: false)
        }
        CoreDataController.shahredInstance.saveChanges()
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanDevicesViewController.refreshDeviceList), name: NotificationKey.RefreshDevice, object: nil)
    }
    
    @IBAction func deleteAll(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to delete all devices?", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            for var item = 0; item < self.devices.count; item += 1 {
                if self.devices[item].gateway.objectID == self.gateway.objectID {
                    self.appDel.managedObjectContext!.deleteObject(self.devices[item])
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
        
        //Delete popup with design same as in android. If khalifa wants design to be the same then uncomment this.
//        let deleteVC = DeleteConfirmation()
//        deleteVC.delegate = self
//        self.presentViewController(deleteVC, animated: false, completion: nil)
  
    }
    
    // MARK: - FINDING NAMES FOR DEVICE
    var deviceNameTimer:NSTimer?
    var timesRepeatedCounter:Int = 0
    var searchForNameWithIndexInDevices = 0
    var arrayOfNamesToBeSearched = [Int]()
    var indexOfNamesToBeSearched = 0
    var longPressScannParameters = false
    
    func findNames() {
        do {
            arrayOfNamesToBeSearched = [Int]()
            indexOfNamesToBeSearched = 0
            
            if devices.count != 0 {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningDeviceName)
                
                // Go through all devices and store all devices which are in defined range and which don't have name parameter
                // Values that are stored in "arrayOfNamesToBeSearched" are indexes in "devices" array of those devices that don't have name
                // Example: devices: [device1, device2, device3], and device1 and device3 don't names. Then
                // arrayOfNamesToBeSearched = [0, 2]
                var from = 0
                var to = 500
                
                if rangeFrom.text != nil && rangeFrom.text! != ""{
                    from = Int(rangeFrom.text!)!-1
                }
                if rangeTo.text != nil && rangeTo.text! != ""{
                    to = Int(rangeTo.text!)!-1
                }
                
                if to < from {
                    alertController("Error", message: "Range can be only number")
                    return
                }
                
                for i in from...to{
                    if i < devices.count{
                        arrayOfNamesToBeSearched.append(i)
                        if devices[i].controlType == ControlType.Sensor
                            || devices[i].controlType == ControlType.IntelligentSwitch
                            || devices[i].controlType == ControlType.Gateway
                            || devices[i].controlType == ControlType.AnalogInput
                            || devices[i].controlType == ControlType.DigitalInput
                            || devices[i].controlType == ControlType.DigitalOutput{
                            findSensorParametar = true
                        }
                    }
                }
                
                arrayOfSensorAdresses = []
                UIApplication.sharedApplication().idleTimerDisabled = true
                if arrayOfNamesToBeSearched.count != 0{
                    let firstDeviceIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                    timesRepeatedCounter = 0
                    pbFN = ProgressBarVC(title: "Finding names", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                    pbFN?.delegate = self
                    self.presentViewController(pbFN!, animated: true, completion: nil)
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: firstDeviceIndexThatDontHaveName, repeats: false)
                    NSLog("func findNames \(firstDeviceIndexThatDontHaveName)")
                    sendCommandForFindingName(index: firstDeviceIndexThatDontHaveName)
                }
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    func findNamesLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began{
            do {
                arrayOfNamesToBeSearched = [Int]()
                indexOfNamesToBeSearched = 0
                if devices.count != 0 {
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningDeviceName)
                    
                    // Go through all devices and store only those which are in defined range and which don't have name parameter
                    // Values that are stored in "arrayOfNamesToBeSearched" are indexes in "devices" array of those devices that don't have name
                    // Example: devices: [device1, device2, device3], and device1 and device3 don't names. Then
                    // arrayOfNamesToBeSearched = [0, 2]
                    var from = 1
                    var to = 255
                    if rangeFrom.text != nil && rangeFrom.text != "" {
                        from = Int(rangeFrom.text!)!-1
                    }
                    if rangeTo.text != nil && rangeTo.text != ""{
                        to = Int(rangeTo.text!)!-1
                    }
                    for i in from...to{
                        if i < devices.count{
//                        if devices[i].address.integerValue >= Int(rangeFrom.text!) && devices[i].address.integerValue <= Int(rangeTo.text!){ // if it is in good range
                            if devices[i].name == "Unknown"{
                                arrayOfNamesToBeSearched.append(i)
                            }
                            if devices[i].controlType == ControlType.Sensor
                                || devices[i].controlType == ControlType.IntelligentSwitch
                                || devices[i].controlType == ControlType.Gateway
                                || devices[i].controlType == ControlType.AnalogInput
                                || devices[i].controlType == ControlType.DigitalInput
                                || devices[i].controlType == ControlType.DigitalOutput{
                                findSensorParametar = true
                                longPressScannParameters = true
                            }
                        }
                    }
                    arrayOfSensorAdresses = []
                    UIApplication.sharedApplication().idleTimerDisabled = true
                    if arrayOfNamesToBeSearched.count != 0{
                        let firstDeviceIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                        timesRepeatedCounter = 0
                        pbFN = ProgressBarVC(title: "Finding names", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                        pbFN?.delegate = self
                        self.presentViewController(pbFN!, animated: true, completion: nil)
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: firstDeviceIndexThatDontHaveName, repeats: false)
                        NSLog("func findNames \(firstDeviceIndexThatDontHaveName)")
                        sendCommandForFindingName(index: firstDeviceIndexThatDontHaveName)
                    }
                }
            } catch let error as InputError {
                alertController("Error", message: error.description)
            } catch {
                alertController("Error", message: "Something went wrong.")
            }
        }
    }
    func nameReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningDeviceName) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let deviceIndex = info["deviceIndexForFoundName"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(deviceIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            devices[deviceIndex].resetImages(appDel.managedObjectContext!) // Needs to be here in order for images to be loaded correctly. After the names are loaded then we know which pictures to load for which device.
            if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                let nextDeviceIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                
                timesRepeatedCounter = 0
                deviceNameTimer?.invalidate()
                deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextDeviceIndexToBeSearched)")
                sendCommandForFindingName(index: nextDeviceIndexToBeSearched)
            }else{
                dismissScaningControls()
            }
        }
    }
    func checkIfDeviceDidGetName (timer:NSTimer) {
        if let deviceIndex = timer.userInfo as? Int {
            // if name not found search again
            if devices[deviceIndex].name == "Unknown" {
                timesRepeatedCounter += 1
                if timesRepeatedCounter < 3 { // Try again
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: deviceIndex, repeats: false)
                    NSLog("func checkIfDeviceDidGetName \(deviceIndex)")
                    sendCommandForFindingName(index: deviceIndex)
                }else{
                    if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(deviceIndex){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                        if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                            indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                            let nextDeviceIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                            timesRepeatedCounter = 0
                            deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                            NSLog("func checkIfDeviceDidGetName \(nextDeviceIndexToBeSearched)")
                            sendCommandForFindingName(index: nextDeviceIndexToBeSearched)
                        }else{
                            dismissScaningControls()
                        }
                    }
                }
            }else{
                if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(deviceIndex){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                    if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                        indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                        let nextDeviceIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                        timesRepeatedCounter = 0
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                        NSLog("func checkIfDeviceDidGetName \(nextDeviceIndexToBeSearched)")
                        sendCommandForFindingName(index: nextDeviceIndexToBeSearched)
                    }else{
                        dismissScaningControls()
                    }
                }
            }
        }
    }
    func sendCommandForFindingName(index index:Int) {
        setProgressBarParametarsForFindingNames(index)
        if devices[index].type == ControlType.Dimmer || devices[index].type == ControlType.AnalogOutput{
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        print(devices[index].type)
        if devices[index].type == ControlType.Curtain || devices[index].type == ControlType.PC{
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getModuleName(address), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Relay || devices[index].type == ControlType.DigitalOutput{
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Climate {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getACName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Sensor || devices[index].type == ControlType.IntelligentSwitch || devices[index].type == ControlType.Gateway  || devices[index].type == ControlType.DigitalInput{
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getSensorName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            //            SendingHandler.sendCommand(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.SaltoAccess {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: Function.getSaltoAccessInfoWithAddress(address), gateway: devices[index].gateway)
        }
//        if devices[index].type == ControlType.HumanInterfaceSeries {
//            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
//            SendingHandler.sendCommand(byteArray: Function.getModuleName(address), gateway: devices[index].gateway)
//            //SendingHandler.sendCommand(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
//        }
    }
    func sendComandForSensorZone(deviceIndex deviceIndex:Int) {
        
        setProgressBarParametarsForFindingSensorParametar(deviceIndex)
        if devices[deviceIndex].controlType == ControlType.Sensor || devices[deviceIndex].controlType == ControlType.IntelligentSwitch || devices[deviceIndex].controlType == ControlType.Gateway || devices[deviceIndex].controlType == ControlType.DigitalInput{
            let address = [UInt8(Int(devices[deviceIndex].gateway.addressOne)), UInt8(Int(devices[deviceIndex].gateway.addressTwo)), UInt8(Int(devices[deviceIndex].address))]
            SendingHandler.sendCommand(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[deviceIndex].channel))), gateway: devices[deviceIndex].gateway)
        }
    }
    func setProgressBarParametarsForFindingNames (var index:Int) {
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(index){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            if let _ = pbFN?.lblHowMuchOf, let _ = pbFN?.lblPercentage, let _ = pbFN?.progressView{
                pbFN?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfNamesToBeSearched+1) / \(arrayOfNamesToBeSearched.count)"
                pbFN?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)*100) + " %"
                pbFN?.progressView.progress = Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)
            }
            
        }
    }
    
    // MARK: - Sensor parametar
    func findParametarsForSensor() {
        do {
            arrayOfSensorAdresses = []
            // Go through all devices and store only those which are in defined range and which ar of type:HumanInterfaceSeries, Gateway, AnalogInput or DigitalInput
            // Values that are stored in "arrayOfSensorAdresses" are indexes in "devices" array of those devices which are filtered
            // Example: devices: [device1, device2, device3], and device1 and device3 are of defined types. Then
            // arrayOfSensorAdresses = [0, 2]
            var from = 0
            var to = 500
            if rangeFrom.text != nil && rangeFrom.text != ""{
                from = Int(rangeFrom.text!)!-1
            }
            if rangeTo.text != nil && rangeTo.text != ""{
                to = Int(rangeTo.text!)!-1
            }
            
            for i in from...to{
                if i < devices.count{
                    if longPressScannParameters {
                        if devices[i].categoryId.integerValue == -1 {
                            if devices[i].controlType == ControlType.Sensor
                                || devices[i].controlType == ControlType.IntelligentSwitch
                                || devices[i].controlType == ControlType.Gateway
                                || devices[i].controlType == ControlType.AnalogInput
                                || devices[i].controlType == ControlType.DigitalInput
                                || devices[i].controlType == ControlType.DigitalOutput{
                                
                                arrayOfSensorAdresses.append(i)
                            }
                        }
                    }else{
                        if devices[i].controlType == ControlType.Sensor
                            || devices[i].controlType == ControlType.IntelligentSwitch
                            || devices[i].controlType == ControlType.Gateway
                            || devices[i].controlType == ControlType.AnalogInput
                            || devices[i].controlType == ControlType.DigitalInput
                            || devices[i].controlType == ControlType.DigitalOutput{
                            
                            arrayOfSensorAdresses.append(i)
                        }
                    }
                    
                }
            }
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfSensorAdresses.count != 0{
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningSensorParametars)
                let index = 0
                let deviceIndex = arrayOfSensorAdresses[index]
                timesRepeatedCounter = 0
                deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: deviceIndex, repeats: false)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    self.pbFN = ProgressBarVC(title: "Finding sensor parametars", percentage: Float(1)/Float(self.arrayOfSensorAdresses.count), howMuchOf: "1 / \(self.arrayOfSensorAdresses.count)")
                    self.pbFN?.delegate = self
                    self.presentViewController(self.pbFN!, animated: true, completion: nil)
                    self.sendComandForSensorZone(deviceIndex: deviceIndex)
                }
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    func checkIfSensorDidGotParametar (timer:NSTimer) {
        if let deviceIndex = timer.userInfo as? Int {
            // if name not found search again
            if devices[deviceIndex].zoneId == 0 {
                timesRepeatedCounter += 1
                if timesRepeatedCounter < 3 { // Try again
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: deviceIndex, repeats: false)
                    sendComandForSensorZone(deviceIndex: deviceIndex)
                }else{
                    if let indexOfDeviceIndexInArrayOfSensorAdresses = arrayOfSensorAdresses.indexOf(deviceIndex){
                        if indexOfDeviceIndexInArrayOfSensorAdresses+1 < arrayOfSensorAdresses.count{ // if next exists
                            indexOfSensorAddresses = indexOfDeviceIndexInArrayOfSensorAdresses+1
                            let nextDeviceIndexToBeSearched = arrayOfSensorAdresses[indexOfDeviceIndexInArrayOfSensorAdresses+1]
                            timesRepeatedCounter = 0
                            deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                            NSLog("func checkIfSensorDidGotParametar \(nextDeviceIndexToBeSearched)")
                            sendComandForSensorZone(deviceIndex: nextDeviceIndexToBeSearched)
                        }else{
                            dismissScaningControls()
                            findSensorParametar = false
                        }
                    }else{
                        dismissScaningControls()
                        findSensorParametar = false
                    }
                }
            }else{
                if let indexOfDeviceIndexInArrayOfSensorAdresses = arrayOfSensorAdresses.indexOf(deviceIndex){
                    if indexOfDeviceIndexInArrayOfSensorAdresses+1 < arrayOfSensorAdresses.count{ // if next exists
                        indexOfSensorAddresses = indexOfDeviceIndexInArrayOfSensorAdresses+1
                        let nextDeviceIndexToBeSearched = arrayOfSensorAdresses[indexOfDeviceIndexInArrayOfSensorAdresses+1]
                        timesRepeatedCounter = 0
                        deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                        NSLog("func checkIfSensorDidGotParametar \(nextDeviceIndexToBeSearched)")
                        sendComandForSensorZone(deviceIndex: nextDeviceIndexToBeSearched)
                    }else{
                        findSensorParametar = false
                        dismissScaningControls()
                        
                    }
                }else{
                    findSensorParametar = false
                    dismissScaningControls()
                    
                }
            }
        }
    }
    func sensorParametarReceivedFromPLC (notification:NSNotification) {
        let parameter = NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningSensorParametars)
        if parameter {
            if let info = notification.userInfo! as? [String:Int] {
                if let deviceIndex = info["sensorIndexForFoundParametar"] {
                    if let indexOfDeviceIndexInArrayOfSensorAdresses = arrayOfSensorAdresses.indexOf(deviceIndex){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                        if indexOfDeviceIndexInArrayOfSensorAdresses+1 < arrayOfSensorAdresses.count{ // if next exists
                            indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfSensorAdresses+1
                            let nextDeviceIndexToBeSearched = arrayOfSensorAdresses[indexOfNamesToBeSearched]
                            
                            timesRepeatedCounter = 0
                            deviceNameTimer?.invalidate()
                            deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                            NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextDeviceIndexToBeSearched)")
                            sendComandForSensorZone(deviceIndex: nextDeviceIndexToBeSearched)
                        }else{
                            findSensorParametar = false
                            dismissScaningControls()
                        }
                    }
                }
            }
        }
    }
    func setProgressBarParametarsForFindingSensorParametar (deviceIndex:Int) {
        var counterOfAttempts = 0
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfSensorAdresses.indexOf(deviceIndex){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            if let _ = pbFN?.lblHowMuchOf, let _ = pbFN?.lblPercentage, let _ = pbFN?.progressView{
                pbFN?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfNamesToBeSearched+1) / \(arrayOfSensorAdresses.count)"
                pbFN?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfSensorAdresses.count)*100) + " %"
                pbFN?.progressView.progress = Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfSensorAdresses.count)
            }
        }
    }
    
    // MARK: - Other
    func refreshDeviceList() {
        updateDeviceList()
        if !searchBarText.isEmpty{
            devices = self.devices.filter() {
                device in
                if device.name.lowercaseString.rangeOfString(searchBarText.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        deviceTableView.reloadData()
    }

    func progressBarDidPressedExit() {
        findSensorParametar = false
        dismissScaningControls()
    }
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        //   For finding names
        deviceNameTimer?.invalidate()

        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningDeviceName)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningSensorParametars)
        pbFN?.dissmissProgressBar()
        
        //   For finding devices
        searchForDeviceWithId = 0
        searchDeviceTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningDevice)
        pbFD?.dissmissProgressBar()
        if !findSensorParametar {
            UIApplication.sharedApplication().idleTimerDisabled = false
            longPressScannParameters = false
        } else {
            findParametarsForSensor()
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
}

//MARK:- Table view dlegates and data source

extension ScanDevicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("scanCell") as? ScanCell {
            let row = "\(indexPath.row+1)"
            let description = devices[indexPath.row].name
            let deviceAddress = "Address: \(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].address))), Channel: \(devices[indexPath.row].channel)"
            
            // Control Type
            var type = "Control Type: \(devices[indexPath.row].controlType)"
            if devices[indexPath.row].controlType == ControlType.Curtain {
                type = "Control Type: \(ControlType.Relay)"
            }
            
            let isEnabledSwitch = devices[indexPath.row].isEnabled.boolValue
            let levelToDisplay = DatabaseHandler.sharedInstance.returnZoneWithIdForScanDevicesCell(Int(devices[indexPath.row].zoneId), location: devices[indexPath.row].gateway.location)
            let zoneToDisplay = DatabaseHandler.sharedInstance.returnZoneWithIdForScanDevicesCell(Int(devices[indexPath.row].parentZoneId), location: devices[indexPath.row].gateway.location)
            let categoryToDisplay = DatabaseHandler.sharedInstance.returnCategoryWithIdForScanDevicesCell(Int(devices[indexPath.row].categoryId), location: devices[indexPath.row].gateway.location)
            let zone = "Level: \(zoneToDisplay) Zone: \(levelToDisplay)"
            let category = "Category: \(categoryToDisplay)"
            let isVisibleSwitch = devices[indexPath.row].isVisible.boolValue
            
            cell.setItemWithParameters(row: row, description: description, address: deviceAddress, type: type, isEnabledSwitch: isEnabledSwitch, zone: zone, category: category, isVisibleSwitch: isVisibleSwitch)

            cell.isVisibleSwitch.tag = indexPath.row
            cell.isEnabledSwitch.tag = indexPath.row
            cell.isEnabledSwitch.addTarget(self, action: #selector(ScanDevicesViewController.changeValueEnable(_:)), forControlEvents: UIControlEvents.ValueChanged)
            cell.isVisibleSwitch.addTarget(self, action: #selector(ScanDevicesViewController.changeValueVisible(_:)), forControlEvents: UIControlEvents.ValueChanged)
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(),{
            let cell = self.deviceTableView.cellForRowAtIndexPath(indexPath)
            self.showChangeDeviceParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - self.deviceTableView.contentOffset.y), device: self.devices[indexPath.row], scanDevicesViewController: self)
        })
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
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
            CoreDataController.shahredInstance.saveChanges()
            updateDeviceList()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
    }
}

extension ScanDevicesViewController: DeleteAllDelegate {
    func deleteConfirmed() {
        for var item = 0; item < self.devices.count; item += 1 {
            if self.devices[item].gateway.objectID == self.gateway.objectID {
                self.appDel.managedObjectContext!.deleteObject(self.devices[item])
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
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
    
    func setItemWithParameters(row row: String, description: String, address: String, type: String, isEnabledSwitch: Bool, zone: String, category: String, isVisibleSwitch: Bool){
        self.backgroundColor = UIColor.clearColor()
        self.lblRow.text = row
        self.lblDesc.text = description
        self.lblAddress.text = address
        self.lblType.text = type
        self.isEnabledSwitch.on = isEnabledSwitch
        self.lblZone.text = zone
        self.lblCategory.text = category
        self.isVisibleSwitch.on = isVisibleSwitch
    }
}

extension ScanDevicesViewController: DevicePropertiesDelegate{
    func saveClicked() {
        deviceTableView.reloadData()
    }
}