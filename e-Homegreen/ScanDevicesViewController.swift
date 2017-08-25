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
        
        appDel = UIApplication.shared.delegate as! AppDelegate

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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ScanDevicesViewController.findDevice))                              //Tap function will call when user tap on button
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(ScanDevicesViewController.findDevicesLongPress(_:)))         //Long function will call when user long press on button.
        tapGesture.numberOfTapsRequired = 1
        longGesture.minimumPressDuration = 1
        findDevicesBtn.addGestureRecognizer(tapGesture)
        findDevicesBtn.addGestureRecognizer(longGesture)
        
        let tapGestureFindNames = UITapGestureRecognizer(target: self, action: #selector(ScanDevicesViewController.findNames))                      //Tap function will call when user tap on button
        let longGestureFindNames = UILongPressGestureRecognizer(target: self, action: #selector(ScanDevicesViewController.findNamesLongPress(_:)))  //Long function will call when user long press on button.
        tapGestureFindNames.numberOfTapsRequired = 1
        longGestureFindNames.minimumPressDuration = 1
        findNamesBtn.addGestureRecognizer(tapGestureFindNames)
        findNamesBtn.addGestureRecognizer(longGestureFindNames)
    }
    override func viewWillAppear(_ animated: Bool) {
        refreshDeviceList()
    }
    override func sendFilterParametar(_ filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshDeviceList()
    }
    override func sendSearchBarText(_ text: String) {
        searchBarText = text
        refreshDeviceList()
        if !text.isEmpty{
            devices = self.devices.filter() {
                device in
                if device.name.lowercased().range(of: text.lowercased()) != nil{
                    return true
                }else{
                    return false
                }
            }
            deviceTableView.reloadData()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        removeObservers()
        addObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ScanDevicesViewController.refreshDeviceList), name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanDevicesViewController.nameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidFindDeviceName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanDevicesViewController.deviceReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidFindDevice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanDevicesViewController.sensorParametarReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidFindSensorParametar), object: nil)
    }    
    func removeObservers() {
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningDeviceName)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningDevice)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningSensorParametars)
        
        Foundation.UserDefaults.standard.synchronize()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidFindDeviceName), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidFindDevice), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidFindSensorParametar), object: nil)
    }
    
    func updateDeviceList () {
        appDel = UIApplication.shared.delegate as! AppDelegate
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "deviceIdForScanningScreen", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if filterParametar.levelName != "All" {
            predicateArray.append(NSPredicate(format: "parentZoneId == %@", NSNumber(value: filterParametar.levelId as Int)))
        }
        if filterParametar.zoneName != "All" {
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(value: filterParametar.zoneId as Int))
            predicateArray.append(zonePredicate)
        }
        if filterParametar.categoryName != "All" {
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(value: filterParametar.categoryId as Int))
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Device]
            devices = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    @IBAction func btnDeleteTextFields(_ sender: AnyObject) {
        rangeFrom.text = ""
        rangeTo.text = ""
    }
    @IBAction func deleteAll(_ sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all devices?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                for item in self.devices {
                    if item.gateway.objectID == self.gateway.objectID {
                        self.appDel.managedObjectContext!.delete(item)
                    }
                }
                CoreDataController.shahredInstance.saveChanges()
                self.refreshDeviceList()
            }
        }
    }
    
    // MARK: - FINDING DEVICES FOR GATEWAY
    var searchDeviceTimer:Foundation.Timer?
    var searchForDeviceWithId:Int?
    var fromAddress:Int?
    var toAddress:Int?
    var arrayOfDevicesToBeSearched = [Int]()
    var indexOfDevicesToBeSearched = 0
    
    func findDevice() {
        arrayOfDevicesToBeSearched = [Int]()
        indexOfDevicesToBeSearched = 0
        UIApplication.shared.isIdleTimerDisabled = true
        var from = 1
        var to = 255
        
        guard let rangeFromText = rangeFrom.text else{
            self.view.makeToast(message: "Range can't be empty")
            return
        }
        
        guard let rangeFrom = Int(rangeFromText) else{
            self.view.makeToast(message: "Range can be only number")
            return
        }
        
        if rangeFrom > 255 || rangeFrom < 0{
            self.view.makeToast(message: "Incorrect value for \"From\" field")
            return
        }
        
        from = rangeFrom
        
        guard let rangeToText = rangeTo.text else{
            self.view.makeToast(message: "Range can't be empty")
            return
        }
        
        guard let rangeTo = Int(rangeToText) else{
            self.view.makeToast(message: "Range can be only number")
            return
        }
        
        if rangeTo > 255 || rangeTo < 0{
            self.view.makeToast(message: "Incorrect value for \"To\" field")
            return
        }
        
        to = rangeTo
        
        if rangeTo < rangeFrom {
            self.view.makeToast(message: "Range is not properly set")
            return
        }
        
        for i in from ... to {
            arrayOfDevicesToBeSearched.append(i)
        }
        let initialPercentage = Float(0)
        
        fromAddress = from
        toAddress = to
        if arrayOfDevicesToBeSearched.count > 0{
            searchForDeviceWithId = arrayOfDevicesToBeSearched[0]
            timesRepeatedCounter = 0
            
            pbFD = ProgressBarVC(title: "Finding devices", percentage: initialPercentage, howMuchOf: "1 / \(arrayOfDevicesToBeSearched.count)")
            pbFD?.delegate = self
            self.present(pbFD!, animated: true, completion: nil)
            searchDeviceTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: searchForDeviceWithId, repeats: false)
            let address = [UInt8(Int(gateway.addressOne)), UInt8(Int(gateway.addressTwo)), UInt8(searchForDeviceWithId!)]
            self.setProgressBarParametarsForSearchingDevices(address)   // Needs to be done because progres bar is an the beginning 100%, for some reason..
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningDevice)
            Foundation.UserDefaults.standard.synchronize()
            SendingHandler.sendCommand(byteArray: OutgoingHandler.searchForDevices(address), gateway: gateway)
        }else{
            self.view.makeToast(message: "No devices to search")
        }
    }
    func findDevicesLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began{
            arrayOfDevicesToBeSearched = [Int]()
            indexOfDevicesToBeSearched = 0
            do {
                let sp = try returnSearchParametars(rangeFrom.text!, to: rangeTo.text!, isScaningNamesAndParametars: false)
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningDevice)
                Foundation.UserDefaults.standard.synchronize()
                UIApplication.shared.isIdleTimerDisabled = true
                
                // Add to array all IDs from range that are not found already
                for i in sp.from ... sp.to {
                    var deviceFound = false
                    if devices.count > 0 {
                        for j in 0...devices.count-1 {
                            if i == devices[j].address.intValue {
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
                    self.present(pbFD!, animated: true, completion: nil)
                    searchDeviceTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: searchForDeviceWithId, repeats: false)
                    let address = [UInt8(Int(gateway.addressOne)), UInt8(Int(gateway.addressTwo)), UInt8(searchForDeviceWithId!)]
                    self.setProgressBarParametarsForSearchingDevices(address)   // Needs to be done because progres bar is an the beginning 100%, for some reason..
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.searchForDevices(address), gateway: gateway)
                }else{
                    self.view.makeToast(message: "No devices to search")
                }
                
            } catch let error as InputError {
                self.view.makeToast(message: error.description)
            } catch {
                self.view.makeToast(message: "Something went wrong.")
            }
        }
    }
    func deviceReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDevice) {
            if let info = (notification as NSNotification).userInfo! as? [String:Int] {
                if let deviceIndex = info["deviceAddresInGateway"] {
                    if deviceIndex == searchForDeviceWithId {
                        if indexOfDevicesToBeSearched+1 < arrayOfDevicesToBeSearched.count {
                            indexOfDevicesToBeSearched += 1
                            let deviceIdToBeSearched = arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched]
                            timesRepeatedCounter = 0
                            searchDeviceTimer?.invalidate()
                            searchDeviceTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: deviceIdToBeSearched, repeats: false)
                            let address = [UInt8(Int(gateway.addressOne)), UInt8(Int(gateway.addressTwo)), UInt8(arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched])]
                            setProgressBarParametarsForSearchingDevices(address)
                            SendingHandler.sendCommand(byteArray: OutgoingHandler.searchForDevices(address), gateway: gateway)
                        }else{
                            dismissScaningControls()
                        }
                    }
                }
            }
        }
    }
    func checkIfGatewayDidGetDevice (_ timer:Foundation.Timer) {
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
                    searchDeviceTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: deviceIdToBeSearched, repeats: false)
                    setProgressBarParametarsForSearchingDevices(address)
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.searchForDevices(address), gateway: gateway)
                }else{
                    indexOfDevicesToBeSearched += 1
                    setProgressBarParametarsForSearchingDevices(address)
                    dismissScaningControls()
                }
            } else {
                if (timesRepeatedCounter + 1) != 4 {
                    timesRepeatedCounter = timesRepeatedCounter + 1
                    searchDeviceTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: deviceIdToBeSearched, repeats: false)
                    setProgressBarParametarsForSearchingDevices(address)
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.searchForDevices(address), gateway: gateway)
                }else{
                    if indexOfDevicesToBeSearched+1 < arrayOfDevicesToBeSearched.count {
                        indexOfDevicesToBeSearched += 1
                        deviceIdToBeSearched = arrayOfDevicesToBeSearched[indexOfDevicesToBeSearched]
                        timesRepeatedCounter = 0
                        searchDeviceTimer?.invalidate()
                        searchDeviceTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfGatewayDidGetDevice(_:)), userInfo: deviceIdToBeSearched, repeats: false)
                        setProgressBarParametarsForSearchingDevices(address)
                        SendingHandler.sendCommand(byteArray: OutgoingHandler.searchForDevices(address), gateway: gateway)
                    }else{
                        setProgressBarParametarsForSearchingDevices(address)
                        indexOfDevicesToBeSearched += 1
                        dismissScaningControls()
                    }
                }
            }
        }
    }
    func setProgressBarParametarsForSearchingDevices (_ address:[UInt8]) {
        let howMuchOf = arrayOfDevicesToBeSearched.count
        let index = indexOfDevicesToBeSearched+1
        if let _ = pbFD?.lblHowMuchOf, let _ = pbFD?.lblPercentage, let _ = pbFD?.progressView{
            pbFD?.lblHowMuchOf.text = "\(index) / \(howMuchOf)"
            pbFD?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(index)/Float(howMuchOf)*100) + " %"
            pbFD?.progressView.progress = Float(index)/Float(howMuchOf)
        }
    }
    
    // MARK: - DELETING DEVICES FOR GATEWAY
    func changeValueEnable (_ sender:UISwitch) {
        if sender.isOn {
            devices[sender.tag].isEnabled = NSNumber(value: true as Bool)
        } else {
            devices[sender.tag].isEnabled = NSNumber(value: false as Bool)
        }
        CoreDataController.shahredInstance.saveChanges()
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanDevicesViewController.refreshDeviceList), name: NotificationKey.RefreshDevice, object: nil)
    }
    func changeValueVisible (_ sender:UISwitch) {
        if sender.isOn {
            devices[sender.tag].isVisible = NSNumber(value: true as Bool)
        } else {
            devices[sender.tag].isVisible = NSNumber(value: false as Bool)
        }
        CoreDataController.shahredInstance.saveChanges()
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanDevicesViewController.refreshDeviceList), name: NotificationKey.RefreshDevice, object: nil)
    }
    
    // MARK: - FINDING NAMES FOR DEVICE
    var deviceNameTimer:Foundation.Timer?
    var timesRepeatedCounter:Int = 0
    var searchForNameWithIndexInDevices = 0
    var arrayOfNamesToBeSearched = [Int]()
    var indexOfNamesToBeSearched = 0
    var longPressScannParameters = false
    
    func findNames() {
        arrayOfNamesToBeSearched = [Int]()
        indexOfNamesToBeSearched = 0
        
        if devices.count != 0 {
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningDeviceName)
            Foundation.UserDefaults.standard.synchronize()
            // Go through all devices and store all devices which are in defined range and which don't have name parameter
            // Values that are stored in "arrayOfNamesToBeSearched" are indexes in "devices" array of those devices that don't have name
            // Example: devices: [device1, device2, device3], and device1 and device3 don't names. Then
            // arrayOfNamesToBeSearched = [0, 2]
            var from = 0
            var to = 2000
            
            if rangeFrom.text != nil && rangeFrom.text! != ""{
                from = Int(rangeFrom.text!)!-1
            }
            if rangeTo.text != nil && rangeTo.text! != ""{
                to = Int(rangeTo.text!)!-1
            }
            
            if to < from {
                self.view.makeToast(message: "Range can be only number")
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
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstDeviceIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                timesRepeatedCounter = 0
                pbFN = ProgressBarVC(title: "Finding names", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                pbFN?.delegate = self
                self.present(pbFN!, animated: true, completion: nil)
                deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: firstDeviceIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstDeviceIndexThatDontHaveName)")
                sendCommandForFindingName(index: firstDeviceIndexThatDontHaveName)
            }
        }
    }
    func findNamesLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began{
            arrayOfNamesToBeSearched = [Int]()
            indexOfNamesToBeSearched = 0
            if devices.count != 0 {
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningDeviceName)
                Foundation.UserDefaults.standard.synchronize()
                
                // Go through all devices and store only those which are in defined range and which don't have name parameter
                // Values that are stored in "arrayOfNamesToBeSearched" are indexes in "devices" array of those devices that don't have name
                // Example: devices: [device1, device2, device3], and device1 and device3 don't names. Then
                // arrayOfNamesToBeSearched = [0, 2]
                var from = 0
                var to = 2000
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
                UIApplication.shared.isIdleTimerDisabled = true
                if arrayOfNamesToBeSearched.count != 0{
                    let firstDeviceIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                    timesRepeatedCounter = 0
                    pbFN = ProgressBarVC(title: "Finding names", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                    pbFN?.delegate = self
                    self.present(pbFN!, animated: true, completion: nil)
                    deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: firstDeviceIndexThatDontHaveName, repeats: false)
                    NSLog("func findNames \(firstDeviceIndexThatDontHaveName)")
                    sendCommandForFindingName(index: firstDeviceIndexThatDontHaveName)
                }
            }
        }
    }
    func nameReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningDeviceName) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let deviceIndex = info["deviceIndexForFoundName"] else{
                return
            }
            var deviceIsSalto = 0
            if let deviceIsSaltoTemp = info["saltoAccess"]{
                deviceIsSalto = deviceIsSaltoTemp
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: deviceIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            devices[deviceIndex].resetImages(appDel.managedObjectContext!) // Needs to be here in order for images to be loaded correctly. After the names are loaded then we know which pictures to load for which device.
            if deviceIsSalto == 1{
                if indexOfDeviceIndexInArrayOfNamesToBeSearched+4 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+4
                    let nextDeviceIndexToBeSearched = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                    
                    timesRepeatedCounter = 0
                    deviceNameTimer?.invalidate()
                    deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                    NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextDeviceIndexToBeSearched)")
                    sendCommandForFindingName(index: nextDeviceIndexToBeSearched)
                }else{
                    dismissScaningControls()
                }
            }else{
                if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                    let nextDeviceIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                    
                    timesRepeatedCounter = 0
                    deviceNameTimer?.invalidate()
                    deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                    NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextDeviceIndexToBeSearched)")
                    sendCommandForFindingName(index: nextDeviceIndexToBeSearched)
                }else{
                    dismissScaningControls()
                }
            }
            
        }
    }
    func checkIfDeviceDidGetName (_ timer:Foundation.Timer) {
        if let deviceIndex = timer.userInfo as? Int {
            // if name not found search again
            if devices[deviceIndex].name == "Unknown" {
                timesRepeatedCounter += 1
                if timesRepeatedCounter < 3 { // Try again
                    deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: deviceIndex, repeats: false)
                    NSLog("func checkIfDeviceDidGetName \(deviceIndex)")
                    sendCommandForFindingName(index: deviceIndex)
                }else{
                    if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: deviceIndex){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                        if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                            indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                            let nextDeviceIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                            timesRepeatedCounter = 0
                            deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                            NSLog("func checkIfDeviceDidGetName \(nextDeviceIndexToBeSearched)")
                            sendCommandForFindingName(index: nextDeviceIndexToBeSearched)
                        }else{
                            dismissScaningControls()
                        }
                    }
                }
            }else{
                if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: deviceIndex){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                    if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                        indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                        let nextDeviceIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                        timesRepeatedCounter = 0
                        deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfDeviceDidGetName(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
                        NSLog("func checkIfDeviceDidGetName \(nextDeviceIndexToBeSearched)")
                        sendCommandForFindingName(index: nextDeviceIndexToBeSearched)
                    }else{
                        dismissScaningControls()
                    }
                }
            }
        }
    }
    func sendCommandForFindingName(index:Int) {
        setProgressBarParametarsForFindingNames(index)
        if devices[index].type == ControlType.Dimmer || devices[index].type == ControlType.AnalogOutput{
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        print(devices[index].type)
        if devices[index].type == ControlType.Curtain || devices[index].type == ControlType.PC{
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getModuleName(address), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Relay || devices[index].type == ControlType.DigitalOutput{
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Climate {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getACName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.Sensor || devices[index].type == ControlType.IntelligentSwitch || devices[index].type == ControlType.Gateway  || devices[index].type == ControlType.DigitalInput{
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getSensorName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.SaltoAccess {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessInfoWithAddress(address), gateway: devices[index].gateway)
        }
        if devices[index].type == ControlType.IntelligentSwitch {
            let address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getModuleName(address), gateway: devices[index].gateway)
        }
    }
    
    // Find sensor parameters
    func sendComandForSensorZone(deviceIndex:Int) {
        
        setProgressBarParametarsForFindingSensorParametar(deviceIndex)
        if devices[deviceIndex].controlType == ControlType.Sensor || devices[deviceIndex].controlType == ControlType.IntelligentSwitch || devices[deviceIndex].controlType == ControlType.Gateway || devices[deviceIndex].controlType == ControlType.DigitalInput{
            let address = [UInt8(Int(devices[deviceIndex].gateway.addressOne)), UInt8(Int(devices[deviceIndex].gateway.addressTwo)), UInt8(Int(devices[deviceIndex].address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.getSensorParameters(address, channel: UInt8(Int(devices[deviceIndex].channel))), gateway: devices[deviceIndex].gateway)
        }
    }
    func setProgressBarParametarsForFindingNames (_ index:Int) {
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: index){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            if let _ = pbFN?.lblHowMuchOf, let _ = pbFN?.lblPercentage, let _ = pbFN?.progressView{
                pbFN?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfNamesToBeSearched+1) / \(arrayOfNamesToBeSearched.count)"
                pbFN?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)*100) + " %"
                pbFN?.progressView.progress = Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)
            }
            
        }
    }
    
    // MARK: - Sensor parametar
    func findParametarsForSensor() {
        arrayOfSensorAdresses = []
        // Go through all devices and store only those which are in defined range and which ar of type:HumanInterfaceSeries, Gateway, AnalogInput or DigitalInput
        // Values that are stored in "arrayOfSensorAdresses" are indexes in "devices" array of those devices which are filtered
        // Example: devices: [device1, device2, device3], and device1 and device3 are of defined types. Then
        // arrayOfSensorAdresses = [0, 2]
        var from = 0
        var to = 2000
        if rangeFrom.text != nil && rangeFrom.text != ""{
            from = Int(rangeFrom.text!)!-1
        }
        if rangeTo.text != nil && rangeTo.text != ""{
            to = Int(rangeTo.text!)!-1
        }
        
        for i in from...to{
            if i < devices.count{
                if longPressScannParameters {
                    if devices[i].categoryId.intValue == -1 {
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
        
        UIApplication.shared.isIdleTimerDisabled = true
        if arrayOfSensorAdresses.count != 0{
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningSensorParametars)
            Foundation.UserDefaults.standard.synchronize()
            let index = 0
            let deviceIndex = arrayOfSensorAdresses[index]
            timesRepeatedCounter = 0
            deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: deviceIndex, repeats: false)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.pbFN = ProgressBarVC(title: "Finding sensor parametars", percentage: Float(1)/Float(self.arrayOfSensorAdresses.count), howMuchOf: "1 / \(self.arrayOfSensorAdresses.count)")
                self.pbFN?.delegate = self
                self.present(self.pbFN!, animated: true, completion: nil)
                self.sendComandForSensorZone(deviceIndex: deviceIndex)
            }
        }
    }
    func checkIfSensorDidGotParametar (_ timer:Foundation.Timer) {
        if let deviceIndex = timer.userInfo as? Int {
            // if name not found search again
            if devices[deviceIndex].zoneId == 0 {
                timesRepeatedCounter += 1
                if timesRepeatedCounter < 3 { // Try again
                    deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: deviceIndex, repeats: false)
                    sendComandForSensorZone(deviceIndex: deviceIndex)
                }else{
                    if let indexOfDeviceIndexInArrayOfSensorAdresses = arrayOfSensorAdresses.index(of: deviceIndex){
                        if indexOfDeviceIndexInArrayOfSensorAdresses+1 < arrayOfSensorAdresses.count{ // if next exists
                            indexOfSensorAddresses = indexOfDeviceIndexInArrayOfSensorAdresses+1
                            let nextDeviceIndexToBeSearched = arrayOfSensorAdresses[indexOfDeviceIndexInArrayOfSensorAdresses+1]
                            timesRepeatedCounter = 0
                            deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
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
                if let indexOfDeviceIndexInArrayOfSensorAdresses = arrayOfSensorAdresses.index(of: deviceIndex){
                    if indexOfDeviceIndexInArrayOfSensorAdresses+1 < arrayOfSensorAdresses.count{ // if next exists
                        indexOfSensorAddresses = indexOfDeviceIndexInArrayOfSensorAdresses+1
                        let nextDeviceIndexToBeSearched = arrayOfSensorAdresses[indexOfDeviceIndexInArrayOfSensorAdresses+1]
                        timesRepeatedCounter = 0
                        deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
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
    func sensorParametarReceivedFromPLC (_ notification:Notification) {
        let parameter = Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningSensorParametars)
        if parameter {
            if let info = (notification as NSNotification).userInfo! as? [String:Int] {
                if let deviceIndex = info["sensorIndexForFoundParametar"] {
                    if let indexOfDeviceIndexInArrayOfSensorAdresses = arrayOfSensorAdresses.index(of: deviceIndex){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                        if indexOfDeviceIndexInArrayOfSensorAdresses+1 < arrayOfSensorAdresses.count{ // if next exists
                            indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfSensorAdresses+1
                            let nextDeviceIndexToBeSearched = arrayOfSensorAdresses[indexOfNamesToBeSearched]
                            
                            timesRepeatedCounter = 0
                            deviceNameTimer?.invalidate()
                            deviceNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanDevicesViewController.checkIfSensorDidGotParametar(_:)), userInfo: nextDeviceIndexToBeSearched, repeats: false)
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
    func setProgressBarParametarsForFindingSensorParametar (_ deviceIndex:Int) {
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfSensorAdresses.index(of: deviceIndex){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
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
                if device.name.lowercased().range(of: searchBarText.lowercased()) != nil{
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

        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningDeviceName)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningSensorParametars)
        Foundation.UserDefaults.standard.synchronize()
        pbFN?.dissmissProgressBar()
        
        //   For finding devices
        searchForDeviceWithId = 0
        searchDeviceTimer?.invalidate()
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningDevice)
        Foundation.UserDefaults.standard.synchronize()
        pbFD?.dissmissProgressBar()
        if !findSensorParametar {
            UIApplication.shared.isIdleTimerDisabled = false
            longPressScannParameters = false
        } else {
            findParametarsForSensor()
        }
    }
    
    func returnSearchParametars (_ from:String, to:String, isScaningNamesAndParametars:Bool) throws -> SearchParametars {
        if !isScaningNamesAndParametars {
            guard let from = Int(from), let to = Int(to) else {
                throw InputError.notConvertibleToInt
            }
            if from < 0 || to < 0 {
                throw InputError.notPositiveNumbers
            }
            if from > to {
                throw InputError.fromBiggerThanTo
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
                    throw InputError.notConvertibleToInt
                }
                if from < 0 || to < 0 {
                    throw InputError.numbersAreNegative
                }
                if from > to {
                    throw InputError.fromBiggerThanTo
                }
                if from <= 0 || to <= 0 {
                    throw InputError.notPositiveNumbers
                }
                if devices.count == 0 {
                    throw InputError.nothingToSearchFor
                }
                if devices.count < to {
                    throw InputError.outOfRange
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "scanCell") as? ScanCell {
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
            let isVisibleSwitch = devices[(indexPath as NSIndexPath).row].isVisible.boolValue
            
            cell.setItemWithParameters(row: row, description: description, address: deviceAddress, type: type, isEnabledSwitch: isEnabledSwitch, zone: zone, category: category, isVisibleSwitch: isVisibleSwitch)
            
            cell.isVisibleSwitch.tag = (indexPath as NSIndexPath).row
            cell.isEnabledSwitch.tag = (indexPath as NSIndexPath).row
            cell.isEnabledSwitch.addTarget(self, action: #selector(ScanDevicesViewController.changeValueEnable(_:)), for: UIControlEvents.valueChanged)
            cell.isVisibleSwitch.addTarget(self, action: #selector(ScanDevicesViewController.changeValueVisible(_:)), for: UIControlEvents.valueChanged)
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            self.showChangeDeviceParametar(device: self.devices[(indexPath as NSIndexPath).row], scanDevicesViewController: self)
        })
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            self.tableView(self.deviceTableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        })
        button.backgroundColor = UIColor.red
        return [button]
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Here needs to be deleted even devices that are from gateway that is going to be deleted
            appDel.managedObjectContext?.delete(devices[(indexPath as NSIndexPath).row])
            CoreDataController.shahredInstance.saveChanges()
            updateDeviceList()
            refreshDeviceList()
        }
    }
}

extension ScanDevicesViewController: DeleteAllDelegate {
    func deleteConfirmed() {
        for item in 0..<self.devices.count{
            if self.devices[item].gateway.objectID == self.gateway.objectID {
                self.appDel.managedObjectContext!.delete(self.devices[item])
            }
        }
        CoreDataController.shahredInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
    }
}

extension ScanDevicesViewController: DevicePropertiesDelegate{
    func saveClicked() {
        deviceTableView.reloadData()
    }
}
