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
    
    static let timerInfoWithStringKey: [String:Int] = ["Once":0, "Daily":1, "Monthly":2, "Yearly":3, "Hourly":4, "Minutely":5, "Timer":6, "Stopwatch/User":7]
    static let timerInfoWithIntKey: [Int:String] = [0:"Once", 1:"Daily", 2:"Monthly", 3:"Yearly", 4:"Hourly", 5:"Minutely", 6:"Timer", 7:"Stopwatch/User"]
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
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway!
    var timers:[Timer] = []
    
    var levelFromFilter:String = "All"
    var zoneFromFilter:String = "All"
    var categoryFromFilter:String = "All"
    
    var selected:AnyObject?
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    var imageDataOne:NSData?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:NSData?
    var customImageTwo:String?
    var defaultImageTwo:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateTimerList()
        
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
        
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanTimerViewController.nameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveTimerFromGateway, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanTimerViewController.timerParametarReceivedFromPLC(_:)), name: NotificationKey.DidReceiveTimerParameterFromGateway, object: nil)
    }
    
    override func sendFilterParametar(filterParametar: FilterItem) {
        levelFromFilter = filterParametar.levelName
        zoneFromFilter = filterParametar.zoneName
        categoryFromFilter = filterParametar.categoryName
        updateTimerList()
        timerTableView.reloadData()
    }
    override func sendSearchBarText(text: String) {
        updateTimerList()
        if !text.isEmpty{
            timers = self.timers.filter() {
                timer in
                if timer.timerName.lowercaseString.rangeOfString(text.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        timerTableView.reloadData()
        
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
        updateTimerList()
        timerTableView.reloadData()
    }
    func updateTimerList() {
        let fetchRequest = NSFetchRequest(entityName: "Timer")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if levelFromFilter != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelFromFilter)
            predicateArray.append(levelPredicate)
        }
        if zoneFromFilter != "All" {
            let zonePredicate = NSPredicate(format: "timeZone == %@", zoneFromFilter)
            predicateArray.append(zonePredicate)
        }
        if categoryFromFilter != "All" {
            let categoryPredicate = NSPredicate(format: "timerCategory == %@", categoryFromFilter)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
            timers = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func handleTap (gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let timerId = Int(IDedit.text!), let timerName = nameEdit.text, let address = Int(devAddressThree.text!), let type = btnType.titleLabel?.text {
            if timerId <= 32767 && address <= 255 && type != "--" {
                var itExists = false
                var existingTimer:Timer?
                for timer in timers {
                    if timer.timerId == timerId && timer.address == address {
                        itExists = true
                        existingTimer = timer
                    }
                }
                if !itExists {
                    let timer = NSEntityDescription.insertNewObjectForEntityForName("Timer", inManagedObjectContext: appDel.managedObjectContext!) as! Timer
                    timer.timerId = timerId
                    timer.timerName = timerName
                    timer.address = address
                    
                    if let customImageOne = customImageOne{
                        timer.timerImageOneCustom = customImageOne
                        timer.timerImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        timer.timerImageOneDefault = def
                        timer.timerImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            timer.timerImageOneCustom = image.imageId
                            timer.timerImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        timer.timerImageTwoCustom = customImageTwo
                        timer.timerImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        timer.timerImageTwoDefault = def
                        timer.timerImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            timer.timerImageTwoCustom = image.imageId
                            timer.timerImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    timer.entityLevelId = level?.id
                    timer.timeZoneId = zoneSelected?.id
                    timer.timerCategoryId = category?.id
                    
                    timer.isBroadcast = broadcastSwitch.on
                    timer.isLocalcast = localcastSwitch.on
                    timer.type = type
                    timer.id = NSUUID().UUIDString
                    timer.entityLevel = btnLevel.titleLabel!.text!
                    timer.timeZone = btnZone.titleLabel!.text!
                    timer.timerCategory = btnCategory.titleLabel!.text!
                    timer.gateway = gateway
                    CoreDataController.shahredInstance.saveChanges()
                    refreshTimerList()
                    
                } else {
                    existingTimer!.timerId = timerId
                    existingTimer!.timerName = timerName
                    existingTimer!.address = address
                    
                    if let customImageOne = customImageOne{
                        existingTimer!.timerImageOneCustom = customImageOne
                        existingTimer!.timerImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        existingTimer!.timerImageOneDefault = def
                        existingTimer!.timerImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingTimer!.timerImageOneCustom = image.imageId
                            existingTimer!.timerImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        existingTimer!.timerImageTwoCustom = customImageTwo
                        existingTimer!.timerImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        existingTimer!.timerImageTwoDefault = def
                        existingTimer!.timerImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingTimer!.timerImageTwoCustom = image.imageId
                            existingTimer!.timerImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    existingTimer!.entityLevelId = level?.id
                    existingTimer!.timeZoneId = zoneSelected?.id
                    existingTimer!.timerCategoryId = category?.id
                    
                    existingTimer!.isBroadcast = broadcastSwitch.on
                    existingTimer!.isLocalcast = localcastSwitch.on
                    existingTimer!.type = type
                    existingTimer!.entityLevel = btnLevel.titleLabel!.text!
                    existingTimer!.timeZone = btnZone.titleLabel!.text!
                    existingTimer!.timerCategory = btnCategory.titleLabel!.text!
                    existingTimer!.gateway = gateway
                    CoreDataController.shahredInstance.saveChanges()
                    refreshTimerList()
                    
                }
            }
        }
    }
    @IBAction func scanTimers(sender: AnyObject) {
        findNames()
    }
    @IBAction func clearRangeFields(sender: AnyObject) {
        
    }
    @IBAction func btnRemove(sender: AnyObject) {
        if timers.count != 0 {
            for timer in timers {
                appDel.managedObjectContext!.deleteObject(timer)
            }
            CoreDataController.shahredInstance.saveChanges()
            refreshTimerList()
            self.view.endEditing(true)
        }
    }
    @IBAction func btnLevel(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = FilterController.shared.getLevelsByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    @IBAction func btnCategory(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = FilterController.shared.getCategoriesByLocation(gateway.location)
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
            let list:[Zone] = FilterController.shared.getZoneByLevel(gateway.location, parentZone: level)
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
            popoverList.append(PopOverItem(name: item.description, id: ""))
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
//    var progressBarScreenTimerParameters: ProgressBarVC?
    var shouldFindTimerParameters = false
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findNames() {
        do {
            arrayOfNamesToBeSearched = [Int]()
            indexOfNamesToBeSearched = 0
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningTimerNames)
            
            if devAddressOne.text != nil && devAddressOne.text != ""{
                addressOne = Int(devAddressOne.text!)!
            }
            if devAddressTwo.text != nil && devAddressTwo.text != ""{
                addressTwo = Int(devAddressTwo.text!)!
            }
            if devAddressThree.text != nil && devAddressThree.text != ""{
                addressThree = Int(devAddressThree.text!)!
            }
            var from = 0
            var to = 250
            if fromTextField.text != nil && fromTextField.text != ""{
                from = Int(fromTextField.text!)!
            }
            if toTextField.text != nil && toTextField.text != ""{
                to = Int(toTextField.text!)!
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
                sendCommandForFindingNameWithTimerAddress(firstTimerIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
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
            
            let timers = DatabaseHandler.sharedInstance.fetchTimers()
            
            var from = 0
            var to = 250
            if fromTextField.text != nil && fromTextField.text != ""{
                from = Int(fromTextField.text!)!
            }
            if toTextField.text != nil && toTextField.text != ""{
                to = Int(toTextField.text!)!
            }
            
            for i in from...to{
                if i <= timers.count{
                        arrayOfParametersToBeSearched.append(i)
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
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
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
        selected = timers[indexPath.row]
        IDedit.text = "\(timers[indexPath.row].timerId)"
        nameEdit.text = "\(timers[indexPath.row].timerName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(timers[indexPath.row].address)))"
        btnType.setTitle("\(timers[indexPath.row].type)", forState: UIControlState.Normal)
        broadcastSwitch.on = timers[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = timers[indexPath.row].isLocalcast.boolValue
        
        if let levelId = timers[indexPath.row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
        }
        if let zoneId = timers[indexPath.row].timeZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
        }
        if let categoryId = timers[indexPath.row].timerCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
        }
        
        if let level = timers[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        }
        if let zone = timers[indexPath.row].timeZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        }
        if let category = timers[indexPath.row].timerCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        }
        
        if let id = timers[indexPath.row].timerImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTimerOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                        imageTimerOne.image = UIImage(named: defaultImage)
                    }else{
                        imageTimerOne.image = UIImage(named: "15 Timer - CLock - 00")
                    }
                }
            }else{
                if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                    imageTimerOne.image = UIImage(named: defaultImage)
                }else{
                    imageTimerOne.image = UIImage(named: "15 Timer - CLock - 00")
                }
            }
        }else{
            if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                imageTimerOne.image = UIImage(named: defaultImage)
            }else{
                imageTimerOne.image = UIImage(named: "15 Timer - CLock - 00")
            }
        }
        
        if let id = timers[indexPath.row].timerImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTimerTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                        imageTimerTwo.image = UIImage(named: defaultImage)
                    }else{
                        imageTimerTwo.image = UIImage(named: "15 Timer - CLock - 01")
                    }
                }
            }else{
                if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                    imageTimerTwo.image = UIImage(named: defaultImage)
                }else{
                    imageTimerTwo.image = UIImage(named: "15 Timer - CLock - 01")
                }
            }
        }else{
            if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                imageTimerTwo.image = UIImage(named: defaultImage)
            }else{
                imageTimerTwo.image = UIImage(named: "15 Timer - CLock - 01")
            }
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.timerTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(timers[indexPath.row])
            CoreDataController.shahredInstance.saveChanges()
            refreshTimerList()
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
                        }else{
                            cell.imageOne.image = UIImage(named: "15 Timer - CLock - 00")
                        }
                    }
                }else{
                    if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageOne.image = UIImage(named: "15 Timer - CLock - 00")
                    }
                }
            }else{
                if let defaultImage = timers[indexPath.row].timerImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }else{
                    cell.imageOne.image = UIImage(named: "15 Timer - CLock - 00")
                }
            }
            
            if let id = timers[indexPath.row].timerImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }else{
                            cell.imageTwo.image = UIImage(named: "15 Timer - CLock - 01")
                        }
                    }
                }else{
                    if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageTwo.image = UIImage(named: "15 Timer - CLock - 01")
                    }
                }
            }else{
                if let defaultImage = timers[indexPath.row].timerImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }else{
                    cell.imageTwo.image = UIImage(named: "15 Timer - CLock - 01")
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
