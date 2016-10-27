//
//  ScanTimerViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

enum TimerType:Int{
    case once = 0, daily, monthly, yearly, hourly, minutely , timer , stopwatch
    
    var description: String {
        switch self{
        case .once:
            return "Once"
        case .daily:
           return "Daily"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        case .hourly:
            return "Hourly"
        case .minutely:
            return "Minutely"
        case .timer:
            return "Timer"
        case .stopwatch:
            return "Stopwatch/User"
        }
    }

    static let allItem:[TimerType] = [once, daily, monthly, yearly, hourly, minutely, timer, stopwatch]
}

class ScanTimerViewController: PopoverVC, ProgressBarDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageTimerOne: UIImageView!
    @IBOutlet weak var imageTimerTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var localcastSwitch: UISwitch!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnLevel: CustomGradientButton!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var timerTableView: UITableView!
    
    var gateway:Gateway!
    var filterParametar:FilterItem!
    var timers:[Timer] = []
    
    var searchBarText:String = ""
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    var timerTypeId:Int?
    
    var imageDataOne:Data?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:Data?
    var customImageTwo:String?
    var defaultImageTwo:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageTimerOne.isUserInteractionEnabled = true
        imageTimerOne.tag = 1
        imageTimerOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanTimerViewController.handleTap(_:))))
        imageTimerTwo.isUserInteractionEnabled = true
        imageTimerTwo.tag = 2
        imageTimerTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanTimerViewController.handleTap(_:))))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressOne.isEnabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        devAddressTwo.isEnabled = false
        
        broadcastSwitch.tag = 100
        broadcastSwitch.isOn = false
        broadcastSwitch.addTarget(self, action: #selector(ScanTimerViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.isOn = false
        localcastSwitch.addTarget(self, action: #selector(ScanTimerViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnType.tag = 4
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        refreshTimerList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    override func sendFilterParametar(_ filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshTimerList()
    }
    
    override func sendSearchBarText(_ text: String) {
        searchBarText = text
        refreshTimerList()
        
    }
    
    override func nameAndId(_ name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            btnZone.setTitle("All", for: UIControlState())
            zoneSelected = nil
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            break
        case 4:
            timerTypeId = Int(id)
            break
        default:
            break
        }
        
        button.setTitle(name, for: UIControlState())
    }
    
    func changeValue (_ sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.isOn = false
        } else if sender.tag == 200 {
            broadcastSwitch.isOn = false
        }
    }
    func refreshTimerList() {
        timers = DatabaseTimersController.shared.updateTimerList(gateway, filterParametar: filterParametar)
        if !searchBarText.isEmpty{
            timers = self.timers.filter() {
                timer in
                if timer.timerName.lowercased().range(of: searchBarText.lowercased()) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        timerTableView.reloadData()
    }
    
    func handleTap (_ gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
    }
    func addObservers(){
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.addObserver(self, selector: #selector(ScanTimerViewController.nameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveTimerFromGateway), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanTimerViewController.timerParametarReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveTimerParameterFromGateway), object: nil)
        
    }
    func removeObservers(){
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningTimerNames)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningTimerParameters)
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveTimerFromGateway), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveTimerParameterFromGateway), object: nil)
    }
    
    @IBAction func btnAdd(_ sender: AnyObject) {
        if let timerId = Int(IDedit.text!), let timerName = nameEdit.text, let address = Int(devAddressThree.text!), let type = btnType.titleLabel?.text {
            if timerId <= 32767 && address <= 255 && type != "--" {
                
                var levelId:Int?
                if let levelIdNumber = level?.id{
                    levelId = Int(levelIdNumber)
                }
                var zoneId:Int?
                if let zoneIdNumber = zoneSelected?.id{
                    zoneId = Int(zoneIdNumber)
                }
                var categoryId:Int?
                if let categoryIdNumber = category?.id{
                    categoryId = Int(categoryIdNumber)
                }
                
                DatabaseTimersController.shared.addTimer(timerId, timerName: timerName, moduleAddress: address, gateway: gateway, type: timerTypeId, levelId: levelId, selectedZoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.isOn, isLocalcast: localcastSwitch.isOn, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo)
                
            }
            refreshTimerList()
            self.view.endEditing(true)
        }else{
            self.view.makeToast(message: "Please check fields: name, id, type and address")
        }
    }
    @IBAction func scanTimers(_ sender: AnyObject) {
        findNames()
    }
    @IBAction func clearRangeFields(_ sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    @IBAction func btnRemove(_ sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all scenes?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                DatabaseTimersController.shared.deleteAllTimers(self.gateway)
                self.refreshTimerList()
                self.view.endEditing(true)
            }
        }
    }
    @IBAction func btnLevel(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnCategory(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnZone(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(gateway.location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnTimerType(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        for item in TimerType.allItem{
            popoverList.append(PopOverItem(name: item.description, id: "\(item.rawValue)"))
        }
        openPopover(sender, popOverList:popoverList)
    }

    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var timerNameTimer:Foundation.Timer?
    var timerParameterTimer: Foundation.Timer?
    var timesRepeatedCounterNames:Int = 0
    var timesRepeatedCounterParameters: Int = 0
    var arrayOfNamesToBeSearched = [Int]()
    var indexOfNamesToBeSearched = 0
    var arrayOfParametersToBeSearched = [Int]()
    var indexOfParametersToBeSearched = 0
    var progressBarScreenTimerNames: ProgressBarVC?
    var shouldFindTimerParameters = false
    
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findNames() {
            arrayOfNamesToBeSearched = [Int]()
            indexOfNamesToBeSearched = 0
            
            addressOne = Int(devAddressOne.text!)!
            addressTwo = Int(devAddressTwo.text!)!
            
            guard let address3Text = devAddressThree.text else{
                self.view.makeToast(message: "Address can't be empty")
                return
            }
            guard let address3 = Int(address3Text) else{
                self.view.makeToast(message: "Address can be only number")
                return
            }
            addressThree = address3
            
            guard let rangeFromText = fromTextField.text else{
                self.view.makeToast(message: "Range can't be empty")
                return
            }
            
            guard let rangeFrom = Int(rangeFromText) else{
                self.view.makeToast(message: "Range can be only number")
                return
            }
            let from = rangeFrom
            
            guard let rangeToText = toTextField.text else{
                self.view.makeToast(message: "Range can't be empty")
                return
            }
            
            guard let rangeTo = Int(rangeToText) else{
                self.view.makeToast(message: "Range can be only number")
                return
            }
            let to = rangeTo
            
            if rangeTo < rangeFrom {
                self.view.makeToast(message: "Range \"from\" can't be higher than range \"to\"")
                return
            }
            for i in from...to{
                arrayOfNamesToBeSearched.append(i)
            }
            shouldFindTimerParameters = true
        
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstTimerIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.present(progressBarScreenTimerNames!, animated: true, completion: nil)
                timerNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: firstTimerIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstTimerIndexThatDontHaveName)")
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningTimerNames)
                sendCommandForFindingNameWithTimerAddress(firstTimerIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    func checkIfTimerDidGetName (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated. 
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterNames += 1
        if timesRepeatedCounterNames < 3 {
            timerNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: timerIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetName \(timerIndex)")
            sendCommandForFindingNameWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: timerIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfTimerIndexInArrayOfNamesToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfTimerIndexInArrayOfNamesToBeSearched+1]
                    timesRepeatedCounterNames = 0
                    timerNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetName \(nextTimerIndexToBeSearched)")
                    sendCommandForFindingNameWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                }else{
                    dismissScaningControls()
                }
            }else{
                dismissScaningControls()
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    func nameReceivedFromPLC (_ notification:Notification) {
        refreshTimerList()
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningTimerNames) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let timerAddress  = info["timerAddress"] else{
                return
            }
            guard let timerId  = info["timerId"] else{
                return
            }
            let timerTemp = self.timers.filter({ (t) -> Bool in
                return (Int(t.address) == timerAddress && Int(t.timerId) == timerId)
            })
            
            if timerTemp.count > 0 {
                guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: Int(timerTemp.first!.timerId)) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                    return
                }
                
                if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                    
                    timesRepeatedCounterNames = 0
                    timerNameTimer?.invalidate()
                    timerNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                    sendCommandForFindingNameWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                }else{
                    dismissScaningControls()
                }
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithTimerAddress(_ timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingNames(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getTimerName(address, timerId: UInt8(timerId)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingNames (_ timerId:Int) {
        print("Progresbar for Names: \(timerId)")
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: timerId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            if let _ = progressBarScreenTimerNames?.lblHowMuchOf, let _ = progressBarScreenTimerNames?.lblPercentage, let _ = progressBarScreenTimerNames?.progressView{
                progressBarScreenTimerNames?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfNamesToBeSearched+1) / \(arrayOfNamesToBeSearched.count)"
                progressBarScreenTimerNames?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)*100) + " %"
                progressBarScreenTimerNames?.progressView.progress = Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)
            }
        }
    }
    
    // MARK: - Timer parameters
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findParametarsForTimer() {
        progressBarScreenTimerNames?.dissmissProgressBar()
        progressBarScreenTimerNames = nil
            arrayOfParametersToBeSearched = [Int]()
            indexOfParametersToBeSearched = 0
            
            refreshTimerList()
            
            guard let rangeFromText = fromTextField.text else{
                self.view.makeToast(message: "Range can't be empty")
                return
            }
            
            guard let rangeFrom = Int(rangeFromText) else{
                self.view.makeToast(message: "Range can be only number")
                return
            }
            let from = rangeFrom
            
            guard let rangeToText = toTextField.text else{
                self.view.makeToast(message: "Range can't be empty")
                return
            }
            
            guard let rangeTo = Int(rangeToText) else{
                self.view.makeToast(message: "Range can be only number")
                return
            }
            let to = rangeTo
            
            if rangeTo < rangeFrom {
                self.view.makeToast(message: "Range \"from\" can't be higher than range \"to\"")
                return
            }
            
            for i in from...to{
                for timerTemp in timers {
                    if timerTemp.timerId.intValue == i{
                        arrayOfParametersToBeSearched.append(i)
                    }
                }
            }
            
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningTimerParameters)
            
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfParametersToBeSearched.count != 0{
                let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                progressBarScreenTimerNames = nil
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding timer parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.present(progressBarScreenTimerNames!, animated: true, completion: nil)
                timerParameterTimer?.invalidate()
                timerParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                sendCommandForFindingParameterWithTimerAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from FindParameter")
            }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithTimerAddress for that specific timer id.
    func checkIfTimerDidGetParametar (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterParameters += 1
        if timesRepeatedCounterParameters < 3 {
            timerParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: timerIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetParameter \(timerIndex)")
            sendCommandForFindingParameterWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            print("Command sent for parameter from CheckIfTimerDidGetParameter (repeat \(timesRepeatedCounterParameters))")
        }else{
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: timerIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfTimerIndexInArrayOfParametersToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfTimerIndexInArrayOfParametersToBeSearched+1]
                    timesRepeatedCounterParameters = 0
                    timerParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetParameter \(nextTimerIndexToBeSearched)")
                    sendCommandForFindingParameterWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                    print("Command sent for parameter from checkIfTimerDidGetParametar: next parameter")
                }else{
                    shouldFindTimerParameters = false
                    dismissScaningControls()
                }
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    func timerParametarReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningTimerParameters) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let timerAddress  = info["timerAddress"] else{
                return
            }
            guard let timerId  = info["timerId"] else{
                return
            }
            let timerTemp = self.timers.filter({ (t) -> Bool in
                return (Int(t.address) == timerAddress && Int(t.timerId) == timerId)
            })
            
            if timerTemp.count > 0 {
                guard let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: Int(timerTemp.first!.timerId)) else{ // Array "indexOfDeviceIndexInArrayOfParametersToBeSearched" contains indexes of timers that don't have name
                    return
                }
                
                if indexOfDeviceIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                    timesRepeatedCounterParameters = 0
                    timerParameterTimer?.invalidate()
                    timerParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func parameterReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                    sendCommandForFindingParameterWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                    print("Command sent for parameter from timerParameterReceivedFromPLC: next parameter")
                }else{
                    shouldFindTimerParameters = false
                    dismissScaningControls()
                }
            }
            
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingParameterWithTimerAddress(_ timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingParameters(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getTimerParametar(address, id: UInt8(timerId)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingParameters (_ timerId:Int) {
        if let indexOfDeviceIndexInArrayOfPatametersToBeSearched = arrayOfParametersToBeSearched.index(of: timerId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            print("Progresbar for Parameters: \(indexOfDeviceIndexInArrayOfPatametersToBeSearched)")
            if let _ = progressBarScreenTimerNames?.lblHowMuchOf {
                if let _ = progressBarScreenTimerNames?.lblPercentage{
                    if let _ = progressBarScreenTimerNames?.progressView{
                            print("Progresbar for Parameters: \(indexOfDeviceIndexInArrayOfPatametersToBeSearched)")
                            progressBarScreenTimerNames?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1) / \(arrayOfParametersToBeSearched.count)"
                            progressBarScreenTimerNames?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1)/Float(arrayOfParametersToBeSearched.count)*100) + " %"
                            progressBarScreenTimerNames?.progressView.progress = Float(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1)/Float(arrayOfParametersToBeSearched.count)
                    }
                }
            }
        }
    }
    
    // Helpers
    func progressBarDidPressedExit() {
        shouldFindTimerParameters = false
        dismissScaningControls()
    }
    func dismissScaningControls() {
        timesRepeatedCounterNames = 0
        timesRepeatedCounterParameters = 0
        timerNameTimer?.invalidate()
        timerParameterTimer?.invalidate()
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningTimerNames)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningTimerParameters)
        progressBarScreenTimerNames!.dissmissProgressBar()

        arrayOfNamesToBeSearched = [Int]()
        indexOfNamesToBeSearched = 0
        arrayOfParametersToBeSearched = [Int]()
        indexOfParametersToBeSearched = 0
        if !shouldFindTimerParameters {
            UIApplication.shared.isIdleTimerDisabled = false
            refreshTimerList()
        } else {
            _ = Foundation.Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(ScanTimerViewController.findParametarsForTimer), userInfo: nil, repeats: false)
        }
    }
}

