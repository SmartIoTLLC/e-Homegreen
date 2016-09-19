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
    case Once = 0, Daily, Monthly, Yearly, Hourly, Minutely , Timer , Stopwatch
    
    var description: String {
        switch self{
        case Once:
            return "Once"
        case Daily:
           return "Daily"
        case Monthly:
            return "Monthly"
        case Yearly:
            return "Yearly"
        case Hourly:
            return "Hourly"
        case Minutely:
            return "Minutely"
        case Timer:
            return "Timer"
        case Stopwatch:
            return "Stopwatch/User"
        }
    }

    static let allItem:[TimerType] = [Once, Daily, Monthly, Yearly, Hourly, Minutely, Timer, Stopwatch]
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
    
    var imageDataOne:NSData?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:NSData?
    var customImageTwo:String?
    var defaultImageTwo:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageTimerOne.userInteractionEnabled = true
        imageTimerOne.tag = 1
        imageTimerOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanTimerViewController.handleTap(_:))))
        imageTimerTwo.userInteractionEnabled = true
        imageTimerTwo.tag = 2
        imageTimerTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanTimerViewController.handleTap(_:))))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressOne.enabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        devAddressTwo.enabled = false
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: #selector(ScanTimerViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: #selector(ScanTimerViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        btnType.tag = 4
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        addObservers()
        refreshTimerList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    
    override func sendFilterParametar(filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshTimerList()
    }
    
    override func sendSearchBarText(text: String) {
        searchBarText = text
        refreshTimerList()
        
    }
    
    override func nameAndId(name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            btnZone.setTitle("All", forState: .Normal)
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
        
        button.setTitle(name, forState: .Normal)
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.on = false
        } else if sender.tag == 200 {
            broadcastSwitch.on = false
        }
    }
    func refreshTimerList() {
        timers = DatabaseTimersController.shared.updateTimerList(gateway, filterParametar: filterParametar)
        if !searchBarText.isEmpty{
            timers = self.timers.filter() {
                timer in
                if timer.timerName.lowercaseString.rangeOfString(searchBarText.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        timerTableView.reloadData()
    }
    
    func handleTap (gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
    }
    func addObservers(){
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanTimerViewController.nameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveTimerFromGateway, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanTimerViewController.timerParametarReceivedFromPLC(_:)), name: NotificationKey.DidReceiveTimerParameterFromGateway, object: nil)
        
    }
    func removeObservers(){
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningTimerNames)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningTimerParameters)
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveTimerFromGateway, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveTimerParameterFromGateway, object: nil)
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
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
                
                DatabaseTimersController.shared.addTimer(timerId, timerName: timerName, moduleAddress: address, gateway: gateway, type: timerTypeId, levelId: levelId, selectedZoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.on, isLocalcast: localcastSwitch.on, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo)
                
            }
            refreshTimerList()
            self.view.endEditing(true)
        }
    }
    @IBAction func scanTimers(sender: AnyObject) {
        findNames()
    }
    @IBAction func clearRangeFields(sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    @IBAction func btnRemove(sender: UIButton) {
        
//        let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to delete all scenes?", preferredStyle: .ActionSheet)
//        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            
//            if self.timers.count != 0 {
//                for timer in self.timers {
//                    self.appDel.managedObjectContext!.deleteObject(timer)
//                }
//            }
//            CoreDataController.shahredInstance.saveChanges()
//            self.refreshTimerList()
//            self.view.endEditing(true)
//        })
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
//            (alert: UIAlertAction!) -> Void in
//            print("Cancelled")
//        })
//        
//        if let popoverController = optionMenu.popoverPresentationController {
//            popoverController.sourceView = sender
//            popoverController.sourceRect = sender.bounds
//        }
//        
//        optionMenu.addAction(deleteAction)
//        optionMenu.addAction(cancelAction)
//        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    @IBAction func btnLevel(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnCategory(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnZone(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(gateway.location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnTimerType(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        for item in TimerType.allItem{
            popoverList.append(PopOverItem(name: item.description, id: "\(item.rawValue)"))
        }
        openPopover(sender, popOverList:popoverList)
    }

    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var timerNameTimer:NSTimer?
    var timerParameterTimer: NSTimer?
    var timesRepeatedCounterNames:Int = 0
    var timesRepeatedCounterParameters: Int = 0
    var arrayOfNamesToBeSearched = [Int]()
    var indexOfNamesToBeSearched = 0
    var arrayOfParametersToBeSearched = [Int]()
    var indexOfParametersToBeSearched = 0
    var alertController:UIAlertController?
    var progressBarScreenTimerNames: ProgressBarVC?
    var shouldFindTimerParameters = false
    
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findNames() {
        do {
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
        
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstTimerIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.presentViewController(progressBarScreenTimerNames!, animated: true, completion: nil)
                timerNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: firstTimerIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstTimerIndexThatDontHaveName)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningTimerNames)
                sendCommandForFindingNameWithTimerAddress(firstTimerIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        } catch let error as InputError {
            self.view.makeToast(message: error.description)
        } catch {
            self.view.makeToast(message: "Something went wrong.")
        }
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    func checkIfTimerDidGetName (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated. 
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterNames += 1
        if timesRepeatedCounterNames < 3 {
            timerNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: timerIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetName \(timerIndex)")
            sendCommandForFindingNameWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfTimerIndexInArrayOfNamesToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfTimerIndexInArrayOfNamesToBeSearched+1]
                    timesRepeatedCounterNames = 0
                    timerNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
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
    func nameReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningTimerNames) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["timerId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
        
            if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                
                timesRepeatedCounterNames = 0
                timerNameTimer?.invalidate()
                timerNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingNameWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithTimerAddress(timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingNames(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getTimerName(address, timerId: UInt8(timerId)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingNames (timerId:Int) {
        print("Progresbar for Names: \(timerId)")
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
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
        do {
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
                    if timerTemp.timerId.integerValue == i{
                        arrayOfParametersToBeSearched.append(i)
                    }
                }
            }
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningTimerParameters)
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfParametersToBeSearched.count != 0{
                let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                progressBarScreenTimerNames = nil
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding timer parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.presentViewController(progressBarScreenTimerNames!, animated: true, completion: nil)
                timerParameterTimer?.invalidate()
                timerParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                sendCommandForFindingParameterWithTimerAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from FindParameter")
            }
        } catch let error as InputError {
            self.view.makeToast(message: error.description)
        } catch {
            self.view.makeToast(message: "Something went wrong.")
        }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithTimerAddress for that specific timer id.
    func checkIfTimerDidGetParametar (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterParameters += 1
        if timesRepeatedCounterParameters < 3 {
            timerParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: timerIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetParameter \(timerIndex)")
            sendCommandForFindingParameterWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            print("Command sent for parameter from CheckIfTimerDidGetParameter (repeat \(timesRepeatedCounterParameters))")
        }else{
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(timerIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfTimerIndexInArrayOfParametersToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfTimerIndexInArrayOfParametersToBeSearched+1]
                    timesRepeatedCounterParameters = 0
                    timerParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
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
    func timerParametarReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningTimerParameters) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["timerId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                timerParameterTimer?.invalidate()
                timerParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func parameterReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingParameterWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from timerParameterReceivedFromPLC: next parameter")
            }else{
                shouldFindTimerParameters = false
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingParameterWithTimerAddress(timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingParameters(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getTimerParametar(address, id: UInt8(timerId)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingParameters (timerId:Int) {
        if let indexOfDeviceIndexInArrayOfPatametersToBeSearched = arrayOfParametersToBeSearched.indexOf(timerId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
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
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningTimerNames)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningTimerParameters)
        progressBarScreenTimerNames!.dissmissProgressBar()

        arrayOfNamesToBeSearched = [Int]()
        indexOfNamesToBeSearched = 0
        arrayOfParametersToBeSearched = [Int]()
        indexOfParametersToBeSearched = 0
        if !shouldFindTimerParameters {
            UIApplication.sharedApplication().idleTimerDisabled = false
            refreshTimerList()
        } else {
            _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(ScanTimerViewController.findParametarsForTimer), userInfo: nil, repeats: false)
        }
    }
    
}

extension ScanTimerViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanTimerViewController: SceneGalleryDelegate{
    
    func backImage(image: Image, imageIndex: Int) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = image.imageId
            imageDataOne = nil
            self.imageTimerOne.image = UIImage(data: image.imageData!)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = image.imageId
            imageDataTwo = nil
            self.imageTimerTwo.image = UIImage(data: image.imageData!)
        }
    }
    func backString(strText: String, imageIndex:Int) {
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
    func backImageFromGallery(data: NSData, imageIndex:Int ) {
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

extension ScanTimerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        IDedit.text = "\(timers[indexPath.row].timerId)"
        nameEdit.text = "\(timers[indexPath.row].timerName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(timers[indexPath.row].address)))"
        
        if let type = TimerType(rawValue: Int(timers[indexPath.row].type)){
            btnType.setTitle(type.description, forState: UIControlState.Normal)
        }else{
            btnType.setTitle("--", forState: UIControlState.Normal)
        }
        
        broadcastSwitch.on = timers[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = timers[indexPath.row].isLocalcast.boolValue
        
        if let levelId = timers[indexPath.row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        if let zoneId = timers[indexPath.row].timeZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, forState: UIControlState.Normal)
        }else{
            btnZone.setTitle("All", forState: UIControlState.Normal)
        }
        if let categoryId = timers[indexPath.row].timerCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, forState: UIControlState.Normal)
        }else{
            btnCategory.setTitle("All", forState: UIControlState.Normal)
        }
        
        if let id = timers[indexPath.row].timerImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTimerOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                        imageTimerOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                    imageTimerOne.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                imageTimerOne.image = UIImage(named: defaultImage)
            }
        }
        
        if let id = timers[indexPath.row].timerImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTimerTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                        imageTimerTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                    imageTimerTwo.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                imageTimerTwo.image = UIImage(named: defaultImage)
            }
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            self.tableView(self.timerTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
        })
        
        button.backgroundColor = UIColor.redColor()
        return [button]
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            DatabaseTimersController.shared.deleteTimer(timers[indexPath.row])
            timers.removeAtIndex(indexPath.row)
            timerTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("timerCell") as? TimerCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(timers[indexPath.row].timerId)"
            cell.labelName.text = timers[indexPath.row].timerName
            cell.address.text = "\(returnThreeCharactersForByte(Int(timers[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(timers[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(timers[indexPath.row].address)))"
            
            if let id = timers[indexPath.row].timerImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }
            }
            
            if let id = timers[indexPath.row].timerImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
}

class TimerCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
}