extension ScanTimerViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanTimerViewController: SceneGalleryDelegate{
    func backImage(_ image: Image, imageIndex: Int) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = image.imageId
            imageDataOne = nil
            self.imageTimerOne.image = UIImage(data: image.imageData! as Data)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = image.imageId
            imageDataTwo = nil
            self.imageTimerTwo.image = UIImage(data: image.imageData! as Data)
        }
    }
    func backString(_ strText: String, imageIndex:Int) {
        if imageIndex == 1 {
            defaultImageOne = strText
            customImageOne = nil
            imageDataOne = nil
            self.imageTimerOne.image = UIImage(named: strText)
        }
        if imageIndex == 2 {
            defaultImageTwo = strText
            customImageTwo = nil
            imageDataTwo = nil
            self.imageTimerTwo.image = UIImage(named: strText)
        }
    }
    func backImageFromGallery(_ data: Data, imageIndex:Int ) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = nil
            imageDataOne = data
            self.imageTimerOne.image = UIImage(data: data)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = nil
            imageDataTwo = data
            self.imageTimerTwo.image = UIImage(data: data)
        }
    }
}

extension ScanTimerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        IDedit.text = "\(timers[(indexPath as NSIndexPath).row].timerId)"
        nameEdit.text = "\(timers[(indexPath as NSIndexPath).row].timerName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(timers[(indexPath as NSIndexPath).row].address)))"
        
        if let type = TimerType(rawValue: Int(timers[(indexPath as NSIndexPath).row].type)){
            btnType.setTitle(type.description, for: UIControlState())
            timerTypeId = type.rawValue
        }else{
            btnType.setTitle("--", for: UIControlState())
            timerTypeId = nil
        }
        
        broadcastSwitch.isOn = timers[(indexPath as NSIndexPath).row].isBroadcast.boolValue
        localcastSwitch.isOn = timers[(indexPath as NSIndexPath).row].isLocalcast.boolValue
        
        if let levelId = timers[(indexPath as NSIndexPath).row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, for: UIControlState())
        }else{
            btnLevel.setTitle("All", for: UIControlState())
        }
        if let zoneId = timers[(indexPath as NSIndexPath).row].timeZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, for: UIControlState())
        }else{
            btnZone.setTitle("All", for: UIControlState())
        }
        if let categoryId = timers[(indexPath as NSIndexPath).row].timerCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, for: UIControlState())
        }else{
            btnCategory.setTitle("All", for: UIControlState())
        }
        
        defaultImageOne = timers[(indexPath as NSIndexPath).row].timerImageOneDefault
        customImageOne = timers[(indexPath as NSIndexPath).row].timerImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = timers[(indexPath as NSIndexPath).row].timerImageTwoDefault
        customImageTwo = timers[(indexPath as NSIndexPath).row].timerImageTwoCustom
        imageDataTwo = nil
        
        if let id = timers[(indexPath as NSIndexPath).row].timerImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTimerOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageOneDefault{
                        imageTimerOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageOneDefault{
                    imageTimerOne.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageOneDefault{
                imageTimerOne.image = UIImage(named: defaultImage)
            }
        }
        
        if let id = timers[(indexPath as NSIndexPath).row].timerImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTimerTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageTwoDefault{
                        imageTimerTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageTwoDefault{
                    imageTimerTwo.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageTwoDefault{
                imageTimerTwo.image = UIImage(named: defaultImage)
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            self.tableView(self.timerTableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        })
        
        button.backgroundColor = UIColor.red
        return [button]
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DatabaseTimersController.shared.deleteTimer(timers[(indexPath as NSIndexPath).row])
            timers.remove(at: (indexPath as NSIndexPath).row)
            timerTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "timersCell") as? TimersCell {
            cell.backgroundColor = UIColor.clear
            cell.labelID.text = "\(timers[(indexPath as NSIndexPath).row].timerId)"
            cell.labelName.text = timers[(indexPath as NSIndexPath).row].timerName
            cell.address.text = "\(returnThreeCharactersForByte(Int(timers[(indexPath as NSIndexPath).row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(timers[(indexPath as NSIndexPath).row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(timers[(indexPath as NSIndexPath).row].address)))"
            
            if let type = TimerType(rawValue: Int(timers[indexPath.row].type)){
                cell.timerTypeLabel.text = type.description
            }else{
                cell.timerTypeLabel.text = ""
            }
            
            if let id = timers[(indexPath as NSIndexPath).row].timerImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }
            }
            
            if let id = timers[(indexPath as NSIndexPath).row].timerImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = timers[(indexPath as NSIndexPath).row].timerImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
}


